---
name: refactoring-orchestrator
description: Orchestrates safe, incremental refactoring workflows with optional git branch (asks user first), git commit checkpoints, user-confirmed rollback on failure (never automatic), and strict behavior preservation verification. Analyzes code quality baseline, creates detailed refactoring plan, captures behavioral snapshot, executes refactoring with test-driven verification, and confirms behavior unchanged.
---

# Refactoring Orchestrator

Safe, incremental refactoring workflow with behavior preservation verification and git checkpoint safety.

## Initialization

**BEFORE executing any phase, you MUST complete these steps:**

### Step 1: Load Framework Patterns

**Read ALL framework reference files NOW using the Read tool:**

1. `../orchestrator-framework/references/phase-execution-pattern.md`
2. `../orchestrator-framework/references/interactive-mode.md`
3. `../orchestrator-framework/references/delegation-enforcement.md`
4. `../orchestrator-framework/references/state-management.md`
5. `../orchestrator-framework/references/initialization-pattern.md`
6. `../orchestrator-framework/references/issue-resolution-pattern.md`

### Step 2: Initialize Workflow

1. **Create Task Items**: Use `TaskCreate` for all phases (see Phase Configuration), then set dependencies with `TaskUpdate addBlockedBy`
2. **Create Task Directory**: `.ai-sdlc/tasks/refactoring/YYYY-MM-DD-task-name/`
3. **Initialize State**: Create `orchestrator-state.yml` with mode and refactoring context

**Output**:
```
🚀 Refactoring Orchestrator Started

Task: [refactoring description]
Mode: [Interactive/YOLO]
Directory: [task-path]

Starting Phase 0: Analyze code quality baseline...
```

---

## When to Use

Use for:
- Improving code structure without changing behavior
- Reducing complexity or eliminating duplication
- Renaming, extracting, or reorganizing code
- Any work described as "refactor", "clean up", "restructure"

**DO NOT use for**: New features, bug fixes, technology migrations.

---

## Core Principles

1. **Behavior Preservation is Sacred**: Zero functional changes allowed
2. **Measure Before Improving**: Establish quantitative baseline first
3. **Incremental Changes**: Small, testable changes with checkpoints
4. **Test-Driven Verification**: Run tests after every change
5. **User-Confirmed Rollback**: Never rollback automatically - always ask user first

**Zero Tolerance Policy**: ANY behavior change = Failed refactoring. No exceptions.

---

## Phase Configuration

| Phase | content | activeForm | Agent/Skill |
|-------|---------|------------|-------------|
| 0 | "Analyze code quality baseline" | "Analyzing code quality baseline" | refactoring-analyzer |
| 1 | "Create refactoring plan" | "Creating refactoring plan" | refactoring-planner |
| 2 | "Capture behavioral snapshot" | "Capturing behavioral snapshot" | behavioral-snapshot-capturer |
| 2.5 | "Set up git branch" | "Setting up git branch" | Direct (optional) |
| 3 | "Execute refactoring" | "Executing refactoring" | Direct + implementation-changes-planner |
| 4 | "Verify behavior preserved" | "Verifying behavior preserved" | behavioral-verifier |
| 5 | "Verify final quality" | "Verifying final quality" | Direct + code-quality-pragmatist |
| 5.5 | "Resolve quality issues" | "Resolving quality issues" | Direct (conditional) |

**IMPORTANT**: Phase 4 has **ZERO TOLERANCE** - any behavior change = FAIL = HALT. No Issue Resolution for Phase 4.

---

## Workflow Phases

### Phase 0: Code Quality Baseline Analysis

**Purpose**: Establish quantitative baseline to measure refactoring success
**Execute**: Task tool - `ai-sdlc:refactoring-analyzer` subagent
**Output**: `analysis/code-quality-baseline.md`, `analysis/target-code-analysis.md`
**State**: Update `refactoring_context.risk_level`

**Analyzer Tasks**:
1. Locate target code files
2. Analyze cyclomatic complexity (per function, average, max)
3. Measure code duplication (percentage, instances)
4. Identify code smells (long methods, god classes, deep nesting)
5. Assess test coverage

→ Pause

**Interactive**: AskUserQuestion - "Baseline analysis complete. Continue to planning?"
**YOLO**: "→ Continuing to Phase 1..."

---

### Phase 1: Refactoring Planning

**Purpose**: Create detailed incremental refactoring plan with git checkpoints
**Execute**: Task tool - `ai-sdlc:refactoring-planner` subagent
**Output**: `implementation/refactoring-plan.md`
**State**: Update `refactoring_context.refactoring_type`, `total_increments`

**Planner Tasks**:
1. Classify refactoring type (Extract, Rename, Simplify, Duplication, Restructure)
2. Break into small, testable increments (1 change per increment)
3. Define git checkpoint for each increment
4. Identify affected tests and regression tiers

→ Pause

**Interactive**: AskUserQuestion - "Refactoring plan ready. Continue to behavioral snapshot?"
**YOLO**: "→ Continuing to Phase 2..."

---

### Phase 2: Behavioral Snapshot Capture

**Purpose**: Capture comprehensive behavioral baseline for post-refactoring comparison
**Execute**: Task tool - `ai-sdlc:behavioral-snapshot-capturer` subagent
**Output**: `analysis/behavioral-snapshot.md`, `analysis/behavioral-fingerprint.yml`
**State**: Update `refactoring_context.baseline_fingerprint`

**Snapshot Captures**:
1. All function signatures in target files
2. Test coverage and test results
3. Observable side effects (DB, API, files, logs)
4. Behavioral fingerprint hash

→ Pause

**Interactive**: AskUserQuestion - "Behavioral snapshot captured. Continue to git branch setup?"
**YOLO**: "→ Continuing to Phase 2.5..."

---

### Phase 2.5: Git Branch Setup (Optional)

**Purpose**: Ask user if they want a dedicated git branch for refactoring
**Execute**: Direct - use AskUserQuestion for branch decision
**Output**: Branch created (if chosen)
**State**: Update `branch_context.use_dedicated_branch`, `refactoring_branch`

**Options**:
- "Yes, create branch" → Create `refactor/YYYY-MM-DD-task-name`, checkout
- "No, work on current branch" → Continue with commits on current branch

→ Pause

**Interactive**: AskUserQuestion - "Git setup complete. Continue to execution?"
**YOLO**: Auto-select "No" (work on current branch)

---

### Phase 3: Refactoring Execution

**Purpose**: Execute refactoring increments with test verification and git checkpoints
**Execute**: Direct for simple (1-3 files), Task tool - `ai-sdlc:implementation-changes-planner` for complex (4+ files)
**Output**: Refactored code with git commit checkpoints
**State**: Update `branch_context.increments_completed`, `commit_checkpoints`

**Standards Reminder**: Review `.ai-sdlc/docs/INDEX.md` before executing.

**Process** (for each increment):
1. Apply refactoring changes
2. Run regression tests (tier based on risk)
3. If tests pass: Create git commit checkpoint
4. If tests fail: **NEVER auto-rollback** - Analyze → Ask User → Execute Choice

**User-Confirmed Rollback Protocol**:
1. STOP - Don't automatically rollback
2. ANALYZE - Check for easy fixes (config, test setup, environment)
3. ASK USER - AskUserQuestion with options: "Try fix" / "Rollback" / "Investigate"
4. EXECUTE - Only rollback if user explicitly chooses it

→ Pause

**Interactive**: AskUserQuestion - "Refactoring complete. Continue to behavior verification?"
**YOLO**: "→ Continuing to Phase 4..."

---

### Phase 4: Behavior Verification

**Purpose**: Verify refactored code behavior matches baseline exactly
**Execute**: Task tool - `ai-sdlc:behavioral-verifier` subagent
**Output**: `verification/behavior-verification-report.md` with PASS/FAIL verdict
**State**: Update `refactoring_context.behavior_verification_status`

**Verification Checks**:
1. Compare function signatures (must match unless explicit rename)
2. Validate test results (must be identical)
3. Confirm side effects preserved (must be identical)
4. Compare behavioral fingerprints

**Verdict Criteria**:
- **PASS**: All signatures match, tests identical, side effects preserved
- **FAIL**: Any behavioral discrepancy found

**CRITICAL**: FAIL verdict = HALT workflow. No Issue Resolution for behavior changes.

→ Conditional: if verdict=PASS continue to Phase 5, otherwise HALT workflow

---

### Phase 5: Final Quality Verification

**Purpose**: Verify quality improvements and check for over-engineering
**Execute**: Direct for metrics, Task tool - `ai-sdlc:code-quality-pragmatist` for pragmatic review
**Output**: `verification/quality-improvement-report.md`, `verification/pragmatic-review.md`
**State**: Update `refactoring_context.quality_verification_status`

**Process**:
1. Re-measure quality metrics (same as Phase 0)
2. Calculate improvements vs baseline
3. Run pragmatic review (check for over-engineering)
4. Generate quality improvement report

→ Conditional: if verdict=PASS complete workflow, if fixable issues continue to Phase 5.5

---

### Phase 5.5: Quality Issue Resolution (Conditional)

**Purpose**: Fix quality issues (over-engineering, unnecessary complexity)
**Execute**: Direct - apply simplifications, re-verify
**Output**: Updated code, `verification_context.fixes_applied`
**State**: Update `reverify_count`, `decisions_made`

**Skip if**: Quality verdict = PASS

**IMPORTANT**: This phase handles QUALITY issues only. Behavior issues are NOT resolved here.

**Process**:
1. Parse issues from pragmatic review
2. Apply auto-fixes (remove unused code, simplify over-abstractions)
3. For user decisions: AskUserQuestion with options
4. Re-verify after fixes (max 3 iterations)

**Exit Conditions**:
- ✅ New verdict = PASS → Workflow complete
- ⚠️ Max iterations (3) reached → Complete with warnings

→ End of workflow

---

## Domain Context (State Extensions)

Refactoring-specific fields in `orchestrator-state.yml`:

```yaml
refactoring_context:
  refactoring_type: "extract" | "rename" | "simplify" | "duplication" | "restructure"
  total_increments: null
  risk_level: null
  baseline_fingerprint: null
  behavior_verification_status: null
  quality_verification_status: null

branch_context:
  use_dedicated_branch: false
  refactoring_branch: null
  increments_completed: []
  commit_checkpoints: []

verification_context:
  last_status: null
  issues_found: null
  fixes_applied: []
  decisions_made: []
  reverify_count: 0
```

---

## Task Structure

```
.ai-sdlc/tasks/refactoring/YYYY-MM-DD-task-name/
├── orchestrator-state.yml
├── analysis/
│   ├── code-quality-baseline.md       # Phase 0
│   ├── target-code-analysis.md        # Phase 0
│   ├── behavioral-snapshot.md         # Phase 2
│   └── behavioral-fingerprint.yml     # Phase 2
├── implementation/
│   └── refactoring-plan.md            # Phase 1
└── verification/
    ├── behavior-verification-report.md    # Phase 4
    ├── post-refactoring-snapshot.md       # Phase 4
    ├── fingerprint-comparison.yml         # Phase 4
    ├── quality-improvement-report.md      # Phase 5
    └── pragmatic-review.md                # Phase 5
```

---

## Auto-Recovery

| Phase | Max Attempts | Strategy |
|-------|--------------|----------|
| 0 | 2 | Expand search, prompt user for target files |
| 1 | 2 | Clarify refactoring type |
| 2 | 1 | Document limitations |
| 2.5 | 0 | User decision (no auto-fix) |
| 3 | 0 | Ask user on failure. **NEVER auto-rollback** |
| 4 | 0 | Read-only. FAIL = HALT |
| 5 | 1 | Flag issues only |
| 5.5 | 3 | Fix-then-reverify cycles |

---

## Command Integration

Invoked via:
- `/ai-sdlc:refactoring:new [description] [--yolo]`
- `/ai-sdlc:refactoring:resume [task-path] [--from=PHASE]`

Task directory: `.ai-sdlc/tasks/refactoring/YYYY-MM-DD-task-name/`
