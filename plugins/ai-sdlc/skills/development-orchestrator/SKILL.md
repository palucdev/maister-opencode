---
name: development-orchestrator
description: Unified orchestrator for all development tasks (bug fixes, enhancements, new features). Adapts workflow phases based on task type while maintaining consistent quality gates. Supports interactive mode (pause between phases) and YOLO mode (continuous execution). Use for any development work that modifies code.
---

# Development Orchestrator

This skill orchestrates the complete development workflow for all task types: bug fixes, enhancements, and new features. It unifies three workflows into one adaptive system.

---

## ⚠️ CRITICAL: Interactive Mode Execution Rules

**STOP! Before executing ANY phase, check the mode:**

**IF mode = interactive (default, no --yolo flag):**
- After EACH phase completion, you MUST STOP and use AskUserQuestion
- DO NOT proceed to the next phase without user confirmation
- This is NOT optional - it's the core orchestrator behavior

**IF mode = yolo (--yolo flag provided):**
- Continue to next phase automatically
- Only stop for critical failures or TDD gates (bugs)

**The AskUserQuestion call after each phase:**
```
Use AskUserQuestion tool:
  Question: "Phase [N] ([Name]) complete. How would you like to proceed?"
  Header: "Phase Complete"
  Options:
  1. "Continue to next phase" - Proceed to [Next Phase Name]
  2. "Review outputs" - View phase artifacts before continuing
  3. "Restart phase" - Re-execute this phase
  4. "Stop workflow" - Save state and exit
```

**FAILURE TO STOP IN INTERACTIVE MODE = BROKEN ORCHESTRATOR. This is the #1 requirement.**

---

## When to Use This Skill

Use this skill for **all development tasks**:
- **Bug fixes**: Fix defects, errors, crashes
- **Enhancements**: Improve existing features
- **New features**: Add completely new functionality

**DO NOT use for:**
- Performance optimization (use `performance-orchestrator`)
- Security remediation (use `security-orchestrator`)
- Code migrations (use `migration-orchestrator`)
- Documentation only (use `documentation-orchestrator`)
- Pure refactoring without functional changes (use `refactoring-orchestrator`)

## Core Principles

1. **Unified Workflow**: Same phases for all task types, different focus
2. **Task-Type Awareness**: Adapt behavior based on bug/enhancement/feature
3. **TDD for Bugs**: Mandatory Red→Green discipline for bug fixes
4. **Gap Analysis for All**: Compare current vs desired state systematically
5. **Backward Compatibility**: Preserve existing functionality (enhancements)
6. **Progress with TodoWrite**: You MUST use TodoWrite tool for progress tracking!

---

## Task Type Detection

### Automatic Detection

Analyze task description to determine type:

**Bug Fix** (task_type = "bug"):
- Keywords: "fix", "bug", "broken", "error", "crash", "fails", "doesn't work", "not working", "issue", "problem"
- Context: Existing code behaving incorrectly
- Directory: `.ai-sdlc/tasks/bug-fixes/`

**Enhancement** (task_type = "enhancement"):
- Keywords: "improve", "enhance", "better", "update", "modify", "extend", "upgrade", "add to existing"
- Context: Existing feature needs improvement
- Directory: `.ai-sdlc/tasks/enhancements/`

**New Feature** (task_type = "feature"):
- Keywords: "add", "new", "create", "build", "implement", "introduce"
- Context: No existing implementation
- Directory: `.ai-sdlc/tasks/new-features/`

### Override with Flag

User can override with `--type=bug|enhancement|feature`

---

## MANDATORY Initialization (Before Any Phase Work)

**CRITICAL: You MUST complete these steps BEFORE executing any workflow phase:**

### Step 1: Determine Task Type

If not provided via `--type` flag:
1. Analyze task description for keywords
2. If ambiguous, use AskUserQuestion:
   ```
   Question: "What type of task is this?"
   Options:
   - "Bug fix" - Something is broken and needs to be fixed
   - "Enhancement" - Improve or extend an existing feature
   - "New feature" - Build something completely new
   ```

### Step 2: Create TodoWrite with All Phases

**Immediately use the TodoWrite tool** to create todos for all phases:

```
Use TodoWrite tool with todos:
[
  {"content": "Check dependencies", "status": "pending", "activeForm": "Checking dependencies"},
  {"content": "Analyze codebase", "status": "pending", "activeForm": "Analyzing codebase"},
  {"content": "Clarify requirements", "status": "pending", "activeForm": "Clarifying requirements"},
  {"content": "Analyze gaps", "status": "pending", "activeForm": "Analyzing gaps"},
  {"content": "Write failing test (TDD Red)", "status": "pending", "activeForm": "Writing failing test"},  // Bug only
  {"content": "Generate UI mockups", "status": "pending", "activeForm": "Generating UI mockups"},
  {"content": "Create specification", "status": "pending", "activeForm": "Creating specification"},
  {"content": "Decide architecture", "status": "pending", "activeForm": "Deciding architecture"},  // Feature/Enhancement only
  {"content": "Audit specification", "status": "pending", "activeForm": "Auditing specification"},
  {"content": "Plan implementation", "status": "pending", "activeForm": "Planning implementation"},
  {"content": "Execute implementation", "status": "pending", "activeForm": "Executing implementation"},
  {"content": "Verify test passes (TDD Green)", "status": "pending", "activeForm": "Verifying test passes"},  // Bug only
  {"content": "Prompt verification options", "status": "pending", "activeForm": "Prompting verification options"},
  {"content": "Verify implementation", "status": "pending", "activeForm": "Verifying implementation"},
  {"content": "Run E2E tests", "status": "pending", "activeForm": "Running E2E tests"},
  {"content": "Generate user documentation", "status": "pending", "activeForm": "Generating user documentation"},
  {"content": "Finalize workflow", "status": "pending", "activeForm": "Finalizing workflow"}
]
```

Note: Skip TDD phases (3 and 9) for non-bug tasks when creating todos.

### Step 3: Output Initialization Summary

```
🚀 Development Orchestrator Started

Task: [description]
Type: [Bug Fix / Enhancement / New Feature]
Mode: [Interactive/YOLO]
Starting Phase: [phase name]
Directory: .ai-sdlc/tasks/[type-directory]/YYYY-MM-DD-task-name/

Workflow Phases:
0.  [ ] Dependency Check (if initiative)
1.  [ ] Codebase Analysis → codebase-analyzer skill
1.5 [ ] Clarifying Questions → resolve scope/requirements
2.  [ ] Gap Analysis → gap-analyzer subagent
3.  [ ] TDD Red Gate (bug only) - Write failing test
4.  [ ] UI Mockup Generation (optional) → ui-mockup-generator subagent
5.  [ ] Specification → specification-creator skill
5.5 [ ] Architecture Decision (conditional) → present approaches
6.  [ ] Specification Audit → spec-auditor subagent
7.  [ ] Planning → implementation-planner skill
8.  [ ] Implementation → implementer skill
9.  [ ] TDD Green Gate (bug only) - Verify test passes
10. [ ] Verification Options Prompt
11. [ ] Verification → implementation-verifier skill (includes reality check, pragmatic review)
12. [ ] E2E Testing (optional) → e2e-test-verifier subagent
13. [ ] User Documentation (optional) → user-docs-generator subagent
14. [ ] Finalization

State file: [task-path]/orchestrator-state.yml

[Interactive mode] You'll be prompted for review after each phase.
[YOLO mode] All phases will run continuously. TDD gates still enforced for bugs.

Starting Phase 0: Codebase Analysis...
```

---

## Progress Tracking

Use `TodoWrite` to show real-time progress. Create todos at workflow start, update at each phase.

**Phase Todos (adapt based on task_type)**:

| Phase | content | activeForm | Task Types |
|-------|---------|------------|------------|
| 0 | "Check dependencies" | "Checking dependencies" | All (if initiative) |
| 1 | "Analyze codebase" | "Analyzing codebase" | All |
| 1.5 | "Clarify requirements" | "Clarifying requirements" | All |
| 2 | "Analyze gaps" | "Analyzing gaps" | All |
| 3 | "Write failing test (TDD Red)" | "Writing failing test" | Bug only |
| 4 | "Generate UI mockups" | "Generating UI mockups" | Enhancement, Feature |
| 5 | "Create specification" | "Creating specification" | All |
| 5.5 | "Decide architecture" | "Deciding architecture" | Feature, Enhancement (conditional) |
| 6 | "Audit specification" | "Auditing specification" | All |
| 7 | "Plan implementation" | "Planning implementation" | All |
| 8 | "Execute implementation" | "Executing implementation" | All |
| 9 | "Verify test passes (TDD Green)" | "Verifying test passes" | Bug only |
| 10 | "Prompt verification options" | "Prompting verification options" | All |
| 11 | "Verify implementation" | "Verifying implementation" | All |
| 12 | "Run E2E tests" | "Running E2E tests" | Optional |
| 13 | "Generate user documentation" | "Generating user documentation" | Optional |
| 14 | "Finalize workflow" | "Finalizing workflow" | All |

---

## Execution Modes

### Interactive Mode (Default)
- Pauses after each major phase for user review
- Prompts for optional phases (E2E, user docs)
- Allows course correction between phases
- Best for: Complex tasks, critical fixes, careful review

### YOLO Mode
- Runs all phases continuously without pausing
- **TDD gates still enforced for bugs** (cannot skip)
- Auto-decides on optional phases
- Best for: Simple tasks, experienced users

---

## Workflow Phases

### Phase 0: Dependency Check (If Part of Initiative)

**When**: Only if task has `initiative_id` in metadata.yml

**Actions**:
1. Read task metadata.yml
2. Check if `initiative_id` field exists
3. If NO initiative_id: Skip (standalone task)
4. If YES: Check all dependencies are "completed"
5. If blocked: Update status to "blocked", exit with message

**Outputs**: None (or blocked status)

---

### Phase 1: Codebase Analysis

**Skill**: `codebase-analyzer`

**Purpose**: Analyze codebase to understand context before making changes

**Actions**:
1. **Invoke codebase-analyzer skill** with:
   - task_type: bug | enhancement | feature
   - description: task description
   - task_path: path to task directory
2. Skill launches 3 parallel Explore subagents
3. Wait for completion and merged results
4. Present findings to user (interactive) or continue (YOLO)

**Focus by Task Type**:

| Task Type | Agent 1 Focus | Agent 2 Focus | Agent 3 Focus |
|-----------|---------------|---------------|---------------|
| **Bug** | Find buggy code path | Trace execution flow | Find tests, reproduction hints |
| **Enhancement** | Find feature files | Analyze current behavior | Find tests, API consumers |
| **Feature** | Find similar patterns | Analyze architecture | Find integration points |

**Outputs**: `analysis/codebase-analysis.md`

**Auto-Fix**: If files not found, expand search (max 2 attempts)

**⏸️ INTERACTIVE MODE: STOP HERE** - After this phase completes, you MUST use AskUserQuestion before proceeding to Phase 1.5.

---

### Phase 1.5: Clarifying Questions (Before Gap Analysis)

**Purpose**: Resolve scope and requirements ambiguities BEFORE detailed gap analysis

**When**: Always after Phase 1 (Codebase Analysis), before Phase 2 (Gap Analysis)

**Why Before Gap Analysis**:
- Scope decisions should be made BEFORE detailed analysis (saves effort)
- Gap analysis can then focus on confirmed scope
- Separates concerns: orchestrator owns user interaction, agents own analysis

**Question Sources** (from codebase analysis):

Based on `analysis/codebase-analysis.md`, identify questions in these categories:

| Category | Question Pattern | When to Ask |
|----------|------------------|-------------|
| **Scope** | "Is [X] in scope?" | Task mentions something that may or may not be included |
| **Integration** | "Should this integrate with [system]?" | Codebase shows related systems |
| **Patterns** | "Should we follow [pattern]?" | Multiple patterns exist in codebase |
| **Edge Cases** | "What should happen when [case]?" | Edge cases not specified |
| **Error Handling** | "How should [error] be handled?" | Error scenarios unclear |
| **Compatibility** | "Must remain backward compatible?" | Existing API/behavior affected |

**Question Categorization**:

- **Critical**: MUST answer before proceeding (scope, blocking ambiguities)
- **Important**: SHOULD answer, have sensible defaults (design choices)

**Actions**:

1. **Analyze Codebase Analysis** for question triggers:
   - Read `analysis/codebase-analysis.md`
   - Look for: multiple similar patterns, related features, unclear scope, error handling gaps

2. **Generate Questions** (max 5 critical, 5 important):
   - Formulate clear question with 2-4 options
   - Include recommendation with rationale
   - Categorize as critical/important

3. **Present Critical Questions** (Interactive Mode):
   ```
   ❓ Clarifying Questions

   Before detailed gap analysis, I need to clarify [N] items:

   Use AskUserQuestion tool:
     Question: "[Specific question about scope/integration/pattern]"
     Header: "[Category]"
     Options:
     1. "[Option A]" - [Description]
     2. "[Option B]" - [Description] (Recommended)
     3. "[Option C]" - [Description]
   ```

4. **Handle Important Questions** (show defaults):
   ```
   📋 Design Decisions (have recommended defaults)

   Use AskUserQuestion tool:
     Question: "Accept design defaults or review individually?"
     Header: "Defaults"
     Options:
     1. "Accept all defaults" - Use recommended patterns (Recommended)
     2. "Review each" - Let me decide each one
   ```

5. **Document Answers** in `analysis/clarifications.md`:
   ```markdown
   # Clarifications

   Questions resolved before gap analysis.

   ## Critical Questions

   **Q1**: [Question]
   **A1**: [Answer] (User confirmed)

   ## Design Defaults

   **Q2**: [Question] → [Default value] (default accepted)

   ---
   *Clarifications complete. Proceeding to Gap Analysis.*
   ```

6. **YOLO Mode Handling**:
   - Accept all recommended defaults
   - Log: "✅ Auto-accepting recommended clarifications"
   - Still create clarifications.md with auto-accepted values
   - Continue to Phase 2

**Critical Gate**:
```
⚠️ DO NOT proceed to Gap Analysis (Phase 2) until:
- All critical questions answered
- Answers documented in analysis/clarifications.md
```

**Outputs**: `analysis/clarifications.md`

**⏸️ INTERACTIVE MODE: STOP HERE** - After this phase completes, you MUST use AskUserQuestion before proceeding to Phase 2.

---

### Phase 2: Gap Analysis

**Agent**: `gap-analyzer` (subagent)

**Purpose**: Compare current state vs desired state

**Actions**:
1. **Invoke gap-analyzer via Task tool:**
   ```
   Use Task tool with parameters:
   - subagent_type: "ai-sdlc:gap-analyzer"
   - description: "Analyze gaps"
   - prompt: "Analyze gaps for [task_type]: [description]. Task path: [task-path]. Analysis: [analysis-path]. Task type: [task_type]"
   ```
2. Wait for completion
3. Handle scope decisions (interactive mode)

**Gap Analysis by Task Type**:

**Bug**:
- Current state: Buggy behavior with reproduction steps
- Desired state: Expected correct behavior
- Gap: What needs to change to fix the bug
- Output: Reproduction data, regression risk areas

**Enhancement**:
- Current state: Existing feature behavior
- Desired state: Improved feature behavior
- Gap: Missing functionality, UX improvements
- Output: Data lifecycle analysis, user journey impact

**Feature**:
- Current state: Codebase without feature
- Desired state: Codebase with integrated feature
- Gap: What needs to be built, where it integrates
- Output: Integration points, patterns to follow

**Outputs**: `analysis/gap-analysis.md`

**Auto-Fix**: Re-analyze if unclear (max 2 attempts)

**⏸️ INTERACTIVE MODE: STOP HERE** - After this phase completes, you MUST use AskUserQuestion before proceeding to Phase 3 (bugs) or Phase 4.

---

### Phase 3: TDD Red Gate (Bug Only)

**Purpose**: Write a failing test that reproduces the bug

**When**: task_type = "bug" AND TDD applicable

**Actions**:
1. Using reproduction data from Phase 2, write a test that:
   - Uses EXACT reproduction inputs/state
   - Asserts expected correct behavior
   - Currently FAILS (proves bug exists)
2. Run the test
3. **Verify test FAILS** (if passes, test doesn't reproduce bug)
4. Document test failure in `implementation/tdd-red-gate.md`

**Critical Gate**:
```
IF test passes before implementation:
  STOP - Test doesn't reproduce the bug
  Ask user: "Test passed before fix. This means either:
  1. The bug is already fixed
  2. Test doesn't reproduce the bug correctly
  Options: [Rewrite test] [Bug already fixed] [Skip TDD]"
```

**TDD Exception Path**:
If TDD truly not applicable (legacy code, integration complexity, etc.):
1. Document why in `implementation/tdd-exception.md`
2. Specify exception type: legacy_code, integration_bug, race_condition, environment_specific
3. Provide alternative validation approach

**Outputs**:
- Failing test file
- `implementation/tdd-red-gate.md` - Test failure log

**⏸️ INTERACTIVE MODE: STOP HERE** - After this phase completes, you MUST use AskUserQuestion before proceeding to Phase 4.

---

### Phase 4: UI Mockup Generation (Optional)

**Agent**: `ui-mockup-generator` (subagent)

**Purpose**: Generate ASCII mockups for UI integration

**When**:
- task_type = "enhancement" or "feature"
- ui_heavy flag is true from Phase 2
- User confirms (interactive mode)

**Actions**:
1. Check ui_heavy flag
2. If true, invoke ui-mockup-generator subagent
3. Generate ASCII mockups showing integration
4. If fails, continue without mockups (optional)

**Outputs**: `analysis/ui-mockups.md`

**⏸️ INTERACTIVE MODE: STOP HERE** - After this phase completes, you MUST use AskUserQuestion before proceeding to Phase 5.

---

### Phase 5: Specification

**Skill**: `specification-creator`

**Purpose**: Create comprehensive specification

**Actions**:
1. Pass codebase analysis + gap analysis to spec creator
2. Include task-type-specific sections:
   - Bug: Root cause, fix approach, regression prevention
   - Enhancement: Compatibility requirements, backward compat
   - Feature: Architecture decisions, integration approach
3. Create specification

**Outputs**:
- `implementation/spec.md`
- `implementation/requirements.md`

**Auto-Fix**: Re-invoke with issues (max 2 attempts)

**⏸️ INTERACTIVE MODE: STOP HERE** - After this phase completes, you MUST use AskUserQuestion before proceeding to Phase 5.5 (if triggered) or Phase 6.

---

### Phase 5.5: Architecture Decision (Conditional)

**Purpose**: Present implementation approaches and get user approval on architecture BEFORE detailed planning

**When**:
- task_type = "feature" or "enhancement"
- Task involves architectural choices (multiple valid approaches)
- NOT for simple bug fixes or straightforward changes

**Skip Conditions**:
- task_type = "bug" (bugs have single correct fix approach)
- Specification already contains clear, unambiguous technical approach
- Task is straightforward with only one reasonable approach

**Trigger Detection**:
```
architectural_decision_needed = TRUE if ANY of:
- Specification mentions "could use X or Y"
- Multiple patterns exist in codebase for similar features
- Task involves new technology/library decision
- Task touches core architecture (auth, data layer, state management)
- Task requires choosing between performance vs simplicity trade-offs
```

**Actions**:

1. **Analyze Implementation Options**

   Review specification and codebase to identify 2-3 distinct approaches:
   - Read `implementation/spec.md` (requirements)
   - Read `analysis/codebase-analysis.md` (existing patterns)
   - Read `analysis/clarifications.md` (user preferences)

2. **Evaluate Each Approach**

   For each approach, analyze:

   | Dimension | Questions to Answer |
   |-----------|---------------------|
   | **Alignment** | How well does this match existing patterns? |
   | **Complexity** | How many files/components affected? |
   | **Risk** | What could go wrong? Rollback difficulty? |
   | **Maintainability** | How easy to extend/modify later? |

3. **Present Approaches to User**

   ```
   🏗️ Architecture Decision

   Based on the specification and codebase analysis, I've identified [N] approaches:

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   **Approach A: [Name]** ⭐ Recommended

   How it works:
   - [Key implementation detail 1]
   - [Key implementation detail 2]

   Trade-offs:
   ✅ Pros: [Pro 1], [Pro 2]
   ⚠️ Cons: [Con 1], [Con 2]

   Codebase fit: [How it aligns with existing patterns]
   Effort: [Low/Medium/High]

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   **Approach B: [Name]**

   [Same structure as above]

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   **My Recommendation**: Approach [A/B/C] because [reasoning]
   ```

4. **Get User Selection**

   ```
   Use AskUserQuestion tool:
     Question: "Which implementation approach should I use?"
     Header: "Architecture"
     Options:
     1. "Approach A: [Name]" - [One-line summary] (Recommended)
     2. "Approach B: [Name]" - [One-line summary]
     3. "Approach C: [Name]" - [One-line summary] (if applicable)
   ```

5. **Document Decision**

   Update `implementation/spec.md` with chosen architecture:
   ```markdown
   ## Technical Approach

   **Chosen Architecture**: [Approach Name]

   **Rationale**: [Why this approach was selected]

   **Alternatives Considered**:
   - [Approach B]: Not chosen because [reason]
   ```

6. **YOLO Mode Handling**:
   - Auto-select recommended approach
   - Log: "✅ Auto-selecting recommended architecture: [Approach Name]"
   - Update spec.md with decision
   - Continue to Phase 6

**Critical Gate**:
```
⚠️ DO NOT proceed to Specification Audit (Phase 6) without:
- User explicitly selecting an approach (interactive) OR auto-selected (YOLO)
- Decision documented in spec.md
```

**Outputs**:
- Updated `implementation/spec.md` with Technical Approach section

**⏸️ INTERACTIVE MODE: STOP HERE** - After this phase completes, you MUST use AskUserQuestion before proceeding to Phase 6.

---

### Phase 6: Specification Audit

**Agent**: `spec-auditor` (subagent)

**Purpose**: Verify specification completeness

**When**: Always after Phase 5 (both Interactive and YOLO)

**Actions**:
1. Invoke spec-auditor with spec.md path
2. Verify scope is clear
3. Check task-type-specific requirements
4. If critical issues: Pause for resolution

**Outputs**: `verification/spec-audit.md`

**⏸️ INTERACTIVE MODE: STOP HERE** - After this phase completes, you MUST use AskUserQuestion before proceeding to Phase 7.

---

### Phase 7: Implementation Planning

**Skill**: `implementation-planner`

**Purpose**: Break specification into implementation steps

**Actions**:
1. Pass spec + analysis to planner
2. Include task-type-specific considerations:
   - Bug: Regression test preservation
   - Enhancement: Targeted regression testing (30-70%)
   - Feature: Integration order
3. Create implementation plan

**Outputs**: `implementation/implementation-plan.md`

**Auto-Fix**: Regenerate with constraints (max 2 attempts)

**⏸️ INTERACTIVE MODE: STOP HERE** - After this phase completes, you MUST use AskUserQuestion before proceeding to Phase 8.

---

### Phase 8: Implementation

**Skill**: `implementer`

**Purpose**: Execute implementation plan

**Actions**:
1. Execute implementation-plan.md step by step
2. Continuous standards discovery from docs/INDEX.md
3. Test-driven approach
4. Run targeted tests incrementally

**Outputs**:
- Implemented code changes
- Updated implementation-plan.md
- `implementation/work-log.md`

**Auto-Fix**: Re-run with error context (max 5 attempts)

**⏸️ INTERACTIVE MODE: STOP HERE** - After this phase completes, you MUST use AskUserQuestion before proceeding to Phase 9 (if bug) or Phase 10.

---

### Phase 9: TDD Green Gate (Bug Only)

**Purpose**: Verify the failing test now passes

**When**: task_type = "bug" AND Phase 3 was executed

**Actions**:
1. Run the test written in Phase 3
2. **Verify test PASSES** (proves fix works)
3. Document success in `implementation/tdd-green-gate.md`

**Critical Gate**:
```
IF test still fails:
  Implementation did not fix the bug
  Options:
  1. [Continue implementing] - Bug not fully fixed
  2. [Review test] - Maybe test is wrong
  3. [Investigate further] - Need more analysis
```

**Outputs**: `implementation/tdd-green-gate.md`

**⏸️ INTERACTIVE MODE: STOP HERE** - After this phase completes, you MUST use AskUserQuestion before proceeding to Phase 10.

---

### Phase 10: Verification Options Prompt

**Purpose**: Determine which optional verification checks to run

**Actions**:
1. Analyze implementation for signals to determine recommendation levels:
   - Files changed count
   - Test coverage
   - Complexity of changes
   - Risk level from task_context

2. Determine recommendations based on task type:
   - **Bug**: Code review `[STRONGLY RECOMMENDED]` (regression risk)
   - **Enhancement**: Code review `[STRONGLY RECOMMENDED]` (compatibility risk)
   - **Feature**: Code review `[Recommended]` (new code)
   - **Production Readiness**: `[STRONGLY RECOMMENDED]` if deploying to production

3. **Prompt user (Interactive mode):**

```
Use AskUserQuestion tool:
  Question: "Which verification checks should I run? (Select all that apply)"
  Header: "Verification Options"
  multiSelect: true
  Options:
  1. Label: "Code Review [STRONGLY RECOMMENDED]"
     Description: "Automated quality, security, and performance analysis. Adds ~3 minutes."
  2. Label: "Production Readiness [Recommended]"
     Description: "Verify deployment readiness: config, monitoring, security. Adds ~4 minutes."
  3. Label: "Skip optional checks"
     Description: "Run basic verification only (plan, tests, standards). Faster but less comprehensive."
```

4. **Auto-decide (YOLO mode):**

```
# For all task types, always enable code review
code_review_enabled = true
code_review_scope = "all"
Output: "✅ Auto-enabling code review (recommended for all changes)"

# Production readiness based on signals
IF task touches deployment/config files OR task description mentions "production":
  production_check_enabled = true
  Output: "✅ Auto-enabling production readiness check"
ELSE:
  production_check_enabled = false
  Output: "⏭️ Skipping production readiness (not production deployment)"

# Reality and pragmatic review always enabled
reality_check_enabled = true
pragmatic_review_enabled = true
Output: "✅ Auto-enabling reality assessment + pragmatic review (mandatory)"
```

5. **Update orchestrator-state.yml** with decisions:

```yaml
orchestrator:
  options:
    code_review_enabled: true | false
    code_review_scope: "all" | "quality" | "security" | "performance"
    production_check_enabled: true | false
    pragmatic_review_enabled: true  # Always true
    reality_check_enabled: true     # Always true
```

6. **Output confirmation:**

```
✅ Verification Configuration

Will run:
- ✅ Basic Verification (plan completion, tests, standards)
- ✅ Reality Assessment (always enabled)
- ✅ Pragmatic Review (always enabled)
[If code_review_enabled]
- ✅ Code Review (Scope: all)
[If production_check_enabled]
- ✅ Production Readiness Check

Proceeding to Phase 11: Verification...
```

**Outputs**: Updated orchestrator-state.yml with verification options

---

### Phase 11: Verification

**Skill**: `implementation-verifier`

**Purpose**: Comprehensive verification of implementation

**Actions**:
1. **Invoke implementation-verifier skill** with task-path
   - The skill reads `orchestrator-state.yml` to determine which optional checks to run
   - The skill internally handles: plan completion, test suite, standards compliance, documentation, code review, pragmatic review, production readiness, reality assessment
2. Wait for skill completion
3. **Verify expected artifacts exist** (based on flags from Phase 10):

   | Artifact | Condition |
   |----------|-----------|
   | `verification/implementation-verification.md` | Always |
   | `verification/code-review-report.md` | If code_review_enabled |
   | `verification/pragmatic-review.md` | If pragmatic_review_enabled |
   | `verification/production-readiness-report.md` | If production_check_enabled |
   | `verification/reality-check.md` | If reality_check_enabled |

4. **If any expected artifact missing**:
   - Log warning: "⚠️ Expected [artifact] not found - [check] may not have run"
   - Use AskUserQuestion to confirm proceeding:
     ```
     Question: "Some verification artifacts are missing. How would you like to proceed?"
     Header: "Missing Artifacts"
     Options:
     1. "Re-run verification" - Invoke implementation-verifier again
     2. "Continue anyway" - Proceed with incomplete verification
     3. "Stop workflow" - Pause to investigate
     ```
5. Parse `implementation-verification.md` for overall status (✅ Passed | ⚠️ Passed with Issues | ❌ Failed)

**Outputs**: Verified artifacts from implementation-verifier

**Auto-Fix**: If tests fail, invoke implementer with fixes (max 3 attempts)

**⏸️ INTERACTIVE MODE: STOP HERE** - After this phase completes, you MUST use AskUserQuestion before proceeding to Phase 12.

---

### Phase 12: E2E Testing (Optional)

**Agent**: `e2e-test-verifier`

**When**:
- Interactive: Prompt user
- YOLO: Auto-run if UI-related
- Explicit: `--e2e` flag

**Outputs**:
- `verification/e2e-verification-report.md`
- `verification/screenshots/`

**⏸️ INTERACTIVE MODE: STOP HERE** - After this phase completes, you MUST use AskUserQuestion before proceeding to Phase 13.

---

### Phase 13: User Documentation (Optional)

**Agent**: `user-docs-generator`

**When**:
- Interactive: Prompt user
- YOLO: Auto-run if user-facing
- Explicit: `--user-docs` flag
- task_type = "feature" or "enhancement" (not bugs)

**Outputs**:
- `documentation/user-guide.md`
- `documentation/screenshots/`

**⏸️ INTERACTIVE MODE: STOP HERE** - After this phase completes, you MUST use AskUserQuestion before proceeding to Phase 14.

---

### Phase 14: Finalization

**Actions**:
1. Create workflow summary
2. Update metadata.yml status to "completed"
3. Provide commit message template
4. Guide next steps

**Outputs**:
- Workflow summary
- Updated metadata.yml
- Commit message template

---

## Output Directory Structure

Directory determined by task_type:

```
.ai-sdlc/tasks/[type-directory]/YYYY-MM-DD-task-name/
├── metadata.yml                           # Task metadata
├── orchestrator-state.yml                 # Workflow state
├── analysis/
│   ├── codebase-analysis.md              # Phase 1 output
│   ├── clarifications.md                 # Phase 1.5 output
│   ├── gap-analysis.md                   # Phase 2 output
│   └── ui-mockups.md                     # Phase 4 output (optional)
├── implementation/
│   ├── spec.md                           # Phase 5 output
│   ├── requirements.md                   # Phase 5 output
│   ├── implementation-plan.md            # Phase 7 output
│   ├── work-log.md                       # Phase 8 output
│   ├── tdd-red-gate.md                   # Phase 3 output (bug only)
│   ├── tdd-green-gate.md                 # Phase 9 output (bug only)
│   └── tdd-exception.md                  # If TDD skipped (bug only)
├── verification/
│   ├── spec-audit.md                     # Phase 6 output
│   ├── implementation-verification.md    # Phase 11 output
│   ├── reality-check.md                  # Phase 11 output (from implementation-verifier)
│   ├── pragmatic-review.md               # Phase 11 output (from implementation-verifier)
│   └── e2e-verification-report.md        # Phase 12 output (optional)
└── documentation/
    ├── user-guide.md                     # Phase 13 output (optional)
    └── screenshots/
```

**Type directories**:
- bug → `bug-fixes/`
- enhancement → `enhancements/`
- feature → `new-features/`

---

## Expected Artifacts by Phase

This table defines the expected outputs from each phase. Used for artifact validation during resume.

| Phase | Skill/Agent | Output Artifact | Condition |
|-------|-------------|-----------------|-----------|
| 1 | codebase-analyzer | `analysis/codebase-analysis.md` | Always |
| 1.5 | orchestrator | `analysis/clarifications.md` | Always |
| 2 | gap-analyzer | `analysis/gap-analysis.md` | Always |
| 3 | (direct) | `implementation/tdd-red-gate.md` | Bug only |
| 4 | ui-mockup-generator | `analysis/ui-mockups.md` | If ui_heavy |
| 5 | specification-creator | `implementation/spec.md` | Always |
| 5 | specification-creator | `implementation/requirements.md` | Always |
| 6 | spec-auditor | `verification/spec-audit.md` | Always |
| 7 | implementation-planner | `implementation/implementation-plan.md` | Always |
| 8 | implementer | `implementation/work-log.md` | Always |
| 9 | (direct) | `implementation/tdd-green-gate.md` | Bug only |
| 11 | implementation-verifier | `verification/implementation-verification.md` | Always |
| 11 | implementation-verifier | `verification/code-review-report.md` | If code_review_enabled |
| 11 | implementation-verifier | `verification/pragmatic-review.md` | If pragmatic_review_enabled |
| 11 | implementation-verifier | `verification/production-readiness-report.md` | If production_check_enabled |
| 11 | implementation-verifier | `verification/reality-check.md` | If reality_check_enabled |
| 12 | e2e-test-verifier | `verification/e2e-verification-report.md` | If e2e_enabled |
| 13 | user-docs-generator | `documentation/user-guide.md` | If user_docs_enabled |

---

## State Management

### orchestrator-state.yml

```yaml
orchestrator:
  task_type: bug | enhancement | feature
  mode: interactive | yolo
  started_phase: analysis
  current_phase: analysis
  completed_phases: []
  failed_phases: []
  auto_fix_attempts:
    codebase_analysis: 0
    clarifying_questions: 0
    gap_analysis: 0
    tdd_red: 0           # Bug only
    specification: 0
    planning: 0
    implementation: 0
    tdd_green: 0         # Bug only
    verification: 0
    e2e_testing: 0
  options:
    e2e_enabled: null
    user_docs_enabled: null
    code_review_enabled: null
    code_review_scope: null
    production_check_enabled: null
    pragmatic_review_enabled: null
    reality_check_enabled: null
  task_context:
    type: bug | enhancement | feature
    risk_level: null
    ui_heavy: null
    clarifications_resolved: null
    architecture_decision: null  # Feature/Enhancement only
    tdd_applicable: true  # Bug only
    reproduction_data: null  # Bug only
  created: [actual current time in ISO 8601, e.g., 2025-12-16T14:30:45Z]
  updated: [actual current time in ISO 8601, e.g., 2025-12-16T14:30:45Z]
  task_path: .ai-sdlc/tasks/[type]/YYYY-MM-DD-task-name
```

---

## Error Handling and Recovery

### Auto-Fix Strategy by Phase

| Phase | Auto-Fix Capability | Max Attempts |
|-------|---------------------|--------------|
| 1 | Expand search, prompt user | 2 |
| 2 | Re-analyze, ask user | 2 |
| 3 | Rewrite test, skip TDD with doc | 2 |
| 4 | Continue without mockups | 1 |
| 5 | Regenerate spec | 2 |
| 6 | Highlight issues | 1 |
| 7 | Regenerate plan | 2 |
| 8 | Fix syntax, imports, tests | 5 |
| 9 | Return to implementation | 3 |
| 11 | Fix tests, re-run | 3 |
| 12 | Prompt app start, fix UI | 2 |
| 13 | Text-only fallback | 1 |

### Critical Failure Handling

**NEVER automatically rollback or revert code changes without user confirmation.**

When failures occur:
1. STOP - Don't attempt automatic rollback
2. ANALYZE - Examine root cause
3. CHECK FOR EASY FIXES - Often simple config issues
4. ASK USER - Use AskUserQuestion with options:
   - "Try suggested fix"
   - "Rollback changes" (user confirms)
   - "Let me investigate"
5. EXECUTE - Only rollback if user explicitly confirms

---

## Command Flags

| Flag | Effect |
|------|--------|
| `--type=bug\|enhancement\|feature` | Override task type detection |
| `--yolo` | Continuous execution (TDD gates still enforced) |
| `--from=PHASE` | Start from specific phase |
| `--e2e` | Force E2E testing |
| `--no-e2e` | Skip E2E testing |
| `--user-docs` | Force user documentation |
| `--no-user-docs` | Skip user documentation |
| `--code-review` | Force code review |
| `--no-code-review` | Skip code review |

---

## Orchestrator Workflow Execution

### Initialization

**STEP 1: Parse Command Arguments**

Extract from invocation:
- Task description (if provided)
- Execution mode: `--yolo` flag or default interactive
- Task type: `--type=bug|enhancement|feature` or auto-detect
- Entry point: `--from=phase` (analysis, gap, spec, plan, implement, verify)
- Optional phase flags: `--e2e`, `--user-docs`, `--code-review`
- Task path: If resuming existing task

**STEP 2: Determine Starting Phase**

**If task path provided** (resuming):
1. Read `orchestrator-state.yml` if exists
2. Check completed_phases from state
3. **Validate artifacts for completed phases**:
   - For each phase in completed_phases:
     - Look up expected artifacts from "Expected Artifacts by Phase" table
     - Check if artifact file exists in task directory
     - If artifact missing AND condition is met (e.g., code_review_enabled for code-review-report.md):
       - Remove phase from completed_phases
       - Log: "⚠️ Phase [N] marked complete but artifact [path] missing. Will re-run."
       - Update orchestrator-state.yml with modified completed_phases
4. Determine next phase to execute (first incomplete or artifact-missing phase)
5. Validate prerequisites for that phase

**Artifact Validation Logic**:
```
For phase in completed_phases:
  artifacts = EXPECTED_ARTIFACTS[phase]  # From table
  For artifact in artifacts:
    If artifact.condition == "Always" OR artifact.condition_flag_is_true:
      If NOT exists(task_path / artifact.path):
        completed_phases.remove(phase)
        Log: "⚠️ Phase [phase] artifact [artifact.path] missing. Phase will be re-run."
```

**If new task**:
1. Start from specified phase (`--from`) or Phase 1 (default)
2. If starting mid-workflow, validate required files exist:
   - Starting from gap (Phase 2): Requires `analysis/codebase-analysis.md`
   - Starting from spec (Phase 5): Requires `analysis/gap-analysis.md`
   - Starting from plan (Phase 7): Requires `implementation/spec.md`
   - Starting from implement (Phase 8): Requires `implementation/spec.md` + `implementation/implementation-plan.md`
   - Starting from verify (Phase 11): Requires implementation complete

**If prerequisites missing**:
```
❌ Cannot start from [phase] - missing prerequisites!

Required files:
- [file1]: ❌ Missing
- [file2]: ✅ Found

Options:
1. Start from beginning (Phase 0: Codebase Analysis)
2. Provide/create missing files manually
3. Specify different entry point with --from

Use AskUserQuestion tool:
  Question: "Cannot start from [phase] - prerequisites missing. What would you like to do?"
  Header: "Prerequisites"
  Options:
  1. "Start from Phase 0" - Begin workflow from the beginning
  2. "Specify different phase" - Choose another entry point
  3. "Exit" - Cancel and resolve manually
```

**STEP 3: Initialize State Management**

**CRITICAL: You MUST create the orchestrator-state.yml file:**

1. Create task directory if new task:
   ```
   .ai-sdlc/tasks/[type-directory]/YYYY-MM-DD-task-name/
   ```

2. **Create orchestrator-state.yml** with initial state:

```yaml
orchestrator:
  task_type: [bug | enhancement | feature]
  mode: [interactive | yolo]
  started_phase: [phase name]
  current_phase: [phase name]
  completed_phases: []
  failed_phases: []
  auto_fix_attempts:
    codebase_analysis: 0
    clarifying_questions: 0
    gap_analysis: 0
    tdd_red: 0           # Bug only
    specification: 0
    planning: 0
    implementation: 0
    tdd_green: 0         # Bug only
    verification: 0
    e2e_testing: 0
  options:
    e2e_enabled: [true | false | null]
    user_docs_enabled: [true | false | null]
    code_review_enabled: [true | false | null]
    code_review_scope: [null | "all" | "quality" | "security" | "performance"]
    production_check_enabled: [true | false | null]
    pragmatic_review_enabled: [true | false | null]
    reality_check_enabled: [true | false | null]
  task_context:
    type: [bug | enhancement | feature]
    risk_level: null
    ui_heavy: null
    tdd_applicable: true  # Bug only
    reproduction_data: null  # Bug only
  created: [actual current time in ISO 8601, e.g., 2025-12-16T14:30:45Z]
  updated: [actual current time in ISO 8601, e.g., 2025-12-16T14:30:45Z]
  task_path: .ai-sdlc/tasks/[type]/YYYY-MM-DD-task-name
```

3. Create metadata.yml if new task:
```yaml
task:
  title: [task name]
  description: [task description]
  type: [bug | enhancement | feature]
  status: in_progress
  created: [actual current time in ISO 8601, e.g., 2025-12-16T14:30:45Z]
  updated: [actual current time in ISO 8601, e.g., 2025-12-16T14:30:45Z]
```

**STEP 4: Output Initialization Summary**

Output this summary to the user (already defined in MANDATORY Initialization section).

---

## Phase Execution Loop

**FOR each phase in workflow, execute these steps:**

**STEP 1: Check if Phase Already Completed**

Read `orchestrator-state.yml`:
- If phase in `completed_phases`: Skip to next phase
- If phase in `failed_phases` and max retries exceeded: Halt with error
- Otherwise: Proceed with execution

**STEP 1.5: Handle Phase Re-Run (Resume Only)**

If resuming and phase was previously in completed_phases but removed due to missing artifacts:
1. Log: "🔄 Re-running Phase [N] due to missing artifacts"
2. Reset any phase-specific context:
   - If Phase 7 needs re-run and verification options were set: Re-prompt for verification options (Phase 6)
   - If Phase 5 needs re-run: Preserve implementation-plan.md, clear work-log.md
3. Clear `auto_fix_attempts` for this phase (reset counter to 0)
4. Continue with normal phase execution

**Note**: This step is only executed during resume when STEP 2 of Initialization detected missing artifacts.

**STEP 2: Update State to Current Phase**

Update orchestrator-state.yml:
```yaml
orchestrator:
  current_phase: [phase-name]
  updated: [actual current time in ISO 8601, e.g., 2025-12-16T14:30:45Z]
```

**STEP 3: Pre-Phase Announcement**

Output:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phase [N]: [Phase Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Phase description]

Invoking: [skill-name/agent-name]

Starting...
```

**STEP 4: Execute Phase**

Execute the phase according to its definition (Workflow Phases section).

**STEP 5: Handle Errors**

If phase fails:
1. Increment `auto_fix_attempts.[phase]` in state
2. If under max attempts: Try auto-fix strategy
3. If max attempts exceeded:
   ```
   Use AskUserQuestion tool:
     Question: "Phase [N] failed after [X] attempts. How would you like to proceed?"
     Header: "Phase Failed"
     Options:
     1. "Retry with guidance" - I'll provide more context for another attempt
     2. "Skip this phase" - Continue to next phase (may cause issues)
     3. "Rollback changes" - Undo changes from this phase
     4. "Stop workflow" - Pause and resume later
   ```

**STEP 6: Update State on Success**

Update orchestrator-state.yml:
```yaml
orchestrator:
  completed_phases:
    - [phase-name]  # Add to list
  current_phase: [next-phase]
  updated: [actual current time in ISO 8601, e.g., 2025-12-16T14:30:45Z]
```

**STEP 7: Post-Phase Review (Interactive Mode Only)**

**IF interactive mode (not YOLO):**

```
✅ Phase [N] Complete: [Phase Name]

Results:
- [Key result 1]
- [Key result 2]

Status: [Success/Success with warnings]

[If warnings exist]
⚠️ Warnings:
- [Warning 1]
- [Warning 2]

[If Phase 1 complete, show classification]
📊 Task Classification:
- Type: [Bug/Enhancement/Feature]
- Risk: [Low/Medium/High]
- UI Heavy: [Yes/No]
```

**Use AskUserQuestion tool:**
```
Use AskUserQuestion tool:
  Question: "Phase [N] ([Phase Name]) complete. How would you like to proceed?"
  Header: "Phase Complete"
  Options:
  1. "Continue to next phase" - Proceed with workflow
     Description: "Move to [Next Phase Name]"
  2. "Review outputs in detail" - Open phase artifacts for review
     Description: "View [output-file.md] before continuing"
  3. "Restart this phase" - Re-execute this phase
     Description: "Discard results and run phase again"
  4. "Stop workflow" - Pause and resume later
     Description: "Save state and exit. Resume with /ai-sdlc:development:resume"
```

Wait for user response and handle accordingly.

**IF YOLO mode:**

Just output and continue:
```
✅ Phase [N] Complete: [Phase Name]
Status: [Success/Success with warnings]
→ Continuing to next phase...
```

---

## Standards Discovery

**CRITICAL: Reference `.ai-sdlc/docs/INDEX.md` throughout the workflow.**

### When to Check Standards

1. **Phase 5 (Specification)**: Read INDEX.md to understand project standards before creating spec
2. **Phase 7 (Planning)**: Ensure implementation plan follows project conventions
3. **Phase 8 (Implementation)**: Continuous standards discovery - read INDEX.md before making changes
4. **Phase 11 (Verification)**: Verify implementation follows documented standards

### Standards Reminder

Before Phases 5, 7, 8, and 11, include this reminder:

```
📋 Standards Discovery

Reading .ai-sdlc/docs/INDEX.md to check applicable standards...

[If INDEX.md exists]
Found standards:
- [List relevant standards from INDEX.md]

Applying these standards during this phase.

[If INDEX.md doesn't exist]
No INDEX.md found. Proceeding without explicit standards.
Consider running /ai-sdlc:init-sdlc to initialize project documentation.
```

### Pass Standards to Skills

When invoking skills (specification-creator, implementation-planner, implementer, implementation-verifier):
- Pass path to INDEX.md
- Include note about standards discovery requirement
- Skills should actively read and apply standards

---

## Integration with Old Commands

This orchestrator replaces:
- `bug-fix-orchestrator` → `--type=bug`
- `enhancement-orchestrator` → `--type=enhancement`
- `feature-orchestrator` → `--type=feature`

Old commands are aliases:
- `/ai-sdlc:bug-fix:new` → `/ai-sdlc:development:new --type=bug`
- `/ai-sdlc:enhancement:new` → `/ai-sdlc:development:new --type=enhancement`
- `/ai-sdlc:feature:new` → `/ai-sdlc:development:new --type=feature`
