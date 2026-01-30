---
name: security-orchestrator
description: Orchestrates security remediation workflows from vulnerability analysis through compliance audit. Identifies security issues, creates prioritized remediation plan, implements fixes incrementally with testing, verifies improvements, and optionally audits compliance (GDPR, HIPAA, SOC 2, PCI DSS).
---

# Security Orchestrator

Systematic security remediation workflow from vulnerability analysis to compliance-ready deployment.

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
2. **Create Task Directory**: `.ai-sdlc/tasks/security/YYYY-MM-DD-task-name/`
3. **Initialize State**: Create `orchestrator-state.yml` with mode and security context

**Output**:
```
🚀 Security Orchestrator Started

Task: [security issue description]
Mode: [Interactive/YOLO]
Directory: [task-path]

Starting Phase 0: Analyze vulnerabilities and baseline...
```

---

## When to Use

Use when:
- Security vulnerabilities detected (dependency CVEs, code vulnerabilities)
- Need systematic security remediation workflow
- Want CVSS-scored vulnerability prioritization
- Require compliance audit (GDPR, HIPAA, SOC 2, PCI DSS)
- Security issues reported or discovered

**DO NOT use for**: New features, bug fixes, performance optimization.

---

## Core Principles

1. **Evidence-Based**: Every finding backed by scan results or code inspection
2. **CVSS-Scored**: Quantitative severity assessment for all vulnerabilities
3. **Risk-Prioritized**: Critical vulnerabilities fixed first
4. **Incremental**: Small, testable security fixes
5. **Verified**: Prove every fix with before/after scans

---

## Local References

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
| 2 | "Implement security fixes" | "Implementing security fixes" | Direct + implementation-changes-planner |
| 3 | "Verify security improvements" | "Verifying security improvements" | security-verifier |
| 3.5 | "Resolve verification issues" | "Resolving verification issues" | Direct (conditional) |
| 4 | "Audit compliance" | "Auditing compliance" | compliance-auditor (optional) |

---

## Workflow Phases

### Phase 0: Vulnerability Analysis & Security Baseline

**Purpose**: Identify all vulnerabilities with CVSS scores and OWASP classification
**Execute**: Task tool - `ai-sdlc:security-analyzer` subagent
**Output**: `analysis/security-baseline.md`, scan artifacts
**State**: Update `security_context.baseline_vulnerabilities`, `critical_vulnerabilities`

**Analyzer checks**:
- Dependency vulnerabilities (npm audit, pip-audit, etc.)
- Authentication and authorization code
- Injection vulnerabilities (SQL, XSS, command injection)
- Sensitive data exposure (hardcoded secrets, logging)
- Security misconfigurations
- Business logic vulnerabilities

→ Pause

**Interactive**: AskUserQuestion - "Baseline complete. Continue to remediation planning?"
**YOLO**: "→ Continuing to Phase 1..."

---

### Phase 1: Security Planning & Remediation Strategy

**Purpose**: Create prioritized remediation plan
**Execute**: Task tool - `ai-sdlc:security-planner` subagent
**Output**: `implementation/security-remediation-plan.md`
**State**: Update `security_context.fixes_planned`

**Planner tasks**:
- Classify fix types (dependency, code pattern, config, cryptography)
- Assess impact and effort for each fix
- Calculate priority scores (CVSS × 10 + Impact × 2 - Effort)
- Group fixes by type and dependency
- Break into incremental steps (max 3 files per increment)
- Define verification steps for each fix

→ Pause

**Interactive**: AskUserQuestion - "Remediation plan ready. Continue to implementation?"
**YOLO**: "→ Continuing to Phase 2..."

---

### Phase 2: Security Implementation with Testing

**Purpose**: Implement security fixes with before/after verification
**Execute**: Direct for simple (1-3 files), Task tool - `ai-sdlc:implementation-changes-planner` for complex (4+ files)
**Output**: Fixed code, `implementation/security-scans/*.json`
**State**: Increment `security_context.fixes_completed` after each fix

**Standards Reminder**: Review `.ai-sdlc/docs/INDEX.md` for security standards before implementing.

**Process** (for each fix in priority order P0 → P1 → P2 → P3):
1. Read fix details from remediation plan
2. Security scan before (save baseline)
3. Implement fix
4. Security scan after
5. Verify fix (eliminated/reduced/unchanged)
6. Run tests (ensure no regressions)
7. Update plan (mark complete/failed)

→ Pause

**Interactive**: AskUserQuestion - "Implementation complete. Continue to verification?"
**YOLO**: "→ Continuing to Phase 3..."

---

### Phase 3: Security Verification

**Purpose**: Verify all fixes resolved vulnerabilities without regressions
**Execute**: Task tool - `ai-sdlc:security-verifier` subagent
**Output**: `verification/security-verification-report.md` with verdict
**State**: Update `security_context.verification_verdict`, `risk_reduction`, `vulnerabilities_fixed`

**Verdict Criteria**:
- **PASS**: All P0 fixed, no critical new vulns, risk reduction >70%
- **PASS with Issues**: Most P0 fixed (>80%), risk reduction >50%
- **FAIL**: Critical vulnerabilities remain or new critical vulns introduced

→ Conditional: if verdict=PASS skip to Phase 4, if fixable issues continue to Phase 3.5, otherwise stop workflow

---

### Phase 3.5: Issue Resolution (Conditional)

**Purpose**: Fix verification issues through direct editing and re-verification
**Execute**: Direct - apply fixes, re-verify with security-verifier
**Output**: Updated code, `verification_context.fixes_applied`
**State**: Update `reverify_count`, `decisions_made`

**Skip if**: verdict = PASS

**Reference**: `../orchestrator-framework/references/issue-resolution-pattern.md`

**Categorize Issues**:
- **Auto-fixable**: Dependency bumps (non-breaking), simple config changes, permission tightening
- **User decision needed**: Breaking dependency changes, config changes affecting functionality
- **Not fixable here**: Architectural security changes (require new cycle)

**Process**:
1. Parse issues from verification report
2. Apply auto-fixes directly
3. For user decisions: AskUserQuestion with options
4. Re-verify after fixes (max 3 iterations)

**Exit Conditions**:
- ✅ New verdict = PASS → Proceed to Phase 4
- ⚠️ Max iterations (3) reached → Ask user: continue with warnings or stop
- ❌ Critical unfixable issues remain → Report to user, recommend stopping

→ Pause

**Interactive**: AskUserQuestion - "Issues resolved. Continue to compliance audit?"
**YOLO**: "→ Continuing to Phase 4..."

---

### Phase 4: Compliance Audit (Optional)

**Purpose**: Audit compliance with regulatory frameworks
**Execute**: Task tool - `ai-sdlc:compliance-auditor` subagent
**Output**: `verification/compliance-assessment-report.md`
**State**: Set compliance audit results

**Skip if**: `options.skip_compliance_audit = true`

**Prerequisites**: Phase 3 verdict = PASS or PASS with Issues

**Applicable Frameworks** (auto-detected):
- Healthcare → HIPAA
- Payments → PCI DSS
- EU users → GDPR
- Enterprise → SOC 2

**Auditor produces**:
- Compliance assessment per framework
- Gaps identified
- Remediation roadmap

→ End of workflow

---

## Domain Context (State Extensions)

Security-specific fields in `orchestrator-state.yml`:

```yaml
security_context:
  baseline_vulnerabilities: null
  critical_vulnerabilities: null
  fixes_planned: null
  fixes_completed: 0
  verification_verdict: null  # "PASS" | "PASS with Issues" | "FAIL"
  risk_reduction: null        # percentage
  vulnerabilities_fixed: null

verification_context:
  last_status: null
  issues_found: null
  fixes_applied: []
  decisions_made: []
  reverify_count: 0  # max 3

options:
  skip_compliance_audit: false
  compliance_frameworks: []  # ["GDPR", "HIPAA", "SOC 2", "PCI DSS"]
```

---

## Task Structure

```
.ai-sdlc/tasks/security/YYYY-MM-DD-task-name/
├── orchestrator-state.yml
├── analysis/
│   └── security-baseline.md          # Phase 0
├── implementation/
│   ├── security-remediation-plan.md  # Phase 1
│   └── security-scans/               # Phase 2
│       ├── before-*.json
│       └── after-*.json
└── verification/
    ├── security-verification-report.md   # Phase 3
    └── compliance-assessment-report.md   # Phase 4 (optional)
```

---

## Auto-Recovery

| Phase | Max Attempts | Strategy |
|-------|--------------|----------|
| 0 | 2 | Try alternative scanners, focus on high-risk areas |
| 1 | 2 | Research OWASP remediation, use conservative estimates |
| 2 | 3 | Fix syntax errors, retry scans, rollback failed fixes |
| 3 | 0 | Read-only, report only |
| 3.5 | 3 | Fix-then-reverify cycles |
| 4 | 0 | Read-only, report only |

---

## Command Integration

Invoked via:
- `/ai-sdlc:security:new [description] [--yolo]`
- `/ai-sdlc:security:resume [task-path] [--from=PHASE]`

Task directory: `.ai-sdlc/tasks/security/YYYY-MM-DD-task-name/`
