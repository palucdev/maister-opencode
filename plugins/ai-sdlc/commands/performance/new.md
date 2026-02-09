---
name: ai-sdlc:performance:new
description: Start a performance optimization workflow with static code analysis for bottleneck detection
---

**ACTION REQUIRED**: This command delegates to a different skill. The `<command-name>` tag refers to THIS command, not the target. Call the Skill tool with skill="ai-sdlc:performance-orchestrator" NOW. Pass all arguments. Do not read files, explore code, or execute workflow steps yourself.

# Performance Optimization Workflow: New

Start performance optimization using static code analysis to identify and fix bottlenecks.

## Usage

```bash
/ai-sdlc:performance:new [description] [--yolo]
```

### Options

- `--yolo`: Continuous execution without pauses

### Providing Profiling Data

If you have runtime profiling data (flame graphs, APM screenshots, slow query logs), you can provide it during Phase 1. The orchestrator will create an `analysis/user-profiling-data/` directory and prompt you to add files there.

## Examples

```bash
/ai-sdlc:performance:new "Dashboard page loading slowly"
/ai-sdlc:performance:new "API response time >1 second" --yolo
/ai-sdlc:performance:new "Optimize database queries for user listing"
```

## See Also

- Workflow details: `skills/performance-orchestrator/SKILL.md`
- Task output: `.ai-sdlc/tasks/performance/YYYY-MM-DD-name/`
