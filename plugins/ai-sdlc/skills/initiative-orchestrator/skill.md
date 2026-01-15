---
name: initiative-orchestrator
description: Orchestrates epic-level initiatives from planning through verification, managing multiple related tasks with dependency coordination and sequential execution. Designed for multi-week projects requiring coordination of 3-15 tasks across different types (new-features, enhancements, migrations, etc.).
---

# Initiative Orchestrator

Epic-level coordination of 3-15 related tasks with dependency management and sequential execution.

## MANDATORY Initialization (Before Any Phase Work)

**CRITICAL: You MUST complete these steps BEFORE executing any workflow phase:**

### Step 0: Load Framework Patterns

**STOP. You MUST read these files NOW using the Read tool before continuing:**

1. `../orchestrator-framework/references/phase-execution-pattern.md` - 7-step phase loop
2. `../orchestrator-framework/references/delegation-enforcement.md` - Delegation patterns and subagent result handling
3. `../orchestrator-framework/references/interactive-mode.md` - Phase gates and AUTO-CONTINUE
4. `../orchestrator-framework/references/state-management.md` - State file operations

**⚠️ FAILURE TO READ THESE FILES IS A WORKFLOW VIOLATION.**

These patterns define:
- How to execute each phase (7-step loop)
- How to delegate to skills (mandatory patterns)
- When to auto-continue vs pause (Phase Gates and ⚡ AUTO)
- How to consume subagent results and continue workflow
- How to manage orchestrator-state.yml

**SELF-CHECK:**
- [ ] Did you use the Read tool to read all 4 files?
- [ ] Do you understand the AUTO-CONTINUE pattern in interactive-mode.md?
- [ ] Do you understand Pattern 6 (Consuming Subagent Results) in delegation-enforcement.md?

If NO to any: STOP and read the files now.

### Step 1: Create TodoWrite with All Phases

**Immediately use the TodoWrite tool** to create todos for all phases:

```
Use TodoWrite tool with todos:
[
  {"content": "Plan initiative tasks", "status": "pending", "activeForm": "Planning initiative tasks"},
  {"content": "Create task directories", "status": "pending", "activeForm": "Creating task directories"},
  {"content": "Resolve dependencies", "status": "pending", "activeForm": "Resolving dependencies"},
  {"content": "Execute tasks", "status": "pending", "activeForm": "Executing tasks"},
  {"content": "Verify initiative", "status": "pending", "activeForm": "Verifying initiative"},
  {"content": "Finalize initiative", "status": "pending", "activeForm": "Finalizing initiative"}
]
```

### Step 2: Output Initialization Summary

**Output this summary to the user:**

```
🚀 Initiative Orchestrator Started

Task: [initiative description]
Mode: [Interactive/YOLO]
Directory: [initiative-path]

Workflow phases:
[Todos list with status]

[Interactive mode] You'll be prompted for review after each phase.
[YOLO mode] All phases will run continuously.

Starting Phase 0: Plan initiative tasks...
```

### Step 3: Only Then Proceed to Phase 0

After completing Steps 0, 1, and 2, proceed to Phase 0 (Initiative Planning).

---

## When to Use This Skill

Use when:
- Epic-level work spanning multiple features (multi-week initiatives)
- Coordinated delivery with related tasks that must work together
- Complex dependencies with technical or logical ordering requirements
- Milestone-based delivery with clear checkpoints

**DO NOT use for**:
- Single standalone tasks (use appropriate task orchestrator)
- Quick fixes or small changes (use individual task types)
- Exploratory work without clear scope (define scope first)

## Core Principles

1. **Dependency-First**: Enforce task execution order based on dependencies
2. **Sequential Execution**: One task at a time to maintain focus and quality
3. **Initiative Context**: Each task knows it's part of a larger initiative
4. **Milestone Tracking**: Group tasks into meaningful delivery checkpoints
5. **Full Resume**: Complete pause/resume capability at any point

---

## Local References

Read these during relevant phases:

| File | When to Use | Purpose |
|------|-------------|---------|
| `references/dependency-resolution.md` | Phase 2 | Dependency graph algorithms and resolution strategies |
| `references/execution-strategies.md` | Phase 3 | Task sequencing and execution patterns |
| `references/phases.md` | General | Detailed phase substeps and decision points |
| `references/state-coordination.md` | All phases | Multi-task state handling and coordination |

---

## Phase Configuration

| Phase | content | activeForm | Agent/Skill |
|-------|---------|------------|-------------|
| 0 | "Plan initiative tasks" | "Planning initiative tasks" | initiative-planner |
| 1 | "Create task directories" | "Creating task directories" | orchestrator |
| 2 | "Resolve dependencies" | "Resolving dependencies" | orchestrator |
| 3 | "Execute tasks" | "Executing tasks" | orchestrator + task orchestrators |
| 4 | "Verify initiative" | "Verifying initiative" | orchestrator |
| 5 | "Finalize initiative" | "Finalizing initiative" | orchestrator |

**Workflow Overview**: 6 phases

**CRITICAL TodoWrite Usage**:
1. At workflow start: Create todos for ALL phases using the Phase Configuration table above (all status=pending)
2. Before each phase: Update that phase to status=in_progress
3. After each phase: Update that phase to status=completed

---

## Workflow Phases

### Phase 0: Initiative Planning

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/initiative-planner.md and following its instructions directly
❌ WRONG: Breaking down the initiative inline in the orchestrator thread
❌ WRONG: Creating initiative.yml and dependency graph yourself

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 0 to: initiative-planner subagent
Method: Task tool
Expected outputs: initiative.yml, spec.md, task-plan.md
```

**INVOKE NOW:**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:initiative-planner"
  description: "Plan initiative tasks"
  prompt: |
    You are the initiative-planner agent. Break down epic into
    concrete tasks with dependency relationships.

    Initiative description: [description]
    Initiative directory: [.ai-sdlc/docs/project/initiatives/YYYY-MM-DD-name/]

    Please:
    1. Gather requirements via AskUserQuestion
    2. Analyze codebase (INDEX.md, existing features)
    3. Decompose into 3-15 tasks
    4. Construct dependency graph
    5. Recommend execution strategy
    6. Define milestones
    7. Assess risks

    Create:
    - initiative.yml (task list, dependencies, metadata)
    - spec.md (initiative goals, success criteria)
    - task-plan.md (dependency graph, milestones)

    Use Read, Grep, Glob, Bash, and AskUserQuestion tools. Do NOT modify code.

⏳ Wait for subagent completion before continuing.

**Outputs**: `initiative.yml`, `spec.md`, `task-plan.md`

**SELF-CHECK (before proceeding to Phase 1):**
- [ ] Did you invoke the Task tool? (not just read the agent file)
- [ ] Did you wait for the tool to return results?
- [ ] Are `initiative.yml`, `spec.md`, and `task-plan.md` present?

If NO to any: STOP - go back and invoke the Task tool.

**Validation**:
- ✅ initiative.yml exists with 3-15 tasks
- ✅ No circular dependencies
- ✅ All task IDs unique
- ✅ All dependency references valid

---

## 🚦 GATE: Phase 0 → Phase 1

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 0 (Initiative Planning) complete. Ready to proceed to Phase 1 (Task Creation)?"
     - Options: ["Continue to Phase 1", "Review Phase 0 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 1 (Task Creation)..."
   - Proceed to Phase 1

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 1: Task Creation

**Execution**: Main orchestrator (direct)

**Process**:
1. Read initiative.yml, extract task list
2. Create task directories in `.ai-sdlc/tasks/[type]/YYYY-MM-DD-task-name/`
3. Initialize task `orchestrator-state.yml` with initiative fields in the `task:` section:
   ```yaml
   task:
     initiative_id: YYYY-MM-DD-initiative-name
     dependencies: [array of task paths]
     blocks: [array of task paths that depend on this]
     milestone: Milestone Name
   ```
4. Create placeholder spec.md in each task directory
5. Create initiative-state.yml with all task tracking

**Outputs**: Task directories, orchestrator-state.yml files, placeholder specs, initiative-state.yml

---

## 🚦 GATE: Phase 1 → Phase 2

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 1 (Task Creation) complete. Ready to proceed to Phase 2 (Dependency Resolution)?"
     - Options: ["Continue to Phase 2", "Review Phase 1 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 2 (Dependency Resolution)..."
   - Proceed to Phase 2

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 2: Dependency Resolution

**Execution**: Main orchestrator (direct)

**Process**:
1. Build dependency graph from initiative.yml
2. Validate graph:
   - **Cycle Detection**: Topological sort, fail if cycle found
   - **Reference Validation**: All dependencies point to valid task IDs
   - **Completeness**: All tasks reachable
3. Compute dependency levels (BFS from tasks with no dependencies)
4. Build execution queue ordered by levels
5. Identify critical path (longest path through graph)
6. Update initiative-state.yml with execution plan

**Outputs**: Validated dependency graph, execution queue, critical path

---

## 🚦 GATE: Phase 2 → Phase 3

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 2 (Dependency Resolution) complete. Ready to proceed to Phase 3 (Task Execution)?"
     - Options: ["Continue to Phase 3", "Review Phase 2 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 3 (Task Execution)..."
   - Proceed to Phase 3

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 3: Task Execution

**⚠️ DELEGATION REQUIRED FOR EACH TASK - DO NOT EXECUTE TASKS INLINE**

❌ WRONG: Reading task orchestrator SKILL.md files and following instructions directly
❌ WRONG: Implementing task work inline in the initiative orchestrator thread
❌ WRONG: Spawning your own subagents to do task work

✅ RIGHT: Invoking appropriate orchestrator skill for each task and waiting for completion

**IMPORTANT**: Execute tasks ONE AT A TIME (sequential execution)

**Task Type to Orchestrator Mapping**:

| Task Type | Orchestrator Skill |
|-----------|-------------------|
| new-feature | ai-sdlc:development-orchestrator |
| enhancement | ai-sdlc:development-orchestrator |
| bug-fix | ai-sdlc:development-orchestrator |
| migration | ai-sdlc:migration-orchestrator |
| refactoring | ai-sdlc:refactoring-orchestrator |
| performance | ai-sdlc:performance-orchestrator |
| security | ai-sdlc:security-orchestrator |
| documentation | ai-sdlc:documentation-orchestrator |

**INVOKE FOR EACH TASK:**

For each task in queue where status != "completed":

1. **Output announcement:**
   ```
   📤 Executing task [N]/[total]: [task name]
   Type: [task type]
   Orchestrator: [orchestrator skill name]
   ```

2. **Invoke orchestrator:**

   Tool: `Skill`
   Parameters:
     skill: "ai-sdlc:[task-type]-orchestrator"

3. **Wait for orchestrator to complete**

4. **Update state after completion**

⚠️ Do NOT batch execute - invoke one skill, wait for completion, then proceed to next.

**Execution Loop**:
1. Select next task from queue (respecting dependency order)
2. Read task's `orchestrator-state.yml` to determine type from `task.type`
3. **Output pre-delegation announcement** (see above)
4. **Invoke appropriate orchestrator via Skill tool**
5. **Wait for orchestrator to complete**
6. Update initiative-state.yml with completion status
7. Unblock dependent tasks (check if their dependencies now satisfied)
8. Repeat until all tasks complete

**SELF-CHECK (after each task):**
- [ ] Did you invoke the Skill tool for this task? (not execute inline)
- [ ] Did you wait for the skill to complete?
- [ ] Is the task's status updated in initiative-state.yml?

If NO to any: STOP - go back and invoke the Skill tool for this task.

**Dependency Unblocking**:
- On task completion, read its `blocks` field
- For each dependent task, check if ALL dependencies now completed
- If yes, move from `blocked` to `pending` in queue

**Failure Handling**:
- Task failure → Pause initiative, prompt user
- Options: Skip task (marks dependents as blocked), retry, abort
- Dependent tasks cannot proceed if dependency failed

---

## 🚦 GATE: Phase 3 → Phase 4

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 3 (Task Execution) complete. Ready to proceed to Phase 4 (Initiative Verification)?"
     - Options: ["Continue to Phase 4", "Review Phase 3 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 4 (Initiative Verification)..."
   - Proceed to Phase 4

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 4: Initiative Verification

**Execution**: Main orchestrator (direct)

**Process**:
1. Validate all tasks completed (check initiative-state.yml)
2. Read each task's verification report
3. Aggregate issues across all tasks
4. Check initiative acceptance criteria from spec.md
5. Create initiative verification report with:
   - Task completion summary
   - Aggregated issues (critical, warnings)
   - Success criteria verification
   - Deployment readiness recommendation (GO/NO-GO)

**Outputs**: `verification-report.md`

**Gate**: Cannot proceed to Phase 5 if critical issues found

---

## 🚦 GATE: Phase 4 → Phase 5

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 4 (Initiative Verification) complete. Ready to proceed to Phase 5 (Finalization)?"
     - Options: ["Continue to Phase 5", "Review Phase 4 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 5 (Finalization)..."
   - Proceed to Phase 5

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 5: Finalization

**Execution**: Main orchestrator (direct)

**Process**:
1. Update roadmap.md (if exists) with initiative completion
2. Create initiative summary.md with:
   - Duration and hours (actual vs estimated)
   - Tasks completed
   - Milestones achieved
   - Metrics (estimation accuracy, success rate)
   - Lessons learned
3. Mark initiative-state.yml as completed

**Outputs**: Updated roadmap.md, summary.md, completed initiative-state.yml

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
      estimated_hours: X
      actual_hours: Y

execution:
  current_level: N
  total_levels: M
  levels:
    level-0: [task-ids]
    level-1: [task-ids]
  critical_path: [task-ids]

progress:
  total_tasks: N
  completed: X
  percent: (completed/total * 100)
  estimated_hours: X
  actual_hours: Y
```

---

## Integration with Task Orchestrators

Task orchestrators (development, migration, etc.) add **Phase 0.5: Dependency Check** when part of an initiative:

1. Read task `orchestrator-state.yml`
2. If `task.initiative_id` exists:
   - Check all dependencies have `task.status: completed`
   - If any dependency not completed: BLOCK task, exit
3. If no `initiative_id`: Skip check (standalone task)

**Impact**: ~30 lines per orchestrator, no breaking changes to standalone tasks

---

## Auto-Recovery

| Phase | Max Attempts | Strategy |
|-------|--------------|----------|
| 0 | 2 | Re-run planner with feedback if circular deps or task count issues |
| 1 | 3 | Skip existing directories, map invalid types to closest valid |
| 2 | 2 | Remove invalid dependencies, fail if no Level 0 tasks |
| 3 | Delegated | Task orchestrators handle their own recovery; initiative pauses on persistent failure |
| 4 | 2 | Return to Phase 3 if not all tasks complete |
| 5 | 3 | Skip roadmap update if file not found |

**Task Failure Handling**:
- Attempts 1-2: Delegate to task orchestrator's auto-fix
- Attempt 3+: Pause initiative, prompt user (skip/retry/abort)

---

## Resume Capability

**Command**: `/ai-sdlc:initiative:resume [initiative-path]`

**Process**:
1. Load initiative-state.yml
2. Validate state consistency (tasks exist, states match)
3. Determine resume point from current_phase
4. Reconstruct context from initiative.yml and task metadata files
5. Continue from current_phase

**State Reconstruction** (if initiative-state.yml corrupted):
1. Read initiative.yml (source of truth for task list)
2. Poll all task `orchestrator-state.yml` files for current status
3. Rebuild dependency graph
4. Prompt user to confirm reconstructed state

---

## Task Structure

```
.ai-sdlc/docs/project/initiatives/YYYY-MM-DD-initiative-name/
├── initiative.yml         # Task list, dependencies, metadata
├── initiative-state.yml   # Execution state and progress
├── spec.md                # Initiative goals, success criteria
├── task-plan.md           # Dependency graph, milestones
├── verification-report.md # Phase 4 output
└── summary.md             # Phase 5 output

.ai-sdlc/tasks/[type]/YYYY-MM-DD-task-name/
├── orchestrator-state.yml # Includes initiative_id, dependencies, blocks in task: section
├── implementation/spec.md # Task specification (placeholder then full)
└── ...                    # Standard task structure
```

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

---

## Success Criteria

Initiative orchestration successful when:

- All tasks completed or accounted for (completed/blocked/skipped)
- Dependencies enforced throughout execution
- Verification reports show passed or passed-with-issues
- Initiative summary created with metrics
- Roadmap updated (if exists)
- Full pause/resume capability maintained
- No data loss on interruption
