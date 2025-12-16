---
name: ai-sdlc:development:resume
description: Resume an interrupted or failed development workflow from where it left off
---

# Development Workflow: Resume

Resume an interrupted development workflow (bug fix, enhancement, or new feature) from where it left off.

## Usage

```bash
/ai-sdlc:development:resume [task-path] [--from=PHASE] [--reset-attempts]
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
# Resume most recent incomplete task
/ai-sdlc:development:resume

# Resume specific task
/ai-sdlc:development:resume .ai-sdlc/tasks/enhancements/2025-01-15-add-sorting/

# Resume from specific phase (skip completed work)
/ai-sdlc:development:resume --from=implement

# Reset retry counters and resume
/ai-sdlc:development:resume --reset-attempts
```

## What This Does

**Invoke the development-orchestrator skill** in resume mode, which:
1. Locates the task and reads `orchestrator-state.yml`
2. Validates artifacts for completed phases (see Expected Artifacts table in skill)
3. Removes phases from completed list if artifacts are missing
4. Resumes from first incomplete or artifact-missing phase
5. Continues normal phase execution

## How Resume Works

The development-orchestrator skill handles resume with artifact validation:

1. **Locate task**: Find orchestrator-state.yml in task directory
2. **Read state**: Determine task type, completed phases, current phase
3. **Validate artifacts**: Check expected files exist for each completed phase
4. **Re-run if missing**: Remove phases from completed list if artifacts missing
5. **Continue execution**: Pick up from first incomplete phase

## State File

Resume uses `orchestrator-state.yml` to track progress:

```yaml
orchestrator:
  task_type: bug | enhancement | feature
  mode: interactive | yolo
  current_phase: implementation
  completed_phases:
    - codebase_analysis
    - gap_analysis
    - tdd_red           # Bug only
    - specification
    - planning
  failed_phases: []
  auto_fix_attempts:
    implementation: 2   # Shows 2 attempts made
```

## Common Resume Scenarios

### After Context Loss
```bash
# Session ended mid-implementation
/ai-sdlc:development:resume
# → Resumes implementation from last step
```

### After Auto-Fix Exhaustion
```bash
# Hit max retry attempts
/ai-sdlc:development:resume --reset-attempts
# → Reset counters, try again
```

### Skip to Later Phase
```bash
# Manual spec edits made, skip re-generation
/ai-sdlc:development:resume --from=plan
# → Validate spec exists, proceed to planning
```

### After TDD Red Gate Issue (Bug Fix)
```bash
# TDD test needed adjustment
/ai-sdlc:development:resume --from=tdd-red
# → Rewrite failing test, continue
```

## Prerequisites by Phase

| Resume Point | Phase # | Required Files |
|--------------|---------|----------------|
| `analysis` | 1 | None (starting point) |
| `gap` | 2 | `analysis/codebase-analysis.md` |
| `tdd-red` | 3 | `analysis/gap-analysis.md` (bug only) |
| `spec` | 5 | `analysis/gap-analysis.md` |
| `plan` | 7 | `implementation/spec.md` |
| `implement` | 8 | `implementation/spec.md`, `implementation/implementation-plan.md` |
| `tdd-green` | 9 | `implementation/tdd-red-gate.md` (bug only) |
| `verify` | 11 | Implementation complete |

## Error Handling

**Missing prerequisites**:
```
❌ Cannot resume from [phase] - missing prerequisites!

Required files:
- implementation/spec.md: ❌ Missing
- implementation/implementation-plan.md: ✅ Found

Options:
1. Start from earlier phase (spec)
2. Create missing files manually
3. Use different --from value
```

**Corrupted state**:
```
⚠️ State file corrupted or missing

Reconstructing from artifacts...
Found: codebase-analysis.md, gap-analysis.md, spec.md
Inferred phase: planning

Continue from planning phase? [Y/n]
```

## Replaces Old Commands

This unified command replaces:
- `/ai-sdlc:bug-fix:resume`
- `/ai-sdlc:enhancement:resume`
- `/ai-sdlc:feature:resume`

Old commands still work as aliases.
