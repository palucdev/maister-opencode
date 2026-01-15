---
name: security-orchestrator
description: Orchestrates security remediation workflows from vulnerability analysis through compliance audit. Identifies security issues, creates prioritized remediation plan, implements fixes incrementally with testing, verifies improvements, and optionally audits compliance (GDPR, HIPAA, SOC 2, PCI DSS).
---

# Security Orchestrator

Systematic security remediation workflow from vulnerability analysis to compliance-ready deployment.

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
  {"content": "Analyze vulnerabilities and baseline", "status": "pending", "activeForm": "Analyzing vulnerabilities and baseline"},
  {"content": "Plan security remediation", "status": "pending", "activeForm": "Planning security remediation"},
  {"content": "Implement security fixes", "status": "pending", "activeForm": "Implementing security fixes"},
  {"content": "Verify security improvements", "status": "pending", "activeForm": "Verifying security improvements"},
  {"content": "Resolve verification issues", "status": "pending", "activeForm": "Resolving verification issues"},
  {"content": "Audit compliance", "status": "pending", "activeForm": "Auditing compliance"}
]
```

Note: Phase 3.5 (Issue Resolution) runs conditionally if verification finds fixable issues.
Note: Phase 4 (Audit compliance) is optional based on compliance requirements.

### Step 2: Output Initialization Summary

**Output this summary to the user:**

```
🚀 Security Orchestrator Started

Task: [security issue description]
Mode: [Interactive/YOLO]
Directory: [task-path]

Workflow phases:
[Todos list with status]

[Interactive mode] You'll be prompted for review after each phase.
[YOLO mode] All phases will run continuously.

Starting Phase 0: Analyze vulnerabilities and baseline...
```

### Step 3: Only Then Proceed to Phase 0

After completing Steps 1 and 2, proceed to Phase 0 (Vulnerability Analysis & Security Baseline).

---

## When to Use This Skill

Use when:
- Security vulnerabilities detected (dependency CVEs, code vulnerabilities)
- Need systematic security remediation workflow
- Want CVSS-scored vulnerability prioritization
- Require compliance audit (GDPR, HIPAA, SOC 2, PCI DSS)
- Security issues reported or discovered

## Core Principles

1. **Evidence-Based**: Every finding backed by scan results or code inspection
2. **CVSS-Scored**: Quantitative severity assessment for all vulnerabilities
3. **Risk-Prioritized**: Critical vulnerabilities fixed first
4. **Incremental**: Small, testable security fixes
5. **Verified**: Prove every fix with before/after scans

---

## Local References

Read these during relevant phases:

| File | When to Use | Purpose |
|------|-------------|---------|
| `references/security-guide.md` | Phase 0-2 | Vulnerability detection patterns and fix strategies |
| `references/vulnerability-types.md` | Phase 0-1 | CVSS scoring guidance and vulnerability classification |

---

## Phase Configuration

| Phase | content | activeForm | Agent/Skill |
|-------|---------|------------|-------------|
| 0 | "Analyze vulnerabilities and baseline" | "Analyzing vulnerabilities and baseline" | security-analyzer |
| 1 | "Plan security remediation" | "Planning security remediation" | security-planner |
| 2 | "Implement security fixes" | "Implementing security fixes" | orchestrator |
| 3 | "Verify security improvements" | "Verifying security improvements" | security-verifier |
| 3.5 | "Resolve verification issues" | "Resolving verification issues" | orchestrator (conditional) |
| 4 | "Audit compliance" | "Auditing compliance" | compliance-auditor (optional) |

**Workflow Overview**: 4-6 phases (Phase 3.5 runs if verification finds fixable issues, Phase 4 optional based on compliance requirements)

**CRITICAL TodoWrite Usage**:
1. At workflow start: Create todos for ALL phases using the Phase Configuration table above (all status=pending)
2. Before each phase: Update that phase to status=in_progress
3. After each phase: Update that phase to status=completed

---

## Workflow Phases

### Phase 0: Vulnerability Analysis & Security Baseline

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/security-analyzer.md and following its instructions directly
❌ WRONG: Running security scans inline in the orchestrator thread
❌ WRONG: Analyzing vulnerabilities yourself

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 0 to: security-analyzer subagent
Method: Task tool
Expected outputs: analysis/security-baseline.md
```

**INVOKE NOW:**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:security-analyzer"
  description: "Analyze vulnerabilities and baseline"
  prompt: |
    You are the security-analyzer agent. Analyze application security and create
    a comprehensive baseline of vulnerabilities.

    Security Issue Description: [user description]
    Task directory: [task-path]

    Please:
    1. Scan dependencies for known vulnerabilities (npm audit, pip-audit, etc.)
    2. Analyze authentication and authorization code
    3. Detect injection vulnerabilities (SQL, XSS, command injection)
    4. Find sensitive data exposure (hardcoded secrets, logging)
    5. Check for security misconfigurations
    6. Identify insecure dependencies
    7. Detect business logic vulnerabilities
    8. Score each vulnerability using CVSS v3.1
    9. Classify by OWASP Top 10 categories
    10. Generate comprehensive security baseline report

    Save to: analysis/security-baseline.md
    Use only Read, Grep, Glob, and Bash tools. Do NOT modify code.

⏳ Wait for subagent completion before continuing.

**Outputs**: `analysis/security-baseline.md`, scan artifacts

**SELF-CHECK (before proceeding to Phase 1):**
- [ ] Did you invoke the Task tool? (not just read the agent file)
- [ ] Did you wait for the tool to return results?
- [ ] Is `analysis/security-baseline.md` present?

If NO to any: STOP - go back and invoke the Task tool.

**State Update**: After security-analyzer completes:
- Update `security_context.baseline_vulnerabilities` from output total vulnerability count
- Update `security_context.critical_vulnerabilities` from output critical/high count

---

## 🚦 GATE: Phase 0 → Phase 1

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 0 (Vulnerability Analysis & Security Baseline) complete. Ready to proceed to Phase 1 (Security Planning & Remediation Strategy)?"
     - Options: ["Continue to Phase 1", "Review Phase 0 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 1 (Security Planning & Remediation Strategy)..."
   - Proceed to Phase 1

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 1: Security Planning & Remediation Strategy

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/security-planner.md and following its instructions directly
❌ WRONG: Creating remediation plan inline in the orchestrator thread
❌ WRONG: Prioritizing vulnerabilities yourself

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 1 to: security-planner subagent
Method: Task tool
Expected outputs: implementation/security-remediation-plan.md
```

**INVOKE NOW:**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:security-planner"
  description: "Plan security remediation"
  prompt: |
    You are the security-planner agent. Analyze security baseline and create
    prioritized remediation plan.

    Task directory: [task-path]

    Please:
    1. Load security baseline from analysis/security-baseline.md
    2. Classify fix types (dependency, code pattern, config, cryptography, etc.)
    3. Assess impact and effort for each fix
    4. Calculate priority scores (CVSS × 10 + Impact × 2 - Effort)
    5. Group fixes by type and dependency
    6. Break into incremental steps (max 3 files per increment)
    7. Define verification steps for each fix
    8. Identify breaking change risks with mitigation
    9. Create comprehensive remediation plan

    Save to: implementation/security-remediation-plan.md
    Use only Read, Grep, Glob, and Bash tools. Do NOT modify code.

⏳ Wait for subagent completion before continuing.

**Outputs**: `implementation/security-remediation-plan.md`

**SELF-CHECK (before proceeding to Phase 2):**
- [ ] Did you invoke the Task tool? (not just read the agent file)
- [ ] Did you wait for the tool to return results?
- [ ] Is `implementation/security-remediation-plan.md` present?

If NO to any: STOP - go back and invoke the Task tool.

**State Update**: After security-planner completes:
- Update `security_context.fixes_planned` from output total fix count

---

## 🚦 GATE: Phase 1 → Phase 2

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 1 (Security Planning & Remediation Strategy) complete. Ready to proceed to Phase 2 (Security Implementation with Testing)?"
     - Options: ["Continue to Phase 2", "Review Phase 1 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 2 (Security Implementation with Testing)..."
   - Proceed to Phase 2

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 2: Security Implementation with Testing

**Execution**: Main orchestrator (direct for simple, delegates for complex)

**Standards Reminder**: Review `.ai-sdlc/docs/INDEX.md` for security standards before implementing.

**Process** (for each fix in priority order P0 → P1 → P2 → P3):

1. **Read Fix Details** from `implementation/security-remediation-plan.md`
2. **Security Scan Before** - Run relevant scanner, save baseline
3. **Implement Fix**:
   - Simple (1-3 files): Edit directly
   - Complex (4+ files): **MUST delegate** to `implementation-changes-planner`
4. **Security Scan After** - Re-run scanner
5. **Verify Fix** - Compare before/after (eliminated/reduced/unchanged)
6. **Run Tests** - Ensure no regressions
7. **Update Plan** - Mark fix complete/failed, document results
8. **State Update** - After each fix completes: Increment `security_context.fixes_completed`

**For Complex Fixes (4+ files):**

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/implementation-changes-planner.md and following instructions directly
❌ WRONG: Planning changes for 4+ files inline in the orchestrator thread
❌ WRONG: Implementing complex security fixes without a structured change plan

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating fix change planning to: implementation-changes-planner subagent
Method: Task tool
Expected outputs: Change plan for current fix
```

**INVOKE NOW (for complex fixes):**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:implementation-changes-planner"
  description: "Plan security fix changes"
  prompt: |
    Plan changes for security fix [N]: [fix description]
    Task directory: [task-path]
    Remediation plan: implementation/security-remediation-plan.md
    Target files: [list of files for this fix]

⏳ Wait for subagent completion, then apply changes.

**Outputs**:
- Fixed code files
- `implementation/security-scans/*.json` - Before/after scan results
- Updated `implementation/security-remediation-plan.md`

**Success**: All fixes implemented (or attempted), scanned, documented

---

## 🚦 GATE: Phase 2 → Phase 3

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 2 (Security Implementation with Testing) complete. Ready to proceed to Phase 3 (Security Verification)?"
     - Options: ["Continue to Phase 3", "Review Phase 2 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 3 (Security Verification)..."
   - Proceed to Phase 3

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 3: Security Verification

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/security-verifier.md and following its instructions directly
❌ WRONG: Running verification scans inline in the orchestrator thread
❌ WRONG: Creating verification report yourself

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 3 to: security-verifier subagent
Method: Task tool
Expected outputs: verification/security-verification-report.md
```

**INVOKE NOW:**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:security-verifier"
  description: "Verify security improvements"
  prompt: |
    You are the security-verifier agent. Verify security fixes resolved
    vulnerabilities without regressions.

    Task directory: [task-path]

    Please:
    1. Load baseline from analysis/security-baseline.md
    2. Load remediation plan from implementation/security-remediation-plan.md
    3. Re-run all dependency vulnerability scans
    4. Re-scan code for vulnerability patterns
    5. Verify each fix individually
    6. Check for new vulnerabilities introduced
    7. Calculate security improvement metrics
    8. Generate verification report with PASS/FAIL verdict

    Save to: verification/security-verification-report.md
    Use only Read, Grep, Glob, and Bash tools. Do NOT modify code.

    Verdict Criteria:
    - PASS: All P0 fixed, no critical new vulns, risk reduction >70%
    - PASS with Issues: Most P0 fixed (>80%), risk reduction >50%
    - FAIL: Critical vulnerabilities remain or new critical vulns introduced

⏳ Wait for subagent completion before continuing.

**Outputs**: `verification/security-verification-report.md` with verdict

**SELF-CHECK (before proceeding to Phase 4):**
- [ ] Did you invoke the Task tool? (not just read the agent file)
- [ ] Did you wait for the tool to return results?
- [ ] Is `verification/security-verification-report.md` present?

If NO to any: STOP - go back and invoke the Task tool.

**Gate**: Cannot proceed to Phase 4 if verdict = FAIL

**State Update**: After security-verifier completes:
- Update `security_context.verification_verdict` from output verdict ("PASS", "PASS with Issues", or "FAIL")
- Update `security_context.risk_reduction` from output percentage (e.g., "75%")
- Update `security_context.vulnerabilities_fixed` from output fixed count

---

## 🚦 GATE: Phase 3 → Phase 3.5 or Phase 4

**STOP. You cannot proceed until this gate clears.**

**Check verification result from `security_context.verification_verdict`:**

1. **If verdict = "PASS"**: Skip Phase 3.5, go directly to Phase 4
2. **If verdict = "PASS with Issues"**: Enter Issue Resolution (Phase 3.5)
3. **If verdict = "FAIL"**: Check `verification_context.issues` for fixable issues
   - If fixable issues exist AND `verification_context.reverify_count` < 3: Enter Phase 3.5
   - Otherwise: STOP workflow, report failures to user

**Mode check (if proceeding to Phase 4 directly):**
1. Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 3 (Security Verification) passed. Ready to proceed to Phase 4 (Compliance Audit)?"
     - Options: ["Continue to Phase 4", "Review Phase 3 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 4 (Compliance Audit)..."
   - Proceed to Phase 4

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 3.5: Issue Resolution (Conditional)

**When to execute**: Verification returned "PASS with Issues" or "FAIL" with fixable issues

**Reference**: See `../orchestrator-framework/references/issue-resolution-pattern.md` for detailed pattern.

**Process Overview**:

1. **Parse Structured Output** from security-verifier:
   - Extract `issues[]` array with severity, source, fixable status
   - Note `issue_counts` (critical, warning, info)

2. **Categorize Issues**:
   - **Auto-fixable**: Dependency bumps (non-breaking), simple config changes, permission tightening
   - **User decision needed**: Breaking dependency changes, config changes that may affect functionality
   - **Not fixable here**: Architectural security changes, complex auth fixes (require new cycle)

3. **For Each Fixable Issue**:
   - If auto-fixable: Apply fix directly
   - If needs user decision: Use `AskUserQuestion`:
     ```
     Question: "Security issue: [description]. How to proceed?"
     Options:
     - "Apply suggested fix" (if fix is clear)
     - "Skip this issue" (accept the risk)
     - "Stop and investigate" (need more analysis)
     ```

4. **Track Progress**:
   ```yaml
   verification_context:
     last_status: "passed_with_issues"
     issues_found: [count]
     fixes_applied: [list of applied fixes]
     decisions_made:
       - issue: "[description]"
         decision: "fix" | "skip" | "defer"
     reverify_count: [0-3]
   ```

5. **Re-verify**: After applying fixes, invoke security-verifier again (increment `reverify_count`)

6. **Exit Conditions**:
   - ✅ New verdict = "PASS" → Proceed to Phase 4
   - ⚠️ Max iterations (3) reached → Ask user: continue with warnings or stop
   - ❌ Critical unfixable issues remain → Report to user, recommend stopping

**State Update**: After Issue Resolution:
- Update `verification_context.reverify_count`
- Update `verification_context.fixes_applied` with list of fixes
- Update `security_context.verification_verdict` with new verdict

---

## 🚦 GATE: Phase 3.5 → Phase 4

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 3.5 (Issue Resolution) complete. [N] issues fixed. Ready to proceed to Phase 4 (Compliance Audit)?"
     - Options: ["Continue to Phase 4", "Review resolution results", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 4 (Compliance Audit)..."
   - Proceed to Phase 4

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 4: Compliance Audit (Optional)

**State Update**: When deciding whether to run compliance audit (Interactive or YOLO):
- Set `options.skip_compliance_audit` based on user choice or auto-decision (default: false if applicable frameworks detected)
- Set `options.compliance_frameworks` based on detected application type (healthcare→HIPAA, payments→PCI DSS, EU users→GDPR, enterprise→SOC 2)

**Prerequisites**: Phase 3 verdict = PASS or PASS with Issues

**Skip if**: `options.skip_compliance_audit = true`

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/compliance-auditor.md and following its instructions directly
❌ WRONG: Running compliance checks inline in the orchestrator thread
❌ WRONG: Creating compliance report yourself

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 4 to: compliance-auditor subagent
Method: Task tool
Expected outputs: verification/compliance-assessment-report.md
```

**INVOKE NOW:**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:compliance-auditor"
  description: "Audit compliance"
  prompt: |
    You are the compliance-auditor agent. Audit application compliance with
    regulatory frameworks.

    Task directory: [task-path]

    Please:
    1. Determine applicable frameworks (GDPR, HIPAA, SOC 2, PCI DSS)
    2. Audit each applicable framework for compliance
    3. Generate compliance assessment report with gaps and remediation roadmap

    Save to: verification/compliance-assessment-report.md
    Use only Read, Grep, Glob, and Bash tools. Do NOT modify code.

⏳ Wait for subagent completion before continuing.

**Outputs**: `verification/compliance-assessment-report.md`

**SELF-CHECK (before completing Phase 4):**
- [ ] Did you invoke the Task tool? (not just read the agent file)
- [ ] Did you wait for the tool to return results?
- [ ] Is `verification/compliance-assessment-report.md` present?

If NO to any: STOP - go back and invoke the Task tool.

---

## Domain Context (State Extensions)

Security-specific fields in `orchestrator-state.yml`:

```yaml
security_context:
  baseline_vulnerabilities: [number]
  critical_vulnerabilities: [number]
  fixes_planned: [number]
  fixes_completed: [number]
  verification_verdict: "PASS" | "PASS with Issues" | "FAIL"
  risk_reduction: "[percentage]%"
  vulnerabilities_fixed: [number]

# Issue Resolution tracking (Phase 3.5)
verification_context:
  last_status: "passed" | "passed_with_issues" | "failed"
  issues_found: [number]
  fixes_applied:
    - "[description of fix 1]"
    - "[description of fix 2]"
  decisions_made:
    - issue: "[issue description]"
      decision: "fix" | "skip" | "defer"
  reverify_count: 0  # max 3

options:
  skip_compliance_audit: false
  compliance_frameworks: ["GDPR", "HIPAA", "SOC 2", "PCI DSS"]
```

---

## Auto-Recovery

| Phase | Max Attempts | Strategy |
|-------|--------------|----------|
| 0 | 2 | Try alternative scanners, focus on high-risk areas |
| 1 | 2 | Research OWASP remediation, use conservative estimates |
| 2 | 3 | Fix syntax errors, retry scans, rollback failed fixes |
| 3 | 0 | Read-only, report only |
| 4 | 0 | Read-only, report only |

---

## Command Integration

Invoked via:
- `/ai-sdlc:security:new [description] [--yolo]`
- `/ai-sdlc:security:resume [task-path]`

Task directory: `.ai-sdlc/tasks/security/YYYY-MM-DD-task-name/`

---

## Success Criteria

Workflow successful when:

- Security baseline documented with all vulnerabilities CVSS-scored
- Remediation plan created with prioritized fixes
- All P0 (Critical/High CVSS >7.0) vulnerabilities fixed
- Verification verdict = PASS (targets met, no critical regressions)
- Risk score reduced by 70-90%+
- Compliance gaps identified (if Phase 4 run)
- Ready for secure deployment
