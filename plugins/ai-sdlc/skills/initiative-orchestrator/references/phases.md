# Initiative Orchestrator Phases Reference

## Overview

This document provides detailed workflows for each of the 6 initiative orchestrator phases. Each phase has clear objectives, inputs/outputs, and decision points.

## Phase Flow

```
Phase 0: Planning
    ↓
Phase 1: Task Creation
    ↓
Phase 2: Dependency Resolution
    ↓
Phase 3: Task Execution ← (Most complex, loops until all tasks complete)
    ↓
Phase 4: Initiative Verification
    ↓
Phase 5: Finalization
```

---

## Phase 0: Initiative Planning

### Objective

Transform epic description into structured task breakdown with dependencies

### Inputs

- Initiative description (user-provided text)
- `.ai-sdlc/docs/INDEX.md` (project context)
- Optional: Timeline, priorities, constraints

### Process Pattern

```
1. Validate prerequisites
   - Check .ai-sdlc/docs/ exists
   - Read INDEX.md for project understanding

2. Create initiative directory structure
   - .ai-sdlc/docs/project/initiatives/YYYY-MM-DD-name/

3. Delegate to initiative-planner agent
   - Launch via Task tool
   - Agent performs:
     * Requirements gathering (AskUserQuestion)
     * Codebase analysis (Read, Glob, Grep)
     * Task decomposition (3-15 tasks)
     * Dependency graph construction
     * Execution strategy recommendation
     * Milestone definition
     * Risk assessment

4. Validate planner output
   - initiative.yml exists with valid structure
   - spec.md exists with goals and criteria
   - task-plan.md exists with dependency graph
   - No circular dependencies (run topological sort)
   - All task IDs unique and valid
   - All dependency references point to existing tasks

5. Save initial state
   - Create initiative-state.yml
   - Set current_phase: planning
```

### Outputs

- `initiatives/YYYY-MM-DD-name/initiative.yml` (task registry, dependencies, milestones)
- `initiatives/YYYY-MM-DD-name/spec.md` (vision, goals, success criteria)
- `initiatives/YYYY-MM-DD-name/task-plan.md` (detailed breakdown, dependency graph)
- `initiatives/YYYY-MM-DD-name/initiative-state.yml` (execution state)

### Decision Points

**Q: Task count out of range?**
- <3 tasks: Too small, not an epic → Suggest single task instead
- >15 tasks: Too large → Suggest breaking into multiple initiatives or reviewing decomposition

**Q: Circular dependencies detected?**
- Identify cycle path (A → B → C → A)
- Prompt user to resolve (manual intervention)
- Cannot proceed until resolved

**Q: User requests adjustments?**
- Re-run planner with new constraints
- Preserve validated portions if possible

### Auto-Recovery Strategies

| Failure | Strategy | Max Attempts |
|---------|----------|--------------|
| Circular dependency | Re-run planner with cycle feedback | 2 |
| Invalid task count | Re-run with scope guidance | 2 |
| Missing dependencies | Validate & regenerate | 2 |
| Planner agent failure | Retry agent launch | 3 |

### State After Completion

```yaml
current_phase: planning
completed_phases: []
phase_results:
  planning:
    initiative_path: initiatives/YYYY-MM-DD-name
    task_count: 8
    estimated_hours: 240
    strategy: mixed
    milestones: ["Foundation", "Core Features", "Production Ready"]
    critical_path_hours: 180
```

---

## Phase 1: Task Creation

### Objective

Create directory structure and initialize metadata for all tasks

### Inputs

- `initiative.yml` (task list with types, dependencies)
- Task type mappings (new-feature → tasks/new-features/, etc.)

### Process Pattern

```
1. Read initiative.yml
   - Extract tasks array
   - For each task: get id, type, name, description, dependencies, blocks, hours

2. Create task directories
   - For each task:
     * Determine path: .ai-sdlc/tasks/[type]/YYYY-MM-DD-name/
     * Create directory structure:
       - analysis/
       - implementation/
       - verification/
       - documentation/ (optional)

3. Initialize task orchestrator-state.yml with `task:` section
   - Copy from initiative.yml task definition
   - Add initiative-specific fields to task section:
     * initiative_id: YYYY-MM-DD-initiative-name
     * dependencies: [array of task paths]
     * blocks: [array of task IDs]
     * milestone: [milestone name]
   - Set task.status: pending
   - Set task.actual_hours: 0

4. Create placeholder spec.md
   - Implementation/spec.md with minimal content:
     * Task name and description
     * Part of initiative: [link]
     * Dependencies: [list]
     * Acceptance criteria: [from initiative]
     * Note: Full spec created during task execution

5. Initialize initiative-state.yml task registry
   - Create tasks.details section
   - All tasks start in tasks.pending array
   - Set coordination.max_parallel (default: 3)
```

### Outputs

- Task directories in `.ai-sdlc/tasks/[type]/YYYY-MM-DD-name/`
- Task `orchestrator-state.yml` files with initiative fields in `task:` section
- Placeholder `spec.md` files
- Updated `initiative-state.yml` with task registry

### Decision Points

**Q: Task directory already exists?**
- Check if part of current initiative (read orchestrator-state.yml task.initiative_id)
- If yes: Skip, log warning (task already created)
- If no: Error, name conflict with different initiative/standalone task

**Q: Invalid task type?**
- Map to closest valid type or prompt user
- Valid types: new-feature, enhancement, migration, bug-fix, refactoring, performance, security, documentation
- Log info message

### Auto-Recovery Strategies

| Failure | Strategy | Max Attempts |
|---------|----------|--------------|
| Directory exists | Skip if same initiative, error if different | 1 |
| Invalid type | Map to valid or prompt | 2 |
| File write failure | Retry with exponential backoff | 3 |

### State After Completion

```yaml
current_phase: task-creation
completed_phases: [planning]
phase_results:
  task_creation:
    tasks_created: 8
    task_types: {new-feature: 5, enhancement: 2, migration: 1}
    directories_created: 8
    placeholder_specs: 8

tasks:
  pending: [all-task-ids]
  in_progress: []
  completed: []
  blocked: []
  failed: []
```

---

## Phase 2: Dependency Resolution

### Objective

Validate dependency graph and finalize execution strategy

### Inputs

- `initiative.yml` (dependencies array per task)
- Task `orchestrator-state.yml` files (for validation)

### Process Pattern

```
1. Build dependency graph
   - Create adjacency list: {task-id: [dependency-ids]}
   - Create reverse graph: {task-id: [tasks-that-depend-on-me]}

2. Validate graph structure
   - Topological sort to detect cycles
   - If cycle found: Identify cycle path, error with details
   - Verify all dependency references exist
   - Check graph is connected (all tasks reachable)

3. Compute dependency levels
   - Breadth-first traversal from Level 0 (no dependencies)
   - Assign level to each task: max(dependency levels) + 1
   - Group tasks by level: {level-0: [...], level-1: [...]}

4. Identify critical path
   - Longest path through graph (sum of estimated hours)
   - Mark tasks on critical path (high priority)
   - Calculate minimum timeline

5. Determine execution strategy
   - Read recommended strategy from initiative.yml
   - Validate against dependency structure:
     * Sequential: Works for any graph
     * Parallel: Only if multiple Level 0 tasks exist
     * Mixed: Recommended for graphs with >1 level and >1 task per level
   - Override if user-selected strategy incompatible

6. Mark initial task states
   - Level 0 tasks: pending (ready to start)
   - All other tasks: blocked (waiting for dependencies)

7. Save execution plan
   - Write execution.levels to initiative-state.yml
   - Write execution.critical_path
   - Write coordination settings
```

### Outputs

- Validated dependency graph
- Execution groups by level
- Critical path identification
- Updated `initiative-state.yml` with execution plan

### Decision Points

**Q: Circular dependency detected?**
- Cannot auto-fix (structural problem)
- Provide cycle path to user
- Pause, require manual resolution
- User must edit initiative.yml and resume

**Q: All tasks blocked (no Level 0)?**
- Graph construction error
- Every task has dependencies but nothing to start from
- Error with message, cannot proceed

**Q: Recommended strategy incompatible?**
- Example: User wants parallel but graph is single chain
- Override with compatible strategy
- Inform user of change and rationale

**Q: Excessive dependency depth (>6 levels)?**
- Warn user: very long critical path
- Suggest reviewing task breakdown
- Can proceed but likely slow execution

### Auto-Recovery Strategies

| Failure | Strategy | Max Attempts |
|---------|----------|--------------|
| Circular dependency | Cannot auto-fix, prompt user | 0 |
| Missing reference | Remove invalid dependency, log warning | 2 |
| All tasks blocked | Cannot auto-fix, error | 0 |

### State After Completion

```yaml
current_phase: dependency-resolution
completed_phases: [planning, task-creation]
phase_results:
  dependency_resolution:
    total_levels: 4
    execution_groups:
      level-0: [task-1, task-2]
      level-1: [task-3]
      level-2: [task-4, task-5, task-6]
      level-3: [task-7, task-8]
    critical_path: [task-1, task-3, task-4, task-7]
    critical_path_hours: 180
    strategy: mixed
    validation: passed

execution:
  current_level: 0
  total_levels: 4
  levels: [as above]
  critical_path: [task-1, task-3, task-4, task-7]

tasks:
  pending: [task-1, task-2]  # Level 0
  blocked: [task-3, task-4, task-5, task-6, task-7, task-8]
```

---

## Phase 3: Task Execution

### Objective

Orchestrate task completion with dependency enforcement and parallel execution

**Most Complex Phase**: Involves polling, coordination, failure handling

### Inputs

- `initiative-state.yml` (execution plan, task states)
- Task `orchestrator-state.yml` files (for status and progress monitoring)

### Process Pattern (High-Level)

```
1. Initialize execution
   - Set current_level: 0
   - Load tasks for Level 0

2. Execution loop (until all tasks complete):
   a. Select tasks to execute
      - Current level tasks with status: pending
      - Verify dependencies satisfied

   b. Launch task orchestrators
      - Sequential: 1 task at a time
      - Parallel/Mixed: All tasks in level (single message, multiple Task calls)

   c. Monitor task progress
      - Poll orchestrator-state.yml files
      - Update initiative-state.yml with progress
      - Detect completion/failure

   d. Handle task completion
      - Update task status: completed
      - Record actual hours
      - Check for dependent tasks to unblock

   e. Handle task failure
      - Record failure details
      - Determine impact on dependent tasks
      - Apply auto-recovery or prompt user

   f. Check level complete
      - If all level tasks complete/failed: Move to next level
      - If tasks still running: Continue monitoring

   g. Update progress metrics
      - Calculate completion percentage
      - Update estimated remaining hours

3. Finalize execution
   - Verify all tasks accounted for (completed/blocked/failed)
   - Log final statistics
```

### Detailed Sub-Processes

#### 3.A Task Selection

```
For current execution level:
  1. Get all tasks in level from execution.levels
  2. Filter by status: pending
  3. For each pending task:
     - Read orchestrator-state.yml task.dependencies
     - Check all dependencies task.status == completed
     - If yes: Add to execute queue
     - If no: Mark blocked (shouldn't happen if graph valid)

Result: Queue of tasks ready to execute this round
```

#### 3.B Task Orchestrator Launch

**Sequential Mode**:
```
1. Take first task from queue
2. Determine task type from orchestrator-state.yml task.type (new-feature, enhancement, etc.)
3. Launch appropriate orchestrator skill:
   - Use Skill tool
   - skill: [feature-orchestrator|enhancement-orchestrator|migration-orchestrator|bug-fix-orchestrator|refactoring-orchestrator]
   - Pass task path, initiative context, mode (interactive/yolo)
4. Wait for completion (synchronous)
5. Process result (update task status, record hours)
6. Move to next task
```

**Parallel/Mixed Mode**:
```
1. Take ALL tasks from queue (up to max_parallel)
2. In SINGLE MESSAGE, launch multiple Skill tool calls:
   - Skill call 1: Launch orchestrator for task-A
   - Skill call 2: Launch orchestrator for task-B
   - Skill call 3: Launch orchestrator for task-C
3. Enter monitoring loop (asynchronous)
4. Wait for all to complete before moving to next level
```

**Skill Tool Parameters**:
```markdown
skill: [task-type]-orchestrator

For each task type, invoke the appropriate skill:
- new-feature → feature-orchestrator
- enhancement → enhancement-orchestrator
- migration → migration-orchestrator
- bug-fix → bug-fix-orchestrator
- refactoring → refactoring-orchestrator
- performance → performance-orchestrator (when implemented)
- security → security-orchestrator (when implemented)
- documentation → documentation-orchestrator (when implemented)

The skill will receive prompt:
  Execute workflow for task: [task-path]

  Initiative Context:
  - Part of initiative: [initiative-name]
  - Initiative ID: [initiative-id]
  - Dependencies satisfied: [list of completed task names]
  - This task will unblock: [list of dependent task names]

  Execution Mode: [--yolo flag if initiative in yolo mode, otherwise interactive]

  Task orchestrator-state.yml task section already contains:
  - initiative_id: [id]
  - dependencies: [paths]
  - blocks: [ids]

  Phase 0.5 (Dependency Check) will verify dependencies before proceeding.

  On completion, update task orchestrator-state.yml:
  - task.status: completed
  - task.actual_hours: [final hours]
```

#### 3.C Task Monitoring

**Polling Loop** (for parallel execution):
```
While tasks_running > 0:
  1. Sleep 30 seconds (or poll interval)

  2. For each in-progress task:
     - Read tasks/[type]/[task-name]/orchestrator-state.yml
     - Check current_phase
     - Check completed_phases

  3. Detect completion:
     - current_phase == "completed"
     - OR: all expected phases in completed_phases

  4. Detect failure:
     - failed_phases not empty
     - OR: auto_fix_attempts exceeded for any phase

  5. Update initiative-state.yml:
     - Move completed tasks: in_progress → completed
     - Move failed tasks: in_progress → failed
     - Update progress metrics

  6. Check for newly unblocked tasks (see 3.D)

  7. If all tasks in level complete: Break loop
```

**State Coordination**:
- Each task orchestrator owns its state file
- Initiative orchestrator polls (reads) task states
- Initiative orchestrator owns initiative-state.yml
- No concurrent writes to same file (no race conditions)

#### 3.D Dependency Unblocking

```
On task completion (task-X):
  1. Read task-X orchestrator-state.yml task.blocks field
     - Get list of task IDs that depend on task-X

  2. For each dependent task-Y:
     a. Read task-Y orchestrator-state.yml task.dependencies
     b. Check if ALL dependencies now completed
     c. If yes:
        - Update task-Y status: blocked → pending
        - Add to execution queue (for next round/level)
        - Log unblock event
     d. If no:
        - Task-Y remains blocked (waiting for other dependencies)

  3. Update initiative-state.yml:
     - Move task-Y from blocked to pending
     - Increment unblocked_count metric
```

#### 3.E Failure Handling

**Detection**:
```
Task orchestrator failure indicated by:
- Task tool returns with error
- orchestrator-state.yml shows failed_phases
- Excessive auto_fix_attempts (>= max for phase)
```

**Recording**:
```yaml
tasks:
  failed:
    - task_id: task-3
      task_path: .ai-sdlc/tasks/new-features/2025-11-14-api
      phase: implementation
      error: "5 test failures detected"
      attempts: 3
      timestamp: YYYY-MM-DDTHH:MM:SSZ
      on_critical_path: true
```

**Impact Analysis**:
```
1. Read failed task orchestrator-state.yml task.blocks field
2. For each dependent task:
   - Mark as blocked (cannot proceed)
   - Add blocked_reason: "Dependency task-3 failed"
3. Determine if on critical path:
   - If yes: Entire initiative blocked
   - If no: Other tasks can continue
```

**Auto-Recovery** (delegate to task orchestrator):
```
Attempt 1-2: Task orchestrator handles its own auto-recovery
  - Initiative orchestrator waits/retries
  - Task orchestrator may auto-fix and continue

Attempt 3+: Escalate to initiative level
  - Pause initiative execution
  - Prompt user with options
```

**User Prompt** (after max attempts):
```
Task failed: [task-name]
Phase: [phase]
Error: [error message]
Attempts: 3

This task blocks: [list]
On critical path: [Yes/No]

Options:
1. Skip task and continue (dependent tasks will be blocked)
2. I'll fix manually and resume
3. Abort initiative

Choice: ___
```

### Outputs

- All tasks status updated (completed/failed/blocked)
- Task orchestrator-state.yml task.actual_hours populated
- Updated initiative-state.yml with execution results

### Decision Points

**Q: Should task execute now?**
- Check dependencies all completed
- Check not already in-progress/completed
- Check execution strategy allows (level-based)

**Q: How many tasks to launch in parallel?**
- Up to coordination.max_parallel (default: 3)
- Or: All tasks in current level (if mixed mode)
- Never exceed system limits

**Q: Task failed, what to do?**
- If <3 attempts: Retry (task orchestrator handles)
- If >=3 attempts: Prompt user
- If on critical path: High priority resolution
- If not on critical path: Can defer

**Q: All tasks in level complete?**
- Move to next level
- Update current_level in state
- Log level completion metrics

**Q: All tasks complete or blocked?**
- End execution loop
- Proceed to Phase 4 (Verification)

### Auto-Recovery Strategies

| Failure | Strategy | Max Attempts |
|---------|----------|--------------|
| Task orchestrator failure | Delegate to task's auto-recovery, then retry | 3 |
| Parallel task conflict | Retry with reduced parallelism | 2 |
| State file corruption | Reconstruct from task states | 2 |
| All tasks blocked | Manual intervention required | 0 |

### State During Execution

```yaml
current_phase: task-execution
phase_results:
  task_execution:
    current_level: 1
    levels_completed: 1
    tasks_completed: 2
    tasks_in_progress: 1
    tasks_failed: 0
    total_hours_so_far: 65

execution:
  current_level: 1
  total_levels: 4

tasks:
  pending: [task-4, task-5, task-6]  # Level 2
  in_progress: [task-3]  # Level 1
  completed: [task-1, task-2]  # Level 0
  blocked: [task-7, task-8]  # Level 3
  failed: []

progress:
  total_tasks: 8
  completed: 2
  in_progress: 1
  percent: 25

coordination:
  parallel_running: 1
  max_parallel: 3
  last_poll: YYYY-MM-DDTHH:MM:SSZ
  next_poll: YYYY-MM-DDTHH:MM:SS+30Z
```

---

## Phase 4: Initiative Verification

### Objective

Verify all tasks complete and integration works

### Inputs

- Updated initiative-state.yml (task completion status)
- Task verification reports: `tasks/[type]/[name]/verification/implementation-verification.md`
- Initiative spec.md (success criteria)

### Process Pattern

```
1. Validate all tasks accounted for
   - Count: completed + blocked + failed == total
   - If not: Error, missing tasks

2. Check individual task verification
   - For each completed task:
     * Read verification/implementation-verification.md
     * Extract overall status (Passed/Passed with Issues/Failed)
     * Aggregate issues by severity (Critical/Warning/Info)

3. Integration testing (optional)
   - If initiative involves multiple interacting features
   - Optionally run cross-task E2E tests
   - Example: Login (task 1) + Create content (task 2) work together

4. Verify success criteria
   - Read spec.md success criteria list
   - For each criterion:
     * Determine if met (check task outputs, tests, etc.)
     * Document evidence or reason not met

5. Aggregate findings
   - Collect all issues across tasks
   - Categorize by severity
   - Identify blockers vs nice-to-fix

6. Create verification report
   - initiatives/[name]/verification-report.md
   - Include:
     * Task completion summary table
     * Integration test results
     * Success criteria checklist
     * Aggregated issues
     * Deployment readiness recommendation
     * Overall status (Passed/Passed with Issues/Failed)

7. Determine deployment readiness
   - ✅ GO: All tasks passed, no critical issues
   - ⚠️ GO with conditions: Passed with issues, conditions documented
   - ❌ NO-GO: Critical issues or failures present
```

### Outputs

- `verification-report.md` with comprehensive assessment
- Deployment readiness determination
- Aggregated issues list

### Decision Points

**Q: Not all tasks completed?**
- Check blocked/failed tasks
- Can initiative be considered complete with some tasks incomplete?
- Usually NO (need all tasks for epic)
- Prompt user to resolve before proceeding

**Q: Critical issues found?**
- Cannot deploy without fixing
- Option 1: Create remediation task list, fix now
- Option 2: Mark initiative as "Passed with Issues", defer fixes
- Decision depends on issue severity and urgency

**Q: Success criteria not met?**
- Investigate why (task incomplete? Wrong scope?)
- Adjust criteria OR add remediation tasks

**Q: Should run integration tests?**
- If multi-feature initiative: YES
- If single feature split into tasks: Maybe (task E2E tests may suffice)
- If data migration: CRITICAL (verify data integrity)

### Auto-Recovery Strategies

| Failure | Strategy | Max Attempts |
|---------|----------|--------------|
| Missing verification report | Skip task, log warning | 1 |
| Success criteria unclear | Mark as "Unable to verify", continue | 1 |
| Integration test failure | Record as critical issue, mark NO-GO | 2 |

### State After Completion

```yaml
current_phase: initiative-verification
completed_phases: [planning, task-creation, dependency-resolution, task-execution]
phase_results:
  verification:
    status: passed|passed-with-issues|failed
    tasks_verified: 8
    critical_issues: 0
    warnings: 3
    info: 12
    deployment_ready: true
    integration_tests_run: true
    integration_tests_passed: true
    success_criteria_met: 100%
```

---

## Phase 5: Finalization

### Objective

Update roadmap, create summary, archive initiative

### Inputs

- Completed initiative-state.yml
- verification-report.md
- All task orchestrator-state.yml files (for actual hours)
- initiative.yml, spec.md, task-plan.md

### Process Pattern

```
1. Calculate final metrics
   - Total duration: completed timestamp - started timestamp
   - Total actual hours: sum of task actual_hours
   - Estimation accuracy: actual vs estimated percentage
   - Task success rate: completed without failures
   - Critical path adherence: on-time vs delayed

2. Create initiative summary
   - initiatives/[name]/summary.md
   - Include:
     * Overview (dates, duration, hours)
     * Tasks completed list with hours
     * Milestones achieved with dates
     * Metrics (accuracy, success rate, etc.)
     * Lessons learned (optional: prompt user for input)
     * Deliverables (links to features, docs)

3. Update roadmap (if exists)
   - Read .ai-sdlc/docs/project/roadmap.md
   - Find initiative entry or create new
   - Mark as ✅ Completed with completion date
   - Add summary link

4. Update initiative state to complete
   - Set current_phase: completed
   - Set completion timestamp
   - Calculate final statistics
   - Save state

5. Optional: Archive initiative
   - Could move to initiatives/archive/
   - Or add archived: true flag
   - For now: Just mark complete
```

### Outputs

- `summary.md` with final metrics and lessons learned
- Updated `roadmap.md` (if exists)
- Completed `initiative-state.yml`

### Decision Points

**Q: Roadmap doesn't exist?**
- Skip roadmap update
- Log info message
- Continue with summary

**Q: User wants to add lessons learned?**
- Prompt for input via AskUserQuestion
- Include in summary.md
- Optional step

**Q: Should archive?**
- For now: No (keep in initiatives/)
- Future enhancement: Archive after N days/months

### Auto-Recovery Strategies

| Failure | Strategy | Max Attempts |
|---------|----------|--------------|
| Roadmap write failure | Skip, log warning, continue | 2 |
| Summary creation failure | Retry, essential output | 3 |
| Metrics calculation error | Use partial metrics, continue | 2 |

### State After Completion

```yaml
current_phase: completed
completed_phases: [all phases]
final_status: success
phase_results:
  finalization:
    roadmap_updated: true
    summary_created: true
    archived: false
    final_metrics:
      total_duration_days: 14
      total_hours: 245
      estimated_hours: 240
      accuracy: 98%
      task_success_rate: 100%

completion:
  timestamp: YYYY-MM-DDTHH:MM:SSZ
  total_duration_hours: 245
  success_rate: 100%
```

---

## Phase Transition Rules

### Moving Forward

```
Can proceed to next phase when:
- Current phase completed_phases contains current phase
- No failed_phases in current phase
- Auto-fix attempts not exceeded
- Required outputs exist and valid

Interactive mode: Prompt user before transition
YOLO mode: Auto-transition if above conditions met
```

### Pausing

```
Can pause at any phase boundary:
- After phase completes
- Save state with current_phase
- Exit orchestrator
- Resume later via /initiative:resume
```

### Skipping Phases

```
Cannot skip phases (sequential dependency):
- Planning creates artifacts for Task Creation
- Task Creation creates artifacts for Dependency Resolution
- Dependency Resolution required before Execution
- Execution required before Verification
- Verification required before Finalization

Exception: Resume can start from any completed phase
```

---

## Error Handling Across Phases

### Common Errors

| Error Type | Handling Strategy |
|------------|-------------------|
| File not found | Check if expected file, retry or skip with warning |
| Invalid YAML | Parse error, attempt to fix or prompt user |
| Agent launch failure | Retry with exponential backoff |
| State corruption | Reconstruct from artifacts |
| User cancellation | Save state, exit cleanly |

### State Consistency

After any error:
1. Save current state (even if incomplete)
2. Log error with context
3. Mark phase as failed if cannot proceed
4. Ensure initiative-state.yml is valid YAML
5. Do not leave partial artifacts (all-or-nothing writes)

---

## Performance Considerations

### Phase Duration Estimates

| Phase | Typical Duration | Primary Factor |
|-------|------------------|----------------|
| Planning | 5-15 minutes | User Q&A, codebase analysis |
| Task Creation | 1-3 minutes | Number of tasks |
| Dependency Resolution | <1 minute | Graph complexity |
| Task Execution | Hours to days | Task complexity, count, parallelism |
| Verification | 5-15 minutes | Number of tasks, integration tests |
| Finalization | 2-5 minutes | Roadmap size, summary generation |

### Optimization Opportunities

- **Planning**: Cache codebase analysis results
- **Task Creation**: Parallelize directory creation
- **Execution**: Maximize parallelism within dependencies
- **Verification**: Parallelize task verification reads

---

## Summary

This reference provides detailed workflows for all 6 phases of initiative orchestration. Each phase has:

✅ Clear objective and scope
✅ Defined inputs and outputs
✅ Step-by-step process pattern
✅ Decision points with options
✅ Auto-recovery strategies
✅ State management approach

For execution-specific patterns, see `execution-strategies.md`.
For dependency algorithms, see `dependency-resolution.md`.
For state coordination details, see `state-coordination.md`.
