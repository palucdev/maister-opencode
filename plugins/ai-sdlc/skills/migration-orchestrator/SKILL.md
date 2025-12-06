---
name: migration-orchestrator
description: Orchestrates the complete migration workflow from current state analysis through implementation to compatibility verification. Handles technology migrations, platform changes, and architecture pattern transitions with adaptive risk assessment, incremental execution, and rollback planning. Supports interactive mode (pause between phases) and YOLO mode (continuous execution). Use when migrating technologies, platforms, or architecture patterns.
---

# Migration Orchestrator

This skill orchestrates the complete development workflow for migrations, ensuring systematic analysis, risk assessment, incremental execution, and comprehensive verification with rollback capabilities.

## When to Use This Skill

Use this skill when:
- Migrating from one framework/library to another (e.g., Vue 2 → Vue 3, Express → Fastify)
- Changing database platforms (e.g., MySQL → PostgreSQL, MongoDB → DynamoDB)
- Refactoring architecture patterns (e.g., REST → GraphQL, Monolith → Microservices)
- Upgrading major versions with breaking changes
- Transitioning platforms or technologies
- Any work involving "migrate", "move from X to Y", "upgrade to", "transition to"

**DO NOT use for:**
- Completely new features (use `feature-orchestrator`)
- Bug fixes (use `bug-fix-orchestrator`)
- Enhancements to existing features (use `enhancement-orchestrator`)
- Pure refactoring without technology/platform changes

## Core Principles

1. **Analyze Before Migrating**: Understand current system thoroughly before planning target state
2. **Risk Assessment**: Classify migration type (code/data/architecture) and assess complexity
3. **Incremental Execution**: Support phased migration with rollback points
4. **Rollback Planning**: Document undo procedures for each migration phase
5. **Dual-Run Support**: Enable running old and new systems in parallel during transition
6. **Complete Workflow**: Guide through all phases from analysis to verification systematically

## Progress Tracking

Use `TodoWrite` to show real-time progress to the user. Create todos at workflow start, update at each phase transition.

**Phase Todos**:

| Phase | content | activeForm |
|-------|---------|------------|
| 0.5 | "Check dependencies" | "Checking dependencies" |
| 0 | "Analyze current state" | "Analyzing current state" |
| 1 | "Plan target state and gaps" | "Planning target state and gaps" |
| 2 | "Create migration strategy" | "Creating migration strategy" |
| 3 | "Plan implementation" | "Planning implementation" |
| 4 | "Execute migration" | "Executing migration" |
| 5 | "Verify and test compatibility" | "Verifying and testing compatibility" |
| 6 | "Generate documentation" | "Generating documentation" |
| 7 | "Finalize workflow" | "Finalizing workflow" |

**Rules**:
- Create all phase todos at workflow start (pending)
- Mark current phase `in_progress` before execution
- Mark phase `completed` immediately after success
- Optional phases skipped: mark as `completed`
- State file remains source of truth for resume logic

---

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
  {"content": "Generate documentation", "status": "pending", "activeForm": "Generating documentation"},
  {"content": "Finalize workflow", "status": "pending", "activeForm": "Finalizing workflow"}
]
```

### Step 2: Output Initialization Summary

**Output this summary to the user:**

```
🚀 Migration Orchestrator Started

Migration: [description]
Mode: [Interactive/YOLO]

Workflow Phases:
0.5. [ ] Dependency Check (if part of initiative)
0. [ ] Current State Analysis → existing-feature-analyzer subagent
1. [ ] Target State Planning & Gap Analysis → gap-analyzer subagent
2. [ ] Migration Strategy Planning
3. [ ] Implementation Planning → implementation-planner skill
4. [ ] Migration Execution → implementer skill
5. [ ] Verification & Compatibility Testing → implementation-verifier skill
6. [ ] Documentation Generation (optional)
7. [ ] Finalization

State file: [task-path]/orchestrator-state.yml

[Interactive mode] You'll be prompted for review after each phase.
[YOLO mode] All phases will run continuously.

Starting Phase 0: Current State Analysis...
```

### Step 3: Only Then Proceed to Phase 0

After completing Steps 1 and 2, proceed to Phase 0 (Current State Analysis).

---

## Execution Modes

### Interactive Mode (Default)
- Pauses after each major phase for user review
- Prompts for migration strategy decisions (incremental, big-bang, dual-run, phased)
- Shows risk assessment and allows course correction
- Confirms migration type detection
- Best for: Complex migrations, breaking changes, critical systems, learning

### YOLO Mode
- Runs all phases continuously without pausing
- Auto-decides migration strategy based on type and complexity
- Reports progress but doesn't wait for approval
- Still pauses for critical decisions (rollback confirmation, cutover)
- Best for: Simple migrations (patch versions), experienced users, non-critical systems

## Workflow Phases

### Phase 0.5: Dependency Check (If Part of Initiative)

**Purpose**: Validate dependencies if this task is part of a larger initiative

**When**: Before Phase 0 (Current State Analysis), only if task has `initiative_id` in metadata.yml

**Actions**:
1. Read task metadata.yml
2. Check if `initiative_id` field exists
3. If NO initiative_id: Skip this phase (standalone task)
4. If YES initiative_id:
   a. Read `dependencies` array from metadata.yml
   b. For each dependency task path:
      - Read dependency task's metadata.yml
      - Check `status` field
   c. If ANY dependency status != "completed":
      - BLOCK task execution
      - Update task status to "blocked" in metadata.yml
      - Exit with message: "Task blocked by dependencies: [list]. Dependencies must complete first. Check initiative status with: /ai-sdlc:initiative:status [initiative-path]"
   d. If ALL dependencies completed:
      - Log: "All dependencies satisfied, proceeding to current state analysis"
      - Continue to Phase 0

**Outputs**:
- None if dependencies satisfied (continues to Phase 0)
- Updated metadata.yml with status="blocked" if dependencies not satisfied
- Error message with blocking dependency list

**Integration**:
- Minimal change to existing workflow
- No impact on standalone tasks (skipped automatically)
- Ensures migration only starts when prerequisites complete (critical for sequential migrations)

### Phase 0: Current State Analysis
**Agent**: `ai-sdlc:existing-feature-analyzer` (subagent)

**Purpose**: Locate and analyze existing system before migration

**Delegation Pattern**:
This phase is executed by the ai-sdlc:existing-feature-analyzer subagent to prevent context pollution in the main orchestrator.

**Your Task for Phase 0**:
1. **Invoke Subagent**: Use Task tool to invoke existing-feature-analyzer
   ```
   Task tool parameters:
   - subagent_type: "ai-sdlc:existing-feature-analyzer"
   - description: "Analyze current system for migration"
   - prompt: "Analyze the existing system for this migration.

   Migration Description: [insert migration description]
   Task Path: [.ai-sdlc/tasks/migrations/YYYY-MM-DD-name/]
   Mode: [interactive or yolo]

   Follow your 7-phase workflow:
   1. Initialization & Validation
   2. Feature Context Extraction
   3. Multi-Strategy Search (filename, keyword, code patterns)
   4. File Scoring & Ranking
   5. Match Presentation & User Confirmation
   6. Feature Analysis (functionality, dependencies, tests, patterns)
   7. Generate Analysis Report

   Create comprehensive current state analysis at:
   analysis/current-state-analysis.md

   Return structured result with:
   - status: success|failed|partial
   - report_path: analysis/current-state-analysis.md
   - summary: [2-3 sentence overview]
   - files_found: [array of {path, confidence, lines, consumers}]
   - technologies: [array of current tech stack items]
   - complexity: simple|moderate|complex
   - effort_estimate: [time estimate]"
   ```

2. **Wait for Completion**: Subagent executes 7-phase analysis workflow

3. **Parse Result**: Extract report path, summary, technologies, complexity

4. **Store in State**: Update orchestrator-state.yml with current system info:
   ```yaml
   current_system:
     description: [summary from subagent]
     technologies: [technologies array from subagent]
   ```

5. **Present to User** (if interactive mode):
   ```
   ✅ Phase 0 Complete: Current State Analysis

   Current System Found:
   - [Primary files] ([lines] lines)
   - Technologies: [tech list]
   - Complexity: [complexity]
   - Migration Effort: [estimate]

   Report: analysis/current-state-analysis.md

   Ready to proceed to Phase 1 (Target State Planning)? [Y/n/review]
   ```

6. **Handle Response**:
   - Y: Proceed to Phase 1
   - n: Exit workflow
   - review: Show report contents, then ask again

**What the Subagent Does**:
- Auto-detects current system files using multi-strategy search
- Analyzes current technologies, dependencies, and complexity
- Documents current architecture patterns
- Assesses test coverage
- Creates comprehensive baseline analysis report

**Outputs**:
- `analysis/current-state-analysis.md` - Current system analysis report (400-600 lines)
- Structured result passed back to orchestrator

**Auto-Fix Strategy**:
- If system files not found: Subagent expands search or prompts user (max 2 attempts)
- If low confidence: Subagent requests manual path
- If analysis fails: Subagent reports partial results
- Orchestrator retry: If subagent fails completely, orchestrator can re-invoke once with adjusted prompt

**Reference**: `agents/existing-feature-analyzer.md`

---

### Phase 1: Target State Planning & Gap Analysis
**Agent**: `gap-analyzer` (subagent)

**Purpose**: Define target system, identify migration scope, classify migration type

**Delegation Pattern**:
This phase is executed by the gap-analyzer subagent for complex analysis workflows.

**Your Task for Phase 1**:
1. **Invoke gap-analyzer via Task tool:**
   ```
   Use Task tool with parameters:
   - subagent_type: "ai-sdlc:gap-analyzer"
   - description: "Analyze migration gaps and target state"
   - prompt: "Perform comprehensive gap analysis for this migration.

   Migration Description: [insert migration description]
   Task Path: [.ai-sdlc/tasks/migrations/YYYY-MM-DD-name/]
   Existing Analysis Path: analysis/current-state-analysis.md
   Mode: [interactive or yolo]

   Follow your adapted 9-phase workflow:
   1. Initialization & Validation
   2. Target System Definition (from migration description)
   3. Gap Identification (features to migrate, APIs to adapt, data to transform)
   4. Migration Type Classification (Code/Data/Architecture)
   5. Migration Strategy Recommendation (incremental/big-bang/dual-run/phased)
   6. Risk Assessment (breaking changes, data loss risks, compatibility issues)
   7. Rollback Requirements (what needs undo procedures)
   8. Effort Estimation
   9. Create Gap Analysis Report

   MIGRATION-SPECIFIC ANALYSIS:
   - Identify breaking changes between current and target
   - Document API/interface differences
   - Assess data transformation needs
   - Evaluate backward compatibility requirements
   - Recommend migration phases if incremental approach needed

   Create comprehensive gap analysis report at:
   analysis/target-state-plan.md

   Return structured result with:
   - status: success|failed|partial
   - report_path: analysis/target-state-plan.md
   - summary: [target system + gaps overview]
   - migration_type: code|data|architecture|general
   - migration_strategy: incremental|big-bang|dual-run|phased
   - risk_level: low|medium|high
   - effort_estimate: [time estimate]
   - breaking_changes: [array of breaking changes]
   - rollback_complexity: simple|moderate|complex"
   ```

2. **Wait for Completion**: Subagent executes 9-phase analysis

3. **Parse Result**: Extract report path, migration type, strategy, risk

4. **Store in State**: Update orchestrator-state.yml with target system info:
   ```yaml
   migration_type: [code|data|architecture|general]
   target_system:
     description: [summary from subagent]
     technologies: [target tech array]
   migration_strategy:
     approach: [incremental|big-bang|dual-run|phased]
     phases: [array of phase names if incremental]
   risk_level: [low|medium|high]
   ```

5. **Present to User** (if interactive mode):
   ```
   ✅ Phase 1 Complete: Target State Planning & Gap Analysis

   Migration Classification:
   - Type: [Code/Data/Architecture]
   - Strategy: [Incremental/Big-Bang/Dual-Run/Phased]
   - Risk Level: [Low/Medium/High]
   - Effort: [hours estimate]

   Key Findings:
   - Breaking changes: [count]
   - Data transformations needed: [yes/no]
   - Backward compatibility: [yes/no/partial]

   Report: analysis/target-state-plan.md

   Confirmed migration type: [type]? [Y/n/specify]
   ```

6. **Handle Response**:
   - Y: Proceed to Phase 2
   - n: Prompt user to specify correct type, update state, continue
   - specify: Ask for type (code/data/architecture/general), update state, continue

**What the Subagent Does**:
- Defines target system goals and requirements
- Compares current vs target (gap analysis)
- **Performs external research** (WebSearch) for version upgrades, technology migrations, and API integrations
- Classifies migration type based on keywords and technologies
- Recommends migration strategy based on complexity and risk
- Identifies breaking changes and compatibility issues (enhanced by external research)
- Assesses rollback complexity
- Documents migration phases if incremental approach needed

**External Research** (automatic):
The gap-analyzer automatically performs web research when it detects version upgrades, technology migrations, or external API integrations. This enriches the analysis with:
- Official migration guides and breaking changes documentation
- Current best practices from authoritative sources
- Known issues and workarounds from community resources

**Outputs**:
- `analysis/target-state-plan.md` - Target system and gap analysis (500-700 lines)
- Structured result passed back to orchestrator (includes `external_research` field)

**Auto-Fix Strategy**:
- If target unclear: Subagent re-prompts user for target details (max 2 attempts)
- If migration type ambiguous: Subagent prompts user to classify
- If gap analysis incomplete: Subagent retries with expanded analysis
- Orchestrator retry: If subagent fails, orchestrator can re-invoke once with clarified prompt

**Reference**: `agents/gap-analyzer.md`

---

### Phase 2: Migration Strategy Specification
**Skill**: `specification-creator`

**Purpose**: Create detailed migration specification with migration-specific prompts

**Actions**:
1. Invoke specification-creator with migration context
2. Pass current_system and target_system from state
3. Pass migration_type and migration_strategy from state
4. Specification-creator prompts for migration-specific details:
   - Rollback requirements for each phase
   - Dual-run synchronization approach (if dual-run strategy)
   - Incremental milestone definitions (if incremental strategy)
   - Data migration procedures (if data migration)
   - Breaking change mitigation strategies
5. Create implementation/spec.md with migration specification
6. Create `analysis/rollback-plan.md` with undo procedures
7. If dual-run: Create `analysis/dual-run-plan.md` with parallel operation details
8. Verify specification quality

**Outputs**:
- `implementation/spec.md` - Migration specification
- `analysis/rollback-plan.md` - Rollback procedures for each phase
- `analysis/dual-run-plan.md` - Dual-run configuration (if applicable)
- `verification/spec-verification.md` - Specification quality report

**Auto-Fix Strategy**:
- If spec verification fails: Re-invoke specification-creator with issues as context (max 2 attempts)
- If rollback plan incomplete: Regenerate with specific constraints
- If dual-run plan missing critical sync details: Re-prompt user for clarification

**State Updates**:
```yaml
rollback_plan_created: true
dual_run_configured: true|false
```

---

### Phase 3: Implementation Planning
**Skill**: `implementation-planner`

**Purpose**: Break migration into executable steps with task groups

**Actions**:
1. Invoke implementation-planner with migration specification
2. Break migration into task groups by migration phase:
   - For incremental: Task group per migration phase
   - For big-bang: Standard task groups (prep, migrate, verify)
   - For dual-run: Task groups (old system, new system, sync, cutover)
   - For phased: Task groups per phase with dependencies
3. Include rollback steps in each task group
4. Define verification points between phases
5. Set dependencies ensuring proper migration sequence

**Outputs**:
- `implementation/implementation-plan.md` - Detailed implementation steps with rollback procedures

**Auto-Fix Strategy**:
- If planning incomplete: Regenerate with migration-specific constraints (max 2 attempts)
- If dependencies incorrect: Re-analyze migration dependencies and regenerate
- If rollback steps missing: Add rollback steps to each task group automatically

---

### Phase 4: Migration Execution
**Skill**: `implementer`

**Purpose**: Execute migration implementation plan incrementally

**Standards Reminder**: The implementer skill reads `.ai-sdlc/docs/INDEX.md` for continuous standards discovery throughout execution. Ensure migration follows project coding standards.

**Actions**:
1. Invoke implementer to execute implementation-plan.md
2. Execute migration incrementally per task group
3. Run tests after each migration phase (not just at end)
4. Enable pause/resume at task group boundaries (critical for migrations)
5. Log progress in implementation/work-log.md
6. Apply continuous standards discovery

**Outputs**:
- Implemented migration changes
- Updated `implementation-plan.md` (all steps complete)
- `implementation/work-log.md` - Migration execution log

**Auto-Fix Strategy**:
- If migration step fails: Re-run with error context (max 3 attempts per group)
- If tests fail: Analyze and fix, check if rollback needed (max 3 attempts per group)
- If breaking change issues: Document workaround and continue
- Max overall retries: 5

**State Updates**:
Track which migration phases completed successfully for rollback reference.

---

### Phase 5: Verification + Compatibility Testing
**Skill**: `implementation-verifier`

**Purpose**: Verify migration success and compatibility

**Actions**:
1. Invoke implementation-verifier for standard checks
2. Add migration-specific compatibility testing:
   - Verify old system still works (if dual-run)
   - Test rollback procedures (non-destructive test)
   - Validate data integrity (for data migrations)
   - Check performance benchmarks (before/after comparison)
   - Verify backward compatibility (if required)
3. Run full test suite to catch regressions
4. Check standards compliance
5. Create comprehensive verification report

**Outputs**:
- `verification/implementation-verification.md` - Standard verification report
- `verification/compatibility-test-results.md` - Migration-specific compatibility results

**Auto-Fix Strategy**:
- If tests fail: Invoke implementer with fix instructions (max 2 attempts)
- If rollback test fails: Document rollback issue, recommend manual rollback procedures
- If data integrity issues: HALT and prompt user (data safety critical)
- Max attempts: 2 (3 for data migrations)

---

### Phase 6: Documentation (Optional)
**Agent**: `user-docs-generator` (subagent)

**Purpose**: Generate migration guide for team

**Triggered When**:
- Interactive mode: Prompt user after Phase 5
- YOLO mode: Auto-run for complex migrations (medium-high risk)
- Explicit flag: `--docs` in command

**Actions**:
1. Invoke user-docs-generator with migration context
2. Generate migration guide including:
   - Migration overview and goals
   - Prerequisites and preparation steps
   - Step-by-step migration procedure
   - Rollback procedures
   - Troubleshooting common issues
   - Verification checklist
3. Include before/after comparisons

**Outputs**:
- `documentation/migration-guide.md` - Complete migration guide for team

**Auto-Fix Strategy**:
- If doc generation fails: Generate text-only without screenshots (max 1 attempt)
- Documentation is optional, failure doesn't block workflow

---

### Phase 7: Finalization
**Actions**:
1. Create comprehensive workflow summary
2. Update task metadata status to "completed"
3. Optionally update roadmap in docs/project/roadmap.md
4. Provide commit message template
5. Guide next steps (testing in staging, production cutover)

**Outputs**:
- Workflow summary report
- Updated `metadata.yml`
- Commit message template

---

## Orchestrator Workflow Execution

### Initialization

**STEP 1: Parse Command Arguments**

Extract from invocation:
- Migration description (if provided)
- Execution mode: `--yolo` flag or default interactive
- Entry point: `--from=PHASE` (analysis, target, spec, plan, execute, verify)
- Migration type override: `--type=TYPE` (code, data, architecture)
- Task path: If resuming existing task

**STEP 2: Detect Migration Type (if new migration)**

**Keyword Detection**:

```
Code Migration Keywords:
- Framework/library names: React, Vue, Angular, Express, Flask, Django, Spring, etc.
- Upgrade terms: "upgrade", "migrate from X to Y", "move from X to Y"
- Version changes: "version 2 to 3", "v1 to v2"

Data Migration Keywords:
- Database names: MySQL, PostgreSQL, MongoDB, Redis, DynamoDB, etc.
- Data terms: "schema change", "data migration", "database migration"
- Storage: "move data", "migrate database"

Architecture Migration Keywords:
- Pattern names: REST, GraphQL, gRPC, SOAP
- Architecture styles: Monolith, Microservices, Serverless, Event-Driven
- Refactoring: "refactor to", "change architecture"

General Migration (fallback):
- Generic "migrate" without specific tech
- Ambiguous descriptions
```

**Detection Logic**:
1. Scan migration description for keywords
2. Count matches per category
3. Classify based on highest match count:
   - Code: Framework/library/version keywords
   - Data: Database/schema/data keywords
   - Architecture: Pattern/architecture keywords
   - General: No clear category or mixed
4. Set migration_type in state
5. If interactive: Prompt user to confirm
6. If YOLO: Auto-proceed with detected type

**STEP 3: Determine Starting Phase**

**If task path provided** (resuming):
1. Read `orchestrator-state.yml` if exists
2. Check `completed_phases`
3. Determine next phase to execute
4. Validate prerequisites for that phase

**If new migration**:
1. Start from specified phase (`--from`) or Phase 0 (default)
2. If starting mid-workflow, validate required files exist:
   - Starting from target: Requires `analysis/current-state-analysis.md`
   - Starting from spec: Requires `analysis/current-state-analysis.md` + `analysis/target-state-plan.md`
   - Starting from plan: Requires `implementation/spec.md`
   - Starting from execute: Requires `implementation/spec.md` + `implementation/implementation-plan.md`
   - Starting from verify: Requires implementation complete

**If prerequisites missing**:
```
❌ Cannot start from [phase] - missing prerequisites!

Required files:
- [file1]: ❌ Missing
- [file2]: ❌ Missing

Options:
1. Start from beginning (Phase 0: Current State Analysis)
2. Provide/create missing files manually
3. Specify different entry point with --from

Which option would you like?
```

**STEP 4: Initialize State Management**

Create/update `orchestrator-state.yml`:

```yaml
orchestrator:
  mode: interactive  # or yolo
  started_phase: analysis  # or target, spec, plan, execute, verify
  current_phase: analysis
  completed_phases: []
  failed_phases: []
  auto_fix_attempts:
    analysis: 0
    target_planning: 0
    specification: 0
    planning: 0
    execution: 0
    verification: 0
    documentation: 0

  # Migration-specific fields
  migration_type: code|data|architecture|general
  current_system:
    description: ""
    technologies: []
  target_system:
    description: ""
    technologies: []
  migration_strategy:
    approach: incremental|big-bang|dual-run|phased
    phases: []
  risk_level: low|medium|high
  rollback_plan_created: false
  dual_run_configured: false

  # External research results (from Phase 1 gap-analyzer)
  external_research:
    performed: false
    category: null  # version_upgrade|technology_migration|external_standards|auth_security|api_integration|architecture
    depth: null     # essential|expanded
    breaking_changes: []
    migration_guide_url: null
    confidence: null  # high|medium|low

  options:
    docs_enabled: false
  created: [timestamp]
  updated: [timestamp]
  task_path: .ai-sdlc/tasks/migrations/YYYY-MM-DD-migration-name
```

**STEP 5: Output Initialization Summary**

```
🚀 Migration Orchestrator Started

Migration: [migration description]
Detected Type: [code|data|architecture|general]
Mode: [Interactive/YOLO]
Starting Phase: [phase name]

Workflow Phases:
0. [x] Current State Analysis - [Starting here / Already complete / Pending]
1. [ ] Target State Planning - [Next / Pending]
2. [ ] Migration Strategy Specification
3. [ ] Implementation Planning
4. [ ] Migration Execution
5. [ ] Verification + Compatibility Testing
6. [ ] Documentation (optional) - [Enabled / Will prompt / Disabled]

State file: [path]/orchestrator-state.yml

[Interactive mode message]
You'll be prompted for review after each phase.
Migration type and strategy will be confirmed.

[YOLO mode message]
All phases will run continuously. Migration type auto-detected. 🚀

Press Enter to begin...
```

### Phase Execution Loop

**Same pattern as feature-orchestrator**:

**FOR each phase in workflow:**

1. Check if phase already completed (skip if in completed_phases)
2. Update state to current phase
3. Pre-phase announcement
4. Execute phase (invoke skill/agent)
5. Analyze phase results
6. If failure: Execute auto-fix strategy
7. Update state after phase (add to completed_phases or failed_phases)
8. Post-phase review (interactive) or continue (YOLO)
9. Handle user response (continue/review/restart/stop)

**Migration-Specific Modifications**:
- Phase 0 and 1 use subagent delegation pattern (Task tool)
- After Phase 1, confirm migration_type with user (interactive mode)
- Store migration-specific fields in state after each phase
- Track rollback_plan_created and dual_run_configured

### Auto-Fix Strategies

**Phase 0 (Current State Analysis)**:
- Retry: If files not found, re-invoke subagent with expanded search patterns (max 2 attempts)
- Fallback: Prompt user for manual file paths if auto-detection fails
- Max attempts: 2

**Phase 1 (Target State Planning)**:
- Retry: If target unclear, re-prompt user for target details (max 2 attempts)
- Fallback: If migration type ambiguous, prompt user to specify type manually
- Max attempts: 2

**Phase 2 (Migration Strategy Specification)**:
- Retry: If spec verification fails, re-invoke specification-creator with issues (max 2 attempts)
- Fallback: If rollback plan incomplete, regenerate with specific constraints
- Max attempts: 2

**Phase 3 (Implementation Planning)**:
- Retry: If plan incomplete, regenerate with migration-specific constraints (max 2 attempts)
- Fallback: If dependencies incorrect, re-analyze and regenerate
- Max attempts: 2

**Phase 4 (Migration Execution)**:
- Retry: Fix syntax errors, missing imports (max 5 overall retries across all task groups)
- Fallback: If migration step fails repeatedly, log issue and prompt user for manual intervention
- Max attempts: 5 overall (distributed across task groups)

**Phase 5 (Verification + Compatibility)**:
- Retry: If tests fail, invoke implementer with fix instructions (max 2 attempts)
- Critical: If data integrity issues in data migration, HALT and prompt user
- Max attempts: 2 (3 for data migrations due to data safety importance)

**Phase 6 (Documentation)**:
- Retry: If doc generation fails, generate text-only without screenshots (max 1 attempt)
- Fallback: Documentation optional, failure doesn't block workflow
- Max attempts: 1

### State Management

**State File Operations**:

**Read State**:
```
path = task_path + "/orchestrator-state.yml"
if file_exists(path):
  state = read_yaml(path)
  return state
else:
  return null
```

**Write State**:
```
state.updated = current_timestamp()
write_yaml(task_path + "/orchestrator-state.yml", state)
```

**Check Phase Complete**:
```
return phase_name in state.completed_phases
```

**Mark Phase Complete**:
```
if phase_name not in state.completed_phases:
  state.completed_phases.append(phase_name)
state.updated = current_timestamp()
write_yaml(state)
```

**Mark Phase Failed**:
```
state.failed_phases.append({
  phase: phase_name,
  attempts: state.auto_fix_attempts[phase_name],
  error: error_message,
  timestamp: current_timestamp()
})
state.updated = current_timestamp()
write_yaml(state)
```

**Increment Auto-Fix Attempts**:
```
state.auto_fix_attempts[phase_name] += 1
state.updated = current_timestamp()
write_yaml(state)
```

### Integration Points

**Reusing Existing Skills**:
- `specification-creator` (Phase 2) - Invoked with migration-specific prompts
- `implementation-planner` (Phase 3) - Invoked with migration context
- `implementer` (Phase 4) - Invoked with implementation-plan.md
- `implementation-verifier` (Phase 5) - Invoked with migration verification requirements

**Reusing Existing Agents** (via Task tool with subagent delegation):
- `existing-feature-analyzer` (Phase 0) - Analyzes current system
- `gap-analyzer` (Phase 1) - Compares current vs target, classifies migration
- `user-docs-generator` (Phase 6, optional) - Generates migration guide

**Tool Access**:
- Read, Write, Edit - File operations
- Glob, Grep - Codebase search
- Bash - Test execution, git operations
- Skill - Invoke other skills
- Task - Invoke subagents

### Error Handling Philosophy

1. **Auto-Fix First**: Attempt automatic fixes before prompting user
2. **Max Attempts**: Respect max attempt limits to avoid infinite loops
3. **Fail Gracefully**: If auto-fix fails, provide clear error message and options
4. **User Control**: Always allow user to retry, skip, or exit
5. **State Preservation**: Save state before failing so workflow can resume
6. **Data Safety**: For data migrations, HALT on data integrity issues (don't auto-fix)

## Output Directory Structure

Migration tasks follow the standard task structure with migration-specific analysis files:

```
.ai-sdlc/tasks/migrations/YYYY-MM-DD-migration-name/
├── metadata.yml                          # Task metadata and tracking
├── orchestrator-state.yml                # Workflow state for resume
├── analysis/                             # Analysis and planning artifacts
│   ├── current-state-analysis.md        # Phase 0 output
│   ├── target-state-plan.md             # Phase 1 output
│   ├── rollback-plan.md                 # Phase 2 output
│   └── dual-run-plan.md                 # Phase 2 output (if dual-run strategy)
├── implementation/                       # Implementation work
│   ├── spec.md                          # Phase 2 output (migration specification)
│   ├── implementation-plan.md           # Phase 3 output
│   └── work-log.md                      # Phase 4 output
├── verification/                         # Verification results
│   ├── spec-verification.md             # Phase 2 output
│   ├── implementation-verification.md   # Phase 5 output
│   └── compatibility-test-results.md    # Phase 5 output
└── documentation/                        # User-facing docs (if enabled)
    └── migration-guide.md               # Phase 6 output (optional)
```

**Key Points**:
- `spec.md` and `implementation-plan.md` go in `implementation/` (consistent with other orchestrators)
- Analysis artifacts (current state, target state, rollback plans) go in `analysis/`
- Verification reports go in `verification/`
- Documentation artifacts go in `documentation/`

## Important Guidelines

1. **Always Start with Phase 0**: Don't skip current state analysis, even if you think you know the system
2. **Confirm Migration Type**: In interactive mode, always confirm detected migration_type with user
3. **Incremental Over Big-Bang**: Recommend incremental approach for complex migrations (lower risk)
4. **Test Between Phases**: For migrations, run tests after each task group (not just at end)
5. **Document Rollback**: Always create rollback plan, even for "simple" migrations
6. **Respect Auto-Fix Limits**: Don't exceed max attempts, prompt user instead
7. **Data Safety Critical**: For data migrations, extra verification and lower risk tolerance
8. **State Management**: Update state after every phase and significant operation

## Example Workflows

### Example 1: Code Migration (Framework Upgrade)

**Scenario**: Migrate from Vue 2 to Vue 3

**Command**: `/ai-sdlc:migration:new "Migrate from Vue 2 to Vue 3"`

**Workflow**:
1. **Phase 0**: Analyze current Vue 2 codebase
   - Detected: 45 Vue components, Vue Router, Vuex
   - Complexity: Moderate
   - Effort: 2-3 days
2. **Phase 1**: Define Vue 3 target
   - Type: Code migration (detected and confirmed)
   - Strategy: Incremental (recommended for 45 components)
   - Breaking changes: 12 identified
3. **Phase 2**: Create migration spec
   - Rollback plan: Revert via git + npm install vue@2
   - Dual-run: Not applicable (can't run Vue 2 and 3 in same app)
   - Phases: Core → Components → Router → Vuex
4. **Phase 3**: Plan implementation
   - Task Group 1: Upgrade core dependencies
   - Task Group 2: Migrate core components
   - Task Group 3: Migrate router and store
   - Task Group 4: Update tests
5. **Phase 4**: Execute migration incrementally
   - Tests run after each task group
   - Rollback point after each group
6. **Phase 5**: Verify migration
   - Full test suite run
   - Performance benchmarks compared
   - Compatibility verified
7. **Phase 6**: Generate migration guide
   - Document breaking changes handled
   - Include rollback procedure
   - Add troubleshooting section

**Result**: ✅ Migration Complete, all tests passing, rollback documented

---

### Example 2: Data Migration (Database Platform Change)

**Scenario**: Migrate from MySQL to PostgreSQL

**Command**: `/ai-sdlc:migration:new "Move database from MySQL to PostgreSQL" --type=data`

**Workflow**:
1. **Phase 0**: Analyze current MySQL database
   - Detected: 23 tables, 450k rows, 5 stored procedures
   - Complexity: Moderate-High
   - Effort: 3-5 days
2. **Phase 1**: Define PostgreSQL target
   - Type: Data migration (confirmed)
   - Strategy: Dual-run (recommended for zero-downtime)
   - Risk: High (data integrity critical)
3. **Phase 2**: Create migration spec
   - Rollback plan: Keep MySQL running, revert connection strings
   - Dual-run: Run both databases, sync writes, read from new
   - Data validation: 100% row count match, checksums
4. **Phase 3**: Plan implementation
   - Task Group 1: Setup PostgreSQL schema
   - Task Group 2: Migrate data (bulk copy)
   - Task Group 3: Setup dual-run sync
   - Task Group 4: Verify data integrity
   - Task Group 5: Cutover to PostgreSQL
5. **Phase 4**: Execute migration
   - Data copied in batches (verify checksums)
   - Dual-run implemented with write sync
   - Tests run after each batch
6. **Phase 5**: Verify migration + compatibility
   - Data integrity: 100% match (450k rows verified)
   - Performance: Queries 15% faster
   - Old MySQL still operational (rollback ready)
   - Compatibility tests: All passed
7. **Phase 6**: Generate migration guide
   - Document cutover procedure
   - Include rollback steps (switch connection strings)
   - Add data verification commands

**Result**: ✅ Migration Complete, data verified, MySQL kept online for 7 days for rollback safety

---

### Example 3: Architecture Migration (REST to GraphQL)

**Scenario**: Refactor REST API to GraphQL

**Command**: `/ai-sdlc:migration:new "Refactor from REST API to GraphQL" --yolo`

**Workflow** (YOLO mode - continuous):
1. **Phase 0**: Analyze REST API (25 endpoints)
2. **Phase 1**: Define GraphQL target (detected: architecture migration, strategy: incremental)
3. **Phase 2**: Create migration spec (dual-run: REST and GraphQL in parallel)
4. **Phase 3**: Plan implementation (4 task groups: schema, resolvers, client, deprecate REST)
5. **Phase 4**: Execute migration (all task groups run continuously)
6. **Phase 5**: Verify (dual-run tests, both APIs work)
7. **Phase 6**: Skip docs (internal API, YOLO auto-decides)

**Result**: ✅ Migration Complete in YOLO mode, GraphQL deployed alongside REST

---

## Validation Checklist

Before completing workflow:

**Phase 0 (Current State Analysis)**:
- ✓ `analysis/current-state-analysis.md` created
- ✓ Current system files identified with confidence scores
- ✓ Current technologies documented
- ✓ State file contains `current_system` fields

**Phase 1 (Target State Planning)**:
- ✓ `analysis/target-state-plan.md` created
- ✓ Migration type detected and confirmed
- ✓ Migration strategy recommended
- ✓ External research performed (if version upgrade or technology migration)
- ✓ State file contains `migration_type`, `target_system`, `migration_strategy`, `risk_level`, `external_research`

**Phase 2 (Migration Strategy Specification)**:
- ✓ `implementation/spec.md` created with migration details
- ✓ `analysis/rollback-plan.md` created
- ✓ `analysis/dual-run-plan.md` created if dual-run strategy
- ✓ State file contains `rollback_plan_created` and `dual_run_configured`

**Phase 3 (Implementation Planning)**:
- ✓ `implementation/implementation-plan.md` created with task groups
- ✓ Rollback steps included in each task group
- ✓ Dependencies set correctly for migration sequence

**Phase 4 (Migration Execution)**:
- ✓ All implementation steps marked complete
- ✓ `implementation/work-log.md` documents migration execution
- ✓ Tests run after each task group (incremental verification)

**Phase 5 (Verification + Compatibility)**:
- ✓ `verification/implementation-verification.md` created
- ✓ `verification/compatibility-test-results.md` created
- ✓ Migration-specific compatibility verified (rollback tested, data integrity checked, old system tested if dual-run)

**Phase 6 (Documentation)** (if enabled):
- ✓ `documentation/migration-guide.md` created
- ✓ Rollback procedures documented
- ✓ Troubleshooting section included

**State Management**:
- ✓ All phases tracked in `completed_phases`
- ✓ Migration-specific fields populated (`migration_type`, `current_system`, `target_system`, `migration_strategy`)
- ✓ State file valid YAML format

---

## Success Criteria

**Overall Workflow**:
- ✅ All 7 phases execute in correct order (0→1→2→3→4→5→6)
- ✅ Migration type detected and confirmed
- ✅ Migration strategy selected (incremental/big-bang/dual-run/phased)
- ✅ Rollback plan created and documented
- ✅ Migration executes incrementally with verification points
- ✅ Compatibility testing validates migration success
- ✅ State file tracks all migration-specific fields
- ✅ Interactive and YOLO modes work correctly
- ✅ Pause/resume capability functional

**Quality Gates**:
- ✅ Current state analysis complete (Phase 0)
- ✅ Target state defined and gaps identified (Phase 1)
- ✅ Migration specification comprehensive (Phase 2)
- ✅ Implementation plan includes rollback steps (Phase 3)
- ✅ Tests pass after each migration phase (Phase 4)
- ✅ Full test suite passes (Phase 5)
- ✅ Compatibility verified (old system works if dual-run, rollback tested)

**Migration-Specific**:
- ✅ For code migrations: Breaking changes documented and handled
- ✅ For data migrations: Data integrity verified (100% row match, checksums)
- ✅ For architecture migrations: Old and new systems coexist (if dual-run)
- ✅ Rollback plan tested (non-destructive test)
