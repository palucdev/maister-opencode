---
name: refactoring-orchestrator
description: Orchestrates safe, incremental refactoring workflows with optional git branch (asks user first), git commit checkpoints, user-confirmed rollback on failure (never automatic), and strict behavior preservation verification. Analyzes code quality baseline, creates detailed refactoring plan, captures behavioral snapshot, executes refactoring with test-driven verification, and confirms behavior unchanged.
---

# Refactoring Orchestrator

Safe, incremental refactoring workflow with behavior preservation verification and git checkpoint safety.

## MANDATORY Initialization (Before Any Phase Work)

**CRITICAL: You MUST complete these steps BEFORE executing any workflow phase:**

### Step 1: Create TodoWrite with All Phases

**Immediately use the TodoWrite tool** to create todos for all phases:

```
Use TodoWrite tool with todos:
[
  {"content": "Analyze code quality baseline", "status": "pending", "activeForm": "Analyzing code quality baseline"},
  {"content": "Create refactoring plan", "status": "pending", "activeForm": "Creating refactoring plan"},
  {"content": "Capture behavioral snapshot", "status": "pending", "activeForm": "Capturing behavioral snapshot"},
  {"content": "Set up git branch", "status": "pending", "activeForm": "Setting up git branch"},
  {"content": "Execute refactoring", "status": "pending", "activeForm": "Executing refactoring"},
  {"content": "Verify behavior preserved", "status": "pending", "activeForm": "Verifying behavior preserved"},
  {"content": "Verify final quality", "status": "pending", "activeForm": "Verifying final quality"}
]
```

Note: Phase 2.5 (Set up git branch) is optional based on user choice.

### Step 2: Output Initialization Summary

**Output this summary to the user:**

```
🚀 Refactoring Orchestrator Started

Task: [refactoring description]
Mode: [Interactive/YOLO]
Directory: [task-path]

Workflow phases:
[Todos list with status]

[Interactive mode] You'll be prompted for review after each phase.
[YOLO mode] All phases will run continuously.

Starting Phase 0: Analyze code quality baseline...
```

### Step 3: Only Then Proceed to Phase 0

After completing Steps 1 and 2, proceed to Phase 0 (Code Quality Baseline Analysis).

---

## When to Use This Skill

Use when:
- Improving code structure without changing behavior
- Reducing complexity or eliminating duplication
- Renaming, extracting, or reorganizing code
- Any work described as "refactor", "clean up", "restructure"

**DO NOT use for**:
- Adding new functionality (use `development-orchestrator --type=feature`)
- Bug fixes (use `development-orchestrator --type=bug`)
- Technology migrations (use `migration-orchestrator`)

## Refactoring Philosophy

**Core Definition**: "A change made to the internal structure of software to make it easier to understand and cheaper to modify without changing its observable behavior." - Martin Fowler

**Zero Tolerance Policy**: ANY behavior change = Failed refactoring. No exceptions.

## Core Principles

1. **Behavior Preservation is Sacred**: Zero functional changes allowed
2. **Measure Before Improving**: Establish quantitative baseline first
3. **Incremental Changes**: Small, testable changes with checkpoints
4. **Test-Driven Verification**: Run tests after every change
5. **User-Confirmed Rollback**: Never rollback automatically - always ask user first

---

## Framework Patterns

This orchestrator follows shared patterns. See:

- **Phase Execution**: `../orchestrator-framework/references/phase-execution-pattern.md`
- **State Management**: `../orchestrator-framework/references/state-management.md`
- **Interactive Mode**: `../orchestrator-framework/references/interactive-mode.md`
- **Initialization**: `../orchestrator-framework/references/initialization-pattern.md`

## Local References

Read these during relevant phases:

| File | When to Use | Purpose |
|------|-------------|---------|
| `references/behavior-preservation.md` | Core & Phase 4 | Defines what "behavior" means and verification strategies |
| `references/quality-metrics.md` | Phase 0 | Metric calculations, thresholds, and interpretation |
| `references/refactoring-types.md` | Phase 1 | Type classification, strategies, and risk assessment |
| `references/auto-fix-strategies.md` | Error handling | Recovery patterns and retry strategies |

---

## Phase Configuration

| Phase | content | activeForm | Agent/Skill |
|-------|---------|------------|-------------|
| 0 | "Analyze code quality baseline" | "Analyzing code quality baseline" | refactoring-analyzer |
| 1 | "Create refactoring plan" | "Creating refactoring plan" | refactoring-planner |
| 2 | "Capture behavioral snapshot" | "Capturing behavioral snapshot" | behavioral-snapshot-capturer |
| 2.5 | "Set up git branch" | "Setting up git branch" | orchestrator (optional) |
| 3 | "Execute refactoring" | "Executing refactoring" | orchestrator |
| 4 | "Verify behavior preserved" | "Verifying behavior preserved" | behavioral-verifier |
| 5 | "Verify final quality" | "Verifying final quality" | orchestrator |

**Workflow Overview**: 6-7 phases (Phase 2.5 optional based on user choice)

**CRITICAL TodoWrite Usage**:
1. At workflow start: Create todos for ALL phases using the Phase Configuration table above (all status=pending)
2. Before each phase: Update that phase to status=in_progress
3. After each phase: Update that phase to status=completed

---

## Workflow Phases

### Phase 0: Code Quality Baseline Analysis

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/refactoring-analyzer.md and following its instructions directly
❌ WRONG: Analyzing code quality inline in the orchestrator thread
❌ WRONG: Calculating complexity metrics yourself

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 0 to: refactoring-analyzer subagent
Method: Task tool
Expected outputs: analysis/code-quality-baseline.md
```

**INVOKE NOW:**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:refactoring-analyzer"
  description: "Analyze code quality baseline"
  prompt: |
    You are the refactoring-analyzer agent. Establish quantitative
    baseline to measure refactoring success.

    Task directory: [task-path]
    Refactoring description: [description]

    Please:
    1. Locate target code files
    2. Analyze cyclomatic complexity (per function, average, max)
    3. Measure code duplication (percentage, instances)
    4. Identify code smells (long methods, god classes, deep nesting)
    5. Assess test coverage (line, branch, function)
    6. Generate comprehensive quality baseline report

    Save to: analysis/code-quality-baseline.md
    Use only Read, Grep, Glob, and Bash tools. Do NOT modify code.

⏳ Wait for subagent completion before continuing.

**Outputs**: `analysis/code-quality-baseline.md`, `analysis/target-code-analysis.md`

**SELF-CHECK (before proceeding to Phase 1):**
- [ ] Did you invoke the Task tool? (not just read the agent file)
- [ ] Did you wait for the tool to return results?
- [ ] Is `analysis/code-quality-baseline.md` present?

If NO to any: STOP - go back and invoke the Task tool.

**State Update**: After refactoring-analyzer completes:
- If structured output includes `risk_level`, update `refactoring_context.risk_level`

---

## 🚦 GATE: Phase 0 → Phase 1

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 0 (Code Quality Baseline Analysis) complete. Ready to proceed to Phase 1 (Refactoring Planning)?"
     - Options: ["Continue to Phase 1", "Review Phase 0 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 1 (Refactoring Planning)..."
   - Proceed to Phase 1

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 1: Refactoring Planning

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/refactoring-planner.md and following its instructions directly
❌ WRONG: Creating refactoring-plan.md inline in the orchestrator thread
❌ WRONG: Breaking down refactoring into increments yourself

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 1 to: refactoring-planner subagent
Method: Task tool
Expected outputs: implementation/refactoring-plan.md
```

**INVOKE NOW:**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:refactoring-planner"
  description: "Create refactoring plan"
  prompt: |
    You are the refactoring-planner agent. Create detailed incremental
    refactoring plan with git checkpoints.

    Task directory: [task-path]
    Input: analysis/code-quality-baseline.md

    Please:
    1. Classify refactoring type (Extract, Rename, Simplify, Duplication, Restructure)
    2. Break into small, testable increments (1 change per increment)
    3. Define git checkpoint for each increment
    4. Identify affected tests and regression tiers (Tier 1, 2, 3)
    5. Assess complexity and risk per increment
    6. Generate comprehensive refactoring plan with rollback procedures

    Save to: implementation/refactoring-plan.md
    Use only Read, Grep, Glob, and Bash tools. Do NOT modify code.

⏳ Wait for subagent completion before continuing.

**Outputs**: `implementation/refactoring-plan.md`

**SELF-CHECK (before proceeding to Phase 2):**
- [ ] Did you invoke the Task tool? (not just read the agent file)
- [ ] Did you wait for the tool to return results?
- [ ] Is `implementation/refactoring-plan.md` present?

If NO to any: STOP - go back and invoke the Task tool.

**State Update**: After refactoring-planner completes:
- Update `refactoring_context.refactoring_type` from output
- Update `refactoring_context.total_increments` from output (number of planned increments)
- Update `refactoring_context.risk_level` from output (if not already set)

---

## 🚦 GATE: Phase 1 → Phase 2

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 1 (Refactoring Planning) complete. Ready to proceed to Phase 2 (Behavioral Snapshot Capture)?"
     - Options: ["Continue to Phase 2", "Review Phase 1 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 2 (Behavioral Snapshot Capture)..."
   - Proceed to Phase 2

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 2: Behavioral Snapshot Capture

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/behavioral-snapshot-capturer.md and following its instructions directly
❌ WRONG: Capturing behavioral snapshot inline in the orchestrator thread
❌ WRONG: Running tests and analyzing signatures yourself

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 2 to: behavioral-snapshot-capturer subagent
Method: Task tool
Expected outputs: analysis/behavioral-snapshot.md, analysis/behavioral-fingerprint.yml
```

**INVOKE NOW:**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:behavioral-snapshot-capturer"
  description: "Capture behavioral snapshot"
  prompt: |
    You are the behavioral-snapshot-capturer agent. Capture comprehensive
    behavioral baseline for comparison after refactoring.

    Task directory: [task-path]
    Input: implementation/refactoring-plan.md (target files list)

    Please:
    1. Identify all functions in target files (signatures, parameters, returns)
    2. Analyze test coverage (direct tests, integration tests)
    3. Run full test suite, capture baseline results
    4. Identify observable side effects (DB, API, files, logs, state changes)
    5. Create behavioral fingerprint (hash of signatures + tests + side effects)
    6. Generate behavioral snapshot report

    Save to:
    - analysis/behavioral-snapshot.md
    - analysis/behavioral-fingerprint.yml

    Use only Read, Grep, Glob, and Bash tools. Do NOT modify code.

⏳ Wait for subagent completion before continuing.

**Outputs**: `analysis/behavioral-snapshot.md`, `analysis/behavioral-fingerprint.yml`

**SELF-CHECK (before proceeding to Phase 2.5):**
- [ ] Did you invoke the Task tool? (not just read the agent file)
- [ ] Did you wait for the tool to return results?
- [ ] Is `analysis/behavioral-snapshot.md` present?

If NO to any: STOP - go back and invoke the Task tool.

**State Update**: After behavioral-snapshot-capturer completes:
- Update `refactoring_context.baseline_fingerprint` from output fingerprint hash

---

## 🚦 GATE: Phase 2 → Phase 2.5

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 2 (Behavioral Snapshot Capture) complete. Ready to proceed to Phase 2.5 (Git Branch Setup)?"
     - Options: ["Continue to Phase 2.5", "Review Phase 2 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 2.5 (Git Branch Setup)..."
   - Proceed to Phase 2.5

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 2.5: Git Branch Setup (Optional)

**Execution**: Main orchestrator (uses AskUserQuestion)

**Purpose**: Ask user if they want a dedicated git branch for refactoring

**Process**:
1. Use AskUserQuestion to ask about branch creation:
   - "Yes, create branch" → Create `refactor/YYYY-MM-DD-task-name`, checkout
   - "No, work on current branch" → Continue on current branch with commits
2. Update state with branch decision

**Benefits of Dedicated Branch**: Isolated work, easy to review/abandon, keeps main clean
**Benefits of Current Branch**: No branch management, simpler for small refactorings

**State Update**: After user chooses branch option:
- Set `branch_context.use_dedicated_branch` to user's choice (true/false)
- If branch created, set `branch_context.refactoring_branch` to branch name

---

## 🚦 GATE: Phase 2.5 → Phase 3

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 2.5 (Git Branch Setup) complete. Ready to proceed to Phase 3 (Refactoring Execution)?"
     - Options: ["Continue to Phase 3", "Review Phase 2.5 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 3 (Refactoring Execution)..."
   - Proceed to Phase 3

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 3: Refactoring Execution

**Execution**: Main orchestrator (direct for simple, delegates for complex)

**Standards Reminder**: Review `.ai-sdlc/docs/INDEX.md` for coding style before executing.

**Process** (for each increment):

1. **Apply Refactoring Changes**
   - Simple (1-3 files): Apply directly with Edit tool
   - Complex (4+ files): **MUST delegate** to `implementation-changes-planner`

**For Complex Increments (4+ files):**

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/implementation-changes-planner.md and following instructions directly
❌ WRONG: Planning changes for 4+ files inline in the orchestrator thread
❌ WRONG: Editing many files without a structured change plan

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating increment change planning to: implementation-changes-planner subagent
Method: Task tool
Expected outputs: Change plan for current increment
```

**INVOKE NOW (for complex increments):**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:implementation-changes-planner"
  description: "Plan refactoring changes"
  prompt: |
    Plan changes for refactoring increment [N]: [increment description]
    Task directory: [task-path]
    Refactoring plan: implementation/refactoring-plan.md
    Target files: [list of files for this increment]

⏳ Wait for subagent completion, then apply changes.

2. **Run Regression Tests** (appropriate tiers based on risk)
   - Tier 1: Direct tests (always)
   - Tier 2: Integration tests (medium+ risk)
   - Tier 3: Domain tests (high risk)

3. **If Tests Pass**: Create git commit checkpoint
   - `git add . && git commit -m "Checkpoint N: [description]"`
   - Continue to next increment

4. **If Tests Fail**: Analyze → Ask User → Execute Choice
   - **NEVER rollback automatically**
   - Analyze root cause (config issue? test setup? actual behavior change?)
   - Use AskUserQuestion with options:
     - "Try suggested fix" (if easy fix identified)
     - "Rollback changes" (user confirms rollback)
     - "Let me investigate" (pause for manual investigation)
   - Execute user's choice

**Outputs**: Refactored code with git commit checkpoints

**Success**: All increments complete, tests pass, checkpoints created

---

## 🚦 GATE: Phase 3 → Phase 4

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 3 (Refactoring Execution) complete. Ready to proceed to Phase 4 (Behavior Verification)?"
     - Options: ["Continue to Phase 4", "Review Phase 3 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 4 (Behavior Verification)..."
   - Proceed to Phase 4

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 4: Behavior Verification

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/behavioral-verifier.md and following its instructions directly
❌ WRONG: Verifying behavior preservation inline in the orchestrator thread
❌ WRONG: Comparing fingerprints yourself

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 4 to: behavioral-verifier subagent
Method: Task tool
Expected outputs: verification/behavior-verification-report.md
```

**INVOKE NOW:**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:behavioral-verifier"
  description: "Verify behavior preserved"
  prompt: |
    You are the behavioral-verifier agent. Verify refactored code
    behavior matches baseline exactly.

    Task directory: [task-path]
    Input: analysis/behavioral-snapshot.md (baseline)

    Please:
    1. Capture post-refactoring state (same process as Phase 2)
    2. Compare function signatures (must match unless explicit rename)
    3. Validate test results (must be identical)
    4. Confirm side effects preserved (must be identical)
    5. Compare behavioral fingerprints
    6. Generate comparison report with PASS/FAIL verdict

    Save to:
    - verification/behavior-verification-report.md
    - verification/post-refactoring-snapshot.md
    - verification/fingerprint-comparison.yml

    Use only Read, Grep, Glob, and Bash tools. Do NOT modify code.

    Verdict Criteria:
    - PASS: All signatures match, tests identical, side effects preserved
    - FAIL: Any behavioral discrepancy found

⏳ Wait for subagent completion before continuing.

**Outputs**: `verification/behavior-verification-report.md` with verdict

**SELF-CHECK (before proceeding to Phase 5):**
- [ ] Did you invoke the Task tool? (not just read the agent file)
- [ ] Did you wait for the tool to return results?
- [ ] Is `verification/behavior-verification-report.md` present?

If NO to any: STOP - go back and invoke the Task tool.

**Gate**: Cannot proceed to Phase 5 if verdict = FAIL

**Note**: Behavior verification failures are NOT auto-fixed. Report only.

**State Update**: After behavioral-verifier completes:
- Update `refactoring_context.behavior_verification_status` from output verdict ("PASS" or "FAIL")

---

## 🚦 GATE: Phase 4 → Phase 5

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 4 (Behavior Verification) complete. Ready to proceed to Phase 5 (Final Quality Verification)?"
     - Options: ["Continue to Phase 5", "Review Phase 4 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 5 (Final Quality Verification)..."
   - Proceed to Phase 5

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 5: Final Quality Verification

**Execution**: Main orchestrator (re-measures metrics, delegates pragmatic review)

**Process**:
1. **Re-measure Quality Metrics** - Same analysis as Phase 0 (orchestrator direct)
2. **Calculate Improvements** - Compare baseline vs post-refactoring
3. **Run Pragmatic Review** - Delegate to `code-quality-pragmatist` (required)
4. **Generate Quality Improvement Report** - Document improvements and goals met

**For Step 3 (Pragmatic Review):**

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/code-quality-pragmatist.md and following instructions directly
❌ WRONG: Checking for over-engineering inline in the orchestrator thread
❌ WRONG: Generating pragmatic-review.md yourself

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating pragmatic review to: code-quality-pragmatist subagent
Method: Task tool
Expected outputs: verification/pragmatic-review.md
```

**INVOKE NOW:**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:code-quality-pragmatist"
  description: "Pragmatic code review"
  prompt: |
    Run pragmatic code review for refactored code.
    Task directory: [task-path]
    Baseline: analysis/code-quality-baseline.md
    Check for over-engineering introduced during refactoring.
    Save to: verification/pragmatic-review.md

⏳ Wait for subagent completion before continuing.

**SELF-CHECK (before completing Phase 5):**
- [ ] Did you invoke the Task tool for pragmatic review?
- [ ] Did you wait for the tool to return results?
- [ ] Is `verification/pragmatic-review.md` present?

If NO to any: STOP - go back and invoke the Task tool.

**Outputs**:
- `verification/quality-improvement-report.md`
- `verification/pragmatic-review.md`

**Success**: Quality improved, goals met, no over-engineering

---

## Domain Context (State Extensions)

Refactoring-specific fields in `orchestrator-state.yml`:

```yaml
refactoring_context:
  refactoring_type: "extract" | "rename" | "simplify" | "duplication" | "restructure"
  total_increments: [number]
  risk_level: "low" | "medium" | "high"
  baseline_fingerprint: "[hash]"
  behavior_verification_status: "PASS" | "FAIL" | null

branch_context:
  use_dedicated_branch: true | false
  refactoring_branch: "refactor/YYYY-MM-DD-task-name" | null
  increments_completed: []
  commit_checkpoints:
    - increment: 1
      description: "[description]"
      commit_hash: "[hash]"
      timestamp: "[ISO 8601]"
```

---

## Task Structure

```
.ai-sdlc/tasks/refactoring/YYYY-MM-DD-refactoring-name/
├── metadata.yml
├── orchestrator-state.yml
├── analysis/
│   ├── code-quality-baseline.md       # Phase 0
│   ├── target-code-analysis.md        # Phase 0
│   ├── behavioral-snapshot.md         # Phase 2
│   └── behavioral-fingerprint.yml     # Phase 2
├── implementation/
│   └── refactoring-plan.md            # Phase 1
└── verification/
    ├── behavior-verification-report.md   # Phase 4
    ├── post-refactoring-snapshot.md      # Phase 4
    ├── fingerprint-comparison.yml        # Phase 4
    ├── quality-improvement-report.md     # Phase 5
    └── pragmatic-review.md               # Phase 5
```

**Git Branch** (optional): `refactor/YYYY-MM-DD-task-name`

---

## Auto-Recovery

| Phase | Max Attempts | Strategy |
|-------|--------------|----------|
| 0 | 2 | Expand search patterns, prompt user for target files |
| 1 | 2 | Clarify refactoring type, use conservative estimates |
| 2 | 1 | Document limitations if critical functions untested |
| 2.5 | 0 | User decision (no auto-fix) |
| 3 | 0 | Analyze → Ask user → Execute choice. **NEVER auto-rollback** |
| 4 | 0 | Read-only, report only. FAIL verdict = HALT |
| 5 | 1 | Flag issues only |

**Critical Rule**: On test failure in Phase 3, **NEVER rollback automatically**. Always:
1. Analyze root cause (config? test setup? actual behavior change?)
2. Ask user with options (try fix / rollback / investigate)
3. Execute user's choice

---

## User-Confirmed Rollback Protocol

When tests fail or behavior verification fails:

1. **STOP** - Don't automatically rollback
2. **ANALYZE** - Check for easy fixes (config issues, test setup, environment)
3. **ASK USER** - Use AskUserQuestion with options:
   - "Try suggested fix" (if easy fix identified)
   - "Rollback changes" (user confirms)
   - "Let me investigate" (pause for manual review)
4. **EXECUTE** - Only rollback if user explicitly chooses it

**Rationale**: Automatic rollback discards work, hides root causes, frustrates users. Many failures are simple config issues with 1-line fixes.

---

## Command Integration

Invoked via:
- `/ai-sdlc:refactoring:new [description] [--yolo]`
- `/ai-sdlc:refactoring:resume [task-path] [--from=PHASE]`

Task directory: `.ai-sdlc/tasks/refactoring/YYYY-MM-DD-task-name/`

---

## Success Criteria

Workflow successful when:

- Code quality baseline established with all metrics
- Refactoring plan created with testable increments
- Behavioral snapshot captured with fingerprint
- All increments executed with git checkpoint commits
- Behavior verification PASS (zero functional changes)
- Quality metrics improved (complexity, duplication reduced)
- No over-engineering introduced
- Ready for code review and merge
