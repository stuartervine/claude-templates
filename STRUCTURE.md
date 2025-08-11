# Code structure guidelines

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
