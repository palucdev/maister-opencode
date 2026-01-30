---
name: research-orchestrator
description: Orchestrates comprehensive research workflows from question definition through findings documentation. Handles technical, requirements, literature, and mixed research types with adaptive methodology, multi-source gathering, pattern synthesis, and evidence-based reporting. Supports standalone research tasks and embedded Phase 0 in other workflows.
---

# Research Orchestrator

Systematic research workflow from question definition to evidence-based documentation.

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
2. **Create Task Directory**: `.ai-sdlc/tasks/research/YYYY-MM-DD-task-name/`
3. **Initialize State**: Create `orchestrator-state.yml` with mode and research context

**Output**:
```
🚀 Research Orchestrator Started

Task: [research question]
Mode: [Interactive/YOLO]
Directory: [task-path]

Starting Phase 0: Initialize research...
```

---

## When to Use

Use when:
- Need comprehensive research on a topic
- Exploring codebase patterns or architecture
- Gathering requirements or best practices
- Want systematic evidence-based answers
- Research will feed into development workflows

**DO NOT use for**: Development tasks, bug fixes, performance optimization.

---

## Core Principles

1. **Evidence-Based**: Every finding must have source citation
2. **Systematic**: Follow structured methodology for consistent results
3. **Multi-Source**: Gather from codebase, docs, config, external sources
4. **Synthesized**: Cross-reference findings, identify patterns
5. **Actionable**: Produce outputs that enable next steps

---

## Local References

| File | When to Use | Purpose |
|------|-------------|---------|
| `references/research-methodologies.md` | Phase 1 | Research methodology selection and approach patterns |

---

## Phase Configuration

| Phase | content | activeForm | Agent/Skill |
|-------|---------|------------|-------------|
| 0 | "Initialize research" | "Initializing research" | Direct |
| 1 | "Plan research methodology" | "Planning research methodology" | research-planner |
| 2 | "Gather information (parallel)" | "Gathering information in parallel" | information-gatherer (x4) |
| 3 | "Analyze and synthesize" | "Analyzing and synthesizing" | research-synthesizer |
| 4 | "Generate outputs" | "Generating outputs" | Direct |
| 5 | "Verify findings" | "Verifying findings" | Direct (optional) |
| 6 | "Integrate into project" | "Integrating into project" | Direct (optional) |
| 7 | "Spawn development" | "Spawning development" | Direct (optional) |

---

## Research Types

| Type | Keywords | Focus | Typical Outputs |
|------|----------|-------|-----------------|
| **Technical** | "how does", "where is", "implementation" | Codebase analysis | Knowledge base, architecture docs |
| **Requirements** | "what are requirements", "user needs" | User/business needs | Specifications, requirements doc |
| **Literature** | "best practices", "industry standards" | External research | Recommendations, comparisons |
| **Mixed** | Multiple keywords, broad questions | Comprehensive investigation | All output types |

---

## Workflow Phases

### Phase 0: Research Initialization

**Purpose**: Define research question, classify type, establish scope
**Execute**: Direct - parse question, classify type, create brief
**Output**: `orchestrator-state.yml`, `planning/research-brief.md`
**State**: Set `research_context.research_type`, `research_question`, `scope`

**Process**:
1. Parse research question (from command or prompt user)
2. Classify research type (auto-detect from keywords or use `--type` flag)
3. Determine scope (included, excluded, constraints)
4. Define success criteria
5. Create research brief

→ Pause

**Interactive**: AskUserQuestion - "Research initialized. Continue to planning?"
**YOLO**: "→ Continuing to Phase 1..."

---

### Phase 1: Research Planning

**Purpose**: Design methodology and identify data sources
**Execute**: Task tool - `ai-sdlc:research-planner` subagent
**Output**: `planning/research-plan.md`, `planning/sources.md`
**State**: Update `research_context.methodology`, `sources`

→ Pause

**Interactive**: AskUserQuestion - "Planning complete. Continue to information gathering?"
**YOLO**: "→ Continuing to Phase 2..."

---

### Phase 2: Information Gathering & Merge

**Purpose**: Gather information from all sources in parallel, then consolidate into summary
**Execute**:
1. Task tool - 4 parallel `ai-sdlc:information-gatherer` subagents
2. Wait for ALL agents to complete
3. Direct - read all findings, create unified summary and verification
**Output**: `analysis/findings/codebase-*.md`, `docs-*.md`, `config-*.md`, `external-*.md`, `analysis/findings/00-summary.md`, `analysis/findings/99-verification.md`
**State**: Track gathering progress, update findings summary

**CRITICAL: Launch all 4 agents in ONE message for parallel execution.**

Each agent gathers from ONE source category:
1. **Codebase Gatherer**: Source code using Glob, Grep, Read
2. **Documentation Gatherer**: Project and code docs
3. **Configuration Gatherer**: Config files (package.json, .env, etc.)
4. **External Gatherer**: Web resources using WebSearch, WebFetch

**Parallel Execution Pattern**:
```
Use Task tool 4 times in ONE message:
- Task 1: source_category=codebase → analysis/findings/codebase-*.md
- Task 2: source_category=documentation → analysis/findings/docs-*.md
- Task 3: source_category=configuration → analysis/findings/config-*.md
- Task 4: source_category=external → analysis/findings/external-*.md
```

**After all agents complete, merge findings:**

**Summary Structure** (`00-summary.md`):
- Research question (from brief)
- Sources investigated by category
- Key findings by category
- Gaps and uncertainties
- Next steps for synthesis

**Verification Structure** (`99-verification.md`):
- Cross-source verification checks
- Confidence assessment (high/medium/low)
- Identified contradictions
- Missing information

→ Pause

**Interactive**: AskUserQuestion - "Findings gathered and merged. Continue to synthesis?"
**YOLO**: "→ Continuing to Phase 3..."

---

### Phase 3: Analysis & Synthesis

**Purpose**: Analyze findings and generate comprehensive research report
**Execute**: Task tool - `ai-sdlc:research-synthesizer` subagent
**Output**: `analysis/synthesis.md`, `analysis/research-report.md`
**State**: Update `research_context.confidence_level`

**Synthesizer produces**:
- Pattern analysis and cross-references
- Comprehensive research report answering research question
- Confidence levels for each finding
- Documented gaps and uncertainties

→ Pause

**Interactive**: AskUserQuestion - "Synthesis complete. Continue to output generation?"
**YOLO**: "→ Continuing to Phase 4..."

---

### Phase 4: Generate Outputs

**Purpose**: Generate conditional outputs based on research type
**Execute**: Direct - create appropriate output files
**Output**: `outputs/recommendations.md`, `outputs/knowledge-base.md`, `outputs/specifications.md` (conditional)
**State**: Track generated outputs

**Conditional Outputs**:
| Output | Generate If | Skip If |
|--------|------------|---------|
| **Recommendations** | Decision-oriented research, comparing approaches | Purely exploratory |
| **Knowledge Base** | Reusable knowledge, technical patterns | One-off research |
| **Specifications** | Feeds into dev workflow, embedded Phase 0 | Standalone research |

→ Pause

**Interactive**: AskUserQuestion - "Outputs generated. Continue to verification?"
**YOLO**: "→ Continuing to Phase 5..."

---

### Phase 5: Verification (Optional)

**Purpose**: Verify research quality and completeness
**Execute**: Direct - user review (interactive) or automated checks (YOLO)
**Output**: `verification/verification-report.md`
**State**: Update verification status

**Skip if**: Technical research with high confidence, simple exploratory
**Enable if**: Mixed research, medium/low confidence, critical gaps identified

**Interactive Mode**: Present report, request user review
**YOLO Mode**: Automated checks (citations present, evidence provided, question addressed)

→ Conditional: if integration_enabled continue to Phase 6, else skip to Phase 7 check

---

### Phase 6: Integration (Optional)

**Purpose**: Integrate outputs into project documentation
**Execute**: Direct - save to appropriate locations
**Output**: `integration-manifest.md`
**State**: Track integration status

**Skip if**: Exploratory research not for documentation
**Enable if**: Specifications generated, knowledge base created

**Process**:
- For specifications: Save path for parent orchestrator
- For knowledge base: Ask user where to place in `.ai-sdlc/docs/`
- For recommendations: Ask if decisions should be documented

→ Conditional: if specifications exist continue to Phase 7, else complete workflow

---

### Phase 7: Spawn Development (Optional)

**Purpose**: Offer to start development workflow with research context
**Execute**: Direct - AskUserQuestion for user decision
**Output**: Development workflow started (if chosen)
**State**: Track spawn decision

**Skip if**: No specifications generated OR mode = yolo

**Interactive Mode**:
```
AskUserQuestion:
  Question: "Research produced specifications. Start development workflow?"
  Options:
  - "Start development with this research"
  - "Skip - I'll start manually later"
  - "Review outputs first"
```

If user chooses "Start development":
- Invoke Skill: `ai-sdlc:development:new [current-research-task-path]`

→ End of workflow

---

## Domain Context (State Extensions)

Research-specific fields in `orchestrator-state.yml`:

```yaml
research_context:
  research_type: "technical" | "requirements" | "literature" | "mixed"
  research_question: "[user's question]"
  scope:
    included: []
    excluded: []
    constraints: []
  methodology: []
  sources: []
  confidence_level: "high" | "medium" | "low"

options:
  verification_enabled: null  # null=auto-detect
  integration_enabled: null
```

---

## Task Structure

```
.ai-sdlc/tasks/research/YYYY-MM-DD-research-name/
├── orchestrator-state.yml
├── planning/
│   ├── research-brief.md           # Phase 0
│   ├── research-plan.md            # Phase 1
│   └── sources.md                  # Phase 1
├── analysis/
│   ├── findings/
│   │   ├── 00-summary.md           # Phase 2 (merge step)
│   │   ├── 99-verification.md      # Phase 2 (merge step)
│   │   ├── codebase-*.md           # Phase 2
│   │   ├── docs-*.md               # Phase 2
│   │   ├── config-*.md             # Phase 2
│   │   └── external-*.md           # Phase 2
│   ├── synthesis.md                # Phase 3
│   └── research-report.md          # Phase 3
├── outputs/
│   ├── recommendations.md          # Phase 4 (conditional)
│   ├── knowledge-base.md           # Phase 4 (conditional)
│   └── specifications.md           # Phase 4 (conditional)
└── verification/
    └── verification-report.md      # Phase 5 (optional)
```

---

## Auto-Recovery

| Phase | Max Attempts | Strategy |
|-------|--------------|----------|
| 0 | 1 | Prompt user for clarification if question unclear |
| 1 | 2 | Expand search patterns, use fallback mixed methodology |
| 2 | 3 | Retry failed agents only, continue with successful categories |
| 2 | 2 | Merge available findings, note missing categories |
| 3 | 2 | Request targeted re-gathering for gaps |
| 4 | 2 | Generate standard outputs, ask user in interactive |
| 5 | 0 | Read-only, report only |
| 6 | 0 | Read-only, provide manual guidance |
| 7 | 0 | User decision only |

---

## Integration with Other Workflows

### As Standalone Research

**Command**: `/ai-sdlc:research:new [research-question]`
**Flow**: Complete all phases, save outputs in task directory

### As Embedded Phase 0

**Invoked by**: development-orchestrator, migration-orchestrator

**Integration**:
1. Parent orchestrator invokes research-orchestrator
2. Research executes phases 0-4 (skip optional phases 5-7)
3. Specifications output fed into parent's specification phase
4. Research report saved in parent task's `analysis/research/` directory

**Handoff**:
```yaml
research_outputs:
  specifications: "[path to specifications.md]"
  research_report: "[path to research-report.md]"
  findings_directory: "[path to findings/]"
```

---

## Command Integration

Invoked via:
- `/ai-sdlc:research:new [question] [--yolo] [--type=TYPE]`
- `/ai-sdlc:research:resume [task-path] [--from=PHASE]`

Task directory: `.ai-sdlc/tasks/research/YYYY-MM-DD-task-name/`
