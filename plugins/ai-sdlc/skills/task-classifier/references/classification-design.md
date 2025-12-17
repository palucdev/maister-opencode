# Task Classification Design Guide

**Design documentation** for developers extending classification methodology. Runtime logic is embedded in `agents/task-classifier.md` for path-independence.

---

## Classification Priority

When multiple types match:
1. **Security** - ALWAYS overrides (critical)
2. **Keyword count** - Type with most matches wins
3. **Context analysis** - Component found, error verified
4. **User confirmation** - If still ambiguous, ask user

---

## Task Type Patterns

### Security (CRITICAL - Always Overrides)

| Category | Keywords |
|----------|----------|
| **Critical** | vulnerability, CVE-*, exploit, SQL injection, XSS, CSRF, auth bypass |
| **High** | sensitive data, credential exposure, insecure, security flaw |
| **Context** | OWASP, CWE numbers, security advisory references |

**Rules**: Confidence 95%+ always. Always require explicit confirmation. Never auto-proceed.

### Bug Fix

| Category | Keywords |
|----------|----------|
| **Primary** | fix, bug, broken, error, crash, defect, regression |
| **Error indicators** | timeout, exception, null pointer, stack trace, fails |
| **State** | incorrect behavior, wrong output, unexpected result |

**Context boosters** (+10% each): Error found in code, stack trace matches files, issue labeled "bug"

### Enhancement (Requires "existing" context)

| Category | Keywords |
|----------|----------|
| **Primary** | improve, enhance, better, upgrade existing, extend existing |
| **Quality** | optimize existing, refine, polish, strengthen |
| **Scope** | expand existing, add feature to, more features for |

**Disambiguation**: If component NOT found in codebase → reclassify as new-feature

### New Feature

| Category | Keywords |
|----------|----------|
| **Creation** | add new, create, build, implement new, introduce |
| **Feature** | feature, functionality, capability, capability |
| **System** | system, module, component (when new) |

**Disambiguation**: If component FOUND in codebase → reclassify as enhancement

### Refactoring

| Category | Keywords |
|----------|----------|
| **Structure** | refactor, restructure, reorganize, modularize |
| **Quality** | clean up, simplify, consolidate, deduplicate |
| **Architecture** | decouple, extract, separate concerns |

**Key distinction**: Behavior must remain unchanged

### Performance

| Category | Keywords |
|----------|----------|
| **Speed** | slow, optimize, speed up, faster, latency |
| **Efficiency** | memory usage, CPU, bottleneck, efficient |
| **Scaling** | scale, throughput, load, concurrent |

### Migration

| Category | Keywords |
|----------|----------|
| **Move** | migrate, move from X to Y, transition, switch to |
| **Upgrade** | upgrade from, update from, replace X with Y |
| **Platform** | new platform, new framework, new database |

### Documentation

| Category | Keywords |
|----------|----------|
| **Create** | document, docs, write guide, API docs |
| **Update** | update docs, documentation update, README |
| **Types** | tutorial, FAQ, changelog, specification |

### Research

| Category | Keywords |
|----------|----------|
| **Investigate** | research, investigate, explore, analyze |
| **Compare** | compare options, evaluate alternatives |
| **Document** | document findings, spike, proof of concept |

### Initiative

| Category | Keywords |
|----------|----------|
| **Scale** | epic, project, initiative, feature set |
| **Scope** | multiple tasks, phase 1/2/3, milestone |
| **Duration** | multi-week, Q1/Q2, sprint goals |

---

## Confidence Calculation

| Confidence | Meaning | User Flow |
|------------|---------|-----------|
| **95%+** | Critical (security) | Warning + explicit confirmation |
| **80-94%** | High | Quick confirmation with override |
| **60-79%** | Medium | Show classification, ask to confirm |
| **<60%** | Low | Present all options, user chooses |

### Base Formula

```
Base: 50%
3+ primary keywords: +30%
2 primary keywords: +25%
1 primary keyword: +15%
Each context booster: +10%
Issue labels match: +5%
Cap at 94% (except security at 98%)
```

---

## Context Analysis

### Codebase Search (Enhancement vs New-Feature)

1. Extract component nouns from description
2. Search codebase for existing files/classes
3. If found → Enhancement (improving existing)
4. If not found → New Feature (creating new)

### Error Verification (Bug Fix)

1. Extract error patterns from description
2. Search codebase for matching errors
3. If found → Boost bug-fix confidence +10%
4. If not found → May still be bug (runtime error)

### Git History

1. Check recent commits for related changes
2. If recent fix → May be regression
3. If recent feature → May be enhancement to new code

---

## Issue Integration

### Detection Patterns

| Source | Pattern | Tool |
|--------|---------|------|
| GitHub short | `#123`, `GH-123` | mcp__github |
| GitHub URL | `github.com/.../issues/` | mcp__github |
| Jira ticket | `PROJ-456` | mcp__jira |
| Jira URL | `atlassian.net/browse/` | mcp__jira |
| Generic | Other URLs | WebFetch |

### Label Mapping

| Issue Label | Task Type | Confidence Boost |
|-------------|-----------|-----------------|
| bug, defect | bug-fix | +10% |
| enhancement | enhancement | +10% |
| feature | new-feature | +10% |
| security | security | → 95%+ |
| performance | performance | +10% |
| documentation | documentation | +10% |

---

## Special Cases

### Compound Tasks

If multiple distinct tasks detected:
- Suggest splitting into separate tasks
- Ask user which to work on first
- Route to appropriate orchestrator

### Vague Descriptions

If <60% confidence on any type:
- Request clarification
- Ask specific questions about intent
- Present all 8 options

### Security Override

Any security keyword:
- Immediately classify as security
- Show warning about critical nature
- Require explicit "yes" confirmation
- Never auto-proceed
