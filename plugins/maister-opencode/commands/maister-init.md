---
name: maister-init
description: Initialize AI SDLC framework with intelligent project analysis and documentation generation
generated-from-skill: true
---

<!-- AUTO-GENERATED from skills/maister-init/SKILL.md - DO NOT EDIT MANUALLY -->

# Maister init Workflow

Initialize AI SDLC framework with intelligent project analysis and documentation generation

## Usage

```bash
/maister-maister-init [--standards-from=PATH]
```

## Workflow

**When this command is invoked:**

1. **Invoke the skill** via the Skill tool as your FIRST action:
   ```
   Use Skill tool:
     skill: "maister-init"
     prompt: [user provided arguments and flags]
   ```

2. **Follow skill instructions**: The skill orchestrates the complete workflow including:
   - Task directory creation and state management
   - Phase execution with interactive gates
   - Subagent delegation for specialized work
   - Pause/resume capability

3. **All orchestration logic lives in the skill**: See `skills/maister-init/SKILL.md` for:
   - Complete phase descriptions
   - Configuration flags and options
   - Resume instructions (`--from=PHASE`, `--reset-attempts`)
   - Examples and use cases

---

**Note**: This is a thin command wrapper. The skill file is the single source of truth for workflow logic.
