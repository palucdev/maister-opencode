---
name: documentation-orchestrator
description: Orchestrates end-user documentation creation workflows with content planning, screenshot generation, and publication. Plans documentation structure, generates content with screenshots, validates readability and completeness, and publishes to appropriate location.
---

# Documentation Orchestrator

Systematic documentation creation workflow from planning to published, user-ready documentation.

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
2. **Create Task Directory**: `.ai-sdlc/tasks/documentation/YYYY-MM-DD-task-name/`
3. **Initialize State**: Create `orchestrator-state.yml` with mode and documentation context

**Output**:
```
🚀 Documentation Orchestrator Started

Task: [documentation description]
Mode: [Interactive/YOLO]
Directory: [task-path]

Starting Phase 0: Plan documentation structure...
```

---

## When to Use

Use for:
- Documenting new features for users
- Creating user guides, tutorials, or FAQ sections
- Updating documentation with screenshots
- Building API documentation or reference guides

**DO NOT use for**: README files, code comments, technical specs, or changelog entries.

---

## Core Principles

1. **User-First**: Write for the least technical user in your audience
2. **Show and Tell**: Combine screenshots with text descriptions
3. **Clear and Simple**: Avoid jargon, use everyday language
4. **Example-Driven**: Use realistic examples, not placeholders
5. **Maintainable**: Structure for easy updates when features change

---

## Phase Configuration

| Phase | content | activeForm | Agent/Skill |
|-------|---------|------------|-------------|
| 0 | "Plan documentation structure" | "Planning documentation structure" | documentation-planner |
| 1 | "Create content with screenshots" | "Creating content with screenshots" | user-docs-generator |
| 2 | "Review and validate" | "Reviewing and validating" | documentation-reviewer |
| 2.5 | "Resolve documentation issues" | "Resolving documentation issues" | Direct (conditional) |
| 3 | "Publish and integrate" | "Publishing and integrating" | Direct |

---

## Workflow Phases

### Phase 0: Documentation Planning & Audience Analysis

**Purpose**: Classify doc type, identify audience, create structured outline
**Execute**: Task tool - `ai-sdlc:documentation-planner` subagent
**Output**: `planning/documentation-outline.md`
**State**: Update `documentation_context.doc_type`, `target_audience`, `tone`

→ Pause

**Interactive**: AskUserQuestion - "Documentation outline complete. Continue to content creation?"
**YOLO**: "→ Continuing to Phase 1..."

---

### Phase 1: Content Creation with Screenshots

**Purpose**: Generate documentation content with Playwright screenshots
**Execute**: Task tool - `ai-sdlc:user-docs-generator` subagent
**Output**: `documentation/user-guide.md`, `documentation/screenshots/*.png`
**State**: Update `documentation_context.content_created`, `screenshot_count`

→ Pause

**Interactive**: AskUserQuestion - "Content created. Continue to review?"
**YOLO**: "→ Continuing to Phase 2..."

---

### Phase 2: Review & Validation

**Purpose**: Validate completeness and readability with metrics
**Execute**: Task tool - `ai-sdlc:documentation-reviewer` subagent
**Output**: `verification/documentation-review.md` with PASS/FAIL verdict
**State**: Update `documentation_context.verdict`, `readability_score`

**Verdict Criteria**:
- **PASS**: All sections present, readability targets met, screenshots valid
- **PASS with Issues**: Minor issues but usable
- **FAIL**: Missing sections, poor readability (<50 ease), broken links

→ Conditional: if verdict=PASS skip to Phase 3, if verdict="PASS with Issues" or fixable FAIL continue to Phase 2.5, otherwise stop workflow

---

### Phase 2.5: Documentation Issue Resolution (Conditional)

**Purpose**: Fix issues identified in review through direct editing
**Execute**: Direct - apply fixes, re-verify with documentation-reviewer
**Output**: Updated documentation, `verification_context.fixes_applied`
**State**: Update `verification_context.reverify_count`, `decisions_made`

**Skip if**: verdict = PASS

**Process**:
1. Parse issues from review (categorize: auto-fixable, needs decision, not fixable)
2. Apply auto-fixes (typos, formatting, broken links, missing alt text)
3. For user decisions: AskUserQuestion with options
4. Re-verify after fixes (max 3 iterations)

**Exit Conditions**:
- ✅ New verdict = PASS → Proceed to Phase 3
- ⚠️ Max iterations (3) reached → Ask user: publish with warnings or stop
- ❌ Critical issues remain → Report to user, recommend revision

→ Pause

**Interactive**: AskUserQuestion - "Issues resolved. Continue to publication?"
**YOLO**: "→ Continuing to Phase 3..."

---

### Phase 3: Publication & Integration

**Purpose**: Format, integrate, and publish documentation
**Execute**: Direct - format, generate TOC, copy to target location
**Output**: Published docs, `verification/publication-summary.md`
**State**: Set `publication.integrated: true`, `publication.validated: true`

**Process**:
1. Format for target platform (markdown standards, image paths)
2. Generate table of contents with anchor links
3. Add navigation links (previous/next)
4. Copy to publication location
5. Validate publication (files, links, images work)
6. Generate publication summary

→ End of workflow

---

## Domain Context (State Extensions)

Documentation-specific fields in `orchestrator-state.yml`:

```yaml
documentation_context:
  doc_type: "user-guide" | "tutorial" | "reference" | "faq" | "api-docs"
  target_audience: "end-users" | "developers" | "admins" | "power-users"
  tone: "friendly" | "technical" | "formal"
  readability_target:
    ease: [60-80 for users, 50-60 for devs]
    grade: [6-8 for users, 9-10 for devs]
  screenshot_count: null
  content_created: false
  review_passed: false
  readability_score:
    ease: null
    grade: null
  verdict: null

verification_context:
  last_status: null
  issues_found: null
  fixes_applied: []
  decisions_made: []
  reverify_count: 0

publication:
  location: null
  format: "markdown"
  integrated: false
  validated: false
```

---

## Task Structure

```
.ai-sdlc/tasks/documentation/YYYY-MM-DD-task-name/
├── orchestrator-state.yml
├── planning/
│   └── documentation-outline.md     # Phase 0
├── documentation/
│   ├── user-guide.md                # Phase 1
│   └── screenshots/                 # Phase 1
├── verification/
│   ├── documentation-review.md      # Phase 2
│   └── publication-summary.md       # Phase 3
└── [published location]             # Phase 3
```

---

## Auto-Recovery

| Phase | Max Attempts | Strategy |
|-------|--------------|----------|
| 0 | 2 | Prompt user if doc type unclear |
| 1 | 3 | Retry failed screenshots, fix formatting |
| 2 | 0 | Read-only, report only |
| 2.5 | 3 | Fix-then-reverify cycles |
| 3 | 1 | Fix formatting, regenerate TOC |

---

## Readability Targets

| Audience | Flesch Reading Ease | Grade Level | Tone |
|----------|---------------------|-------------|------|
| End Users (non-technical) | 60-80 | 6-8 | Friendly |
| Developers | 50-60 | 9-10 | Technical |
| Power Users/Admins | 50-70 | 8-10 | Professional |

---

## Documentation Types

| Type | Purpose | Structure |
|------|---------|-----------|
| **User Guide** | Help users accomplish tasks | Overview → Prerequisites → Steps → Troubleshooting |
| **Tutorial** | Teach through hands-on practice | Objectives → Steps → Practice → Summary |
| **Reference** | Complete technical details | Listing → Parameters → Examples → Edge cases |
| **FAQ** | Answer common questions | Question → Answer → Link to details |
| **API Docs** | Document endpoints | Endpoint → Method → Parameters → Response |

---

## Command Integration

Invoked via:
- `/ai-sdlc:documentation:new [description] [--yolo] [--type=TYPE]`
- `/ai-sdlc:documentation:resume [task-path]`

Task directory: `.ai-sdlc/tasks/documentation/YYYY-MM-DD-task-name/`
