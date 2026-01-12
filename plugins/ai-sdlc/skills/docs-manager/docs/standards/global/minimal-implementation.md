## Minimal implementation principles

- **Build What You Need**: Only create methods, classes, and functions that will actually be called; avoid speculative "might need later" code
- **Purpose Over Speculation**: Every method should serve a clear purpose - either it's called from somewhere, or it significantly improves code readability
- **Clean Up Exploration Artifacts**: Delete helper methods and utilities created during development exploration that ended up unused
- **No Future-Proofing Stubs**: Avoid empty methods, placeholder functions, or interfaces "for future extensibility" that aren't needed now
- **Avoid "Just in Case" Abstractions**: Don't create factories, strategies, or adapters unless there's an immediate use case requiring them
- **Review Before Commit**: Before completing a task, verify all new methods have callers or serve a clear readability purpose
- **Dead Code is Technical Debt**: Unused code confuses future readers and adds maintenance burden; remove it promptly
