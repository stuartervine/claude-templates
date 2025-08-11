## Recent Improvements

### Test Objects Can Be Mutable
- Failure: Added complexity to test objects by making them follow production immutability rules
- Correction: Simplified test implementations to be mutable when needed for easier testing
- Rule: It's acceptable for test objects to be mutable even if they represent immutable production objects
- Benefit: Simpler tests, easier assertions, and better separation of test and production concerns

### Prefer Tests Over Print Debugging
- Failure: Added temporary print statements to debug test failures
- Correction: Added proper test helpers and assertions instead
- Rule: Use tests, assertions, and test helpers for debugging instead of print statements
- Benefit: More maintainable code, reproducible test behavior, and cleaner codebase

### Consistent In-Memory Implementation Naming
- Failure: In-memory implementations were in a single file with unclear naming (TestXYZ)
- Correction: Added clear naming convention for in-memory implementations
- Rule: Name files as in_memory_<object_name>.py and classes as InMemory<ObjectName>
- Benefit: More consistent, descriptive, and maintainable test implementations

### UI-Business Logic Separation
- Failure: UI code contained business logic, making it difficult to test and add new interfaces
- Correction: Added principles for proper separation of UI from core business logic
- Rule: Implement UI as thin adapters that communicate with business logic through well-defined data structures
- Benefit: More maintainable code, cleaner architecture, ability to add new interfaces without changing business logic

### Dependency Injection Over Global Patching
- Failure: Using patching and monkey-patching in tests, making them brittle and hard to maintain
- Correction: Added principles for proper dependency injection and avoidance of global patching
- Rule: Never patch or monkey-patch in tests; always inject test implementations directly
- Benefit: More maintainable, testable code with explicit dependencies and better design

### Domain-Focused Naming Convention
- Failure: Using language implementation terms like "Interface" or "Class" in file and class names
- Correction: Added clear naming convention rules emphasizing domain concepts over implementation details
- Rule: Name interfaces after domain concepts and implementations with specific type prefixes
- Benefit: More readable code that reflects the domain model rather than technical implementation details

### Clean Testing Through Abstractions
- Failure: Excessive mocking of our own services, making tests brittle and less meaningful
- Correction: Added principles for abstracting external dependencies behind interfaces
- Rule: Create in-memory implementations for testing rather than mocking your own code
- Benefit: Tests that are more robust, meaningful, and better represent actual application behavior

### Python Virtual Environment Rules
- Failure: Running Python commands without activating the virtual environment
- Correction: Added explicit rules for always activating the virtual environment
- Rule: ALWAYS run `source .venv/bin/activate` before executing any Python commands

### Strict Test-First Enforcement
- Failure: Production code was written without first creating a failing test
- Correction: Added stronger language to emphasize that writing code without tests first is never acceptable
- Rule: STOP IMMEDIATELY if you find yourself writing production code without a test first

### Test Suite Verification
- Failure: Changes to implement a feature were made without verifying all tests still pass
- Correction: Added explicit test verification step to the development process
- Rule: Always run the full test suite after implementing a feature, fix any failures, and repeat until all tests pass

### TDD Enforcement
- Failure: Code was written without first creating failing tests
- Correction: Strengthened TDD principles to emphasize that ALL code must be test-driven
- Rule: Never write any production code without first having a failing test that demonstrates the need for that code

### Immutability First
- Failure: Created mutable objects with setters that modify internal state
- Correction: Added principles for immutability and proper object design
- Rule: Design classes to be immutable by default and avoid exposing internal state with getters/setters

### Behavior-Based Testing
- Failure: Tests were focusing on object state and implementation details rather than behavior
- Correction: Added principles for behavior-driven testing
- Rule: Write tests that verify what a component does (its behavior and outputs), not how it's implemented or its internal state

### Working Software Priority
- Failure: Created well-tested individual components without a working end-to-end system
- Correction: Emphasized the need for a runnable system from the first line of code
- Rule: Always prioritize having a working end-to-end system over adding new features or components

### Test File Management
- Failure: Creating new test files with suffixes like `test_analyze_refactored.py` when `test_analyze.py` already exists
- Correction: Added explicit rule to always update existing test files in place
- Rule: Never create new test files when existing ones already exist; modify the existing test file directly
- Benefit: Maintains consistency, avoids test file proliferation, and keeps related tests together