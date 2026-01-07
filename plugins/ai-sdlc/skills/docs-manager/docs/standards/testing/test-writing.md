## Test Writing Best Practices

### Core Principles

- **Test Behavior, Not Implementation**: Focus tests on what the code does, not how it does it, to reduce brittleness and allow safe refactoring
- **Clear Test Names**: Use descriptive names that explain what's being tested and the expected outcome (e.g., `shouldReturnErrorWhenUserNotFound`)
- **Mock External Dependencies**: Isolate units by mocking databases, APIs, file systems, and other external services to ensure reliability and speed
- **Fast Execution**: Keep unit tests fast (milliseconds) so developers run them frequently during development

### Coverage Guidelines

- **Risk-Based Testing**: Prioritize testing based on business criticality, impact of failure, and likelihood of bugs
- **Balance Coverage and Velocity**: Adjust test coverage based on project needs, domain risk, and team workflow preferences
- **Critical Path Focus**: Ensure core user workflows and critical business logic are well-tested
- **Context-Appropriate Depth**: Edge case and error state testing should match the risk profile of the code
