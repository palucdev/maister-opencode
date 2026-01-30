---
name: ai-sdlc:standards:discover
description: Automatically discover coding standards, conventions, and best practices from multiple sources in the project (configuration files, source code, pull requests, documentation, CI/CD)
---

**NOTE**: This is a multi-step workflow that invokes other skills (docs-manager) and subagents at specific phases. The `<command-name>` tag refers to THIS command only — you MUST still use the Skill tool and Task tool to invoke those other skills when instructed below.

# Discover Project Standards

You are running an automated standards discovery process that analyzes multiple sources in the project to extract coding standards, conventions, and best practices. This command will examine configuration files, code patterns, documentation, pull requests, and CI/CD configs to discover what standards are actually being used.

## Command Usage

```bash
/ai-sdlc:standards:discover [options]
```

### Options

- `--scope=SCOPE`: Discovery scope
  - Values: `full`, `global`, `frontend`, `backend`, `testing`, `quick`
  - Default: `full`
  - `quick` only analyzes config files (fast, 30-60s)

- `--confidence=N`: Minimum confidence threshold (0-100)
  - Default: `60`
  - Only show findings with confidence ≥ threshold

- `--auto-apply`: Auto-apply very high confidence standards (≥90%)
  - Default: `false` (always ask user)

- `--skip-external`: Skip GitHub PR analysis and external sources
  - Default: `false`

- `--pr-count=N`: Number of recent PRs to analyze
  - Default: `20`
  - Only used if GitHub integration available

## What You Are Doing

You will discover project standards by:

1. **Planning** - Determine scope, read existing standards
2. **Config Analysis** - Extract standards from linter/compiler configs
3. **Code Mining** - Sample code to find naming and pattern conventions
4. **Documentation** - Parse README, CONTRIBUTING for explicit standards
5. **External Analysis** - Analyze PRs and CI/CD (if available)
6. **Aggregation** - Combine findings, calculate confidence, deduplicate
7. **User Review** - Present findings with evidence for approval
8. **Application** - Apply approved standards via docs-manager

## Your Workflow

### PHASE 0: Planning & Initialization (10-15s)

**Step 1: Parse Command Options**

Extract options from command invocation:
- `scope`: Determines which categories to discover
- `confidence`: Minimum threshold for displaying findings
- `auto_apply`: Whether to auto-apply ≥90% confidence
- `skip_external`: Whether to skip PR/CI analysis
- `pr_count`: How many PRs to analyze

**Step 2: Check Prerequisites**

```bash
# Verify .ai-sdlc/docs/ exists
test -d .ai-sdlc/docs || echo "NOT_INITIALIZED"
```

If NOT_INITIALIZED:
```
❌ Project not initialized with ai-sdlc framework

Would you like to run /init-sdlc first?

Use AskUserQuestion:
- "Yes, run /init-sdlc now"
- "No, cancel discovery"
```

**Step 3: Read Existing Standards**

```bash
# Read INDEX.md to see what standards already exist
cat .ai-sdlc/docs/INDEX.md
```

Store existing standard paths to avoid duplicates and identify updates vs creates.

**Step 4: Generate Discovery Plan**

Based on scope option, determine what to analyze:

| Scope | Config | Code | Docs | External | Categories |
|-------|--------|------|------|----------|------------|
| `full` | ✓ | ✓ | ✓ | ✓ | All |
| `global` | ✓ | ✓ (limited) | ✓ | ✓ | global only |
| `frontend` | ✓ (FE configs) | ✓ (FE files) | ✓ | ✓ | frontend only |
| `backend` | ✓ (BE configs) | ✓ (BE files) | ✓ | ✓ | backend only |
| `testing` | ✓ (test configs) | ✓ (test files) | ✓ | ✓ | testing only |
| `quick` | ✓ | ✗ | ✗ | ✗ | All (config-based only) |

**Step 5: Display Plan**

```
🔍 Standards Discovery Plan

Scope: [scope]
Min Confidence: [threshold]%
Auto-apply: [yes/no]

Sources to analyze:
✓ Configuration files (.eslintrc, tsconfig, package.json, etc.)
[✓/✗] Source code patterns (naming, imports, error handling)
[✓/✗] Documentation (README, CONTRIBUTING)
[✓/✗] Pull requests (last [pr_count])
[✓/✗] CI/CD configs

Estimated time: [time estimate based on scope]

Continue? [Yes/No]
```

Use AskUserQuestion if user confirmation needed.

### IMPORTANT: Parallel Execution for Optimal Performance

**Phases 1-4 should run in parallel** for best performance. Instead of executing each phase sequentially, invoke ALL discovery subagents in a single message using multiple Task tool calls.

**How to execute in parallel:**

```
In a SINGLE message to the user, invoke multiple Task tool calls:

1. Task (config-standards-analyzer) - Phase 1
2. Task (code-pattern-analyzer) - Phase 2
3. Task (docs-standards-extractor) - Phase 3
4. Task (external-standards-analyzer) - Phase 4 (if not --skip-external)

All subagents will execute concurrently.

Wait for ALL subagents to complete, then proceed to Phase 5 (Aggregation).
```

**Time savings**: Parallel execution reduces total time from ~2 minutes to ~45-60 seconds.

**Note**: Only Phases 1-4 run in parallel. Phases 0, 5, 6, 7 run sequentially.

---

### PHASE 1: Configuration Analysis (20-30s)

**Invoke config-standards-analyzer subagent using the Task tool:**

```
Use Task tool:
  subagent_type: general-purpose
  model: haiku  # Fast for config parsing
  description: "Analyze configuration files for standards"
  prompt: "Analyze project configuration files to discover coding standards and conventions.

**Your task**: Find and analyze configuration files, extract standards, return structured findings.

**Configuration files to analyze**:

1. **Linter configs**:
   - .eslintrc.* (JavaScript/TypeScript linting rules)
   - .prettierrc* (Code formatting rules)
   - pylintrc, .pylintrc (Python linting)
   - .rubocop.yml (Ruby linting)

2. **Compiler configs**:
   - tsconfig.json (TypeScript compiler options)
   - jsconfig.json (JavaScript config)

3. **Package managers**:
   - package.json (npm scripts, conventions)
   - requirements.txt (Python dependencies)
   - Gemfile (Ruby dependencies)
   - pom.xml (Java Maven)

4. **Editor configs**:
   - .editorconfig (indentation, line endings, charset)

5. **Container configs**:
   - Dockerfile
   - docker-compose.yml

**For each config file found**:

1. Read and parse the file
2. Extract rules/settings that indicate coding standards:
   - **ESLint**: Naming conventions (camelcase), code style (quotes, semicolons, indentation), framework patterns (react/prefer-stateless-function), import rules
   - **Prettier**: Formatting rules (semi, singleQuote, trailingComma, tabWidth)
   - **TypeScript**: Compiler strictness (strict, noImplicitAny), module resolution, path aliases
   - **Package.json**: Script patterns, testing conventions, pre-commit hooks
   - **EditorConfig**: Indentation (spaces/tabs, size), charset, line endings, trailing whitespace

3. Categorize each finding:
   - **global/**: Language-agnostic (indentation, line endings, general error handling)
   - **frontend/**: UI-specific (React rules, CSS conventions, component patterns)
   - **backend/**: Server-specific (API rules, database conventions)
   - **testing/**: Test-related (test frameworks, coverage requirements)

4. Calculate confidence (70-85% for explicit config files)

**Output format** (return YAML):

```yaml
findings:
  - category: 'frontend/components'
    standard_name: 'Component Style'
    description: 'Use functional components with React hooks'
    confidence: 85
    evidence:
      - '.eslintrc.js: react/prefer-stateless-function: error'
      - '.eslintrc.js: react-hooks/rules-of-hooks: error'
    source: 'eslint-config'
    examples: []

  - category: 'global/code-style'
    standard_name: 'Semicolons'
    description: 'Always use semicolons'
    confidence: 82
    evidence:
      - '.eslintrc.js: semi: [error, always]'
      - '.prettierrc: semi: true'
    source: 'linter-config'
    examples:
      - 'const x = 5;  // Correct'

  # ... more findings
```

**Important**:
- Only include findings with clear evidence
- Be specific in descriptions
- Include file paths in evidence
- Return empty list if no config files found
- Focus on actionable, verifiable standards

Return the YAML findings structure."
```

**Wait for subagent to complete and return config-based findings.**

**Expected output from subagent**:
- YAML structure with findings array
- Each finding has: category, standard_name, description, confidence, evidence, source, examples
- Typical result: 10-25 config-based standards discovered

**Display progress** after subagent completes:
```
[Phase 1] Configuration Analysis Complete
  ✓ Subagent analyzed configuration files
  ✓ Found [N] standards from configs
  ✓ Categories: global ([X]), frontend ([Y]), backend ([Z]), testing ([W])
```

### PHASE 2: Code Pattern Mining (30-60s)

**Only if scope includes code analysis** (skip if `scope=quick`)

**Invoke code-pattern-analyzer subagent using the Task tool:**

```
Use Task tool:
  subagent_type: general-purpose
  model: haiku  # Fast for pattern analysis
  description: "Analyze code patterns for standards"
  prompt: "Analyze source code patterns to discover coding conventions and standards.

**Your task**: Sample code files, detect patterns in naming/imports/structure, return findings.

**Sampling strategy** (for performance):
- Frontend files: Sample 50 files (*.ts, *.tsx, *.js, *.jsx, *.vue)
- Backend files: Sample 50 files (*.py, *.rb, *.java, *.go)
- Test files: Sample 30 files (*.test.*, *.spec.*)

**Patterns to analyze**:

1. **File Naming Conventions**:
   - Detect PascalCase, kebab-case, snake_case distribution
   - Calculate consistency percentage
   - Create finding if ≥80% consistency

2. **Import Patterns**:
   - Absolute vs relative imports (import { X } from '@/path' vs '../../path')
   - Import organization (grouped? sorted?)
   - Path aliasing usage

3. **Error Handling**:
   - try/catch usage patterns
   - Custom error class usage
   - Error wrapping patterns
   - Logging patterns

4. **Component/Code Structure** (frontend):
   - React: Functional vs class components
   - Vue: Composition API vs Options API
   - Props patterns, hooks usage

5. **API Patterns** (backend):
   - Endpoint naming (/api/v1/, /v1/, no versioning?)
   - Resource naming (plural vs singular)
   - Route parameter style (kebab-case vs camelCase)

**For each pattern found**:
1. Calculate consistency (% of files following pattern)
2. Only report if consistency ≥60%
3. Categorize as global/frontend/backend/testing
4. Include evidence with file counts and examples

**Output format** (return YAML):

```yaml
findings:
  - category: 'frontend/components'
    standard_name: 'Component File Naming'
    description: 'Use PascalCase for React component filenames'
    confidence: 88
    evidence:
      - '247 of 250 .tsx files use PascalCase'
      - 'Examples: UserProfile.tsx, LoginForm.tsx, DataTable.tsx'
    source: 'code-patterns'
    examples:
      - 'UserProfile.tsx  // Correct'
      - 'user-profile.tsx  // Avoid'

  - category: 'global/imports'
    standard_name: 'Import Path Style'
    description: 'Use absolute imports with @ alias'
    confidence: 72
    evidence:
      - '180 of 250 imports use @/ alias'
      - 'tsconfig.json defines @ path alias'
    source: 'code-patterns'
    examples:
      - 'import { User } from \"@/models/User\"  // Preferred'

  - category: 'frontend/components'
    standard_name: 'Component Style'
    description: 'Use functional components with hooks (no class components)'
    confidence: 100
    evidence:
      - '247 functional components found'
      - '0 class-based components found'
    source: 'code-patterns'
    examples: []

  # ... more findings
```

**Important**:
- Sample files randomly for representative results
- Only report patterns with ≥60% consistency
- Be specific about what was analyzed (file counts)
- Return empty list if no clear patterns found
- Focus on actionable, consistent patterns

Return the YAML findings structure."
```

**Wait for subagent to complete and return code pattern findings.**

**Expected output from subagent**:
- YAML structure with code-based findings
- Typical result: 10-20 pattern-based standards
- Lower confidence than config (60-85%) because patterns are inferred

**Display progress** after subagent completes:
```
[Phase 2] Code Pattern Mining Complete
  ✓ Subagent analyzed code patterns
  ✓ Sampled ~130 files total
  ✓ Found [N] pattern-based standards
  ✓ Patterns: naming ([X]), imports ([Y]), structure ([Z]), errors ([W])
```

### PHASE 3: Documentation Extraction (15-25s)

**Only if scope includes docs** (skip if `scope=quick`)

**Invoke docs-standards-extractor subagent using the Task tool:**

```
Use Task tool:
  subagent_type: general-purpose
  model: haiku  # Fast for text parsing
  description: "Extract standards from documentation"
  prompt: "Extract coding standards and conventions from project documentation files.

**Your task**: Find and parse documentation, extract explicit standards, return findings.

**Documentation files to analyze**:

1. **README.md** - Main project documentation
   - Look for: Code Style, Contributing Guidelines, Conventions, Best Practices sections

2. **CONTRIBUTING.md** - Contribution guidelines
   - Look for: PR requirements, commit conventions, testing requirements, code review standards

3. **ARCHITECTURE.md** / **docs/architecture/** - Architectural documentation
   - Look for: Design patterns, architectural decisions

4. **ADRs** (Architecture Decision Records) - adr/ or decisions/ directory
   - Extract rationale for architectural standards

**For each documentation file found**:

1. Read the file
2. Identify sections about standards, conventions, or best practices
3. Extract explicit statements:
   - \"We use...\"
   - \"Always...\" / \"Never...\"
   - \"Prefer X over Y\"
   - Code examples showing correct patterns

4. Categorize findings as global/frontend/backend/testing
5. Assign higher confidence (80-90%) for explicit, documented standards

**Output format** (return YAML):

```yaml
findings:
  - category: 'frontend/components'
    standard_name: 'Component Style'
    description: 'Use functional components with React hooks'
    confidence: 90
    evidence:
      - 'README.md ## Code Style: \"We use functional components with hooks\"'
      - 'CONTRIBUTING.md: \"Do not use class components\"'
    source: 'documentation'
    examples:
      - 'function UserProfile() { ... }  // Correct'

  - category: 'global/commits'
    standard_name: 'Commit Message Format'
    description: 'Use Conventional Commits (type: description)'
    confidence: 85
    evidence:
      - 'CONTRIBUTING.md: \"Commit messages must follow Conventional Commits\"'
      - 'Examples: feat: add login, fix: resolve timeout'
    source: 'documentation'
    examples:
      - 'feat: add user authentication'
      - 'fix: resolve memory leak in cache'

  # ... more findings
```

**Important**:
- Only extract explicitly stated standards (not inferred)
- Include exact quotes from documentation in evidence
- Note which file each standard comes from
- Return empty list if no documentation found
- Prioritize actionable, clear standards

Return the YAML findings structure."
```

**Wait for subagent to complete and return documentation findings.**

**Expected output from subagent**:
- YAML structure with doc-based findings
- Typical result: 5-15 documented standards
- High confidence (80-90%) because they're explicitly documented

**Display progress** after subagent completes:
```
[Phase 3] Documentation Extraction Complete
  ✓ Subagent analyzed documentation
  ✓ Found [N] documented standards
  ✓ Sources: README ([X]), CONTRIBUTING ([Y]), Architecture ([Z])
```

### PHASE 4: External Analysis (30-45s, conditional)

**Skip if `--skip-external` flag set**

**Invoke external-standards-analyzer subagent using the Task tool:**

```
Use Task tool:
  subagent_type: general-purpose
  model: haiku  # Fast for API calls and parsing
  description: "Analyze external sources for standards"
  prompt: "Analyze pull requests and CI/CD configurations to discover enforced standards.

**Your task**: Mine external sources for standards evidence, return findings.

**External sources to analyze**:

1. **Pull Requests** (via gh CLI):
   - Check if `gh` CLI is available: `which gh && gh auth status`
   - If available: Get last [pr_count] merged PRs
   - Mine review comments for repeated feedback patterns
   - Look for: \"Please use...\", \"Always...\", \"Avoid...\" in reviews

2. **CI/CD Workflows**:
   - GitHub Actions: .github/workflows/*.yml
   - GitLab CI: .gitlab-ci.yml
   - Extract: Testing requirements, linting steps, coverage thresholds, pre-deployment checks

3. **Pre-commit Hooks**:
   - Husky: .husky/ directory
   - pre-commit framework: .pre-commit-config.yaml
   - Extract: Mandatory checks, formatting requirements

**For PR analysis** (if gh CLI available):

```bash
# Check availability
if ! which gh >/dev/null 2>&1; then
  echo \"GitHub CLI not available\"
  exit 0  # Skip, not an error
fi

# Get PRs
gh pr list --state merged --limit [pr_count] --json number,title 2>/dev/null || exit 0

# For each PR, analyze review comments for patterns
# Count occurrences of similar feedback
```

**For CI/CD analysis**:
- Read workflow files
- Extract lint, test, build commands
- Identify quality gates (coverage %, must-pass checks)

**Output format** (return YAML):

```yaml
github_available: true  # or false
findings:
  - category: 'global/async'
    standard_name: 'Async/Await Pattern'
    description: 'Prefer async/await over promise chains'
    confidence: 75
    evidence:
      - 'PR #234 review: \"Please refactor to async/await\"'
      - 'PR #189 review: \"Use async/await for consistency\"'
      - '5 PRs had similar feedback'
    source: 'pr-reviews'
    examples: []

  - category: 'testing/coverage'
    standard_name: 'Code Coverage Requirement'
    description: 'Maintain 80% code coverage minimum'
    confidence: 90
    evidence:
      - '.github/workflows/test.yml: coverage threshold 80%'
      - 'CI fails if coverage < 80%'
    source: 'ci-config'
    examples: []

  # ... more findings
```

**Important**:
- Handle gh CLI gracefully if not available (return empty list, not error)
- Only report patterns that appear in 3+ PRs (significant feedback)
- Lower confidence (65-80%) for PR-based findings (opinion-based)
- Higher confidence (85-95%) for CI/CD enforced standards
- Return empty list if no external sources available

Return the YAML findings structure including github_available flag."
```

**Wait for subagent to complete and return external findings.**

**Expected output from subagent**:
- YAML structure with external findings
- github_available flag
- Typical result: 5-20 external standards (if GitHub available), 2-5 (CI/CD only)
- Variable confidence: 65-80% (PR comments), 85-95% (CI enforced)

**Display progress** after subagent completes:
```
[Phase 4] External Analysis Complete
  [✓/⏭️] GitHub PR analysis ([available/skipped])
  ✓ Subagent analyzed external sources
  ✓ Found [N] external standards
  ✓ Sources: PR reviews ([X]), CI/CD ([Y]), hooks ([Z])
```

### PHASE 5: Aggregation & Deduplication (15-20s)

**Step 1: Combine All Findings**

Merge findings from all phases:
- Phase 1: Config findings
- Phase 2: Code pattern findings
- Phase 3: Documentation findings
- Phase 4: External findings

**Step 2: Deduplicate**

Group findings by `category + standard_name`:

```
If multiple findings for "frontend/components Component Style":
  1. From ESLint config: "prefer functional components"
  2. From code analysis: "0 class components, 247 functional"
  3. From README: "Use functional components with hooks"

→ Merge into single finding:
  - Take highest confidence
  - Combine all sources
  - Aggregate all evidence
  - Note consistency across sources
```

**Step 3: Calculate Final Confidence Scores**

```javascript
function calculateConfidence(finding) {
  let score = 0

  // Source count (15% each, max 45%)
  score += Math.min(finding.sources.length * 15, 45)

  // Consistency (if found in multiple places with same pattern)
  if (finding.consistency >= 90) score += 20
  else if (finding.consistency >= 70) score += 10

  // Explicit vs inferred
  if (finding.has_config_source) score += 15  // Config file
  else if (finding.has_doc_source) score += 10  // Documentation
  else score += 5  // Inferred from code

  // Evidence strength (5% per evidence item, max 20%)
  score += Math.min(finding.evidence.length * 5, 20)

  // PR feedback boost (if 5+ PR reviews mention it)
  if (finding.pr_mentions >= 5) score += 10

  return Math.min(score, 100)  // Cap at 100%
}
```

**Step 4: Categorize by Confidence**

Split findings into:
- **High** (≥80%): Very confident, multiple sources, consistent
- **Medium** (60-79%): Moderate confidence, some evidence
- **Low** (<60%): Weak patterns, inconsistent, needs review

**Step 5: Detect Conflicts**

Check for contradictory standards:

```
Example conflict:
Finding A: "Use semicolons" (from .eslintrc)
Finding B: "No semicolons" (from .prettierrc)

→ Flag as conflict, ask user to resolve
```

Output progress:
```
[Phase 5] Aggregation
  ✓ Combined 64 raw findings
  ✓ Deduplicated to 23 unique standards
  ✓ Calculated confidence scores
  ✓ Detected 2 conflicts requiring resolution

  Summary:
    High confidence (≥80%): 12 standards
    Medium confidence (60-79%): 7 standards
    Low confidence (<60%): 4 standards
    Conflicts: 2
```

### PHASE 6: User Review & Approval (variable time)

**Step 1: Present High-Confidence Findings**

```
✅ DISCOVERED: 12 High-Confidence Standards (≥80%)

These standards have strong evidence across multiple sources.

### 1. Frontend / Component Structure ⭐⭐⭐
**Confidence**: 94%
**Sources**: ESLint config + 247 code files + README.md
**Standard**: Use functional components with React hooks (no class components)

**Evidence**:
• .eslintrc.js: react/prefer-stateless-function rule enabled
• Code analysis: 247 functional components, 0 class components
• README.md: "We use functional components with hooks"

**Recommendation**: Create standards/frontend/components.md

---

### 2. Global / Code Style - Semicolons ⭐⭐⭐
**Confidence**: 89%
**Sources**: ESLint + Prettier + EditorConfig
**Standard**: Always use semicolons

**Evidence**:
• .eslintrc.js: semi: ['error', 'always']
• .prettierrc: semi: true
• 100% of TypeScript files use semicolons

**Recommendation**: Update standards/global/coding-style.md

---

[... 10 more high-confidence standards ...]

---

Apply all 12 high-confidence standards?

Use AskUserQuestion:
- "Yes, apply all 12"
- "Review individually"
- "Skip all"
```

If user selects "Review individually", show each with Accept/Modify/Skip options.

If user selects "Yes, apply all 12", mark all as approved.

**Step 2: Present Medium-Confidence Findings**

```
⚠️ FOUND: 7 Medium-Confidence Standards (60-79%)

These standards have some evidence but may need clarification.

### 1. Backend / API Versioning ⚠️
**Confidence**: 72%
**Sources**: 12 route files + 3 PR comments
**Standard**: Use URL-based versioning (/api/v1/, /api/v2/)

**Evidence**:
• 12 route files use /api/v1/ prefix
• PR #156 comment: "maintain v1 compatibility"
• PR #189 comment: "add to /api/v1/ not root"

**Conflicts**:
⚠️ 2 routes use /v2/ (different pattern from /api/v2/)

**Recommendation**: Create standards/backend/api.md

Options for this standard:

Use AskUserQuestion:
- "Accept as-is (document current practice)"
- "Modify (I'll specify the correct standard)"
- "Skip (not confident enough)"
```

For each medium-confidence standard, get user decision.

**Step 3: Present Low-Confidence Findings**

```
❓ DETECTED: 4 Low-Confidence Patterns (<60%)

These patterns appear occasionally but aren't consistently applied.

1. Testing / Mock Naming
   Confidence: 45% | Inconsistent: Some use .mock.ts, some use __mocks__/

2. Frontend / Prop Validation
   Confidence: 38% | Mixed: PropTypes in some files, TypeScript in others

3. Backend / Database Queries
   Confidence: 52% | Unclear pattern for query builders vs raw SQL

4. Global / Comment Style
   Confidence: 41% | Mixed JSDoc and regular comments

These may indicate areas where standards should be established.

Use AskUserQuestion:
- "Show details for each pattern"
- "Skip all (not confident enough)"
- "Manually add standards for these later"
```

**Step 4: Handle Conflicts**

```
⚠️ CONFLICTS DETECTED: 2 Standards with Contradictions

### Conflict 1: Semicolon Usage
**Source A** (.eslintrc): Always use semicolons
**Source B** (.prettierrc): No semicolons (semi: false)

Resolution needed:

Use AskUserQuestion:
- "Use ESLint setting (semicolons)"
- "Use Prettier setting (no semicolons)"
- "Manually resolve (I'll specify)"
```

**Step 5: Collect Approved Standards**

After user review, compile list of approved standards with their final content.

### PHASE 7: Application & Integration (20-30s)

**Step 1: Prepare Standards Content**

For each approved standard, generate markdown content:

```markdown
# [Standard Name]

## Overview
[Description from discovery]

## Standard
[The actual rule/convention]

## Examples

✅ **Preferred**:
[Code example showing correct pattern]

❌ **Avoid**:
[Code example showing incorrect pattern]

## Rationale
[Why this standard exists - from evidence]

## Evidence
- [Source 1]
- [Source 2]
- [Source 3]

## Related
- [Links to related standards if any]
```

**Step 2: Check Existing Standards**

For each standard to apply:

```bash
# Check if standard file exists
test -f .ai-sdlc/docs/standards/[category]/[name].md && echo "EXISTS" || echo "NEW"
```

Determine action:
- **EXISTS**: Update existing (merge new findings with existing content)
- **NEW**: Create new standard file

**Step 3: Invoke docs-manager for Each Standard**

**For new standards**:

```
Invoke docs-manager skill:

command: docs-manager
context: "Create new documentation file: standards/[category]/[name].md

Standard Name: [name]
Category: [category]

Content:
[Generated markdown content]

Please:
1. Create the standard file with this content
2. Maintain proper markdown formatting
3. Add to INDEX.md with description
4. Verify CLAUDE.md integration"
```

**For existing standards (updates)**:

```
Invoke docs-manager skill:

command: docs-manager
context: "Update documentation file: standards/[category]/[name].md

Current file exists. Add these newly discovered practices:

[New content to merge]

Evidence:
[Evidence from discovery]

Please:
1. Read current file
2. Merge new practices with existing
3. Avoid duplicates
4. Update INDEX.md if description changed
5. Verify CLAUDE.md integration"
```

Wait for docs-manager to complete each operation.

**Step 4: Final INDEX.md Regeneration**

After all standards applied:

```
Invoke docs-manager skill:

command: docs-manager
context: "Regenerate INDEX.md to include all newly created/updated standards.

Ensure all files in .ai-sdlc/docs/standards/ are properly indexed."
```

**Step 5: Verify CLAUDE.md Integration**

```bash
# Check CLAUDE.md references standards
grep -q "ai-sdlc/docs/standards" CLAUDE.md && echo "✓ Integrated" || echo "⚠️ Missing"
```

If missing, invoke docs-manager to add integration.

**Step 6: Validation**

```bash
# Count created/updated files
find .ai-sdlc/docs/standards -name "*.md" -type f | wc -l

# Verify INDEX.md updated
grep -c "standards/" .ai-sdlc/docs/INDEX.md
```

Output progress:
```
[Phase 7] Application
  ✓ Created 8 new standard files
  ✓ Updated 4 existing standard files
  ✓ Regenerated INDEX.md
  ✓ Verified CLAUDE.md integration

  Standards applied: 12 total
```

### PHASE 8: Final Summary & Report

**Step 1: Generate Discovery Report**

```markdown
# 🔍 Standards Discovery Report

**Completed**: [timestamp]
**Scope**: [scope setting]
**Duration**: [total time]

---

## Summary

✅ **Discovered**: [total] standards across all sources
- High confidence (≥80%): [count]
- Medium confidence (60-79%): [count]
- Low confidence (<60%): [count]

📊 **Applied**: [count] standards
- Created: [count] new standards
- Updated: [count] existing standards
- Skipped: [count] (user declined or low confidence)

🗂️ **Categories**:
- Global: [count] standards
- Frontend: [count] standards
- Backend: [count] standards
- Testing: [count] standards

---

## Sources Analyzed

✅ Configuration Files
- .eslintrc.js: [findings count]
- tsconfig.json: [findings count]
- package.json: [findings count]
- .editorconfig: [findings count]

[✅/⏭️] Source Code Patterns
- Files sampled: [count]
- Naming conventions detected
- Import patterns analyzed
- Error handling patterns found

[✅/⏭️] Documentation
- README.md parsed
- CONTRIBUTING.md parsed
- [Additional docs]

[✅/⏭️] External Sources
- Pull requests analyzed: [count]
- CI/CD workflows: [count]
- Pre-commit hooks: [count]

---

## Standards Applied

### Created ([count])
1. standards/[category]/[name].md - [description]
2. [...]

### Updated ([count])
1. standards/[category]/[name].md - [what was added]
2. [...]

---

## Skipped Findings

### Low Confidence ([count])
- [Pattern]: [reason for low confidence]
- [...]

### User Declined ([count])
- [Standard]: [user's reason if provided]

---

## Next Steps

### 1. Review Applied Standards

```bash
# View all standards
cat .ai-sdlc/docs/INDEX.md

# Review specific standard
cat .ai-sdlc/docs/standards/[category]/[name].md
```

### 2. Standards Are Now Active

✅ Automatically applied during implementation (via implementer skill)
✅ Referenced in INDEX.md
✅ Integrated with CLAUDE.md

### 3. Team Communication

Consider:
- Commit and push the new standards
- Notify team members
- Schedule review meeting for controversial standards
- Update project documentation

### 4. Continuous Discovery

Run discovery again when:
- Adding new team members with different practices
- After major refactoring
- When introducing new technologies
- Quarterly to catch evolving patterns

```bash
# Re-run discovery
/ai-sdlc:standards:discover --scope=full
```

---

💡 **Tip**: Standards are living documents. Update them as your team's practices evolve using `/ai-sdlc:standards:update`.
```

**Step 2: Display Summary to User**

```
✅ DISCOVERY COMPLETE!

📊 Results:
- Analyzed [X] configuration files
- Sampled [Y] source files
- Parsed [Z] documentation files
- Reviewed [N] pull requests

🎯 Standards:
- Created: [count] new
- Updated: [count] existing
- Total active: [count]

📂 Location: .ai-sdlc/docs/standards/

⏱️ Duration: [time]

---

## Quick Stats

High confidence applied: [count]/[total high]
Medium confidence applied: [count]/[total medium]
Low confidence skipped: [count]

---

View full report? [Yes/No]
```

If Yes, display the full markdown report above.

## Error Handling

### GitHub CLI Not Available

```
⚠️ GitHub CLI (gh) not found

Pull request analysis requires GitHub CLI.

Install: brew install gh (macOS) or https://cli.github.com

For now, continuing without PR analysis...
```

### GitHub API Rate Limit

```
⚠️ GitHub API rate limit reached

PR analysis incomplete. Rate limit resets in [time].

Options:
- Continue without PR analysis
- Wait [time] and retry
- Cancel discovery

Use AskUserQuestion
```

### Config File Parse Error

```
⚠️ Failed to parse [filename]

Error: [error message]

Skipping this config file and continuing...
```

### No Standards Discovered

```
⚠️ No standards discovered meeting confidence threshold ([threshold]%)

Possible reasons:
- Very new project with little code
- Inconsistent practices across codebase
- Threshold too high (try --confidence=40)

Suggestions:
- Lower confidence threshold: --confidence=40
- Check specific scope: --scope=frontend
- Manually add standards: /ai-sdlc:standards:update
```

### docs-manager Fails

```
❌ Failed to apply standard: [name]

Error from docs-manager: [error]

Options:
- Retry this standard
- Skip and continue with remaining
- Cancel entire application phase

Use AskUserQuestion
```

## Examples

### Example 1: Full Discovery (Default)

```bash
/ai-sdlc:standards:discover
```

**Process**:
- Analyzes all sources (config, code, docs, PRs, CI)
- ~2-4 minutes
- Discovers 15-30 standards typically
- Interactive approval for each confidence level

### Example 2: Quick Discovery (Config Only)

```bash
/ai-sdlc:standards:discover --scope=quick
```

**Process**:
- Only analyzes configuration files
- ~30-60 seconds
- Discovers 10-15 config-based standards
- Fast for initial setup

### Example 3: Frontend Standards Only

```bash
/ai-sdlc:standards:discover --scope=frontend
```

**Process**:
- Analyzes frontend configs and files only
- ~1-2 minutes
- Discovers React/Vue/CSS standards
- Focused analysis

### Example 4: High Confidence Only, Auto-Apply

```bash
/ai-sdlc:standards:discover --confidence=80 --auto-apply
```

**Process**:
- Only shows ≥80% confidence findings
- Auto-applies ≥90% without asking
- Fastest for confident automation
- Still asks for 80-89% findings

### Example 5: Skip External Analysis

```bash
/ai-sdlc:standards:discover --skip-external
```

**Process**:
- Skips GitHub PR and CI analysis
- Faster (saves 30-45s)
- Useful when GitHub unavailable
- Still analyzes config, code, docs

## Integration Points

### With docs-manager Skill

Primary integration - docs-manager handles:
- Creating new standard files
- Updating existing standards (merge new with existing)
- Regenerating INDEX.md after all changes
- Verifying CLAUDE.md integration

### With implementer Skill

Discovered standards become immediately available:
- implementer reads INDEX.md continuously
- New standards applied during implementation
- No restart needed

### With standards:update Command

Complementary workflow:
- `discover` = automated bulk discovery
- `update` = manual single standard updates from conversation

## Notes

**Performance**:
- Full discovery: 2-4 minutes typical
- Quick mode: 30-60 seconds
- Scales well to large codebases (sampling strategy)

**Accuracy**:
- Config-based findings: 85-95% accuracy (explicit)
- Code-based findings: 70-85% accuracy (inferred)
- Doc-based findings: 80-90% accuracy (explicit but may be outdated)
- PR-based findings: 65-80% accuracy (opinion-based)

**Sampling Strategy**:
- Samples files rather than exhaustive analysis
- 50 files per category typical
- Statistically significant for most projects
- Trade-off: speed vs completeness

**Confidence Thresholds**:
- ≥90%: Very high - safe to auto-apply
- 80-89%: High - minimal review needed
- 60-79%: Medium - review recommended
- <60%: Low - needs manual verification

**Best Practices**:
- Run discovery after initializing with `/init-sdlc`
- Re-run quarterly or after major changes
- Review medium-confidence findings carefully
- Resolve conflicts based on team decision
- Commit standards to version control
