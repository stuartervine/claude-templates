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
