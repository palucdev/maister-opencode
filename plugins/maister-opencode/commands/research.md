---
name: research
description: Orchestrates comprehensive research workflows from question definition through findings documentation. Handles technical, requirements, literature, and mixed research types with adaptive methodology, multi-source gathering, pattern synthesis, and evidence-based reporting. Supports standalone research tasks and embedded research phase in other workflows.
generated-from-skill: true
---

<!-- AUTO-GENERATED from skills/research/SKILL.md - DO NOT EDIT MANUALLY -->

# Research Workflow

Orchestrates comprehensive research workflows from question definition through findings documentation. Handles technical, requirements, literature, and mixed research types with adaptive methodology, multi-source gathering, pattern synthesis, and evidence-based reporting. Supports standalone research tasks and embedded research phase in other workflows.

## Usage

```bash
/maister-research [task description]
```

## Workflow

**When this command is invoked:**

1. **Invoke the skill** via the Skill tool as your FIRST action:
   ```
   Use Skill tool:
     skill: "research"
     prompt: [user provided arguments and flags]
   ```

2. **Follow skill instructions**: The skill orchestrates the complete workflow including:
   - Task directory creation and state management
   - Phase execution with interactive gates
   - Subagent delegation for specialized work
   - Pause/resume capability

3. **All orchestration logic lives in the skill**: See `skills/research/SKILL.md` for:
   - Complete phase descriptions
   - Configuration flags and options
   - Resume instructions (`--from=PHASE`, `--reset-attempts`)
   - Examples and use cases

---

**Note**: This is a thin command wrapper. The skill file is the single source of truth for workflow logic.
