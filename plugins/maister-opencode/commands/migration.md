---
name: migration
description: Orchestrates the complete migration workflow from current state analysis through implementation to compatibility verification. Handles technology migrations, platform changes, and architecture pattern transitions with adaptive risk assessment, incremental execution, and rollback planning. Use when migrating technologies, platforms, or architecture patterns.
generated-from-skill: true
---

<!-- AUTO-GENERATED from skills/migration/SKILL.md - DO NOT EDIT MANUALLY -->

# Migration Workflow

Orchestrates the complete migration workflow from current state analysis through implementation to compatibility verification. Handles technology migrations, platform changes, and architecture pattern transitions with adaptive risk assessment, incremental execution, and rollback planning. Use when migrating technologies, platforms, or architecture patterns.

## Usage

```bash
/maister-migration [task description]
```

## Workflow

**When this command is invoked:**

1. **Invoke the skill** via the Skill tool as your FIRST action:
   ```
   Use Skill tool:
     skill: "migration"
     prompt: [user provided arguments and flags]
   ```

2. **Follow skill instructions**: The skill orchestrates the complete workflow including:
   - Task directory creation and state management
   - Phase execution with interactive gates
   - Subagent delegation for specialized work
   - Pause/resume capability

3. **All orchestration logic lives in the skill**: See `skills/migration/SKILL.md` for:
   - Complete phase descriptions
   - Configuration flags and options
   - Resume instructions (`--from=PHASE`, `--reset-attempts`)
   - Examples and use cases

---

**Note**: This is a thin command wrapper. The skill file is the single source of truth for workflow logic.
