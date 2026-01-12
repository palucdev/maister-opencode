# State Coordination Reference

## Overview

Initiative orchestration requires coordinating state across multiple files: initiative-level state, individual task states, and task metadata. This reference covers file-based state management patterns, conflict detection, and resume capability.

## State File Hierarchy

```
.ai-sdlc/
├── docs/project/initiatives/YYYY-MM-DD-name/
│   ├── initiative.yml              (IMMUTABLE: source of truth)
│   ├── initiative-state.yml        (MUTABLE: execution state)
│   ├── spec.md                     (IMMUTABLE after planning)
│   └── task-plan.md                (IMMUTABLE after planning)
│
└── tasks/[type]/YYYY-MM-DD-task-name/
    └── orchestrator-state.yml      (MUTABLE: execution + metadata)
```

**Note**: Task metadata (title, description, status, dependencies, etc.) is stored in the `task:` section of `orchestrator-state.yml`. No separate `metadata.yml` file is needed.

### State Ownership

| File | Owner | Read By | Write By |
|------|-------|---------|----------|
| initiative.yml | Initiative planner | Initiative orchestrator, Tasks | Initiative planner only |
| initiative-state.yml | Initiative orchestrator | Initiative orchestrator | Initiative orchestrator only |
| task orchestrator-state.yml | Task orchestrator | Initiative orchestrator (poll) | Task orchestrator only |

**Key Principle**: Each file has single writer, multiple readers → No write conflicts

**Note**: Task metadata is in the `task:` section of `orchestrator-state.yml`, so initiative orchestrator reads both execution state and metadata from a single file.

---

## Initiative State File (initiative-state.yml)

### Purpose

Track initiative-level execution progress, task statuses, and coordination state.

### Full Structure

```yaml
meta:
  last_updated: "2025-11-14T15:30:45Z"  # ISO 8601 timestamp
  version: 1                             # Schema version
  state_file_version: 3                  # Increments on each write

orchestrator:
  mode: interactive|yolo
  current_phase: planning|task-creation|dependency-resolution|task-execution|initiative-verification|finalization|completed
  completed_phases: [planning, task-creation]
  failed_phases: []
  execution_strategy: sequential

  auto_fix_attempts:
    planning: 0
    task_creation: 0
    dependency_resolution: 0
    task_execution: 2
    verification: 0
    finalization: 0

tasks:
  pending: [task-id-4, task-id-5]      # Ready to execute
  in_progress: [task-id-3]             # Currently executing
  completed: [task-id-1, task-id-2]    # Finished successfully
  blocked: [task-id-6, task-id-7]      # Waiting for dependencies
  failed: []                            # Failed and not recovered

  details:
    task-id-1:
      path: .ai-sdlc/tasks/new-features/2025-11-14-auth
      type: new-feature
      status: completed
      dependencies: []
      blocks: [task-id-3]
      started: "2025-11-14T10:00:00Z"
      completed: "2025-11-14T14:30:00Z"
      estimated_hours: 40
      actual_hours: 35
      orchestrator_phase: completed    # Last known phase of task orchestrator

    task-id-3:
      path: .ai-sdlc/tasks/enhancements/2025-11-14-sso
      type: enhancement
      status: in-progress
      dependencies: [task-id-1]
      blocks: [task-id-6]
      started: "2025-11-14T15:00:00Z"
      completed: null
      estimated_hours: 50
      actual_hours: 0
      orchestrator_phase: implementation  # Currently in implementation

execution:
  queue: [task-id-4, task-id-5, task-id-6, task-id-7]  # Tasks waiting to execute
  queue_position: 3                                     # Current position in overall queue
  current_task: task-id-3                              # Currently executing task
  total_levels: 4
  levels:
    level-0: [task-id-1, task-id-2]
    level-1: [task-id-3]
    level-2: [task-id-4, task-id-5]
    level-3: [task-id-6, task-id-7]
  critical_path: [task-id-1, task-id-3, task-id-6]
  critical_path_hours: 120

progress:
  total_tasks: 7
  completed: 2
  in_progress: 1
  blocked: 2
  failed: 0
  pending: 2
  percent: 28  # (completed / total * 100)

  estimated_hours: 240
  actual_hours: 35
  remaining_hours: 205

coordination:
  current_task: task-id-3
  last_updated: "2025-11-14T15:30:00Z"

timestamps:
  created: "2025-11-14T09:00:00Z"
  started: "2025-11-14T10:00:00Z"
  completed: null
  last_activity: "2025-11-14T15:30:45Z"

phase_results:
  planning:
    initiative_path: initiatives/2025-11-14-auth-system
    task_count: 7
    estimated_hours: 240
    strategy: sequential
    milestones: ["Foundation", "Core Features", "Production"]
    completed_at: "2025-11-14T09:45:00Z"

  task_creation:
    tasks_created: 7
    task_types: {new-feature: 4, enhancement: 2, migration: 1}
    completed_at: "2025-11-14T09:50:00Z"

  dependency_resolution:
    total_levels: 4
    critical_path_hours: 120
    validation: passed
    completed_at: "2025-11-14T09:55:00Z"

  task_execution:
    current_level: 1
    levels_completed: 1
    tasks_completed: 2
    tasks_in_progress: 1
    tasks_failed: 0
    total_hours_so_far: 35
```

### State File Operations

#### Read State

```python
def read_initiative_state(initiative_path):
    state_file = f"{initiative_path}/initiative-state.yml"

    if not file_exists(state_file):
        return None  # Not yet initialized

    content = read_file(state_file)
    state = parse_yaml(content)

    return state
```

#### Write State

```python
def write_initiative_state(initiative_path, state):
    state_file = f"{initiative_path}/initiative-state.yml"

    # Update meta information
    state['meta']['last_updated'] = current_iso_timestamp()
    state['meta']['state_file_version'] += 1

    # Update timestamps
    state['timestamps']['last_activity'] = current_iso_timestamp()

    # Write atomically
    write_yaml_atomic(state_file, state)
```

#### Atomic Write Pattern

```python
def write_yaml_atomic(file_path, data):
    """Write YAML atomically to prevent corruption"""

    temp_file = f"{file_path}.tmp"

    # Write to temp file
    write_file(temp_file, yaml.dump(data))

    # Atomic rename (overwrites existing)
    rename(temp_file, file_path)

    # Now file_path has new content, no partial writes
```

---

## Conflict Detection and Resolution

### Timestamp-Based Detection

**Problem**: Multiple processes updating same state file simultaneously

**Solution**: Timestamp-based optimistic locking

#### Write with Conflict Detection

```python
def write_state_with_conflict_detection(initiative_path, updater_func):
    max_retries = 3

    for attempt in range(max_retries):
        # Read current state
        current_state = read_initiative_state(initiative_path)
        last_updated = current_state['meta']['last_updated']

        # Apply updates via callback
        new_state = updater_func(current_state)

        # Re-read to check if changed
        check_state = read_initiative_state(initiative_path)

        if check_state['meta']['last_updated'] != last_updated:
            # CONFLICT: State changed between read and write
            log_warning(f"State conflict detected (attempt {attempt+1})")

            if attempt < max_retries - 1:
                sleep(random(0.5, 1.5))  # Random backoff
                continue  # Retry
            else:
                raise StateConflictError("Max retries exceeded")

        # No conflict, safe to write
        write_initiative_state(initiative_path, new_state)
        return

Usage:
    def update_task_completion(state):
        state['tasks']['completed'].append('task-id-3')
        state['tasks']['in_progress'].remove('task-id-3')
        state['progress']['completed'] += 1
        return state

    write_state_with_conflict_detection(initiative_path, update_task_completion)
```

### Conflict Scenarios

#### Scenario 1: Two Tasks Complete Simultaneously

```
Time 0:
  State: in_progress: [task-A, task-B]

Time 1:
  Task A orchestrator: Read state, detect A complete
  Task B orchestrator: Read state, detect B complete

Time 2:
  Task A orchestrator: Write state (move A to completed)
  Task B orchestrator: Write state (move B to completed)
  ❌ Second write overwrites first (B completion recorded, A lost)

Prevention:
  - Initiative orchestrator polls (doesn't rely on task orchestrators writing)
  - Task orchestrators only write to their own state files
  - Initiative orchestrator reads both, updates initiative-state atomically
```

#### Scenario 2: User Manual Edit During Execution

```
Time 0:
  Initiative orchestrator executing

Time 1:
  User manually edits initiative-state.yml

Time 2:
  Initiative orchestrator writes update
  ❌ Overwrites user's manual edit

Detection:
  - Timestamp check detects conflict
  - Prompt user to retry or merge manually

Prevention:
  - Warn users not to edit state during execution
  - Use /initiative:status to view, don't edit state directly
```

---

## Cross-File State Coordination

### Polling Pattern (Task Completion Detection)

**Objective**: Detect when task orchestrator completes without task writing to initiative-state

**Pattern**:

```python
def poll_task_status(task_path):
    """Poll task orchestrator-state.yml for completion"""

    orchestrator_state_file = f"{task_path}/orchestrator-state.yml"

    if not file_exists(orchestrator_state_file):
        return "not-started"

    state = read_yaml(orchestrator_state_file)

    # Check current phase
    current_phase = state['orchestrator']['current_phase']

    if current_phase == "completed":
        return "completed"

    # Check failed phases
    if len(state['orchestrator']['failed_phases']) > 0:
        return "failed"

    # Check completed phases count (all phases done)
    total_phases = get_expected_phases_for_task_type(state['task_type'])
    completed_count = len(state['orchestrator']['completed_phases'])

    if completed_count == total_phases:
        return "completed"

    return "in-progress"


def poll_all_in_progress_tasks(initiative_state):
    """Poll all in-progress tasks, update initiative state"""

    updates = []

    for task_id in initiative_state['tasks']['in_progress']:
        task_details = initiative_state['tasks']['details'][task_id]
        task_path = task_details['path']

        status = poll_task_status(task_path)

        if status == "completed":
            updates.append({
                'task_id': task_id,
                'action': 'move_to_completed'
            })

        elif status == "failed":
            updates.append({
                'task_id': task_id,
                'action': 'move_to_failed'
            })

    # Apply all updates atomically
    if len(updates) > 0:
        apply_task_status_updates(initiative_state, updates)
```

### Sequential Execution Loop

```python
def task_execution_loop(initiative_path):
    """Main execution loop for sequential task execution"""

    while True:
        state = read_initiative_state(initiative_path)

        # Check if any tasks remaining
        if len(state['execution']['queue']) == 0:
            break  # All tasks complete

        # Get next task from queue
        next_task = state['execution']['queue'][0]

        # Verify dependencies satisfied
        if not dependencies_satisfied(next_task, state):
            # Move to blocked, try next task
            move_to_blocked(next_task, state)
            continue

        # Mark as in-progress
        state['tasks']['in_progress'] = [next_task]
        state['execution']['current_task'] = next_task
        write_initiative_state(initiative_path, state)

        # Invoke task orchestrator via Skill tool (synchronous)
        # Use Skill tool with: skill=[type]-orchestrator
        result = invoke_task_orchestrator(next_task)

        # Update state based on result
        if result.success:
            move_to_completed(next_task, state)
            check_unblocked_tasks(state)
        else:
            handle_failure(next_task, state, result)

        write_initiative_state(initiative_path, state)
```

---

## Task Metadata Coordination

Task metadata is stored in the `task:` section of `orchestrator-state.yml` (unified state file).

### Task Metadata Fields

```yaml
# In tasks/[type]/YYYY-MM-DD-name/orchestrator-state.yml

orchestrator:
  # ... execution state fields ...

task:
  title: Task Name
  description: Full task description
  type: new-feature
  status: pending|in-progress|completed|blocked|failed

  # Initiative coordination
  initiative_id: YYYY-MM-DD-initiative-name
  dependencies: [.ai-sdlc/tasks/new-features/YYYY-MM-DD-auth]
  blocks: [task-id-5, task-id-6]
  milestone: Foundation

  # Optional metadata
  tags: []
  priority: high

  # Hours tracking
  estimated_hours: 40
  actual_hours: 35
```

### Reading Task Metadata

```python
def read_task_state(task_path):
    state_file = f"{task_path}/orchestrator-state.yml"
    return read_yaml(state_file)


def get_task_metadata(task_path):
    state = read_task_state(task_path)
    return state.get('task', {})


def get_task_actual_hours(task_path):
    metadata = get_task_metadata(task_path)
    return metadata.get('actual_hours', 0)


def is_task_complete(task_path):
    metadata = get_task_metadata(task_path)
    return metadata.get('status') == 'completed'
```

### Writing Task Metadata (Task Orchestrator Only)

```python
def update_task_status(task_path, new_status, actual_hours=None):
    """Called by task orchestrator on completion"""

    state = read_task_state(task_path)

    state['task']['status'] = new_status
    state['orchestrator']['updated'] = current_iso_timestamp()

    if actual_hours is not None:
        state['task']['actual_hours'] = actual_hours

    write_yaml(f"{task_path}/orchestrator-state.yml", state)
```

---

## State Reconstruction

### When Needed

- initiative-state.yml corrupted or deleted
- State file version mismatch
- Resume after long interruption
- Recover from system crash

### Reconstruction Algorithm

```python
def reconstruct_initiative_state(initiative_path):
    """Rebuild initiative-state.yml from source files"""

    # Read source of truth
    initiative = read_yaml(f"{initiative_path}/initiative.yml")

    # Initialize new state
    state = {
        'meta': {
            'last_updated': current_iso_timestamp(),
            'version': 1,
            'state_file_version': 1
        },
        'orchestrator': {
            'mode': 'interactive',  # Default, may ask user
            'current_phase': None,  # Determine below
            'completed_phases': [],
            'failed_phases': [],
            'execution_strategy': initiative['execution']['strategy']
        },
        'tasks': {
            'pending': [],
            'in_progress': [],
            'completed': [],
            'blocked': [],
            'failed': [],
            'details': {}
        },
        # ... other sections
    }

    # Reconstruct task states from task orchestrator-state.yml
    for task in initiative['tasks']:
        task_id = task['id']
        task_path = task['path']

        # Read task metadata from orchestrator-state.yml
        task_metadata = get_task_metadata(task_path)
        task_status = task_metadata.get('status', 'pending')

        # Categorize task
        state['tasks'][task_status].append(task_id)

        # Fill in details
        state['tasks']['details'][task_id] = {
            'path': task_path,
            'type': task['type'],
            'status': task_status,
            'dependencies': task['dependencies'],
            'blocks': task.get('blocks', []),
            'estimated_hours': task['estimated_hours'],
            'actual_hours': task_metadata.get('actual_hours', 0)
        }

    # Determine current phase from task states
    total_tasks = len(initiative['tasks'])
    completed_count = len(state['tasks']['completed'])

    if completed_count == 0:
        # No tasks started
        if task_directories_exist(initiative['tasks']):
            state['orchestrator']['current_phase'] = 'dependency-resolution'
            state['orchestrator']['completed_phases'] = ['planning', 'task-creation']
        else:
            state['orchestrator']['current_phase'] = 'task-creation'
            state['orchestrator']['completed_phases'] = ['planning']

    elif completed_count == total_tasks:
        # All complete
        state['orchestrator']['current_phase'] = 'finalization'
        state['orchestrator']['completed_phases'] = [
            'planning', 'task-creation', 'dependency-resolution',
            'task-execution', 'initiative-verification'
        ]

    else:
        # Some tasks in progress
        state['orchestrator']['current_phase'] = 'task-execution'
        state['orchestrator']['completed_phases'] = [
            'planning', 'task-creation', 'dependency-resolution'
        ]

    # Rebuild execution groups (from dependency graph)
    state['execution'] = rebuild_execution_groups(initiative)

    # Recalculate progress
    state['progress'] = calculate_progress(state['tasks'])

    # Save reconstructed state
    write_initiative_state(initiative_path, state)

    return state
```

### Validation After Reconstruction

```python
def validate_reconstructed_state(state, initiative):
    """Verify reconstructed state is valid"""

    checks = []

    # Check task count matches
    total_in_state = sum([
        len(state['tasks']['pending']),
        len(state['tasks']['in_progress']),
        len(state['tasks']['completed']),
        len(state['tasks']['blocked']),
        len(state['tasks']['failed'])
    ])

    checks.append(total_in_state == len(initiative['tasks']))

    # Check all task IDs valid
    all_task_ids = set([t['id'] for t in initiative['tasks']])
    state_task_ids = set(state['tasks']['details'].keys())

    checks.append(all_task_ids == state_task_ids)

    # Check current phase valid
    valid_phases = ['planning', 'task-creation', 'dependency-resolution',
                    'task-execution', 'initiative-verification', 'finalization', 'completed']

    checks.append(state['orchestrator']['current_phase'] in valid_phases)

    return all(checks)
```

---

## Resume Capability

### Resume from Saved State

```python
def resume_initiative(initiative_path, from_phase=None):
    """Resume initiative execution from saved state"""

    # Read current state
    state = read_initiative_state(initiative_path)

    if state is None:
        # No state file, try reconstruction
        log_info("State file not found, attempting reconstruction")
        state = reconstruct_initiative_state(initiative_path)

    # Validate state
    initiative = read_yaml(f"{initiative_path}/initiative.yml")
    if not validate_reconstructed_state(state, initiative):
        raise StateValidationError("State validation failed")

    # Determine resume point
    if from_phase is not None:
        # User override
        resume_phase = from_phase
    else:
        # Resume from current_phase
        resume_phase = state['orchestrator']['current_phase']

    # Check if already complete
    if resume_phase == 'completed':
        log_info("Initiative already completed")
        show_summary(initiative_path)
        return

    # Resume execution
    log_info(f"Resuming from phase: {resume_phase}")
    execute_from_phase(initiative_path, state, resume_phase)
```

### Resume After Failure

```python
def resume_after_failure(initiative_path):
    """Resume initiative after task failure"""

    state = read_initiative_state(initiative_path)

    # Check for failed tasks
    if len(state['tasks']['failed']) == 0:
        log_info("No failed tasks, resuming normally")
        resume_initiative(initiative_path)
        return

    # Analyze failures
    for task_id in state['tasks']['failed']:
        task_details = state['tasks']['details'][task_id]

        print(f"Task failed: {task_id}")
        print(f"  Path: {task_details['path']}")
        print(f"  Type: {task_details['type']}")

        # Check if user fixed it
        current_status = get_task_metadata(task_details['path']).get('status')

        if current_status == 'completed':
            # User fixed it!
            print(f"  ✓ Now shows as completed, will move to completed list")

            # Move from failed to completed
            state['tasks']['failed'].remove(task_id)
            state['tasks']['completed'].append(task_id)
            state['tasks']['details'][task_id]['status'] = 'completed'

        else:
            # Still failed
            print(f"  ✗ Still failed")

            # Prompt user
            action = ask_user("Skip this task and continue? (yes/no): ")

            if action == "yes":
                # Leave in failed, mark dependent tasks as blocked
                block_dependent_tasks(state, task_id)
            else:
                print("Please fix the task and run /initiative:resume again")
                return

    # Save updated state
    write_initiative_state(initiative_path, state)

    # Resume from task-execution
    execute_from_phase(initiative_path, state, 'task-execution')
```

---

## State Consistency Guarantees

### Invariants

Always true assertions about state:

```python
def check_state_invariants(state):
    """Verify state consistency"""

    # All tasks in exactly one status list
    all_tasks = (
        set(state['tasks']['pending']) |
        set(state['tasks']['in_progress']) |
        set(state['tasks']['completed']) |
        set(state['tasks']['blocked']) |
        set(state['tasks']['failed'])
    )

    assert len(all_tasks) == state['progress']['total_tasks']

    # No task in multiple lists
    for status1 in ['pending', 'in_progress', 'completed', 'blocked', 'failed']:
        for status2 in ['pending', 'in_progress', 'completed', 'blocked', 'failed']:
            if status1 != status2:
                assert len(set(state['tasks'][status1]) & set(state['tasks'][status2])) == 0

    # Progress metrics match
    assert state['progress']['completed'] == len(state['tasks']['completed'])
    assert state['progress']['in_progress'] == len(state['tasks']['in_progress'])

    # Timestamps logical
    if state['timestamps']['completed'] is not None:
        assert state['timestamps']['completed'] >= state['timestamps']['started']

    # All in-progress tasks have dependencies satisfied (or are Level 0)
    for task_id in state['tasks']['in_progress']:
        dependencies = state['tasks']['details'][task_id]['dependencies']
        for dep_path in dependencies:
            # Find dependency task ID
            dep_id = find_task_id_by_path(state, dep_path)
            assert dep_id in state['tasks']['completed']  # Dependency must be complete

    return True
```

### Validation on Every Write

```python
def write_initiative_state_with_validation(initiative_path, state):
    """Write state with consistency checks"""

    # Check invariants before writing
    try:
        check_state_invariants(state)
    except AssertionError as e:
        log_error(f"State inconsistency detected: {e}")
        raise StateConsistencyError(f"Cannot write invalid state: {e}")

    # Write
    write_initiative_state(initiative_path, state)
```

---

## Performance Considerations

### State File Size

Typical initiative (10 tasks):
- initiative-state.yml: ~5-10 KB
- Not a performance concern

Large initiative (50 tasks):
- initiative-state.yml: ~20-50 KB
- Still fast to read/write (<100ms)

### Polling Overhead

Poll interval: 30 seconds
Operations per poll: Read N task orchestrator-state.yml files (N = in-progress tasks)

Overhead:
- 3 tasks in progress: 3 file reads every 30s = minimal
- 10 tasks in progress (unlikely): 10 file reads = still minimal

Optimization:
- Use file modification time to skip unchanged files
- Adjust poll interval based on task count

### Conflict Resolution Cost

Retry with backoff: 0.5-1.5 second delay
Max 3 retries: ~3-4 seconds worst case
Rare occurrence (only if concurrent updates)

---

## Summary

State coordination in initiative orchestration:

**Key Principles**:
- Single writer per file (no write conflicts)
- Polling for cross-file coordination
- Timestamp-based conflict detection
- Atomic writes (temp file + rename)
- State reconstruction from source files

**State Files**:
- `initiative-state.yml`: Initiative orchestrator owns
- `orchestrator-state.yml`: Task orchestrator owns (includes task metadata in `task:` section)

**Coordination Pattern**:
- Initiative orchestrator polls task states
- Detects completion via orchestrator-state.yml
- Updates initiative-state.yml atomically
- No circular dependencies in state updates

**Resume Capability**:
- Read saved state file
- Validate consistency
- Reconstruct if corrupted
- Resume from current phase

For phase workflows, see `phases.md`.
For execution patterns, see `execution-strategies.md`.
