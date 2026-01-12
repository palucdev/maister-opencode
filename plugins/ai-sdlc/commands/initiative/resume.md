---
name: ai-sdlc:initiative:resume
description: Resume an interrupted or failed initiative workflow from where it left off
---

# Resume Initiative Workflow

Resume initiative execution from saved state after interruption, failure, or manual pause.

## Usage

```bash
/ai-sdlc:initiative:resume [initiative-path] [--from=phase] [--reset-attempts] [--clear-failures]
```

### Parameters

**`initiative-path`** (required): Path to initiative directory
- Example: `initiatives/2025-11-14-auth-system`
- Or: `.ai-sdlc/docs/project/initiatives/2025-11-14-auth-system`

**`--from=phase`** (optional): Override resume point
- Phases: `planning`, `task-creation`, `dependency-resolution`, `task-execution`, `verification`, `finalization`
- Default: Resume from `current_phase` in state file
- Use case: Restart from specific phase after manual adjustments

**`--reset-attempts`** (optional): Reset auto-fix attempt counters
- Useful if max attempts exceeded but issue is now fixed
- Allows orchestrator to retry failed phases

**`--clear-failures`** (optional): Clear failed task list
- Removes tasks from failed list
- Re-evaluates task status from metadata
- Use after manually fixing failed tasks

### Examples

**Basic resume** (from saved state):
```bash
/ai-sdlc:initiative:resume initiatives/2025-11-14-auth-system
```

**Resume from specific phase**:
```bash
/ai-sdlc:initiative:resume initiatives/2025-11-14-auth-system --from=task-execution
```

**Resume after fixing failures**:
```bash
/ai-sdlc:initiative:resume initiatives/2025-11-14-auth-system --clear-failures --reset-attempts
```

## How Resume Works

### 1. Load State

Reads `initiative-state.yml` from initiative directory:
- Current phase
- Completed phases
- Task status (completed, in-progress, blocked, failed)
- Execution progress
- Auto-fix attempt counts

### 2. Validate State

Checks state consistency:
- All referenced tasks exist
- Task counts match initiative.yml
- Current phase is valid
- No data corruption

### 3. Reconstruct if Needed

If state file missing or corrupted:
- Reads initiative.yml (source of truth)
- Polls all task orchestrator-state.yml files
- Reconstructs state from task statuses
- Determines current phase from progress
- Prompts user to confirm reconstructed state

### 4. Resume Execution

Continues from determined resume point:
- Respects execution mode (interactive/YOLO)
- Handles in-progress tasks appropriately
- Continues with remaining work

---

## What You Are Doing

**Invoke the initiative-orchestrator skill NOW in resume mode using the Skill tool.**

The skill will:
1. Load and validate `initiative-state.yml`
2. Determine resume point (from state or `--from` flag)
3. Handle in-progress/failed/blocked tasks
4. Continue orchestration from the determined phase
5. Execute remaining tasks sequentially via their respective orchestrator skills

---

## Resume Scenarios

### Scenario 1: Normal Interruption

**Situation**: Paused initiative, want to continue

**State**: All tasks accounted for, no failures

**Action**:
```bash
/ai-sdlc:initiative:resume initiatives/2025-11-14-name
```

**Result**: Continues from current phase

### Scenario 2: Task Failure

**Situation**: Task failed, initiative paused

**State**: One or more tasks in `failed` list

**Prompt**:
```
Task failed: api-implementation (task-2)
Phase: implementation
Error: 5 test failures

This task blocks: frontend-ui (task-3), integration-tests (task-4)
On critical path: Yes

Options:
1. I fixed it manually, mark as complete and continue
2. Skip task and continue (dependents will be blocked)
3. Retry task (will attempt again)
4. Abort

Choice: ___
```

**Option 1**: User fixed manually
- Checks task orchestrator-state.yml task.status
- If now "completed", moves to completed list
- Unblocks dependent tasks
- Continues execution

**Option 2**: Skip failed task
- Leaves in failed list
- Marks dependent tasks as blocked
- Continues with independent tasks

**Option 3**: Retry
- Re-runs task orchestrator
- Uses `--reset-attempts` flag internally

### Scenario 3: State File Lost

**Situation**: initiative-state.yml deleted or corrupted

**Action**:
```bash
/ai-sdlc:initiative:resume initiatives/2025-11-14-name
```

**Process**:
1. Detects missing state file
2. Reads initiative.yml
3. Polls all task orchestrator-state.yml files for status
4. Reconstructs state:
   - Completed: task.status == "completed"
   - In-progress: task.status == "in-progress"
   - Blocked: Dependencies not satisfied
   - Pending: Dependencies satisfied, not started
5. Determines current phase from progress
6. Shows reconstructed state:
   ```
   State file not found, reconstructed from task metadata:

   Tasks:
   - Completed: 3/10
   - In-progress: 1/10
   - Pending: 6/10

   Current phase: task-execution
   Resume from here? [Yes/No]
   ```

### Scenario 4: Manual Adjustments

**Situation**: User manually edited initiative.yml or task metadata

**Action**:
```bash
/ai-sdlc:initiative:resume initiatives/2025-11-14-name --from=dependency-resolution
```

**Process**:
- Skips to dependency-resolution phase
- Re-validates dependency graph
- Continues from there

## What Gets Resumed

### Phase: Task Execution

**In-Progress Tasks**:
- Checks status of each in-progress task
- If task orchestrator still running: Waits for completion
- If task completed: Moves to completed list
- If task failed: Handles failure (see above)

**Pending Tasks**:
- Checks dependencies
- If satisfied: Adds to execution queue
- If not: Keeps in pending/blocked

**Blocked Tasks**:
- Re-checks dependencies
- If now satisfied: Moves to pending
- If still not: Remains blocked

### Phase: Verification

**Already Verified**:
- Skips re-verification
- Uses existing reports

**Partial Verification**:
- Continues from where it left off

### Phase: Finalization

**Summary Created**:
- Updates with latest data

**Roadmap Not Updated**:
- Completes roadmap update

## Flags in Detail

### `--from=phase`

Override resume point, start from specific phase.

**Valid phases**:
- `planning`: Re-run initiative planning (creates new task breakdown)
- `task-creation`: Create task directories (if not yet created)
- `dependency-resolution`: Re-validate dependencies
- `task-execution`: Resume/restart task execution
- `verification`: Run verification
- `finalization`: Create summary and update roadmap

**Use cases**:
- Manual edits to initiative.yml → Use `--from=dependency-resolution`
- Want to re-verify → Use `--from=verification`
- Summary needs update → Use `--from=finalization`

### `--reset-attempts`

Reset auto-fix attempt counters to zero.

**Why needed**:
- Orchestrator tracks auto-fix attempts per phase
- After max attempts (usually 3), stops trying
- If you fixed issue manually, reset counter to allow retry

**Example**:
```yaml
# Before reset
auto_fix_attempts:
  task_execution: 3  # Max reached, won't retry

# After --reset-attempts
auto_fix_attempts:
  task_execution: 0  # Reset, can retry
```

### `--clear-failures`

Remove all tasks from `failed` list and re-evaluate.

**Process**:
1. Read current failed tasks list
2. For each failed task:
   - Read task orchestrator-state.yml task.status
   - If status == "completed": Move to completed
   - If status == "in-progress": Move to in-progress
   - If status == "failed": Keep in failed (not fixed yet)
3. Update state file

**Use after**:
- Manually fixing failed tasks
- Want to re-check task statuses

## Resume vs. Restart

### Resume (This Command)

- Continues from where it left off
- Preserves completed work
- Respects current state
- Faster (doesn't redo work)

### Restart (Manual)

- Delete initiative-state.yml
- Run `/ai-sdlc:initiative:new` with same description
- Starts from scratch
- Loses all progress

**When to restart**:
- Initiative planning was wrong (need different tasks)
- Want to completely redo
- State is hopelessly corrupted

**When to resume**:
- Normal interruption
- Task failure (can fix and continue)
- Partial completion
- Want to preserve progress

## State Validation

Before resuming, validates:

✅ initiative-state.yml exists or can be reconstructed
✅ All task paths in state point to existing task directories
✅ Task counts match between state and initiative.yml
✅ Current phase is valid
✅ No tasks in multiple status lists (pending AND completed, etc.)
✅ Dependencies are consistent

If validation fails:
- Shows specific error
- Suggests fixes
- May auto-fix minor issues
- Critical issues require manual intervention

## Common Resume Issues

### "State file corrupted"

**Cause**: initiative-state.yml has invalid YAML or data

**Fix**: Reconstruction attempted automatically. If fails, manually delete state file and retry (will reconstruct from tasks)

### "Task status mismatch"

**Cause**: Task orchestrator-state.yml shows different status than initiative-state.yml

**Fix**: Use `--clear-failures` to re-sync from task status (source of truth)

### "Cannot resume, missing tasks"

**Cause**: Task directories referenced in state don't exist

**Fix**: Check if tasks were deleted. If so, edit initiative.yml to remove them, then use `--from=dependency-resolution`

### "All tasks blocked"

**Cause**: Dependencies not satisfied, nothing can proceed

**Fix**: Check failed tasks. Fix failures or skip them to unblock dependents.

## Monitoring During Resume

Use status command to monitor:
```bash
/ai-sdlc:initiative:status initiatives/2025-11-14-name
```

Shows real-time:
- Current phase
- Tasks in progress
- Completion percentage
- Blocked tasks and why
- Estimated completion

## Related Commands

- **`/ai-sdlc:initiative:new`**: Start new initiative
- **`/ai-sdlc:initiative:status`**: Check progress
- **`/ai-sdlc:feature:resume`**: Resume single task (not initiative)

---

Invoke the **initiative-orchestrator** skill in resume mode to continue your initiative from where it left off, with dependency enforcement and sequential task coordination.
