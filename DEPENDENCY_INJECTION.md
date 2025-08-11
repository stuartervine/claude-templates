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
