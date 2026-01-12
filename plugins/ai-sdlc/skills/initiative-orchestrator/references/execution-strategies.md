# Execution Strategies Reference

## Overview

Initiative orchestrator uses **sequential execution** for coordinating multiple tasks. Each task orchestrator runs one at a time because task orchestrators need the main agent to delegate phases to subagents.

## Sequential Execution

### Description

Execute tasks one at a time in dependency order. Tasks are queued based on dependency levels - Level 0 tasks first, then Level 1, etc.

### Why Sequential Only

**Architecture Constraint**: Each task orchestrator (feature-orchestrator, enhancement-orchestrator, etc.) needs the main agent to delegate work to specialized subagents. This requires synchronous, one-at-a-time execution.

Parallel execution would require:
- Multiple independent agent sessions (not currently supported)
- Complex coordination between parallel skill executions
- Race condition handling for shared resources

Sequential execution provides:
- Simpler coordination
- Clear progress tracking
- No race conditions
- Reliable state management

### Execution Pattern

```
Initialize:
  Queue = All tasks sorted by dependency order (topological sort)
  - Level 0 tasks first (no dependencies)
  - Level 1 tasks next (depend on Level 0)
  - And so on...

Loop:
  1. Pop next task from queue
  2. Verify dependencies satisfied
  3. Use Skill tool to invoke task orchestrator (synchronous)
  4. Wait for orchestrator to complete all phases
  5. Record result in initiative-state.yml
  6. Check for newly unblocked tasks
  7. Add unblocked tasks to end of queue
  8. Repeat until queue empty
```

### Task Orchestrator Invocation

**Use the Skill tool** to invoke the appropriate orchestrator:

```markdown
Use Skill tool:
  skill: [task-type]-orchestrator

The skill loads and executes all phases for the task.

Task Type Mapping:
  - new-feature → feature-orchestrator
  - enhancement → enhancement-orchestrator
  - migration → migration-orchestrator
  - bug-fix → bug-fix-orchestrator
  - refactoring → refactoring-orchestrator
  - performance → performance-orchestrator
  - security → security-orchestrator
  - documentation → documentation-orchestrator
```

Provide context to the orchestrator:
```
Task path: [task-path]
Task type: [type from orchestrator-state.yml task section]

Initiative context:
- Part of initiative: [initiative-name]
- Initiative ID: [initiative-id]
- Execution mode: [--yolo if initiative in yolo mode]
```

### Example Flow

```
Tasks with dependencies:
  A (Level 0) - no dependencies
  B (Level 0) - no dependencies
  C (Level 1) - depends on A
  D (Level 1) - depends on B
  E (Level 2) - depends on C and D

Queue: [A, B, C, D, E]

Time 0:
  Execute: A (using Skill tool with feature-orchestrator)
  Queue: [B, C, D, E]

Time T1 (A complete):
  Execute: B (using Skill tool with enhancement-orchestrator)
  Queue: [C, D, E]

Time T2 (B complete):
  C is now ready (A complete)
  D is now ready (B complete)
  Execute: C
  Queue: [D, E]

Time T3 (C complete):
  Execute: D
  Queue: [E]

Time T4 (D complete):
  E is now ready (C and D complete)
  Execute: E
  Queue: []

Time T5 (E complete):
  Done
```

### State Tracking

```yaml
execution:
  queue: [task-C, task-D, task-E]
  current_task: task-B

tasks:
  pending: [task-C, task-D, task-E]
  in_progress: [task-B]
  completed: [task-A]
  blocked: []
```

### Advantages

✅ Simple to implement and debug
✅ No coordination complexity
✅ No race conditions
✅ Clear progress tracking
✅ Works for any dependency graph
✅ Reliable subagent delegation

### Performance

```
Total Time = Sum of all task durations
Example: 5 tasks × 40 hours each = 200 hours
```

---

## Failure Handling

```
On task failure:
  1. Record failure in initiative-state.yml
  2. Identify dependent tasks (from task's `blocks` field)
  3. Mark dependent tasks as blocked
  4. Prompt user with options:
     - Skip task and continue (dependents remain blocked)
     - Retry task (attempt again)
     - Abort initiative

If user chooses to skip:
  - Move task to failed list
  - Continue with next non-blocked task in queue

If user chooses retry:
  - Re-invoke the task orchestrator
  - Continue from where it left off
```

---

## Dependency Levels

### Purpose

Dependency levels organize tasks for execution order:
- **Level 0**: Tasks with no dependencies (start here)
- **Level 1**: Tasks depending only on Level 0 tasks
- **Level N**: Tasks depending on tasks in Level 0 through N-1

### Computation

```
1. Build dependency graph from initiative.yml
2. BFS traversal from tasks with no dependencies
3. Assign level = max(dependency levels) + 1
4. Tasks at same level can be executed in any order
5. Create queue sorted by level, then by priority/alphabetical
```

### Example

```
Dependencies:
  A → C
  B → C
  C → E
  D → E

Levels:
  Level 0: [A, B, D]  (no dependencies)
  Level 1: [C]        (depends on A, B which are Level 0)
  Level 2: [E]        (depends on C which is Level 1, and D which is Level 0)

Execution Queue: [A, B, D, C, E]
```

---

## Progress Tracking

### Metrics

```yaml
progress:
  total_tasks: 10
  completed: 3
  in_progress: 1
  blocked: 2
  failed: 0
  pending: 4
  percent: 30

  queue_position: 4/10
  current_task: task-D
```

### Visualization

```
[===>      ] 30% (Task 4/10: task-D)

Completed: A, B, C
Current:   D (in progress)
Pending:   E, F, G, H
Blocked:   I, J (waiting for F)
```

---

## Summary

- **Execution**: Sequential, one task at a time
- **Tool**: Use `Skill` tool to invoke task orchestrators
- **Order**: Based on dependency levels (topological sort)
- **State**: Track queue position and task status
- **Failures**: Pause and prompt user for resolution

For dependency algorithms, see `dependency-resolution.md`.
For state management, see `state-coordination.md`.
