---
name: ai-sdlc:feature:new
description: Start a new feature development workflow (alias for /ai-sdlc:development:new --type=feature)
---

# New Feature Development Workflow

**This command is an alias for the unified development workflow.**

Equivalent to: `/ai-sdlc:development:new [description] --type=feature [options]`

## Usage

```bash
/ai-sdlc:feature:new [description] [--yolo] [--from=PHASE] [--e2e] [--user-docs]
```

### Arguments

- **description** (optional): Brief description of the feature
  - Example: "Add user authentication with email/password"
  - If omitted, you'll be prompted

### Options

- `--yolo`: Run in YOLO mode (continuous without pauses)
  - Default: Interactive mode (pause between phases)
- `--from=PHASE`: Start from specific phase
  - Values: `analysis`, `gap`, `spec`, `plan`, `implement`, `verify`
  - Default: `analysis`
- `--e2e`: Auto-enable E2E testing (don't prompt)
- `--user-docs`: Auto-enable user documentation generation (don't prompt)

## Examples

```bash
# Interactive mode (default)
/ai-sdlc:feature:new "Add shopping cart functionality"

# YOLO mode (fast execution)
/ai-sdlc:feature:new "Add dark mode toggle" --yolo

# With E2E and docs pre-enabled
/ai-sdlc:feature:new "Build user dashboard" --e2e --user-docs

# Resume from specific phase
/ai-sdlc:feature:new --from=implement
```

## What This Does

Routes to `development-orchestrator` skill with `task_type=feature`, which includes:

- **Phase 0**: Codebase Analysis (3 parallel Explore agents - patterns, integration points)
- **Phase 1**: Gap Analysis (no feature vs integrated feature)
- **Phase 2**: UI Mockup Generation (if UI-heavy)
- **Phase 3**: Specification
- **Phase 4**: Implementation Planning
- **Phase 5**: Implementation
- **Phase 7**: Verification
- **Phase 8**: E2E Testing (optional)
- **Phase 9**: User Documentation (optional)

## Outputs

Task directory: `.ai-sdlc/tasks/new-features/YYYY-MM-DD-name/`

- `analysis/codebase-analysis.md` - Codebase patterns and integration points
- `analysis/gap-analysis.md` - What to build and where
- `implementation/spec.md` - Feature specification
- `implementation/implementation-plan.md` - Task breakdown
- `implementation/work-log.md` - Activity log
- `verification/implementation-verification.md` - Quality report
- `documentation/` - User docs (if enabled)

## Execution Modes

**Interactive** (default): Pauses after each phase. Always prompts for optional phases.

**YOLO** (`--yolo`): Runs continuously. Auto-decides on optional phases.

## Resume

If interrupted:
```bash
/ai-sdlc:feature:resume .ai-sdlc/tasks/new-features/2025-10-26-user-auth
```

Or use the unified command:
```bash
/ai-sdlc:development:resume .ai-sdlc/tasks/new-features/2025-10-26-user-auth
```

---

**Invoke**: development-orchestrator skill with task_type=feature
