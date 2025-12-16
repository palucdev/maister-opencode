---
name: ai-sdlc:enhancement:resume
description: Resume an interrupted or failed enhancement workflow (alias for /ai-sdlc:development:resume)
---

# Enhancement Workflow: Resume

**This command is an alias for the unified development resume workflow.**

Equivalent to: `/ai-sdlc:development:resume [task-path] [options]`

## Usage

```bash
/ai-sdlc:enhancement:resume [task-path] [--from=PHASE] [--reset-attempts]
```

### Arguments

- **task-path** (optional): Path to existing task directory
  - Example: `.ai-sdlc/tasks/enhancements/2025-01-15-add-sorting/`
  - If omitted, will search for recent incomplete tasks

### Options

- `--from=PHASE`: Override and start from specific phase
  - Values: `analysis`, `gap`, `spec`, `plan`, `implement`, `verify`
  - Default: Resume from last incomplete phase
- `--reset-attempts`: Reset auto-fix attempt counters
  - Use if stuck in retry loop

## Examples

```bash
# Resume most recent incomplete enhancement
/ai-sdlc:enhancement:resume

# Resume specific task
/ai-sdlc:enhancement:resume .ai-sdlc/tasks/enhancements/2025-01-15-add-sorting/

# Resume from specific phase
/ai-sdlc:enhancement:resume --from=implement

# Reset retry counters and resume
/ai-sdlc:enhancement:resume --reset-attempts
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
  task_type: enhancement
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
/ai-sdlc:development:resume .ai-sdlc/tasks/enhancements/2025-01-15-add-sorting/
```

---

**Invoke**: development-orchestrator skill in resume mode
