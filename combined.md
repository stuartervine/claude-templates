# Combined Markdown Files

Generated on: Sat Aug 16 13:32:05 PDT 2025

## DEPENDENCY_INJECTION.md

## Dependency Injection

**CRITICAL: PREFER DEPENDENCY INJECTION OVER GLOBAL PATCHING.** Do not rely on monkey-patching or global module patching in tests.

1. **Use constructor injection** for all dependencies
   - Dependencies should be passed explicitly through constructors or function parameters
   - Never instantiate dependencies directly inside a class or function
   - Define interfaces for dependencies to enable clean substitution

2. **Avoid global state and singletons**
   - Dependencies should not be accessed through global variables, static methods, or singletons
   - Make all dependencies explicit in method signatures

3. **Use composition roots**
   - Centralize dependency creation in composition roots
   - Keep implementation details out of business logic
   - Use a factory if absolutely necessary, but prefer direct object injection with a top level composition.

4. **In tests, inject test doubles directly**
   - Never patch or monkey-patch in tests
   - Create in memory implementations of interfaces for testing, these should behave in a similar fashion to the real implementation
   - Always inject implementations through the constructor or parameters
   - Refactor code that cannot be tested without patching

Code that follows dependency injection principles is more maintainable, more testable, and follows better design principles. It allows easy substitution of implementations and avoids hidden coupling between components.

---

## HTTP_SEPARATION.md

## HTTP-Business Logic Separation

**CRITICAL: STRICTLY SEPARATE HTTP HANDLING FROM BUSINESS LOGIC.** Each layer should have a single responsibility with
clear boundaries.

1. **Use the Ports and Adapters pattern for HTTP APIs**
    - Core business logic should be completely HTTP-agnostic
    - HTTP handlers should only manage request/response transformation
    - Communication between layers should be via well-defined interfaces and domain objects

2. **Implement HTTP handlers as thin adapters**
    - HTTP handler code should only:
        - Extract and validate data from HTTP requests (headers, body, query params, path params)
        - Transform into domain-specific data structures
        - Pass data to business service layer
        - Receive domain results and encode into appropriate HTTP responses
        - Handle HTTP-specific concerns (status codes, content negotiation, caching headers)
    - No business rules or domain logic should exist in handler code

3. **Use domain objects for service communication**
    - Define explicit input domain objects for service operations
    - Define explicit output domain objects for service results
    - Use immutable data structures whenever possible
    - Never pass HTTP-specific objects (Request, Response, Context) to service layer
    - Services should never import HTTP libraries or frameworks

4. **Create dedicated application services**
    - Implement core functionality in service classes that know nothing about HTTP
    - Services should accept domain input objects and return domain output objects
    - Services should be easily testable without any HTTP infrastructure
    - Handle all business validation and logic at the service layer

5. **Design composable route structures**
    - Group related routes into logical modules/routers
    - Use middleware for cross-cutting HTTP concerns (auth, logging, CORS)
    - Keep route definitions declarative and easy to understand
    - Enable route composition without duplicating business logic

6. **Make transport layer swappable**
    - The same service layer should work with HTTP, gRPC, CLI, message queues, etc.
    - Adding a new transport should require no changes to the service layer
    - All dependencies (databases, external services) should be injected via interfaces

7. **Handle errors appropriately at each layer**
    - Service layer returns domain-specific errors
    - HTTP layer translates domain errors to appropriate HTTP status codes and responses
    - Don't leak internal implementation details through HTTP responses

---

## PYTHON.md

## PYTHON RULES

### General rules
- Use Python 3.11 or greater
- Use Python Types

### File and Class Naming

- Name files as `<object_name>.py` (e.g., `file_store.py`)
- File names should represent their implementation and interface. For example:
  - We may have a `Store` protocol in a `store.py` file.
  - An implementation of `FileStore` in a `file_store.py` file.
  - And an implementation of `InMemoryStore` in an `in_memory_store.py` file.
  - All stores live in the `store` package & folder.
- Each file should contain a single implementation focused on one domain concept
- Group related implementations in appropriate packages (e.g., `testing` for test doubles)
- Avoid generic terms like "Test" or "Mock" or "Impl" in the class name
- Avoid pattern names e.g. `AbstractFileFactory` and use more behavioural names e.g. `FileCreator`.

### Composition

Prefer composing objects instead of long method implementations.
- In general more objects with shorter methods are a good thing.
- Objects should focus on a single responsibility
- Methods should be clearly named and easy to understand what they do. 
- Prefer clarity over terseness.

### In Memory Testing Objects

**CRITICAL: IN-MEMORY IMPLEMENTATIONS SHOULD FOLLOW A CLEAR NAMING CONVENTION.** 

1. **In-memory implementation files**
   - Name files as `in_memory_<object_name>.py` (e.g., `in_memory_browser.py`)

2. **In-memory implementation classes**
   - Name classes as `InMemory<ObjectName>` (e.g., `InMemoryBrowser`)
   - The class name should reflect its domain purpose, not implementation details

3. **Implementation behavior**
   - In-memory implementations should behave like the real implementations but without external dependencies
   - They should provide additional methods for test verification and setup
   - All functionality relevant to tests should be fully implemented

This naming convention makes the purpose of test implementations immediately clear and ensures consistency throughout the codebase.

### Virtual Environment
- **ALWAYS** activate the virtual environment before running any Python commands
  - Use `source .venv/bin/activate` before running pip, pytest, or python
  - Never run Python commands with the system Python interpreter
  - Check that the virtual environment is activated before installing packages
  - Use the activated environment for all development operations

### Package Management
- Install the project in development mode after making code changes: `pip install -e .`
- Run tests from the project root with the virtual environment activated
- Use the project's specified package manager (uv) for installing dependencies
- Verify package dependencies match those in pyproject.toml

### Naming Conventions

**VERY IMPORTANT: Naming of files and classes is critical.** Do not name classes and files with language implementation details such as "Interface" or "Class".

- Domain abstractions should be named using domain-specific terms
- Files containing interfaces should be named after the domain concept (e.g., `storage.py`)
- Implementation classes should be named with their specific implementation type (e.g., `S3Storage`)
- Implementation files should be named with the specific implementation prefix (e.g., `s3_storage.py`)

Example:
- Interface: `Storage` in file `storage.py`
- Implementation: `S3Storage` in file `s3_storage.py`

### Testing: Behaviour driven tests

We prefer simplicity when reading tests:
- You should create builders & helper functions / classes to remove boiler plate & noisy code and make it easier for developers to understand the intention of the code.
  - For any object that is being used as part of an assertion - create it in the test method, not in a helper. 
- These helpers should be created in the test file, unless they are to be shared across tests.
  - DO NOT chain helper methods. 
- For builders that help create complex objects, create these in a separate file of <object name>_builder.py
  - DO chain builder methods.  
- The name of the test should be simple and to the point.
- You should not need to insert comments into tests - they should be easily understood without the comments.
- ALWAYS update tests in place; do not create new files with suffixes like "_refactored" or "_updated".
- Maintain backward compatibility with existing test imports and module structure when refactoring.
- **NEVER create new test files when existing ones already exist.** If `test_analyzer.py` exists, modify it instead of creating `test_analyzer_refactored.py` or similar.
- When refactoring or updating tests, edit the existing test file directly to maintain consistency and avoid test file proliferation.

This sort of test is bad:

```python
def test_workflow_with_url_and_actions_produces_expected_structure() -> None:
    """Test that a workflow with URL and actions produces the expected structure."""
    # Create a workflow with URL and actions
    test_url = "https://example.com"
    llm_thing = InMemoryLLMThing()
    recorder = WorkflowRecorder(start_url=test_url, llm_thing=llm_thing)
    
    click_action: Action = {"type": "click", "selector": "#button1"}
    fill_action: Action = {"type": "fill", "selector": "#input1", "value": "test"}
    
    recorder = recorder.add_action(click_action).add_action(fill_action)
    
    # Get the workflow and verify its structure
    workflow = recorder.get_workflow()
    assert workflow["start_url"] == test_url
    assert len(workflow["actions"]) == 2
    assert workflow["actions"][0]["type"] == "click"
    assert workflow["actions"][1]["type"] == "fill"
    assert llm_thing.received_prompt("Some text")
```

This sort of test is better:
```python
def test_records_a_workflow() -> None:
    test_url = "https://example.com"
    click_action: Action = {"type": "click", "selector": "#button1"}
    fill_action: Action = {"type": "fill", "selector": "#input1", "value": "test"}
    
    llm_thing = InMemoryLLMThing()
    recorder = recorder_with(start_url=test_url, llm_thing=llm_thing, action=[click_action, fill_action])
    workflow = recorder.get_workflow()
    
    workflow_assertions = assert_workflow(workflow)
    assert workflow_assertions.has_url(test_url)
    assert workflow_assertions.contains_actions([click_action, fill_action])
    assert llm_thing.received_prompt("Some text")
 ```


This naming convention ensures that your code reflects the domain model rather than the technical implementation details, making the code more readable and maintainable.

---

## STRUCTURE.md

# Code structure guidelines

## Working Software and Iterative Development

**CRITICAL: WORKING SOFTWARE OVER FEATURES.** Prioritize having a runnable system from the first line of code. All components should be wired together into a working end-to-end system as early as possible.

- Work in small, manageable increments
- Add the minimal amount of code needed for each feature
- Maintain a working state throughout development
- Build vertical slices (end-to-end functionality) rather than horizontal layers
- Ensure the core application can always be run, even with limited functionality
- Prioritize integrating components into a working system over adding new features
- Test the complete system regularly, not just individual components

## Task Management
- Break down large tasks into smaller, actionable items
- Check off completed items as progress is made

## Code Quality

### Self-Documenting Code

- Code should document itself through clear naming and structure
- Choose descriptive names for classes, methods, and variables that reveal intention
- Avoid redundant comments that merely restate what the code already says
- Use comments sparingly and only when they add value beyond what the code itself expresses
- Comments should explain WHY, not WHAT or HOW
- Structure code to make its purpose and flow immediately obvious
- Extract complex logic into independent objects or well-named functions with clear inputs and outputs
- Prefer better code structure over explanatory comments

### General Quality
- Write clean, maintainable code
- Focus on readability and simplicity
- Refactor regularly to prevent technical debt

## Immutability and State Management

- Prefer immutable data structures and pure functions
- Avoid mutable state where possible
- Design classes with immutability in mind:
  - Use constructor parameters for required state instead of setters
  - Return new instances instead of modifying existing ones
  - Make methods return new objects rather than modifying internal state
- Avoid getters and setters that expose or modify internal state
- Use functional programming patterns where appropriate
- Test outputs and behaviors, not internal structure

## Build and Deployment
- Maintain simple, parameterized commands for all operations:
  - Build
  - Run tests
  - Run application
  - Deploy

---

## TDD.md

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
---

## UI_SEPARATION.md

## UI-Business Logic Separation

**CRITICAL: STRICTLY SEPARATE USER INTERFACE FROM BUSINESS LOGIC.** Each layer should have a single responsibility with clear boundaries.

1. **Use the Ports and Adapters pattern**
   - Core business logic should be completely UI-agnostic
   - UI components should only handle presentation and user interaction
   - Communication between layers should be via well-defined interfaces and data structures

2. **Implement UI as a thin adapter**
   - UI code should only:
     - Extract information from the UI framework
     - Translate into domain-specific data structures
     - Pass data to the business logic
     - Receive results and render them appropriately
   - No business rules or complex logic should exist in UI code

3. **Use data classes for input and output**
   - Define explicit input data classes for operations
   - Define explicit output data classes for results
   - Use immutable data structures whenever possible
   - Never pass UI-specific objects to business logic

4. **Create dedicated core application services**
   - Implement core functionality in dedicated application service classes
   - These services should accept domain-specific input and return domain-specific output
   - Services should be easily testable without any UI components

5. **Make interfaces swappable**
   - CLI, Web UI, API, and other interfaces should all use the same business logic
   - Adding a new interface should require no changes to the core business logic
   - All dependencies must be injected to allow easy substitution

Following this separation ensures your application's core functionality is independent of the UI framework, enabling better testing, maintainability, and the ability to add new interfaces without modifying the business logic.

---

