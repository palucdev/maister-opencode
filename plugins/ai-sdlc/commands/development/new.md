---
name: ai-sdlc:development:new
description: Start a new development workflow (bug fix, enhancement, or new feature) with unified orchestration through all phases
---

# Development Workflow: New

**IMMEDIATE ACTION REQUIRED**: Invoke the development-orchestrator skill NOW:

```
Use Skill tool:
  skill: "ai-sdlc:development-orchestrator"
```

Do NOT proceed manually. The skill handles the entire workflow.

---

Start any development task from codebase analysis through implementation to verified code. Automatically detects task type or accepts explicit override.

## Usage

```bash
/ai-sdlc:development:new [description] [--type=TYPE] [--yolo] [--from=PHASE] [--e2e] [--user-docs]
```

### Arguments

- **description** (optional): Task to implement
  - Example: "Fix login timeout bug"
  - Example: "Add sorting to user table"
  - Example: "Build new dashboard widget"
  - If omitted, you'll be prompted

### Options

- `--type=TYPE`: Explicitly set task type
  - Values: `bug`, `enhancement`, `feature`
  - Default: Auto-detected from description
- `--yolo`: Run in YOLO mode (continuous without pauses)
  - Default: Interactive mode (pause between phases)
  - Note: TDD gates still enforced for bugs
- `--from=PHASE`: Start from specific phase
  - Values: `analysis`, `gap`, `spec`, `plan`, `implement`, `verify`
  - Default: `analysis`
- `--e2e` / `--no-e2e`: Force enable/skip E2E testing
- `--user-docs` / `--no-user-docs`: Force enable/skip user documentation
- `--code-review` / `--no-code-review`: Force enable/skip code review

## Examples

```bash
# Auto-detect task type (interactive mode)
/ai-sdlc:development:new "Fix crash when clicking submit"
# → Detected as bug fix

/ai-sdlc:development:new "Add export button to user table"
# → Detected as enhancement

/ai-sdlc:development:new "Build notification system"
# → Detected as new feature

# Explicit type override
/ai-sdlc:development:new "Update login flow" --type=enhancement

# YOLO mode (fast execution)
/ai-sdlc:development:new "Fix typo in header" --type=bug --yolo

# With optional phases enabled
/ai-sdlc:development:new "Build dashboard filters" --e2e --user-docs

# Resume from specific phase
/ai-sdlc:development:new --from=implement
```

## What This Does

**Invoke the development-orchestrator skill** which guides through unified phases:

### All Task Types

| Phase | Name | Description |
|-------|------|-------------|
| 1 | **Codebase Analysis** | 3 parallel Explore agents analyze code |
| 2 | **Gap Analysis** | Compare current vs desired state |
| 5 | **Specification** | Create task specification |
| 6 | **Spec Audit** | Verify spec completeness |
| 7 | **Planning** | Break into implementation steps |
| 8 | **Implementation** | Execute plan with standards |
| 11 | **Verification** | Full verification (tests, standards, code review, reality check, pragmatic review) |
| 14 | **Finalization** | Summary, commit template |

### Bug-Specific Phases

| Phase | Name | Description |
|-------|------|-------------|
| 3 | **TDD Red Gate** | Write failing test (mandatory) |
| 9 | **TDD Green Gate** | Verify test passes (mandatory) |

### UI-Related Phases (Optional)

| Phase | Name | When |
|-------|------|------|
| 4 | **UI Mockups** | UI-heavy tasks |
| 12 | **E2E Testing** | `--e2e` or prompt |
| 13 | **User Docs** | `--user-docs` or prompt |

## Task Type Detection

**Bug Fix** (auto-detected):
- Keywords: "fix", "bug", "broken", "error", "crash", "fails"
- Directory: `.ai-sdlc/tasks/bug-fixes/`

**Enhancement** (auto-detected):
- Keywords: "improve", "enhance", "update", "modify", "extend"
- Directory: `.ai-sdlc/tasks/enhancements/`

**New Feature** (auto-detected):
- Keywords: "add", "new", "create", "build", "implement"
- Directory: `.ai-sdlc/tasks/new-features/`

## TDD Discipline (Bugs Only)

For bug fixes, TDD Red→Green gates are **mandatory**:

1. **Phase 3 (Red Gate)**: Write test using exact reproduction data
   - Test MUST fail (proves bug exists)
   - If test passes: bug already fixed or test wrong

2. **Phase 9 (Green Gate)**: Verify test passes after fix
   - Test MUST pass (proves fix works)
   - If still fails: implementation incomplete

**TDD Exception**: If TDD not feasible (legacy code, etc.), document alternative validation.

## Replaces Old Commands

This unified command replaces:
- `/ai-sdlc:bug-fix:new` → `/ai-sdlc:development:new --type=bug`
- `/ai-sdlc:enhancement:new` → `/ai-sdlc:development:new --type=enhancement`
- `/ai-sdlc:feature:new` → `/ai-sdlc:development:new --type=feature`

Old commands still work as aliases.

## Output Structure

```
.ai-sdlc/tasks/[type-directory]/YYYY-MM-DD-task-name/
├── orchestrator-state.yml           # Execution state + task metadata
├── analysis/
│   ├── codebase-analysis.md
│   ├── gap-analysis.md
│   └── ui-mockups.md (optional)
├── implementation/
│   ├── spec.md
│   ├── implementation-plan.md
│   ├── work-log.md
│   ├── tdd-red-gate.md (bug only)
│   └── tdd-green-gate.md (bug only)
├── verification/
│   ├── spec-audit.md
│   ├── implementation-verification.md
│   ├── code-review-report.md (if enabled)
│   ├── pragmatic-review.md (if enabled)
│   ├── production-readiness-report.md (if enabled)
│   └── reality-check.md (if enabled)
└── documentation/ (optional)
```
