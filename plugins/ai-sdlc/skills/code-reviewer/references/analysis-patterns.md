# Code Review Analysis Patterns

Consolidated reference for quality, security, and performance analysis patterns.

---

## Code Quality Patterns

### Complexity Indicators

| Pattern | Threshold | Risk |
|---------|-----------|------|
| Function length | >50 lines | Maintainability |
| Nesting depth | >4 levels | Readability |
| Parameter count | >5 | Design smell |
| Cyclomatic complexity | >10 branches | Testing difficulty |
| File length | >500 lines | Consider splitting |

### Code Smell Categories

**Structural Smells**:
- God classes (>10 responsibilities)
- Long methods (>50 lines)
- Feature envy (method uses other class more than own)
- Data clumps (same fields grouped repeatedly)

**Logic Smells**:
- Deep nesting
- Complex conditionals
- Duplicate code blocks
- Switch statements on type

**Naming Smells**:
- Single letter variables (except i, j, k for loops)
- Misleading names
- Inconsistent naming conventions

### Detection Approach

For each file:
1. Count function/method lengths
2. Measure nesting depth
3. Identify repeated patterns (potential duplication)
4. Note TODO/FIXME/HACK comments
5. Check for magic numbers (unexplained literals)

---

## Security Patterns

### Critical Vulnerabilities

| Vulnerability | Detection Pattern | Risk |
|--------------|-------------------|------|
| **Hardcoded secrets** | Strings matching `api_key`, `password`, `token`, `secret` | Credential exposure |
| **SQL injection** | String concatenation in queries, `${}` in SQL | Data breach |
| **Command injection** | User input to `exec`, `system`, `child_process` | System compromise |
| **eval usage** | `eval()`, `Function()`, `new Function` | Code execution |
| **Path traversal** | User input in `readFile`, `path.join` | File system access |

### Warning-Level Security

| Issue | Detection Pattern | Risk |
|-------|-------------------|------|
| **XSS potential** | `innerHTML`, `dangerouslySetInnerHTML` | Script injection |
| **Weak random** | `Math.random()` for security purposes | Predictable values |
| **Missing HTTPS** | HTTP URLs for sensitive operations | Data interception |
| **Logging secrets** | `log.*password`, `console.log.*token` | Credential leak |

### Auth/Authz Checks

Look for:
- API endpoints without auth middleware
- Sensitive operations without permission checks
- Session handling issues (expiry, invalidation)
- CORS misconfigurations

### OWASP Top 10 Alignment

| OWASP | What to Check |
|-------|---------------|
| Injection | SQL, command, XSS, LDAP |
| Broken Auth | Session management, credential storage |
| Sensitive Data Exposure | Encryption, secrets management |
| XML External Entities | XML parsing without disabling |
| Broken Access Control | Authorization checks |
| Security Misconfiguration | Default configs, error messages |
| XSS | Output encoding, sanitization |
| Insecure Deserialization | Pickle, JSON.parse on untrusted |
| Known Vulnerabilities | Outdated dependencies |
| Logging/Monitoring | Audit trails, error logging |

---

## Performance Patterns

### Database Issues

| Pattern | Detection | Impact |
|---------|-----------|--------|
| **N+1 queries** | Query inside `.map()`, `.forEach()`, loop | Exponential DB calls |
| **Missing indexes** | WHERE on unindexed columns | Slow queries |
| **No pagination** | `findAll()`, `SELECT *` without LIMIT | Memory exhaustion |
| **Eager loading** | Missing `include`/`join` causing multiple queries | Extra round trips |

**Solution patterns**:
- N+1: Batch queries with `findMany({ where: { id: { in: ids } } })`
- Pagination: Add `limit`/`offset` or cursor-based
- Eager loading: Use `include` relations

### Blocking Operations

| Pattern | Detection | Impact |
|---------|-----------|--------|
| **Sync file I/O** | `readFileSync`, `writeFileSync` | Thread blocking |
| **Sync crypto** | `crypto.pbkdf2Sync` | Thread blocking |
| **Large loops** | Processing without yielding | Event loop blocking |

### Memory Issues

| Pattern | Detection | Impact |
|---------|-----------|--------|
| **Large file load** | Reading entire file to memory | Memory exhaustion |
| **Unbounded arrays** | Accumulating without limits | Memory leak |
| **Missing cleanup** | Event listeners not removed | Memory leak |

### Caching Opportunities

Look for:
- Repeated expensive computations
- Frequent database queries for same data
- External API calls without caching
- Static data loaded on every request

---

## Severity Classification

### Critical (Must Fix)

- Hardcoded production secrets
- SQL/command injection vulnerabilities
- Missing authentication on sensitive endpoints
- eval/exec with user input
- Path traversal vulnerabilities

### Warning (Should Fix)

- N+1 query patterns
- Sync blocking operations
- Missing error handling
- XSS potential (innerHTML)
- High complexity (>10 cyclomatic)

### Info (Nice to Fix)

- TODO/FIXME comments
- Magic numbers
- Minor duplication (<10 lines)
- console.log statements
- Missing JSDoc on complex functions

---

## Context-Aware Analysis

### Consider Project Type

| Project Type | Focus Areas |
|--------------|-------------|
| API/Backend | Auth, injection, N+1, error handling |
| Frontend/SPA | XSS, state management, performance |
| CLI tool | Input validation, error messages |
| Library | API design, backward compatibility |

### Consider Tech Stack

Read `.ai-sdlc/docs/standards/` for:
- Framework-specific patterns
- Project conventions
- Approved libraries
- Custom rules

### False Positive Avoidance

Don't flag:
- Intentional patterns (documented)
- Test files (different standards)
- Generated code
- Third-party code in vendor/
