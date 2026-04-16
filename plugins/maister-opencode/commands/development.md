---
name: development
description: Unified orchestrator for all development tasks. ALWAYS execute when invoked — never skip for 'straightforward' tasks. Phases adapt based on detected task characteristics rather than predetermined types. Use for any development work that modifies code.
generated-from-skill: true
---

<!-- AUTO-GENERATED from skills/development/SKILL.md - DO NOT EDIT MANUALLY -->

# Development Workflow

Unified orchestrator for all development tasks. ALWAYS execute when invoked — never skip for 'straightforward' tasks. Phases adapt based on detected task characteristics rather than predetermined types. Use for any development work that modifies code.

## Usage

```bash
/maister-development [task description]
```

## Workflow

**When this command is invoked:**

1. **Invoke the skill** via the Skill tool as your FIRST action:
   ```
   Use Skill tool:
     skill: "development"
     prompt: [user provided arguments and flags]
   ```

2. **Follow skill instructions**: The skill orchestrates the complete workflow including:
   - Task directory creation and state management
   - Phase execution with interactive gates
   - Subagent delegation for specialized work
   - Pause/resume capability

3. **All orchestration logic lives in the skill**: See `skills/development/SKILL.md` for:
   - Complete phase descriptions
   - Configuration flags and options
   - Resume instructions (`--from=PHASE`, `--reset-attempts`)
   - Examples and use cases

---

**Note**: This is a thin command wrapper. The skill file is the single source of truth for workflow logic.
