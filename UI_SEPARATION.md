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
