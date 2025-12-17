# Implementer Execution Guide

Consolidated reference for execution modes, change plans, standards discovery, and progress tracking.

---

## Execution Mode Selection

### Decision Criteria

| Steps | Mode | Strategy | Use When |
|-------|------|----------|----------|
| 1-3 | Direct | Execute yourself | Simple bug fixes, config changes, single-file updates |
| 4-8 | Plan-Execute | Delegate planning, apply changes | Standard features, moderate complexity |
| 9+ | Orchestrated | Group-by-group delegation | Complex features, multiple layers |

### Secondary Factors

**Consider higher mode if**: Multiple tech layers, external integrations, complex logic, many files
**Consider lower mode if**: Single file, clear patterns, minimal dependencies, time-sensitive

### Mode Switching

You can switch modes mid-implementation if complexity differs from expectations. Document the switch in work-log.md.

---

## Change Plan Format

When subagent creates a change plan, expect this structure:

```markdown
# Change Plan: [Task Name]

## Standards Applied
- [List from docs/INDEX.md]
- Note any discovered during planning

## Task Group N: [Name]

### Step N.1: [Description]
**File**: [path]
**Action**: Create new file / Modify existing
**Changes**: [Exact content or FIND/REPLACE]
**Standards**: [Which standards applied]

### Step N.n: Verify Tests
**Command**: [test command for this group only]
**Expected**: [N] tests passing

## File Manifest
- New: [files to create]
- Modified: [files to change]

## Notes for Main Agent
- Re-check standards before each change
- Document any adjustments in work-log.md
```

**Key points**:
- Subagent creates plan only (no file modifications)
- Main agent applies all changes
- Follow test-driven order (tests → implement → verify)

---

## Standards Discovery

### When to Check docs/INDEX.md

| Phase | Purpose |
|-------|---------|
| Initial (Phase 1) | Understand available standards |
| Before each task group | Identify specialty-area standards |
| Before each step | Check if keywords suggest new standards |
| Before applying changes | Verify compliance |
| Final (Phase 3) | Ensure nothing missed |

### Discovery Triggers

| Keywords in Step | Check These Standards |
|-----------------|----------------------|
| file, upload, download | file-handling, storage, security |
| auth, login, permission | security, authentication |
| email, notification | email, external-services |
| payment, billing | security, secrets, payment |
| form, input | forms, validation, accessibility |
| API, endpoint | api, error-handling |
| migration, schema | database, migrations |

### Discovery Principle

Not all standards are obvious initially. Standards become relevant as implementation progresses. Check continuously, apply immediately when discovered, document in work-log.md.

---

## Progress Tracking

### Checkbox Format

```markdown
Before: - [ ] 2.3 Step description
After:  - [x] 2.3 Step description
```

Use lowercase `x` only. Mark group header (`X.0`) only after ALL steps complete.

### When to Mark

**Immediately** after completing each step:
1. Complete the work
2. Mark checkbox with Edit tool
3. Verify it's marked (read file)
4. Log in work-log.md
5. Then proceed to next step

Never batch updates. Never mark ahead.

### Why It Matters

- Enables workflow resumption after interruptions
- Verification phase validates all complete
- Creates audit trail
- Shows progress to team

### Validation

Phase 3 runs blocking validation. No unmarked `- [ ]` steps can remain. If validation fails, mark missing steps before proceeding.

---

## Work Log Format

Keep `implementation/work-log.md` updated:

```markdown
## [YYYY-MM-DD HH:MM] - [Event]

**Action**: [What was done]
**Files**: [Modified files]
**Standards**: [Applied standards]
**Notes**: [Decisions, discoveries]
```

Update after:
- Each task group completion
- Standards discovery
- Test execution
- Final completion

---

## Quick Reference

### Common Paths

- Task: `.ai-sdlc/tasks/[type]/[dated-name]/`
- Plan: `[task]/implementation/implementation-plan.md`
- Spec: `[task]/implementation/spec.md`
- Work log: `[task]/implementation/work-log.md`
- Standards: `.ai-sdlc/docs/standards/`
- Index: `.ai-sdlc/docs/INDEX.md`

### Test-Driven Pattern

1. Write 2-8 tests (step X.1)
2. Implement (steps X.2 to X.n-1)
3. Run only new tests (step X.n) - not entire suite

### Subagent Roles

- `implementation-changes-planner`: Creates markdown plans only
- Main agent (you): Applies all file changes with Edit/Write tools
