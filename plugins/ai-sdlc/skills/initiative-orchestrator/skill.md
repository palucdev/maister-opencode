---
name: initiative-orchestrator
description: Orchestrates epic-level initiatives from planning through verification, managing multiple related tasks with dependency coordination and sequential execution. Designed for multi-week projects requiring coordination of 3-15 tasks across different types (new-features, enhancements, migrations, etc.).
---

# Initiative Orchestrator

Epic-level coordination of 3-15 related tasks with dependency management and sequential execution.

## Initialization

**BEFORE executing any phase, you MUST complete these steps:**

### Step 1: Load Framework Patterns

**Read ALL framework reference files NOW using the Read tool:**

1. `../orchestrator-framework/references/phase-execution-pattern.md`
2. `../orchestrator-framework/references/interactive-mode.md`
3. `../orchestrator-framework/references/delegation-enforcement.md`
4. `../orchestrator-framework/references/state-management.md`
5. `../orchestrator-framework/references/initialization-pattern.md`
6. `../orchestrator-framework/references/issue-resolution-pattern.md`

### Step 2: Initialize Workflow

1. **Create Task Items**: Use `TaskCreate` for all phases (see Phase Configuration), then set dependencies with `TaskUpdate addBlockedBy`
2. **Create Initiative Directory**: `.ai-sdlc/docs/project/initiatives/YYYY-MM-DD-name/`
3. **Initialize State**: Create `initiative-state.yml` with mode and tracking info

**Output**:
```
🚀 Initiative Orchestrator Started

Initiative: [description]
Mode: [Interactive/YOLO]
Directory: [initiative-path]

Starting Phase 0: Plan initiative tasks...
```

---

## When to Use

Use for:
- Epic-level work spanning multiple features (multi-week initiatives)
- Coordinated delivery with related tasks that must work together
- Complex dependencies with technical or logical ordering requirements
- Milestone-based delivery with clear checkpoints

**DO NOT use for**: Single standalone tasks, quick fixes, exploratory work without clear scope.

---

## Core Principles

1. **Dependency-First**: Enforce task execution order based on dependencies
2. **Sequential Execution**: One task at a time to maintain focus and quality
3. **Initiative Context**: Each task knows it's part of a larger initiative
4. **Milestone Tracking**: Group tasks into meaningful delivery checkpoints
5. **Full Resume**: Complete pause/resume capability at any point

---

## Phase Configuration

| Phase | content | activeForm | Agent/Skill |
|-------|---------|------------|-------------|
| 0 | "Plan initiative tasks" | "Planning initiative tasks" | initiative-planner |
| 1 | "Create task directories" | "Creating task directories" | Direct |
| 2 | "Resolve dependencies" | "Resolving dependencies" | Direct |
| 3 | "Execute tasks" | "Executing tasks" | Task orchestrators |
| 4 | "Verify initiative" | "Verifying initiative" | Direct |
| 5 | "Finalize initiative" | "Finalizing initiative" | Direct |

---

## Workflow Phases

### Phase 0: Initiative Planning

**Purpose**: Break down epic into concrete tasks with dependency relationships
**Execute**: Task tool - `ai-sdlc:initiative-planner` subagent
**Output**: `initiative.yml`, `spec.md`, `task-plan.md`
**State**: Update task list, dependencies, milestones

**Validation**:
- initiative.yml exists with 3-15 tasks
- No circular dependencies
- All task IDs unique and references valid

→ Pause

**Interactive**: AskUserQuestion - "Initiative plan complete. Continue to task creation?"
**YOLO**: "→ Continuing to Phase 1..."

---

### Phase 1: Task Creation

**Purpose**: Create task directories and initialize state files
**Execute**: Direct - create directories, initialize state files
**Output**: Task directories with `orchestrator-state.yml` files
**State**: Update initiative-state.yml with all task tracking

**Process**:
1. Read initiative.yml, extract task list
2. Create task directories in `.ai-sdlc/tasks/[type]/YYYY-MM-DD-task-name/`
3. Initialize task `orchestrator-state.yml` with initiative fields:
   ```yaml
   task:
     initiative_id: YYYY-MM-DD-initiative-name
     dependencies: [array of task paths]
     blocks: [array of task paths that depend on this]
     milestone: Milestone Name
   ```
4. Create placeholder spec.md in each task directory

→ Pause

**Interactive**: AskUserQuestion - "Task directories created. Continue to dependency resolution?"
**YOLO**: "→ Continuing to Phase 2..."

---

### Phase 2: Dependency Resolution

**Purpose**: Build and validate dependency graph, compute execution order
**Execute**: Direct - build graph, detect cycles, compute levels
**Output**: Validated dependency graph, execution queue, critical path
**State**: Update execution levels and critical path in initiative-state.yml

**Process**:
1. Build dependency graph from initiative.yml
2. Validate: cycle detection, reference validation, completeness
3. Compute dependency levels (BFS from tasks with no dependencies)
4. Build execution queue ordered by levels
5. Identify critical path (longest path through graph)

→ Pause

**Interactive**: AskUserQuestion - "Dependencies resolved. Continue to task execution?"
**YOLO**: "→ Continuing to Phase 3..."

---

### Phase 3: Task Execution

**Purpose**: Execute tasks sequentially using appropriate orchestrators
**Execute**: Skill tool - invoke orchestrator for each task
**Output**: Completed task artifacts in each task directory
**State**: Update task status in initiative-state.yml

**Task Type to Orchestrator Mapping**:

| Task Type | Orchestrator Skill |
|-----------|-------------------|
| new-feature, enhancement, bug-fix | ai-sdlc:development-orchestrator |
| migration | ai-sdlc:migration-orchestrator |
| refactoring | ai-sdlc:refactoring-orchestrator |
| performance | ai-sdlc:performance-orchestrator |
| security | ai-sdlc:security-orchestrator |
| documentation | ai-sdlc:documentation-orchestrator |

**Execution Loop** (ONE TASK AT A TIME):
1. Select next task from queue (respecting dependency order)
2. Output: `📤 Executing task [N]/[total]: [task name]`
3. Invoke appropriate orchestrator via Skill tool
4. Wait for completion
5. Update initiative-state.yml with completion status
6. Unblock dependent tasks (check if their dependencies now satisfied)
7. Repeat until all tasks complete

**Dependency Unblocking**:
- On task completion, read its `blocks` field
- For each dependent task, check if ALL dependencies now completed
- If yes, move from `blocked` to `pending` in queue

**Failure Handling**:
- Task failure → Pause initiative, prompt user
- Options: Skip task (marks dependents as blocked), retry, abort

→ Pause

**Interactive**: AskUserQuestion - "All tasks executed. Continue to verification?"
**YOLO**: "→ Continuing to Phase 4..."

---

### Phase 4: Initiative Verification

**Purpose**: Validate all tasks completed and aggregate verification results
**Execute**: Direct - aggregate reports, check acceptance criteria
**Output**: `verification-report.md`
**State**: Update verification status

**Process**:
1. Validate all tasks completed (check initiative-state.yml)
2. Read each task's verification report
3. Aggregate issues across all tasks
4. Check initiative acceptance criteria from spec.md
5. Create initiative verification report with GO/NO-GO recommendation

**Gate**: Cannot proceed if critical issues found

→ Pause

**Interactive**: AskUserQuestion - "Verification complete. Continue to finalization?"
**YOLO**: "→ Continuing to Phase 5..."

---

### Phase 5: Finalization

**Purpose**: Complete workflow with summary and roadmap update
**Execute**: Direct - create summary, update roadmap
**Output**: `summary.md`, updated roadmap.md (if exists)
**State**: Set status to completed

**Process**:
1. Update roadmap.md (if exists) with initiative completion
2. Create summary.md with metrics, lessons learned
3. Mark initiative-state.yml as completed

→ End of workflow

---

## Domain Context (State Extensions)

Initiative-specific fields in `initiative-state.yml`:

```yaml
orchestrator:
  mode: interactive | yolo
  current_phase: planning | task-creation | dependency-resolution | task-execution | verification | finalization | completed
  execution_strategy: sequential

tasks:
  pending: [task-ids]
  in_progress: [task-ids]
  completed: [task-ids]
  blocked: [task-ids]
  failed: [task-ids]

  details:
    task-id:
      path: .ai-sdlc/tasks/[type]/YYYY-MM-DD-name
      type: new-feature | enhancement | etc
      status: pending | in-progress | completed | blocked | failed
      dependencies: [task-paths]
      blocks: [task-ids]
      estimated_hours: null
      actual_hours: null

execution:
  current_level: null
  total_levels: null
  levels:
    level-0: [task-ids]
    level-1: [task-ids]
  critical_path: [task-ids]

progress:
  total_tasks: null
  completed: 0
  percent: 0
```

---

## Task Structure

```
.ai-sdlc/docs/project/initiatives/YYYY-MM-DD-initiative-name/
├── initiative.yml              # Task list, dependencies, metadata
├── initiative-state.yml        # Execution state and progress
├── spec.md                     # Initiative goals, success criteria
├── task-plan.md                # Dependency graph, milestones
├── verification-report.md      # Phase 4 output
└── summary.md                  # Phase 5 output

.ai-sdlc/tasks/[type]/YYYY-MM-DD-task-name/
├── orchestrator-state.yml      # Includes initiative_id, dependencies
├── implementation/spec.md      # Task specification
└── ...                         # Standard task structure
```

---

## Integration with Task Orchestrators

Task orchestrators add **Phase 0: Dependency Check** when part of an initiative:

1. Read task `orchestrator-state.yml`
2. If `task.initiative_id` exists:
   - Check all dependencies have `task.status: completed`
   - If any dependency not completed: BLOCK task, exit
3. If no `initiative_id`: Skip check (standalone task)

---

## Auto-Recovery

| Phase | Max Attempts | Strategy |
|-------|--------------|----------|
| 0 | 2 | Re-run planner if circular deps or task count issues |
| 1 | 3 | Skip existing directories, map invalid types |
| 2 | 2 | Remove invalid dependencies, fail if no Level 0 tasks |
| 3 | Delegated | Task orchestrators handle their own recovery |
| 4 | 2 | Return to Phase 3 if not all tasks complete |
| 5 | 3 | Skip roadmap update if file not found |

---

## Command Integration

Invoked via:
- `/ai-sdlc:initiative:new [description] [--yolo]`
- `/ai-sdlc:initiative:resume [initiative-path]`
- `/ai-sdlc:initiative:status [initiative-path]` (view progress)

Initiative directory: `.ai-sdlc/docs/project/initiatives/YYYY-MM-DD-name/`

---

## Constraints

- **Task Count**: 3-15 tasks per initiative
- **Execution**: Sequential (one task at a time)
- **Dependency Depth**: Warn if >6 levels (very long critical path)
- **Phase Boundaries**: Always save state at phase boundaries
