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
rm -f "$OUT/.mcp.json"

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

# 4b. Rename init skill to flow-init (avoids overriding OpenCode's built-in /init,
#     and uses a clean name without the maister- prefix)
#     Handle both LF and CRLF line endings (source files may have CRLF)
sedi 's/^name: init\r\{0,1\}$/name: flow-init/' "$OUT/skills/init/SKILL.md"
mv "$OUT/skills/init" "$OUT/skills/flow-init"

# 4c. Add user-invocable: true to flow-init skill
echo "Adding user-invocable: true to flow-init skill..."
awk '
  BEGIN { 
    frontmatter_count = 0
  }
  /^---/ {
    frontmatter_count++
    if (frontmatter_count == 2) {
      # Closing frontmatter delimiter - insert user-invocable before it
      print "user-invocable: true"
    }
    print
    next
  }
  { print }
' "$OUT/skills/flow-init/SKILL.md" > "$OUT/skills/flow-init/SKILL.md.tmp" && mv "$OUT/skills/flow-init/SKILL.md.tmp" "$OUT/skills/flow-init/SKILL.md"
echo "Added user-invocable: true to flow-init skill"

# 4d. Replace maister:init references with flow-init in content
#     Run BEFORE step 5 so step 5's maister: strip doesn't turn it into bare 'init'
find "$OUT" -name "*.md" | while IFS= read -r f; do
  sedi 's/maister:init/flow-init/g' "$f"
done

# 4e. Update path references from skills/init/ to skills/flow-init/
find "$OUT" -name "*.md" | while IFS= read -r f; do
  sedi 's|skills/init/SKILL\.md|skills/flow-init/SKILL.md|g' "$f"
done

# 5. Strip maister: prefix from cross-references in content (produces bare names matching actual agent names)
#    Run AFTER name: transforms (step 3/4) and maister:init → flow-init (step 4d)
#    so frontmatter is already clean and flow-init is already substituted
find "$OUT" -name "*.md" | while IFS= read -r f; do
  sedi 's/maister://g' "$f"
done

# 6. Replace CLAUDE.md references with AGENTS.md (OpenCode's native rules file)
find "$OUT" -name "*.md" | while IFS= read -r f; do
  sedi 's/CLAUDE\.md/AGENTS.md/g' "$f"
done

# 7. Replace AskUserQuestion with question (OpenCode's question tool)
find "$OUT" -name "*.md" | while read f; do
  sedi 's/AskUserQuestion/question/g' "$f"
done

# 7.5. Add model: inherit to agents without model property (for OpenCode)
if [ -d "$OUT/agents" ]; then
  echo "Adding model: inherit to agents without model property..."
  find "$OUT/agents" -name "*.md" | while IFS= read -r f; do
    # Use awk to add model: inherit at end of frontmatter if not present
    awk '
      BEGIN { 
        in_frontmatter = 0
        has_model = 0
        frontmatter_count = 0
      }
      /^---/ {
        frontmatter_count++
        if (frontmatter_count == 1) {
          # Opening frontmatter delimiter
          in_frontmatter = 1
          print
          next
        } else if (frontmatter_count == 2) {
          # Closing frontmatter delimiter - insert model: inherit if needed
          if (!has_model) {
            print "model: inherit"
          }
          print
          in_frontmatter = 0
          next
        }
      }
      in_frontmatter && /^model:/ {
        has_model = 1
      }
      { print }
    ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  done
  echo "Added model: inherit to agents"
fi

# 7.6. Add mode: subagent and hidden: true to agent frontmatter (for OpenCode)
if [ -d "$OUT/agents" ]; then
  echo "Adding subagent metadata to agents..."
  find "$OUT/agents" -name "*.md" | while IFS= read -r f; do
    # Use awk to add mode and hidden properties at end of frontmatter
    # Guards prevent duplicate injection if source agent already has mode: or hidden:
    awk '
      BEGIN { 
        frontmatter_count = 0
        has_mode = 0
        has_hidden = 0
      }
      /^---/ {
        frontmatter_count++
        if (frontmatter_count == 2) {
          # Closing frontmatter delimiter - insert mode and hidden before it if not present
          if (!has_mode) {
            print "mode: subagent"
          }
          if (!has_hidden) {
            print "hidden: true"
          }
        }
        print
        next
      }
      frontmatter_count == 1 && /^mode:/ {
        has_mode = 1
      }
      frontmatter_count == 1 && /^hidden:/ {
        has_hidden = 1
      }
      { print }
    ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  done
  echo "Added subagent metadata to agent files"
fi

# 7.7. Auto-generate commands for user-invocable skills
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
    
    # Generate command file
    cat > "$OUT/commands/${skill_name}.md" <<EOF
---
name: ${skill_name}
description: ${description}
argument-hint: ${argument_hint}
generated-from-skill: true
---

<!-- AUTO-GENERATED from skills/${skill_name}/SKILL.md - DO NOT EDIT MANUALLY -->

CRITICAL INSTRUCTION: You MUST invoke the ${skill_name} skill immediately as your FIRST action.

Use the Skill tool with these exact parameters:
  name: "${skill_name}"
  prompt: "\$ARGUMENTS"

DO NOT:
- Analyze the task before invoking the skill
- Decide the task is "straightforward" and skip the skill
- Substitute your own approach or workflow
- Execute any part of the workflow yourself

WHY: The user explicitly chose this workflow by using /${skill_name}. 
Invoke the skill now and let it orchestrate the complete workflow.

---

## About This Workflow

${description}

The skill handles:
- Task directory creation and state management
- Phase execution with interactive gates
- Subagent delegation for specialized work
- Pause/resume capability

See \`skills/${skill_name}/SKILL.md\` for complete workflow documentation.
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
- **Skill invocation rule**: When a skill command is invoked (e.g., `/development`, `/flow-init`), you MUST
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
