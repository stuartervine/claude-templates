# Test-Driven Development (TDD)

**CRITICAL: TEST-DRIVEN DEVELOPMENT IS NON-NEGOTIABLE.** Every single line of production code must be written in response to a failing test. No exceptions. ALWAYS write a test first, then implement the code to make the test pass. If you find yourself writing production code without having written a test first, STOP IMMEDIATELY.

### Testing External Dependencies

**DO NOT MOCK YOUR OWN CODE.** Instead, follow these principles:

1. **Abstract external dependencies** behind clean interfaces specific to your domain needs
2. **Create in-memory implementations** of these interfaces for testing
3. **Use real implementations** of your own services in tests
4. **Only mock third-party libraries**, never your own code
5. **Design for testability** with dependency injection and clear interfaces

By following this approach, tests become more meaningful, less brittle, and better represent real application behavior. This also promotes better architecture by encouraging proper separation of concerns.

### Behavior-Driven Testing

- **Test behavior, not implementation**: Focus tests on what components DO, not how they're built
- Avoid testing internal state or implementation details
- Tests should verify outcomes and side effects, not the existence of specific methods
- Write tests from the perspective of a consumer of the component
- Tests should document and verify the intended behavior of the system
- A test should fail only when the behavior it verifies is broken

### The TDD Process

Strictly follow the Red-Green-Refactor cycle for every code change:

1. **Red**: Write a failing test for the desired behavior first
   - The test must be written before any production code
   - Run the test to confirm it fails (for the right reason)
   - Only proceed when you have a failing test

2. **Green**: Write the minimum code needed to make the test pass
   - Write only the code necessary to pass the test - no more
   - Resist the urge to implement features not yet covered by tests
   - Run the test to confirm it passes

3. **Refactor**: Clean up the code while keeping tests green
   - Look for opportunities to improve the code
   - Run tests after each refactoring to ensure nothing broke
   - Only commit after tests are passing

4. **Verify**: Run the full test suite after implementing a feature
   - Always run the complete test suite after making changes
   - If any tests fail, identify the cause and fix the issue
   - Repeat until all tests pass consistently
   - Never consider implementation complete until all tests pass

### Common TDD Violations to Avoid

- Writing production code without a failing test first - THIS IS NEVER ACCEPTABLE
- Writing multiple tests before making the first one pass
- Writing more production code than needed to pass the current test
- Skipping the refactor step when code could be improved
- Adding functionality "while you're there" without a test driving it
- Creating new modules or classes without corresponding test files
- Implementing features because they "will be needed soon" without a test driving them

## The testing pyramid

The Test Pyramid is a testing strategy that organizes automated tests into three main layers, shaped like a pyramid to indicate the relative quantity and scope of each test type.

#### Core Structure (Bottom to Top)
1. Unit Tests (Base - Most Tests)
- Purpose: Test individual components in isolation
- Scope: Single functions, methods, or classes
- Characteristics:
  - Fast execution (seconds/minutes for thousands)
  - Focus on business logic and edge cases
  - Test public interfaces, not private methods

Implementation Pattern:

```
// Arrange: Set up test data and mocks
// Act: Call the method under test  
// Assert: Verify expected results
```

2. Integration Tests (Middle - Fewer Tests)
- Purpose: Test interactions between components
- Scope: Database connections, API calls, file systems
- Types:
  - Database integration tests
  - Service integration tests
  - Contract tests (Consumer-Driven Contracts with tools like Pact)

3. End-to-End/UI Tests (Top - Fewest Tests)
- Purpose: Test complete user workflows
- Scope: Full system including UI
- Characteristics:
  - Slowest and most brittle
  - High maintenance cost
  - Focus only on critical user journeys
  - Uses real API calls / browsers

#### Key Principles
- Test Granularity: Write tests at different levels of detail
- Pyramid Shape: More lower-level tests, fewer higher-level tests
- Fast Feedback: Quick-running tests catch issues early
- Avoid Duplication: Don't test the same functionality at multiple levels
- Push Tests Down: Prefer lower-level tests when possible for speed

#### When Writing Code
- Unit Tests: Write for all business logic, controllers, services, utilities
- Integration Tests: Write for database queries, external API calls, file operations
- End-to-End Tests: Write only for the most critical user paths (e.g., login, purchase flow)

#### Anti-Patterns to Avoid
- Ice Cream Cone: Too many slow, high-level tests
- Test Duplication: Testing the same logic at multiple pyramid levels
- Testing Implementation Details: Focus on behavior, not internal structure
- Flaky Tests: Tests that fail unpredictably due to timing/environment issues