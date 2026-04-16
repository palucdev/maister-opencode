#!/bin/bash
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CORE="$ROOT/plugins/maister"
OUT="$ROOT/plugins/maister-opencode"

# Cross-platform sed in-place (macOS needs '' arg, Linux doesn't)
sedi() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

# 1. Copy source, wipe old output first
rm -rf "$OUT"
cp -r "$CORE" "$OUT"

# 2. Remove Claude Code-only directories
rm -rf "$OUT/hooks"
rm -rf "$OUT/.claude-plugin"

# 3. Strip plugin prefix from command names: "maister:foo" → "foo"
#    OpenCode namespaces commands automatically from the package name
find "$OUT/commands" -name "*.md" | while IFS= read -r f; do
  sedi 's/^name: maister:/name: /' "$f"
done

# 4. Strip plugin prefix from skill names: "maister:foo" → "foo"
#    OpenCode skill names must be lowercase alphanumeric with hyphens only
find "$OUT/skills" -name "*.md" | while IFS= read -r f; do
  sedi 's/^name: maister:/name: /' "$f"
done

# 4b. Rename init skill to maister-init (avoids overriding OpenCode's built-in /init)
#     Handle both LF and CRLF line endings (source files may have CRLF)
sedi 's/^name: init\r\{0,1\}$/name: maister-init/' "$OUT/skills/init/SKILL.md"
mv "$OUT/skills/init" "$OUT/skills/maister-init"

# 5. Replace maister: prefix with maister- for cross-references in content
#    Run AFTER name: transforms so frontmatter name lines are already clean
find "$OUT" -name "*.md" | while IFS= read -r f; do
  sedi 's/maister:/maister-/g' "$f"
done

# 6. Replace CLAUDE.md references with AGENTS.md (OpenCode's native rules file)
find "$OUT" -name "*.md" | while IFS= read -r f; do
  sedi 's/CLAUDE\.md/AGENTS.md/g' "$f"
done

# 7. Replace AskUserQuestion with question (OpenCode's question tool)
find "$OUT" -name "*.md" | while read f; do
  sedi 's/AskUserQuestion/question/g' "$f"
done

# 7.5. Auto-generate commands for user-invocable skills
echo "Generating commands for user-invocable skills..."

for skill_dir in "$OUT/skills"/*; do
  if [ ! -d "$skill_dir" ]; then
    continue
  fi
  
  skill_md="$skill_dir/SKILL.md"
  if [ ! -f "$skill_md" ]; then
    continue
  fi
  
  # Check if user-invocable: true (using grep for CRLF compatibility)
  if grep -q "^user-invocable:[[:space:]]*true" "$skill_md"; then
    skill_name=$(basename "$skill_dir")
    echo "  Generating command for skill: $skill_name"
    
    # Extract metadata from frontmatter using sed (handles CRLF)
    name=$(sed -n 's/^name:[[:space:]]*//p' "$skill_md" | tr -d '\r' | head -1)
    
    # Extract description (may span multiple lines)
    description=$(sed -n '/^description:/,/^[a-z-]*:/{/^description:/s/^description:[[:space:]]*//p;/^[a-z-]*:/!p}' "$skill_md" | tr -d '\r' | head -1)
    
    # Extract argument hint
    argument_hint=$(sed -n 's/^argument-hint:[[:space:]]*//p' "$skill_md" | tr -d '\r' | head -1)
    
    # Default argument hint if not provided
    if [ -z "$argument_hint" ]; then
      argument_hint="[task description]"
    fi
    
    # Capitalize first letter for title
    title=$(echo "$skill_name" | awk '{ for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2)) }1' | sed 's/-/ /g')
    
    # Generate command file
    cat > "$OUT/commands/${skill_name}.md" <<EOF
---
name: ${skill_name}
description: ${description}
generated-from-skill: true
---

<!-- AUTO-GENERATED from skills/${skill_name}/SKILL.md - DO NOT EDIT MANUALLY -->

# ${title} Workflow

${description}

## Usage

\`\`\`bash
/maister-${skill_name} ${argument_hint}
\`\`\`

## Workflow

**When this command is invoked:**

1. **Invoke the skill** via the Skill tool as your FIRST action:
   \`\`\`
   Use Skill tool:
     skill: "${skill_name}"
     prompt: [user provided arguments and flags]
   \`\`\`

2. **Follow skill instructions**: The skill orchestrates the complete workflow including:
   - Task directory creation and state management
   - Phase execution with interactive gates
   - Subagent delegation for specialized work
   - Pause/resume capability

3. **All orchestration logic lives in the skill**: See \`skills/${skill_name}/SKILL.md\` for:
   - Complete phase descriptions
   - Configuration flags and options
   - Resume instructions (\`--from=PHASE\`, \`--reset-attempts\`)
   - Examples and use cases

---

**Note**: This is a thin command wrapper. The skill file is the single source of truth for workflow logic.
EOF
  fi
done

echo "Generated commands for user-invocable skills"

# 8. Rename CLAUDE.md → AGENTS.md and append platform note
mv "$OUT/CLAUDE.md" "$OUT/AGENTS.md"

cat >> "$OUT/AGENTS.md" << 'EOF'

## Platform: OpenCode

This is the OpenCode variant of maister. Key differences from Claude Code:
- **Project instructions file**: `AGENTS.md` (this file).
- **Skill invocation rule**: When any `/maister-*` command is used, you MUST
  invoke it via the `skill` tool as your FIRST action. No exceptions. Do not
  analyze the task first, do not decide it's "straightforward", do not substitute
  your own approach. The user chose this workflow intentionally.
- **User questions**: Use OpenCode's native `question` tool for interactive prompts.
- **Subagents**: Use the `task` tool to invoke subagents.
- **Compaction**: After context compaction, re-read `orchestrator-state.yml` in
  the active task directory to verify `completed_phases` and determine the next
  phase. Use the `question` tool at Phase Gates.
- **MCP**: The Playwright MCP server is declared in `opencode.json`.
EOF

# 9. Write JS hooks plugin
mkdir -p "$OUT/.opencode/plugins"
cp "$SCRIPT_DIR/hooks-template.js" "$OUT/.opencode/plugins/hooks.js"

# 10. Extract version from source plugin.json and write ROOT-LEVEL package.json
#     This enables: "plugin": ["maister-opencode@git+https://github.com/palucdev/maister-opencode.git"]
#     Bun resolves the git URL to the repo root, finds package.json, and loads the main entry point.
VERSION=$(awk -F'"' '/"version"[[:space:]]*:/ { print $4; exit }' "$CORE/.claude-plugin/plugin.json")

if [ -z "$VERSION" ]; then
  echo "Error: Could not extract version from $CORE/.claude-plugin/plugin.json" >&2
  exit 1
fi

cat > "$ROOT/package.json" << EOF
{
  "name": "maister-opencode",
  "version": "$VERSION",
  "type": "module",
  "main": "plugins/maister-opencode/.opencode/plugins/hooks.js"
}
EOF

# 11. Write opencode.json declaring Playwright MCP server
cat > "$OUT/opencode.json" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "playwright": {
      "type": "local",
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
EOF

echo "Built OpenCode variant at $OUT"
