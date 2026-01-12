---
name: migration-orchestrator
description: Orchestrates the complete migration workflow from current state analysis through implementation to compatibility verification. Handles technology migrations, platform changes, and architecture pattern transitions with adaptive risk assessment, incremental execution, and rollback planning. Supports interactive mode (pause between phases) and YOLO mode (continuous execution). Use when migrating technologies, platforms, or architecture patterns.
---

# Migration Orchestrator

Systematic migration workflow from current state analysis to verified migration with rollback capabilities.

## MANDATORY Initialization (Before Any Phase Work)

**CRITICAL: You MUST complete these steps BEFORE executing any workflow phase:**

### Step 1: Create TodoWrite with All Phases

**Immediately use the TodoWrite tool** to create todos for all phases:

```
Use TodoWrite tool with todos:
[
  {"content": "Check dependencies", "status": "pending", "activeForm": "Checking dependencies"},
  {"content": "Analyze current state", "status": "pending", "activeForm": "Analyzing current state"},
  {"content": "Plan target state and gaps", "status": "pending", "activeForm": "Planning target state and gaps"},
  {"content": "Create migration strategy", "status": "pending", "activeForm": "Creating migration strategy"},
  {"content": "Plan implementation", "status": "pending", "activeForm": "Planning implementation"},
  {"content": "Execute migration", "status": "pending", "activeForm": "Executing migration"},
  {"content": "Verify and test compatibility", "status": "pending", "activeForm": "Verifying and testing compatibility"},
  {"content": "Generate documentation", "status": "pending", "activeForm": "Generating documentation"}
]
```

**Skip phases based on context** (remove from todo list before starting):
- **Not part of initiative**: Skip "Check dependencies"
- **Documentation not needed**: Skip "Generate documentation"

### Step 2: Output Initialization Summary

**Output this summary to the user:**

```
🚀 Migration Orchestrator Started

Task: [migration description]
Mode: [Interactive/YOLO]
Directory: [task-path]

Workflow phases:
[Todos list with status]

[Interactive mode] You'll be prompted for review after each phase.
[YOLO mode] All phases will run continuously.

Starting Phase 0: Analyze current state...
```

### Step 3: Only Then Proceed to Phase 0

After completing Steps 1 and 2, proceed to Phase 0 (Current State Analysis).

---

## When to Use This Skill

Use when:
- Migrating from one framework/library to another (e.g., Vue 2 → Vue 3, Express → Fastify)
- Changing database platforms (e.g., MySQL → PostgreSQL, MongoDB → DynamoDB)
- Refactoring architecture patterns (e.g., REST → GraphQL, Monolith → Microservices)
- Upgrading major versions with breaking changes
- Any work involving "migrate", "move from X to Y", "upgrade to"

**DO NOT use for**:
- Completely new features (use `development-orchestrator --type=feature`)
- Bug fixes (use `development-orchestrator --type=bug`)
- Pure refactoring without technology change (use `refactoring-orchestrator`)

## Core Principles

1. **Analyze Before Migrating**: Understand current system before planning target state
2. **Risk Assessment**: Classify migration type (code/data/architecture) and assess complexity
3. **Incremental Execution**: Support phased migration with rollback points
4. **Rollback Planning**: Document undo procedures for each migration phase
5. **Dual-Run Support**: Enable running old and new systems in parallel during transition

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
| `references/migration-types.md` | Phase 0-1 | Migration type classification (code, data, architecture) |
| `references/migration-strategies.md` | Phase 2-4 | Rollback planning, dual-run patterns, verification strategies |

---

## Phase Configuration

| Phase | content | activeForm | Agent/Skill |
|-------|---------|------------|-------------|
| 0.5 | "Check dependencies" | "Checking dependencies" | orchestrator (initiative only) |
| 0 | "Analyze current state" | "Analyzing current state" | codebase-analyzer |
| 1 | "Plan target state and gaps" | "Planning target state and gaps" | gap-analyzer |
| 2 | "Create migration strategy" | "Creating migration strategy" | specification-creator |
| 3 | "Plan implementation" | "Planning implementation" | implementation-planner |
| 4 | "Execute migration" | "Executing migration" | implementer |
| 5 | "Verify and test compatibility" | "Verifying and testing compatibility" | implementation-verifier |
| 6 | "Generate documentation" | "Generating documentation" | user-docs-generator (optional) |

**Workflow Overview**: 7-8 phases (Phase 0.5 only if part of initiative, Phase 6 optional)

**CRITICAL TodoWrite Usage**:
1. At workflow start: Create todos for ALL phases using the Phase Configuration table above (all status=pending)
2. Before each phase: Update that phase to status=in_progress
3. After each phase: Update that phase to status=completed

---

## Migration Types

| Type | Keywords | Strategy | Risk Focus |
|------|----------|----------|------------|
| **Code** | framework, library, upgrade, version | Incremental or phased | Breaking changes, API differences |
| **Data** | database, schema, data migration | Dual-run (zero downtime) | Data integrity, checksums |
| **Architecture** | REST→GraphQL, monolith→microservices | Dual-run or phased | Compatibility, rollback |
| **General** | Ambiguous or mixed | Case-by-case | Varies |

**Migration Strategy Options**:
- **Incremental**: Migrate component-by-component with tests between
- **Big-Bang**: Complete migration in one change (simple migrations only)
- **Dual-Run**: Run old and new systems in parallel during transition
- **Phased**: Multiple deployment phases with validation between

---

## Workflow Phases

### Phase 0.5: Dependency Check (Initiative Only)

**Execution**: Main orchestrator (direct)

**When**: Only if task has `initiative_id` in `orchestrator-state.yml` task section

**Process**:
1. Read `orchestrator-state.yml`, check for `task.initiative_id`
2. If no initiative_id → Skip to Phase 0
3. If has initiative_id → Check all dependencies have status="completed"
4. If dependencies not met → BLOCK with message and exit

**Success**: All dependencies satisfied or not part of initiative

---

## 🚦 GATE: Phase 0.5 → Phase 0

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 0.5 (Dependency Check) complete. Ready to proceed to Phase 0 (Current State Analysis)?"
     - Options: ["Continue to Phase 0", "Review Phase 0.5 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 0 (Current State Analysis)..."
   - Proceed to Phase 0

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 0: Current State Analysis

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading codebase-analyzer/SKILL.md and following its instructions directly
❌ WRONG: Spawning your own Explore subagents to analyze the codebase
❌ WRONG: Analyzing the current system inline in the orchestrator thread

✅ RIGHT: Using the Skill tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 0 to: codebase-analyzer skill
Method: Skill tool
Expected outputs: analysis/current-state-analysis.md
```

**INVOKE NOW:**

Tool: `Skill`
Parameters:
  skill: "ai-sdlc:codebase-analyzer"

⏳ Wait for skill completion before continuing.

**Outputs**: `analysis/current-state-analysis.md`

**SELF-CHECK (before proceeding to Phase 1):**
- [ ] Did you invoke the Skill tool? (not just read the SKILL.md)
- [ ] Did you wait for the tool to return results?
- [ ] Is `analysis/current-state-analysis.md` present?

If NO to any: STOP - go back and invoke the Skill tool.

**Success**: Current system files identified, technologies documented, complexity assessed

---

## 🚦 GATE: Phase 0 → Phase 1

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 0 (Current State Analysis) complete. Ready to proceed to Phase 1 (Target State Planning & Gap Analysis)?"
     - Options: ["Continue to Phase 1", "Review Phase 0 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 1 (Target State Planning & Gap Analysis)..."
   - Proceed to Phase 1

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 1: Target State Planning & Gap Analysis

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/gap-analyzer.md and following its instructions directly
❌ WRONG: Analyzing migration gaps inline in the orchestrator thread
❌ WRONG: Classifying migration type yourself

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 1 to: gap-analyzer subagent
Method: Task tool
Expected outputs: analysis/target-state-plan.md
```

**INVOKE NOW:**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:gap-analyzer"
  description: "Analyze migration gaps and target state"
  prompt: |
    You are the gap-analyzer agent. Perform comprehensive gap analysis
    for this migration.

    Migration Description: [description]
    Task directory: [task-path]
    Existing Analysis: analysis/current-state-analysis.md

    Please:
    1. Define target system from migration description
    2. Identify gaps (features to migrate, APIs to adapt, data to transform)
    3. Classify migration type (code/data/architecture)
    4. Recommend migration strategy (incremental/big-bang/dual-run/phased)
    5. Assess risk level and breaking changes
    6. Document rollback requirements
    7. Perform external research (WebSearch) for version upgrades or technology migrations

    Save to: analysis/target-state-plan.md
    Use only Read, Grep, Glob, WebSearch, and Bash tools. Do NOT modify code.

⏳ Wait for subagent completion before continuing.

**Outputs**: `analysis/target-state-plan.md`

**SELF-CHECK (before proceeding to Phase 2):**
- [ ] Did you invoke the Task tool? (not just read the agent file)
- [ ] Did you wait for the tool to return results?
- [ ] Is `analysis/target-state-plan.md` present?

If NO to any: STOP - go back and invoke the Task tool.

**State Update**: After gap-analyzer completes, read structured output:
- Update `migration_context.migration_type` from output (code/data/architecture/general)
- Update `migration_context.current_system` from output (description, technologies)
- Update `migration_context.target_system` from output (description, technologies)
- Update `migration_context.migration_strategy` from output (approach, phases)
- Update `migration_context.risk_level` from output
- Update `migration_context.breaking_changes` from output
- If external research performed, update `external_research` block (performed, category, breaking_changes, migration_guide_url)

---

## 🚦 GATE: Phase 1 → Phase 2

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 1 (Target State Planning & Gap Analysis) complete. Ready to proceed to Phase 2 (Migration Strategy Specification)?"
     - Options: ["Continue to Phase 2", "Review Phase 1 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 2 (Migration Strategy Specification)..."
   - Proceed to Phase 2

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 2: Migration Strategy Specification

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading specification-creator/skill.md and following its instructions directly
❌ WRONG: Writing migration specification inline in the orchestrator thread
❌ WRONG: Creating rollback plan yourself

✅ RIGHT: Using the Skill tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 2 to: specification-creator skill
Method: Skill tool
Expected outputs: implementation/spec.md, analysis/rollback-plan.md
```

**INVOKE NOW:**

Tool: `Skill`
Parameters:
  skill: "ai-sdlc:specification-creator"

⏳ Wait for skill completion before continuing.

**Outputs**:
- `implementation/spec.md` - Migration specification
- `analysis/rollback-plan.md` - Rollback procedures for each phase
- `analysis/dual-run-plan.md` - (if dual-run strategy)

**SELF-CHECK (before proceeding to Phase 3):**
- [ ] Did you invoke the Skill tool? (not just read the skill.md)
- [ ] Did you wait for the tool to return results?
- [ ] Is `implementation/spec.md` present?

If NO to any: STOP - go back and invoke the Skill tool.

**State Update**: After specification-creator completes:
- Set `migration_context.rollback_plan_created: true` (if rollback-plan.md created)
- Set `migration_context.dual_run_configured: true` (if dual-run-plan.md created)

---

## 🚦 GATE: Phase 2 → Phase 3

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 2 (Migration Strategy Specification) complete. Ready to proceed to Phase 3 (Implementation Planning)?"
     - Options: ["Continue to Phase 3", "Review Phase 2 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 3 (Implementation Planning)..."
   - Proceed to Phase 3

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 3: Implementation Planning

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading implementation-planner/skill.md and following its instructions directly
❌ WRONG: Creating implementation plan inline in the orchestrator thread
❌ WRONG: Breaking migration into task groups yourself

✅ RIGHT: Using the Skill tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 3 to: implementation-planner skill
Method: Skill tool
Expected outputs: implementation/implementation-plan.md
```

**INVOKE NOW:**

Tool: `Skill`
Parameters:
  skill: "ai-sdlc:implementation-planner"

⏳ Wait for skill completion before continuing.

**Outputs**: `implementation/implementation-plan.md` with rollback procedures

**SELF-CHECK (before proceeding to Phase 4):**
- [ ] Did you invoke the Skill tool? (not just read the skill.md)
- [ ] Did you wait for the tool to return results?
- [ ] Is `implementation/implementation-plan.md` present?

If NO to any: STOP - go back and invoke the Skill tool.

**Success**: Plan complete with rollback steps, dependencies correct

---

## 🚦 GATE: Phase 3 → Phase 4

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 3 (Implementation Planning) complete. Ready to proceed to Phase 4 (Migration Execution)?"
     - Options: ["Continue to Phase 4", "Review Phase 3 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 4 (Migration Execution)..."
   - Proceed to Phase 4

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 4: Migration Execution

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading implementer/SKILL.md and following its instructions directly
❌ WRONG: Executing migration steps inline in the orchestrator thread
❌ WRONG: Making code changes yourself without invoking implementer

✅ RIGHT: Using the Skill tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 4 to: implementer skill
Method: Skill tool
Expected outputs: Migration changes, updated implementation-plan.md
```

**Standards Reminder**: Review `.ai-sdlc/docs/INDEX.md` for project standards before implementing.

**INVOKE NOW:**

Tool: `Skill`
Parameters:
  skill: "ai-sdlc:implementer"

⏳ Wait for skill completion before continuing.

**Outputs**:
- Implemented migration changes
- Updated `implementation-plan.md` (all steps complete)
- `implementation/work-log.md`

**SELF-CHECK (before proceeding to Phase 5):**
- [ ] Did you invoke the Skill tool? (not just read the SKILL.md)
- [ ] Did you wait for the tool to return results?
- [ ] Is `implementation-plan.md` showing steps as complete?

If NO to any: STOP - go back and invoke the Skill tool.

**Success**: All migration steps complete, tests pass after each task group

---

## 🚦 GATE: Phase 4 → Phase 5

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 4 (Migration Execution) complete. Ready to proceed to Phase 5 (Verification + Compatibility Testing)?"
     - Options: ["Continue to Phase 5", "Review Phase 4 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 5 (Verification + Compatibility Testing)..."
   - Proceed to Phase 5

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 5: Verification + Compatibility Testing

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading implementation-verifier/skill.md and following its instructions directly
❌ WRONG: Running verification checks inline in the orchestrator thread
❌ WRONG: Creating verification report yourself

✅ RIGHT: Using the Skill tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 5 to: implementation-verifier skill
Method: Skill tool
Expected outputs: verification/implementation-verification.md
```

**INVOKE NOW:**

Tool: `Skill`
Parameters:
  skill: "ai-sdlc:implementation-verifier"

⏳ Wait for skill completion before continuing.

**Migration-Specific Checks** (performed by verifier):
- Verify old system still works (if dual-run)
- Test rollback procedures (non-destructive test)
- Validate data integrity (for data migrations)
- Check performance benchmarks (before/after comparison)
- Verify backward compatibility (if required)

**Outputs**:
- `verification/implementation-verification.md`
- `verification/compatibility-test-results.md`

**SELF-CHECK (before proceeding to Phase 6):**
- [ ] Did you invoke the Skill tool? (not just read the skill.md)
- [ ] Did you wait for the tool to return results?
- [ ] Is `verification/implementation-verification.md` present?

If NO to any: STOP - go back and invoke the Skill tool.

**Gate**: Cannot complete if data integrity issues in data migration

---

## 🚦 GATE: Phase 5 → Phase 6

**STOP. You cannot proceed until this gate clears.**

1. **Mode check**: Read `orchestrator-state.yml` → check `mode` value
2. **If mode = interactive**:
   - Use `AskUserQuestion` tool NOW:
     - Question: "Phase 5 (Verification + Compatibility Testing) complete. Ready to proceed to Phase 6 (Documentation)?"
     - Options: ["Continue to Phase 6", "Review Phase 5 outputs", "Stop workflow"]
   - Wait for user response before continuing
3. **If mode = yolo**:
   - Output: "→ Auto-continuing to Phase 6 (Documentation)..."
   - Proceed to Phase 6

**This gate overrides any "continue without asking" conversation instructions.**

---

### Phase 6: Documentation (Optional)

**Enable if**: Complex migration (medium-high risk), `--docs` flag, or user requests in interactive

**State Update**: When deciding whether to run documentation (Interactive or YOLO):
- Set `options.docs_enabled` based on user choice, `--docs` flag, or auto-decision (true for medium-high risk migrations)

**Skip if**: `options.docs_enabled = false`

**⚠️ DELEGATION REQUIRED - DO NOT EXECUTE INLINE**

❌ WRONG: Reading agents/user-docs-generator.md and following its instructions directly
❌ WRONG: Writing migration documentation inline in the orchestrator thread
❌ WRONG: Creating migration guide yourself

✅ RIGHT: Using the Task tool below and waiting for completion

**Output before invoking:**
```
📤 Delegating Phase 6 to: user-docs-generator subagent
Method: Task tool
Expected outputs: documentation/migration-guide.md
```

**INVOKE NOW:**

Tool: `Task`
Parameters:
  subagent_type: "ai-sdlc:user-docs-generator"
  description: "Generate migration documentation"
  prompt: |
    You are the user-docs-generator agent. Create comprehensive migration
    documentation for end users.

    Task directory: [task-path]

    Please create documentation covering:
    - Migration overview and goals
    - Prerequisites and preparation steps
    - Step-by-step migration procedure
    - Rollback procedures
    - Troubleshooting common issues
    - Verification checklist

    Save to: documentation/migration-guide.md

⏳ Wait for subagent completion before continuing.

**Outputs**: `documentation/migration-guide.md`

**SELF-CHECK (after documentation generation):**
- [ ] Did you invoke the Task tool? (not just skip or do inline)
- [ ] Did you wait for the tool to return results?
- [ ] Is `documentation/migration-guide.md` present?

If NO to any and `options.docs_enabled = true`: STOP - go back and invoke the Task tool.

---

## Domain Context (State Extensions)

Migration-specific fields in `orchestrator-state.yml`:

```yaml
migration_context:
  migration_type: "code" | "data" | "architecture" | "general"
  current_system:
    description: "[summary]"
    technologies: []
  target_system:
    description: "[summary]"
    technologies: []
  migration_strategy:
    approach: "incremental" | "big-bang" | "dual-run" | "phased"
    phases: []
  risk_level: "low" | "medium" | "high"
  breaking_changes: []
  rollback_plan_created: false
  dual_run_configured: false

external_research:
  performed: false
  category: null  # version_upgrade|technology_migration|api_integration
  breaking_changes: []
  migration_guide_url: null

options:
  docs_enabled: false
```

---

## Task Structure

```
.ai-sdlc/tasks/migrations/YYYY-MM-DD-migration-name/
├── orchestrator-state.yml            # Execution state + task metadata
├── analysis/
│   ├── current-state-analysis.md    # Phase 0
│   ├── target-state-plan.md         # Phase 1
│   ├── rollback-plan.md             # Phase 2
│   └── dual-run-plan.md             # Phase 2 (if dual-run)
├── implementation/
│   ├── spec.md                      # Phase 2
│   ├── implementation-plan.md       # Phase 3
│   └── work-log.md                  # Phase 4
├── verification/
│   ├── implementation-verification.md  # Phase 5
│   └── compatibility-test-results.md   # Phase 5
└── documentation/
    └── migration-guide.md           # Phase 6 (optional)
```

---

## Auto-Recovery

| Phase | Max Attempts | Strategy |
|-------|--------------|----------|
| 0 | 2 | Expand search patterns, prompt user for file paths |
| 1 | 2 | Re-prompt for target details, prompt user to specify type |
| 2 | 2 | Re-invoke spec-creator with issues, regenerate rollback plan |
| 3 | 2 | Regenerate with migration constraints, fix dependencies |
| 4 | 5 | Fix syntax errors, prompt user for manual intervention on repeated failure |
| 5 | 2-3 | Invoke implementer with fix instructions. **HALT on data integrity issues** |
| 6 | 1 | Generate text-only without screenshots (optional phase) |

**Data Safety Critical**: For data migrations, HALT on data integrity issues - don't auto-fix.

---

## Command Integration

Invoked via:
- `/ai-sdlc:migration:new [description] [--yolo] [--type=TYPE]`
- `/ai-sdlc:migration:resume [task-path] [--from=PHASE]`

Task directory: `.ai-sdlc/tasks/migrations/YYYY-MM-DD-task-name/`

---

## Success Criteria

Workflow successful when:

- Current state thoroughly analyzed (Phase 0)
- Migration type detected and confirmed (Phase 1)
- Migration strategy selected (incremental/big-bang/dual-run/phased)
- Rollback plan created and documented
- Migration executes incrementally with verification points
- Tests pass after each migration phase
- Compatibility testing validates migration success
- For data migrations: 100% data integrity verified
- Ready for production cutover or rollback if needed
