---
name: ai-sdlc:bug-fix:resume
description: Resume an interrupted or failed bug fix workflow (alias for /ai-sdlc:development:resume)
---

# Resume Bug Fix Workflow

**This command is an alias for the unified development resume workflow.**

Equivalent to: `/ai-sdlc:development:resume [task-path] [options]`

## Usage

```bash
/ai-sdlc:bug-fix:resume [task-path] [--from=PHASE] [--reset-attempts]
```

### Arguments

- **task-path** (optional): Path to existing task directory
  - Example: `.ai-sdlc/tasks/bug-fixes/2025-01-15-fix-login/`
  - If omitted, will search for recent incomplete tasks

### Options

- `--from=PHASE`: Override and start from specific phase
  - Values: `analysis`, `gap`, `tdd-red`, `spec`, `plan`, `implement`, `tdd-green`, `verify`
  - Default: Resume from last incomplete phase
- `--reset-attempts`: Reset auto-fix attempt counters
  - Use if stuck in retry loop

## Examples

```bash
# Resume most recent incomplete bug fix
/ai-sdlc:bug-fix:resume

# Resume specific task
/ai-sdlc:bug-fix:resume .ai-sdlc/tasks/bug-fixes/2025-01-15-fix-login-timeout/

# Resume from specific phase (skip completed work)
/ai-sdlc:bug-fix:resume --from=implement

# Reset retry counters and resume
/ai-sdlc:bug-fix:resume --reset-attempts
```

## How Resume Works

1. **Locate task**: Find orchestrator-state.yml in task directory
2. **Read state**: Determine completed phases, current phase
3. **Validate prerequisites**: Ensure required files exist for resume point
4. **Continue execution**: Pick up from last incomplete phase

## State File

Resume uses `orchestrator-state.yml` to track progress:

```yaml
orchestrator:
  task_type: bug
  mode: interactive | yolo
  current_phase: implementation
  completed_phases:
    - codebase_analysis
    - gap_analysis
    - tdd_red
    - specification
    - planning
  failed_phases: []
  auto_fix_attempts:
    implementation: 2   # Shows 2 attempts made
```

## TDD Gate Validation

For bug fixes, the TDD gates are mandatory:
- **TDD Red Gate** (Phase 1.5): Test must FAIL before fix
- **TDD Green Gate** (Phase 5.5): Test must PASS after fix

Resume will validate these gates were properly completed.

## Alternative

You can also use the unified resume command:
```bash
/ai-sdlc:development:resume .ai-sdlc/tasks/bug-fixes/2025-01-15-fix-login/
```

---

**Invoke**: development-orchestrator skill in resume mode
