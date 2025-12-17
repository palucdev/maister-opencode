# Verification Report Template

## Purpose

The verification report documents that an implementation:
- Completed all planned tasks
- Passes its test suite
- Follows applicable standards
- Has complete documentation
- Is ready for code review

## Report Structure

```markdown
# Implementation Verification Report: [Task Name]

**Task**: [name from spec.md]
**Location**: `.ai-sdlc/tasks/[type]/[dated-name]/`
**Date**: [YYYY-MM-DD]
**Status**: ✅ Passed | ⚠️ Passed with Issues | ❌ Failed

---

## Executive Summary

[2-3 sentences: completion status, key metrics, major findings, verdict]

---

## 1. Implementation Plan Verification

**Status**: ✅ Complete | ⚠️ Nearly Complete | ❌ Incomplete
**Completion**: [M]/[N] steps ([%])

### Task Groups
- [x] Task Group 1: [Name] - ✅ Verified (spot check evidence)
- [x] Task Group 2: [Name] - ✅ Verified

### Incomplete/Issues
[List or "None"]

---

## 2. Test Suite Results

**Status**: ✅ All Passing | ⚠️ Some Failures | ❌ Critical Failures
**Pass Rate**: [P]/[N] ([%])

### Failed Tests
[List with file, error, category - or "None"]

### Potential Regressions
[Failures in unrelated areas - or "None"]

---

## 3. Standards Compliance

**Status**: ✅ Fully Compliant | ⚠️ Mostly Compliant | ❌ Non-Compliant

### Applicability Analysis
| Standard | Applies? | Reasoning |
|----------|----------|-----------|
| [standard] | ✅/❌ | [reason] |

### Compliance Summary
- Applied: [N] standards
- Expected: [M] standards
- Gaps: [list or "None"]

---

## 4. Documentation Completeness

**Status**: ✅ Complete | ⚠️ Adequate | ❌ Incomplete

- Implementation plan: [status]
- Work log: [N] entries, [completeness]
- Spec alignment: [status]
- User docs: [status or N/A]

---

## 5. Optional Reviews (if performed)

### Code Review
**Status**: [Clean/Issues/Critical]
- Critical: [N], Warnings: [M], Info: [K]

### Pragmatic Review
**Status**: [Appropriate/Over-Engineered/Critical]
- Issues: [summary]

### Production Readiness
**Status**: [Ready/Concerns/Not Ready] ([%])
- Blockers: [N], Concerns: [M]

### Reality Assessment
**Status**: [Ready/Issues/Not Ready]
- Functional completeness: [%]

---

## 6. Overall Assessment

**Status**: ✅ Passed | ⚠️ Passed with Issues | ❌ Failed

| Aspect | Status | Details |
|--------|--------|---------|
| Implementation | ✅/⚠️/❌ | [M]/[N] steps |
| Tests | ✅/⚠️/❌ | [P]/[N] passing |
| Standards | ✅/⚠️/❌ | [compliance] |
| Documentation | ✅/⚠️/❌ | [completeness] |

### Issues Requiring Attention
[Critical issues, minor issues, or "None"]

### Recommendations
[Specific, actionable next steps]

---

## Verification Checklist

- [x] Implementation plan verified
- [x] Full test suite executed
- [x] Standards compliance assessed
- [x] Documentation validated
- [ ] Code review (optional)
- [ ] Pragmatic review (optional)
- [ ] Production readiness (optional)
- [ ] Reality check (optional)

**Ready for**: Code Review | Fixes Required | Re-Implementation
```

## Status Criteria

| Status | Criteria |
|--------|----------|
| ✅ Passed | 100% implementation, 95%+ tests, standards compliant, docs complete |
| ⚠️ Passed with Issues | 90-99% implementation OR 90-94% tests OR minor gaps |
| ❌ Failed | <90% implementation OR <90% tests OR critical issues |

## Guidelines

- Use ✅ ⚠️ ❌ icons consistently
- Provide evidence (file names, counts, percentages)
- Make recommendations specific and actionable
- Distinguish critical vs minor issues
