---
name: ai-sdlc:enhancement:new
description: Start a new enhancement workflow (alias for /ai-sdlc:development:new --type=enhancement)
---

# Enhancement Workflow: New

**This command is an alias for the unified development workflow.**

Equivalent to: `/ai-sdlc:development:new [description] --type=enhancement [options]`

## Usage

```bash
/ai-sdlc:enhancement:new [description] [--yolo] [--from=PHASE] [--e2e] [--user-docs]
```

### Arguments

- **description** (optional): Enhancement to implement
  - Example: "Add sorting to user table"
  - If omitted, you'll be prompted

### Options

- `--yolo`: Run in YOLO mode (continuous without pauses)
  - Default: Interactive mode (pause between phases)
- `--from=PHASE`: Start from specific phase
  - Values: `analysis`, `gap`, `spec`, `plan`, `implement`, `verify`
  - Default: `analysis`
- `--e2e` / `--no-e2e`: Force enable/skip E2E testing
- `--user-docs` / `--no-user-docs`: Force enable/skip user documentation

## Examples

```bash
# Interactive mode (default)
/ai-sdlc:enhancement:new "Add export button to user table"

# YOLO mode (fast execution)
/ai-sdlc:enhancement:new "Add tooltips" --yolo

# With optional phases enabled
/ai-sdlc:enhancement:new "Build dashboard filters" --e2e --user-docs

# Resume from specific phase
/ai-sdlc:enhancement:new --from=implement
```

## What This Does

Routes to `development-orchestrator` skill with `task_type=enhancement`, which includes:

- **Phase 0**: Codebase Analysis (3 parallel Explore agents)
- **Phase 1**: Gap Analysis (current vs improved state, user journey impact)
- **Phase 2**: UI Mockup Generation (if UI-heavy)
- **Phase 3**: Specification
- **Phase 4**: Implementation Planning
- **Phase 5**: Implementation
- **Phase 7**: Verification + Compatibility
- **Phase 8**: E2E Testing (optional)
- **Phase 9**: User Documentation (optional)

## Enhancement Types

| Type | Risk | Description |
|------|------|-------------|
| **Additive** | Low | New functionality alongside existing |
| **Modificative** | Medium-High | Changes existing behavior |
| **Refactor-Based** | Medium-High | Restructures implementation |

## Outputs

Task directory: `.ai-sdlc/tasks/enhancements/YYYY-MM-DD-name/`

## Resume

If interrupted:
```bash
/ai-sdlc:enhancement:resume .ai-sdlc/tasks/enhancements/2025-10-27-add-sorting
```

Or use the unified command:
```bash
/ai-sdlc:development:resume .ai-sdlc/tasks/enhancements/2025-10-27-add-sorting
```

---

**Invoke**: development-orchestrator skill with task_type=enhancement
