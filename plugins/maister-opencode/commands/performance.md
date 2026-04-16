---
name: performance
description: Orchestrates performance optimization workflows using static code analysis to identify bottlenecks (N+1 queries, missing indexes, O(n^2) algorithms, blocking I/O, memory leaks). Accepts optional user-provided profiling data. Reuses standard specification, planning, implementation, and verification phases.
generated-from-skill: true
---

<!-- AUTO-GENERATED from skills/performance/SKILL.md - DO NOT EDIT MANUALLY -->

# Performance Workflow

Orchestrates performance optimization workflows using static code analysis to identify bottlenecks (N+1 queries, missing indexes, O(n^2) algorithms, blocking I/O, memory leaks). Accepts optional user-provided profiling data. Reuses standard specification, planning, implementation, and verification phases.

## Usage

```bash
/maister-performance [task description]
```

## Workflow

**When this command is invoked:**

1. **Invoke the skill** via the Skill tool as your FIRST action:
   ```
   Use Skill tool:
     skill: "performance"
     prompt: [user provided arguments and flags]
   ```

2. **Follow skill instructions**: The skill orchestrates the complete workflow including:
   - Task directory creation and state management
   - Phase execution with interactive gates
   - Subagent delegation for specialized work
   - Pause/resume capability

3. **All orchestration logic lives in the skill**: See `skills/performance/SKILL.md` for:
   - Complete phase descriptions
   - Configuration flags and options
   - Resume instructions (`--from=PHASE`, `--reset-attempts`)
   - Examples and use cases

---

**Note**: This is a thin command wrapper. The skill file is the single source of truth for workflow logic.
