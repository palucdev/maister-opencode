---
name: ai-sdlc:feature:resume
description: Resume an interrupted or failed feature development workflow (alias for /ai-sdlc:development:resume)
---

# Resume Feature Development Workflow

**This command is an alias for the unified development resume workflow.**

Equivalent to: `/ai-sdlc:development:resume [task-path] [options]`

## Usage

```bash
/ai-sdlc:feature:resume [task-path] [--from=PHASE] [--reset-attempts]
```

### Arguments

- **task-path** (optional): Path to existing task directory
  - Example: `.ai-sdlc/tasks/new-features/2025-01-15-user-auth/`
  - If omitted, will search for recent incomplete tasks

### Options

- `--from=PHASE`: Override and start from specific phase
  - Values: `analysis`, `gap`, `spec`, `plan`, `implement`, `verify`
  - Default: Resume from last incomplete phase
- `--reset-attempts`: Reset auto-fix attempt counters
  - Use if stuck in retry loop

## Examples

```bash
# Resume most recent incomplete feature
/ai-sdlc:feature:resume

# Resume specific task
/ai-sdlc:feature:resume .ai-sdlc/tasks/new-features/2025-01-15-user-auth/

# Resume from specific phase
/ai-sdlc:feature:resume --from=implement

# Reset retry counters and resume
/ai-sdlc:feature:resume --reset-attempts
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
  task_type: feature
  mode: interactive | yolo
  current_phase: implementation
  completed_phases:
    - codebase_analysis
    - gap_analysis
    - specification
    - planning
  failed_phases: []
  auto_fix_attempts:
    implementation: 2
```

## Prerequisites by Phase

| Resume Point | Required Files |
|--------------|----------------|
| `gap` | `analysis/codebase-analysis.md` |
| `spec` | `analysis/gap-analysis.md` |
| `plan` | `implementation/spec.md` |
| `implement` | `implementation/spec.md`, `implementation/implementation-plan.md` |
| `verify` | Implementation complete |

## Alternative

You can also use the unified resume command:
```bash
/ai-sdlc:development:resume .ai-sdlc/tasks/new-features/2025-01-15-user-auth/
```

---

**Invoke**: development-orchestrator skill in resume mode
