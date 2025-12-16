---
name: ai-sdlc:bug-fix:new
description: Start a comprehensive bug fixing workflow (alias for /ai-sdlc:development:new --type=bug)
---

# Bug Fix Workflow: New

**This command is an alias for the unified development workflow.**

Equivalent to: `/ai-sdlc:development:new [descript
ion] --type=bug [options]`

## Usage
why 
```bash
/ai-sdlc:bug-fix:new [description] [--yolo] [--from=PHASE]
```

### Arguments

- **description** (optional): Brief description of the bug
  - Example: "Fix login timeout with special characters"
  - If omitted, you'll be prompted

### Options

- `--yolo`: Run in YOLO mode (continuous without pauses)
  - Default: Interactive mode (pause between phases)
  - Note: TDD gates still enforced
- `--from=PHASE`: Start from specific phase
  - Values: `analysis`, `gap`, `tdd-red`, `spec`, `plan`, `implement`, `tdd-green`, `verify`
  - Default: `analysis`

## Examples

```bash
# Interactive mode (default)
/ai-sdlc:bug-fix:new "Fix login timeout with special characters"

# YOLO mode (fast execution)
/ai-sdlc:bug-fix:new "Null pointer in profile page" --yolo

# Resume from specific phase
/ai-sdlc:bug-fix:new --from=implement
```

## What This Does

Routes to `development-orchestrator` skill with `task_type=bug`, which includes:

- **Phase 0**: Codebase Analysis (3 parallel Explore agents)
- **Phase 1**: Gap Analysis (buggy vs correct behavior)
- **Phase 1.5**: TDD Red Gate (write failing test - MANDATORY)
- **Phase 3**: Specification
- **Phase 4**: Implementation Planning
- **Phase 5**: Implementation
- **Phase 5.5**: TDD Green Gate (verify test passes - MANDATORY)
- **Phase 7**: Verification

## TDD Discipline

**Critical**: The orchestrator enforces TDD Red-Green:
1. Test must FAIL before fix (proves test catches the bug)
2. Test must PASS after fix (proves fix works)

If test passes before fix, the test doesn't reproduce the bug - check reproduction data.

## Outputs

Task directory: `.ai-sdlc/tasks/bug-fixes/YYYY-MM-DD-name/`

## Resume

If interrupted:
```bash
/ai-sdlc:bug-fix:resume .ai-sdlc/tasks/bug-fixes/2025-10-27-fix-login-timeout
```

Or use the unified command:
```bash
/ai-sdlc:development:resume .ai-sdlc/tasks/bug-fixes/2025-10-27-fix-login-timeout
```

---

**Invoke**: development-orchestrator skill with task_type=bug
