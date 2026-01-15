---
name: performance-orchestrator
description: Orchestrates performance optimization workflows with profiling, benchmarking, and load testing. Measures baseline, identifies bottlenecks, implements optimizations incrementally with benchmarks, and verifies production readiness.
---

# Performance Orchestrator

Systematic performance optimization workflow from profiling to production-ready deployment.

## MANDATORY Initialization (Before Any Phase Work)

**CRITICAL: You MUST complete these steps BEFORE executing any workflow phase:**

### Step 0: Load Framework Patterns

**STOP. You MUST read these files NOW using the Read tool before continuing:**

1. `../orchestrator-framework/references/phase-execution-pattern.md` - 7-step phase loop
2. `../orchestrator-framework/references/delegation-enforcement.md` - Delegation patterns and subagent result handling
3. `../orchestrator-framework/references/interactive-mode.md` - Phase gates and AUTO-CONTINUE
4. `../orchestrator-framework/references/state-management.md` - State file operations

**⚠️ FAILURE TO READ THESE FILES IS A WORKFLOW VIOLATION.**

These patterns define:
- How to execute each phase (7-step loop)
- How to delegate to skills (mandatory patterns)
- When to auto-continue vs pause (Phase Gates and ⚡ AUTO)
- How to consume subagent results and continue workflow
- How to manage orchestrator-state.yml

**SELF-CHECK:**
- [ ] Did you use the Read tool to read all 4 files?
- [ ] Do you understand the AUTO-CONTINUE pattern in interactive-mode.md?
- [ ] Do you understand Pattern 6 (Consuming Subagent Results) in delegation-enforcement.md?

If NO to any: STOP and read the files now.

### Step 1: Create TodoWrite with All Phases

**Immediately use the TodoWrite tool** to create todos for all phases:

```
Use TodoWrite tool with todos:
[
  {"content": "Profile and establish baseline", "status": "pending", "activeForm": "Profiling and establishing baseline"},
  {"content": "Analyze bottlenecks and plan", "status": "pending", "activeForm": "Analyzing bottlenecks and planning"},
  {"content": "Implement with benchmarking", "status": "pending", "activeForm": "Implementing with benchmarking"},
  {"content": "Verify performance improvements", "status": "pending", "activeForm": "Verifying performance improvements"},
  {"content": "Resolve verification issues", "status": "pending", "activeForm": "Resolving verification issues"},
  {"content": "Load test and check readiness", "status": "pending", "activeForm": "Load testing and checking readiness"}
]
```

Note: Phase 3.5 (Issue Resolution) runs conditionally if verification finds fixable issues.

### Step 2: Output Initialization Summary

**Output this summary to the user:**

```
🚀 Performance Orchestrator Started

Task: [performance issue description]
Mode: [Interactive/YOLO]
Directory: [task-path]

Workflow phases:
[Todos list with status]

[Interactive mode] You'll be prompted for review after each phase.
[YOLO mode] All phases will run continuously.

Starting Phase 0: Profile and establish baseline...
```

### Step 3: Only Then Proceed to Phase 0

After completing Steps 1 and 2, proceed to Phase 0 (Performance Baseline & Profiling).

---

## When to Use This Skill

Use when:
- Application slow (response time >1s, high latency)
- Need systematic optimization workflow
- Want benchmarking and verification
- Require load testing before production
- Performance issues reported

## Core Principles

1. **Measure First**: Never optimize without baseline metrics
2. **Benchmark-Driven**: Prove every optimization with benchmarks
3. **Incremental**: One optimization at a time (attribute improvements)
4. **Production-Realistic**: Test with real data volumes and traffic patterns
5. **Quantitative**: Use objective metrics, not subjective feelings

---

## Local References

Read these during relevant phases:

| File | When to Use | Purpose |
|------|-------------|---------|
| `references/performance-optimization-guide.md` | Phase 1-2 | Optimization patterns, bottleneck classifications, benchmarking strategies |

---

## Phase Configuration

| Phase | content | activeForm | Agent/Skill |
|-------|---------|------------|-------------|
| 0 | "Profile and establish baseline" | "Profiling and establishing baseline" | performance-profiler |
| 1 | "Analyze bottlenecks and plan" | "Analyzing bottlenecks and planning" | bottleneck-analyzer |
| 2 | "Implement with benchmarking" | "Implementing with benchmarking" | orchestrator |
| 3 | "Verify performance improvements" | "Verifying performance improvements" | performance-verifier |
| 3.5 | "Resolve verification issues" | "Resolving verification issues" | orchestrator (conditional) |
| 4 | "Load test and check readiness" | "Load testing and checking readiness" | orchestrator |

**Workflow Overview**: 5-6 phases (Phase 3.5 runs if verification finds fixable issues)

**CRITICAL TodoWrite Usage**:
1. At workflow start: Create todos for ALL phases using the Phase Configuration table above (all status=pending)
2. Before each phase: Update that phase to status=in_progress
3. After each phase: Update that phase to status=completed

---

## Workflow Phases

### Phase 0: Performance Baseline & Profiling

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/performance-profiler.md and following its instructions directly
❌ WRONG: Running profiling commands inline in the orchestrator thread
❌ WRONG: Measuring performance metrics yourself

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 0 to: performance-profiler subagent
Method: Task tool
Expected outputs: analysis/performance-baseline.md
```

**INVOKE NOW:**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:performance-profiler"
  description: "Profile and establish baseline"
  prompt: |
    You are the performance-profiler agent. Analyze application performance
    and create a comprehensive baseline report.

    Performance Issue: [user description]
    Task directory: [task-path]

    Please:
    1. Identify performance target from description
    2. Measure response time (p50, p95, p99) using load testing
    3. Measure throughput (req/sec, saturation point)
    4. Profile CPU usage (hot functions)
    5. Profile memory usage (heap size, growth, leaks)
    6. Count database queries (N+1 patterns, slow queries)
    7. Identify performance hotspots
    8. Generate comprehensive baseline report

    Save to: analysis/performance-baseline.md
    Use only Read, Grep, Glob, and Bash tools. Do NOT modify code.

⏳ Wait for subagent completion before continuing.

**Outputs**: `analysis/performance-baseline.md`, profiling artifacts

**SELF-CHECK (before proceeding to Phase 1):**
- [ ] Did you invoke the Task tool? (not just read the agent file)
- [ ] Did you wait for the tool to return results?
- [ ] Is `analysis/performance-baseline.md` present?

If NO to any: STOP - go back and invoke the Task tool.

**State Update**: After performance-profiler completes:
- Update `performance_context.baseline_p95` from output p95 response time (milliseconds)
- Update `performance_context.target_p95` from output optimization target (if specified)

---

## 🚦 GATE: Phase 0 → Phase 1

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 0 (Performance Baseline & Profiling) complete. Ready to proceed to Phase 1 (Bottleneck Analysis & Optimization Planning)?"
     - Options: ["Continue to Phase 1", "Review Phase 0 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 1 (Bottleneck Analysis & Optimization Planning)..."
   - Proceed to Phase 1

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 1: Bottleneck Analysis & Optimization Planning

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/bottleneck-analyzer.md and following its instructions directly
❌ WRONG: Analyzing performance baseline inline in the orchestrator thread
❌ WRONG: Creating optimization plan yourself

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 1 to: bottleneck-analyzer subagent
Method: Task tool
Expected outputs: implementation/optimization-plan.md
```

**INVOKE NOW:**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:bottleneck-analyzer"
  description: "Analyze bottlenecks and plan"
  prompt: |
    You are the bottleneck-analyzer agent. Analyze performance baseline
    data and create prioritized optimization plan.

    Task directory: [task-path]

    Please:
    1. Load performance baseline from analysis/performance-baseline.md
    2. Analyze database performance (detect N+1 queries, missing indexes)
    3. Review CPU hotspots (identify inefficient algorithms)
    4. Detect memory issues (leaks, excessive allocations)
    5. Identify I/O bottlenecks (blocking operations, slow APIs)
    6. Classify bottlenecks by type
    7. Assess impact and effort for each bottleneck
    8. Create prioritized optimization plan (P0/P1/P2/P3)

    Save to: implementation/optimization-plan.md
    Use only Read, Grep, Glob, and Bash tools. Do NOT modify code.

⏳ Wait for subagent completion before continuing.

**Outputs**: `implementation/optimization-plan.md`

**SELF-CHECK (before proceeding to Phase 2):**
- [ ] Did you invoke the Task tool? (not just read the agent file)
- [ ] Did you wait for the tool to return results?
- [ ] Is `implementation/optimization-plan.md` present?

If NO to any: STOP - go back and invoke the Task tool.

**State Update**: After bottleneck-analyzer completes:
- Update `performance_context.optimizations_planned` from output total optimization count

---

## 🚦 GATE: Phase 1 → Phase 2

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 1 (Bottleneck Analysis & Optimization Planning) complete. Ready to proceed to Phase 2 (Implementation with Benchmarking)?"
     - Options: ["Continue to Phase 2", "Review Phase 1 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 2 (Implementation with Benchmarking)..."
   - Proceed to Phase 2

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 2: Implementation with Benchmarking

**Execution**: Main orchestrator (direct for simple, delegates for complex)

**Standards Reminder**: Review `.ai-sdlc/docs/INDEX.md` for performance standards before implementing.

**Process** (for each optimization in priority order P0 → P1 → P2 → P3):

1. **Read Optimization Details** from `implementation/optimization-plan.md`
2. **Benchmark Before** - Measure current performance for target endpoint
3. **Implement Optimization**:
   - Simple (1-3 files): Edit directly
   - Complex (4+ files): **MUST delegate** to `implementation-changes-planner`
4. **Benchmark After** - Re-measure performance
5. **Verify Improvement** - Calculate percentage improvement vs target
6. **Run Tests** - Ensure no regressions
7. **Update Plan** - Mark optimization complete/failed, document results
8. **State Update** - After each optimization completes: Increment `performance_context.optimizations_completed`

**For Complex Optimizations (4+ files):**

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/implementation-changes-planner.md and following instructions directly
❌ WRONG: Planning changes for 4+ files inline in the orchestrator thread
❌ WRONG: Implementing complex optimizations without a structured change plan

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating optimization change planning to: implementation-changes-planner subagent
Method: Task tool
Expected outputs: Change plan for current optimization
```

**INVOKE NOW (for complex optimizations):**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:implementation-changes-planner"
  description: "Plan performance optimization changes"
  prompt: |
    Plan changes for optimization [N]: [optimization description]
    Task directory: [task-path]
    Optimization plan: implementation/optimization-plan.md
    Target files: [list of files for this optimization]

⏳ Wait for subagent completion, then apply changes.

**Outputs**:
- Modified code files
- `implementation/benchmarks/*.txt` - Before/after benchmarks
- Updated `implementation/optimization-plan.md`

**Success**: All optimizations implemented (or attempted), benchmarked, documented

---

## 🚦 GATE: Phase 2 → Phase 3

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 2 (Implementation with Benchmarking) complete. Ready to proceed to Phase 3 (Performance Verification)?"
     - Options: ["Continue to Phase 3", "Review Phase 2 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 3 (Performance Verification)..."
   - Proceed to Phase 3

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 3: Performance Verification

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/performance-verifier.md and following its instructions directly
❌ WRONG: Running verification benchmarks inline in the orchestrator thread
❌ WRONG: Creating verification report yourself

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 3 to: performance-verifier subagent
Method: Task tool
Expected outputs: verification/performance-verification.md
```

**INVOKE NOW:**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:performance-verifier"
  description: "Verify performance improvements"
  prompt: |
    You are the performance-verifier agent. Verify performance optimizations
    achieved target improvements.

    Task directory: [task-path]

    Please:
    1. Load baseline metrics from analysis/performance-baseline.md
    2. Load optimization targets from implementation/optimization-plan.md
    3. Re-measure all performance metrics (same methodology as baseline)
    4. Compare baseline vs optimized (calculate improvement percentages)
    5. Verify optimization targets met
    6. Check for regressions (other endpoints slower)
    7. Generate verification report with PASS/FAIL verdict

    Save to: verification/performance-verification.md
    Use only Read, Grep, Glob, and Bash tools. Do NOT modify code.

    Verdict Criteria:
    - PASS: All critical targets met, no critical regressions
    - PASS with Concerns: Most targets met (>80%), minor regressions only
    - FAIL: Critical targets not met (<80%) or critical regressions

⏳ Wait for subagent completion before continuing.

**Outputs**: `verification/performance-verification.md` with verdict

**SELF-CHECK (before proceeding to Phase 4):**
- [ ] Did you invoke the Task tool? (not just read the agent file)
- [ ] Did you wait for the tool to return results?
- [ ] Is `verification/performance-verification.md` present?

If NO to any: STOP - go back and invoke the Task tool.

**Gate**: Cannot proceed to Phase 4 if verdict = FAIL

**State Update**: After performance-verifier completes:
- Update `performance_context.verification_verdict` from output verdict ("PASS", "PASS with Concerns", or "FAIL")
- Update `performance_context.overall_improvement` from output percentage (e.g., "65%")

---

## 🚦 GATE: Phase 3 → Phase 3.5 or Phase 4

**STOP. You cannot proceed until this gate clears.**

**Check verification result from `performance_context.verification_verdict`:**

1. **If verdict = "PASS"**: Skip Phase 3.5, go directly to Phase 4
2. **If verdict = "PASS with Concerns"**: Enter Issue Resolution (Phase 3.5)
3. **If verdict = "FAIL"**: Check `verification_context.issues` for fixable issues
   - If fixable issues exist AND `verification_context.reverify_count` < 3: Enter Phase 3.5
   - Otherwise: STOP workflow, report failures to user

**Mode check (if proceeding to Phase 4 directly):**
1. Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 3 (Performance Verification) passed. Ready to proceed to Phase 4 (Load Testing & Production Readiness)?"
     - Options: ["Continue to Phase 4", "Review Phase 3 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 4 (Load Testing & Production Readiness)..."
   - Proceed to Phase 4

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 3.5: Issue Resolution (Conditional)

**When to execute**: Verification returned "PASS with Concerns" or "FAIL" with fixable issues

**Reference**: See `../orchestrator-framework/references/issue-resolution-pattern.md` for detailed pattern.

**Process Overview**:

1. **Parse Structured Output** from performance-verifier:
   - Extract `issues[]` array with severity, source, fixable status
   - Note `issue_counts` (critical, warning, info)
   - Check `metrics.regressions_found`

2. **Categorize Issues**:
   - **Auto-fixable**: Cache config tuning, query hints, simple index additions, config adjustments
   - **User decision needed**: Trade-off decisions (memory vs speed), breaking changes
   - **Not fixable here**: Algorithm redesign, architecture changes, complex optimization trade-offs

3. **For Each Fixable Issue**:
   - If auto-fixable: Apply fix directly
   - If needs user decision: Use `AskUserQuestion`:
     ```
     Question: "Performance issue: [description]. How to proceed?"
     Options:
     - "Apply suggested fix" (if fix is clear)
     - "Skip this issue" (accept the trade-off)
     - "Stop and investigate" (need more analysis)
     ```

4. **Track Progress**:
   ```yaml
   verification_context:
     last_status: "passed_with_concerns"
     issues_found: [count]
     fixes_applied: [list of applied fixes]
     decisions_made:
       - issue: "[description]"
         decision: "fix" | "skip" | "defer"
     reverify_count: [0-3]
   ```

5. **Re-verify**: After applying fixes, invoke performance-verifier again (increment `reverify_count`)

6. **Exit Conditions**:
   - ✅ New verdict = "PASS" → Proceed to Phase 4
   - ⚠️ Max iterations (3) reached → Ask user: continue with concerns or stop
   - ❌ Critical regressions remain → Report to user, recommend stopping

**State Update**: After Issue Resolution:
- Update `verification_context.reverify_count`
- Update `verification_context.fixes_applied` with list of fixes
- Update `performance_context.verification_verdict` with new verdict

---

## 🚦 GATE: Phase 3.5 → Phase 4

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 3.5 (Issue Resolution) complete. [N] issues fixed. Ready to proceed to Phase 4 (Load Testing & Production Readiness)?"
     - Options: ["Continue to Phase 4", "Review resolution results", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 4 (Load Testing & Production Readiness)..."
   - Proceed to Phase 4

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 4: Load Testing & Production Readiness

**State Update**: When deciding which optional checks to run (Interactive or YOLO):
- Set `options.skip_load_testing` based on user choice or auto-decision (default: false)
- Set `options.skip_production_check` based on user choice or auto-decision (default: false for production deployments)

**Execution**: Main orchestrator (optionally delegates to `production-readiness-checker`)

**Prerequisites**: Phase 3 verdict = PASS or PASS with Concerns

**Process**:

1. **Configure Load Tests** - Define scenarios (ramp-up, sustained, spike)
2. **Run Load Tests** - Execute using k6 or similar tool
3. **Monitor Resources** - CPU (<90%), memory (stable), connections, error rates (<1%)
4. **Analyze Results** - Response times under load, throughput capacity
5. **Production Readiness** (if `options.skip_production_check = false`) - Delegate to `production-readiness-checker`
6. **Generate Report** - Create `verification/load-test-results.md`

**Load Test Scenarios**:
- Ramp-up: Gradually increase to 200 VUs over 10 minutes
- Sustained: 500 VUs for 30 minutes
- Spike: 10x sudden increase to 1000 VUs

**For Production Readiness Check (Step 5):**

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading production-readiness-checker/skill.md and following its instructions directly
❌ WRONG: Running production readiness checks inline in the orchestrator thread
❌ WRONG: Creating production readiness report yourself

✅ RIGHT: Using the Skill tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating production readiness check to: production-readiness-checker skill
Method: Skill tool
Expected outputs: verification/production-readiness-report.md
```

**INVOKE NOW (for production readiness):**

Tool: `Skill`
Parameters:
  skill: "ai-sdlc:production-readiness-checker"

⏳ Wait for skill completion before continuing.

**SELF-CHECK (after production readiness check):**
- [ ] Did you invoke the Skill tool? (not just skip or do inline)
- [ ] Did you wait for the tool to return results?
- [ ] Is `verification/production-readiness-report.md` present?

If NO to any and `options.skip_production_check = false`: STOP - go back and invoke the Skill tool.

**Outputs**:
- `verification/load-test-results.md`
- `verification/production-readiness-report.md` (if production check enabled)

**Success**: Load tests pass, production readiness verified

---

## Domain Context (State Extensions)

Performance-specific fields in `orchestrator-state.yml`:

```yaml
performance_context:
  baseline_p95: [milliseconds]
  target_p95: [milliseconds]
  optimizations_planned: [number]
  optimizations_completed: [number]
  verification_verdict: "PASS" | "PASS with Concerns" | "FAIL"
  overall_improvement: "[percentage]%"

# Issue Resolution tracking (Phase 3.5)
verification_context:
  last_status: "passed" | "passed_with_concerns" | "failed"
  issues_found: [number]
  fixes_applied:
    - "[description of fix 1]"
    - "[description of fix 2]"
  decisions_made:
    - issue: "[issue description]"
      decision: "fix" | "skip" | "defer"
  reverify_count: 0  # max 3

options:
  skip_load_testing: false
  skip_production_check: false
```

---

## Auto-Recovery

| Phase | Max Attempts | Strategy |
|-------|--------------|----------|
| 0 | 2 | Expand profiling, try alternatives, prompt user |
| 1 | 2 | Prompt user if bottleneck unclear, use conservative estimates |
| 2 | 3 | Fix syntax errors, retry benchmarks, rollback failed optimizations |
| 3 | 0 | Read-only, report only |
| 4 | 1 | Retry failed load tests, adjust parameters |

---

## Command Integration

Invoked via:
- `/ai-sdlc:performance:new [description] [--yolo]`
- `/ai-sdlc:performance:resume [task-path]`

Task directory: `.ai-sdlc/tasks/performance/YYYY-MM-DD-task-name/`

---

## Success Criteria

Workflow successful when:

- Performance baseline documented with all metrics
- Bottlenecks identified and prioritized
- All P0 optimizations implemented and verified
- Verification verdict = PASS (targets met, no critical regressions)
- Load tests pass under production-like load
- Overall performance improvement 50-70%+
- Ready for production deployment
