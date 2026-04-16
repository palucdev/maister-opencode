---
name: product-design
description: Interactive product/feature design orchestrator. Transforms fuzzy ideas into structured product briefs through collaborative exploration, iterative refinement, and visual prototyping. Adaptive phases detect design complexity and adjust depth.
generated-from-skill: true
---

<!-- AUTO-GENERATED from skills/product-design/SKILL.md - DO NOT EDIT MANUALLY -->

# Product design Workflow

Interactive product/feature design orchestrator. Transforms fuzzy ideas into structured product briefs through collaborative exploration, iterative refinement, and visual prototyping. Adaptive phases detect design complexity and adjust depth.

## Usage

```bash
/maister-product-design [task description]
```

## Workflow

**When this command is invoked:**

1. **Invoke the skill** via the Skill tool as your FIRST action:
   ```
   Use Skill tool:
     skill: "product-design"
     prompt: [user provided arguments and flags]
   ```

2. **Follow skill instructions**: The skill orchestrates the complete workflow including:
   - Task directory creation and state management
   - Phase execution with interactive gates
   - Subagent delegation for specialized work
   - Pause/resume capability

3. **All orchestration logic lives in the skill**: See `skills/product-design/SKILL.md` for:
   - Complete phase descriptions
   - Configuration flags and options
   - Resume instructions (`--from=PHASE`, `--reset-attempts`)
   - Examples and use cases

---

**Note**: This is a thin command wrapper. The skill file is the single source of truth for workflow logic.
