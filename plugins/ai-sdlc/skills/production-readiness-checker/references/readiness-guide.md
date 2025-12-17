# Production Readiness Guide

Consolidated reference for production readiness verification. Trust Claude to reason about specific detection patterns.

---

## Risk Classification

### 🔴 Deployment Blockers (Must Fix)

| Category | Blockers |
|----------|----------|
| **Configuration** | Missing .env.example, hardcoded secrets, no startup validation |
| **Monitoring** | No health endpoint, no error tracking, sensitive data in logs |
| **Resilience** | No graceful shutdown, critical paths unprotected |
| **Performance** | No connection pooling, no rate limiting, no request timeouts |
| **Security** | No HTTPS, CORS wildcard (*), critical CVEs |
| **Deployment** | Missing migrations, no rollback plan |

### 🟡 Concerns (Should Fix)

| Category | Concerns |
|----------|----------|
| **Configuration** | Hardcoded URLs/ports, no feature flags |
| **Monitoring** | No structured logging, missing metrics, incomplete health checks |
| **Resilience** | No retry logic, no circuit breakers, poor degradation |
| **Performance** | No caching, suboptimal pool size, missing indexes |
| **Security** | Incomplete headers, high CVEs, weak CSP |
| **Deployment** | No staging tests, no rollback testing |

### 🟢 Recommendations (Nice to Have)

Circuit breakers, business metrics, canary deployments, disaster recovery plan.

---

## GO/NO-GO Criteria

### Required for Production (Any missing = 🔴 NO-GO)

1. Health check endpoint (/health or /healthz)
2. Error tracking service configured
3. Environment variables externalized
4. No hardcoded secrets
5. Database connection pooling
6. Graceful shutdown handlers (SIGTERM/SIGINT)
7. HTTPS enforced
8. No critical security vulnerabilities
9. Rate limiting on public endpoints
10. Request timeouts configured

### Recommended (Missing = 🟡 GO with Mitigations)

- Metrics instrumentation
- Retry logic for external calls
- Security headers (Helmet/equivalent)
- Staging environment testing
- Structured logging

---

## Report Structure

### Executive Summary

```markdown
**Status**: 🔴 Not Ready | 🟡 With Concerns | 🟢 Ready
**Recommendation**: GO / NO-GO / GO with Mitigations
**Overall Readiness**: [%]
**Risk**: Low / Medium / High / Critical

**Blockers**: [N]  **Concerns**: [M]  **Recommendations**: [K]
```

### Category Breakdown

| Category | Score | Status |
|----------|-------|--------|
| Configuration | [%] | 🔴/🟡/🟢 |
| Monitoring | [%] | 🔴/🟡/🟢 |
| Resilience | [%] | 🔴/🟡/🟢 |
| Performance | [%] | 🔴/🟡/🟢 |
| Security | [%] | 🔴/🟡/🟢 |
| Deployment | [%] | 🔴/🟡/🟢 |

### Finding Format

Each finding must include:
- **Location**: Specific file/line
- **Issue**: What's wrong
- **Risk**: Why it matters for production
- **Fix**: How to resolve

### Prioritized Actions

Group by urgency:
1. **Immediate** (blockers): Before deployment
2. **Before Deployment** (concerns): Address or mitigate
3. **Post-Deployment** (recommendations): Improve over time

---

## Scoring Guidelines

| Score | Interpretation |
|-------|---------------|
| 90-100% | Excellent - fully ready |
| 75-89% | Good - ready with minor concerns |
| 60-74% | Fair - significant concerns |
| 40-59% | Poor - major improvements needed |
| <40% | Critical - not ready |

**Calculation**:
- Each required check weighted 2x
- Any blocker = 0% for that category
- Overall = average of category scores

---

## Detection Principles

### Configuration

| What to Find | Where to Look |
|--------------|---------------|
| Env var usage | `process.env`, `os.getenv`, `ENV[]` |
| Documentation | `.env.example`, `.env.template` |
| Startup validation | Config initialization code |
| Hardcoded values | Inline URLs, ports, hosts |
| Secrets in code | `password=`, `api_key=`, `secret=` |

### Monitoring

| What to Find | Where to Look |
|--------------|---------------|
| Logging library | Winston, Pino, structlog |
| Metrics | Prometheus, StatsD, Datadog |
| Error tracking | Sentry, Bugsnag, Rollbar |
| Health endpoint | `/health`, `/healthz`, `/ping` |
| Sensitive logging | `log.*password`, `log.*token` |

### Resilience

| What to Find | Where to Look |
|--------------|---------------|
| Signal handlers | `SIGTERM`, `SIGINT` handlers |
| Try-catch coverage | Async operations, DB calls |
| Retry patterns | External API calls |
| Circuit breakers | Dependency wrappers |

### Performance

| What to Find | Where to Look |
|--------------|---------------|
| Connection pool | DB config, pool size settings |
| Rate limiting | Middleware configuration |
| Timeouts | HTTP client configs |
| Caching | Redis/Memcached integration |

### Security

| What to Find | Where to Look |
|--------------|---------------|
| HTTPS redirect | Server configuration |
| Security headers | Helmet, middleware |
| CORS config | Origin settings |
| Dependency audit | npm audit, pip-audit results |

### Deployment

| What to Find | Where to Look |
|--------------|---------------|
| Migrations | Database migration files |
| Rollback | Down migrations |
| Staging | Environment configs |

---

## Environment Standards

| Check | Production | Staging |
|-------|------------|---------|
| Health checks | Required | Required |
| Error tracking | Required | Recommended |
| Metrics | Required | Optional |
| Security headers | Required | Recommended |
| Rate limiting | Required | Optional |
| Full observability | Required | Recommended |

---

## Post-Deployment Verification

Verify within 15 minutes:
- Health endpoint returns 200
- Logs flowing to aggregation
- Metrics appearing in dashboard
- Error tracking receiving events
- Database connections healthy
- Critical user flows pass smoke tests
- Error rate < 1%
- Response times within baseline

---

## Rollback Criteria

Trigger rollback if:
- Health check failures
- Error rate > 5%
- Response time > 3x baseline
- Database connection failures
- Critical feature broken
- Security vulnerability exploited

---

## Summary

Production readiness verification focuses on:
1. **Safety**: Can we deploy without breaking production?
2. **Observability**: Can we detect and diagnose issues?
3. **Resilience**: Can we recover from failures?
4. **Reversibility**: Can we roll back if needed?

Apply appropriate rigor based on target environment. Production requires full compliance; staging allows relaxed standards.
