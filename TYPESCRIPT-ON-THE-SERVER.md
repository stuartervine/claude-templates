# TypeScript Server Development Principles

## Core Philosophy

Build server applications using TypeScript and Node.js following domain-driven design principles, emphasizing
testability, maintainability, and clear separation of concerns.

## Framework Selection

### Preferred Frameworks

- **hapijs** (TypeScript) - Lightweight HTTP library for Node.js
- **esbuild** for packing
- **Native Node.js HTTP module** - For maximum control

### Avoid

- **Express** - Too opinionated, middleware-heavy, and difficult to test in isolation
- **webpack** - Too complicated

## SOLID Principles

### Single Responsibility Principle

Each class should have one reason to change. Break down complex functionality into focused, cohesive units.

```typescript
// Good: Single responsibility
class OrderValidator {
    validate(order: Order): ValidationResult {
        // Only validates orders
    }
}

class OrderRepository {
    save(order: Order): Promise<void> {
        // Only handles order persistence
    }
}

// Bad: Multiple responsibilities
class OrderManager {
    validate(order: Order): ValidationResult {
    }

    save(order: Order): Promise<void> {
    }

    sendEmail(order: Order): Promise<void> {
    }
}
```

### Dependency Inversion

Depend on abstractions (interfaces), not concrete implementations.

## Architecture Patterns

### Domain-Driven Design Structure

Organize code by domain concepts, not technical layers:

```
src/
├── orders/
│   ├── domain/
│   │   ├── Order.ts
│   │   ├── OrderLine.ts
│   │   └── OrderStatus.ts
│   ├── repositories/
│   │   ├── OrderRepository.ts
│   │   ├── PostgresOrderRepository.ts
│   │   └── InMemoryOrderRepository.ts
│   ├── services/
│   │   ├── OrderService.ts
│   │   └── OrderValidator.ts
│   ├── api/
│   │   └── OrderController.ts
│   └── __tests__/
│       ├── OrderService.test.ts
│       ├── OrderValidator.test.ts
│       └── OrderController.test.ts
├── customers/
│   ├── domain/
│   ├── repositories/
│   ├── services/
│   └── api/
├── shared/
│   ├── types/
│   └── utils/
└── infrastructure/
    ├── database/
    │   └── connection.ts
    ├── http/
    │   └── server.ts
    └── config/
        └── environment.ts
```

### Interfaces

Interfaces should be used for each domain service - they should not start with an 'I' but be more generally named around
the domain concept.

### Repository Pattern

Isolate database access behind domain-specific repository interfaces:

```typescript
// Interface (abstraction)
interface OrderRepository {
    findById(id: string): Promise<Order | null>;

    save(order: Order): Promise<void>;

    findByCustomerId(customerId: string): Promise<Order[]>;
}

// PostgreSQL implementation
class PostgresOrderRepository implements OrderRepository {
    constructor(private db: DatabaseConnection) {
    }

    async findById(id: string): Promise<Order | null> {
        const row = await this.db.query('SELECT * FROM orders WHERE id = $1', [id]);
        return row ? this.mapToOrder(row) : null;
    }

    async save(order: Order): Promise<void> {
        await this.db.query(
            'INSERT INTO orders (id, customer_id, total) VALUES ($1, $2, $3)',
            [order.id, order.customerId, order.total]
        );
    }

    async findByCustomerId(customerId: string): Promise<Order[]> {
        const rows = await this.db.query('SELECT * FROM orders WHERE customer_id = $1', [customerId]);
        return rows.map(this.mapToOrder);
    }

    private mapToOrder(row: any): Order {
        return new Order(row.id, row.customer_id, row.total);
    }
}

// In-memory implementation for testing
class InMemoryOrderRepository implements OrderRepository {
    private orders: Map<string, Order> = new Map();

    async findById(id: string): Promise<Order | null> {
        return this.orders.get(id) || null;
    }

    async save(order: Order): Promise<void> {
        this.orders.set(order.id, order);
    }

    async findByCustomerId(customerId: string): Promise<Order[]> {
        return Array.from(this.orders.values())
            .filter(order => order.customerId === customerId);
    }
}
```

### External System Isolation

Wrap third-party services behind domain-specific interfaces:

```typescript
// Domain interface
interface PaymentGateway {
    processPayment(amount: number, token: string): Promise<PaymentResult>;

    refund(transactionId: string): Promise<void>;
}

// Stripe implementation
class StripePaymentGateway implements PaymentGateway {
    constructor(private stripe: Stripe) {
    }

    async processPayment(amount: number, token: string): Promise<PaymentResult> {
        const charge = await this.stripe.charges.create({
            amount,
            currency: 'usd',
            source: token
        });
        return {success: true, transactionId: charge.id};
    }

    async refund(transactionId: string): Promise<void> {
        await this.stripe.refunds.create({charge: transactionId});
    }
}

// Mock implementation for testing
class MockPaymentGateway implements PaymentGateway {
    public processedPayments: Array<{ amount: number, token: string }> = [];

    async processPayment(amount: number, token: string): Promise<PaymentResult> {
        this.processedPayments.push({amount, token});
        return {success: true, transactionId: `mock-${Date.now()}`};
    }

    async refund(transactionId: string): Promise<void> {
        // Mock implementation
    }
}
```

## Testing Strategy

### Test Pyramid

Follow the test pyramid principle:

- **Unit Tests (70-80%)**: Test individual classes and functions in isolation
- **Integration Tests (15-25%)**: Test interactions between components
- **End-to-End Tests (5-10%)**: Test complete user flows

### Unit Tests

Test business logic in isolation using in-memory implementations:

```typescript
describe('OrderService', () => {
    let orderService: OrderService;
    let orderRepository: InMemoryOrderRepository;
    let paymentGateway: MockPaymentGateway;

    beforeEach(() => {
        orderRepository = new InMemoryOrderRepository();
        paymentGateway = new MockPaymentGateway();
        orderService = new OrderService(orderRepository, paymentGateway);
    });

    it('should create and save a new order', async () => {
        const order = await orderService.createOrder('customer-123', [
            {productId: 'prod-1', quantity: 2, price: 10.00}
        ]);

        expect(order.id).toBeDefined();
        expect(order.total).toBe(20.00);

        const savedOrder = await orderRepository.findById(order.id);
        expect(savedOrder).toEqual(order);
    });

    it('should process payment for an order', async () => {
        const order = await orderService.createOrder('customer-123', [
            {productId: 'prod-1', quantity: 1, price: 50.00}
        ]);

        await orderService.processPayment(order.id, 'token-123');

        expect(paymentGateway.processedPayments).toHaveLength(1);
        expect(paymentGateway.processedPayments[0].amount).toBe(50.00);
    });
});
```

### Integration Tests

Test database interactions and external service integrations:

```typescript
describe('PostgresOrderRepository', () => {
    let repository: PostgresOrderRepository;
    let db: DatabaseConnection;

    beforeAll(async () => {
        db = await createTestDatabase();
        repository = new PostgresOrderRepository(db);
    });

    afterAll(async () => {
        await db.close();
    });

    beforeEach(async () => {
        await db.query('TRUNCATE TABLE orders');
    });

    it('should save and retrieve an order', async () => {
        const order = new Order('order-1', 'customer-1', 100.00);
        await repository.save(order);

        const retrieved = await repository.findById('order-1');
        expect(retrieved).toEqual(order);
    });
});
```

### End-to-End Tests

Test complete API flows without external dependencies:

```typescript
describe('Order API', () => {
    let app: Application;
    let orderRepository: InMemoryOrderRepository;

    beforeAll(() => {
        orderRepository = new InMemoryOrderRepository();
        const paymentGateway = new MockPaymentGateway();
        const orderService = new OrderService(orderRepository, paymentGateway);
        app = createApp(orderService);
    });

    it('should create an order via POST /orders', async () => {
        const response = await request(app)
            .post('/orders')
            .send({
                customerId: 'customer-123',
                items: [{productId: 'prod-1', quantity: 2, price: 10.00}]
            });

        expect(response.status).toBe(201);
        expect(response.body.id).toBeDefined();
        expect(response.body.total).toBe(20.00);
    });
});
```

### Testing Without External Dependencies

Your application should be fully testable without:

- Real databases (use in-memory implementations)
- External APIs (use mock implementations)
- File system (use in-memory storage)
- Network calls (use dependency injection)

## Dependency Injection

Use constructor injection for testability:

```typescript
class OrderService {
    constructor(
        private orderRepository: IOrderRepository,
        private paymentGateway: IPaymentGateway,
        private emailService: IEmailService
    ) {
    }

    async createOrder(customerId: string, items: OrderItem[]): Promise<Order> {
        // Business logic here
    }
}

// Production
const orderService = new OrderService(
    new PostgresOrderRepository(db),
    new StripePaymentGateway(stripe),
    new SendGridEmailService(sendgrid)
);

// Testing
const orderService = new OrderService(
    new InMemoryOrderRepository(),
    new MockPaymentGateway(),
    new MockEmailService()
);
```

## Running the Application

### Simple Commands

Provide clear, simple commands to run the system:

```json
{
  "scripts": {
    "dev": "ts-node-dev src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest",
    "test:unit": "jest --testPathPattern=unit",
    "test:integration": "jest --testPathPattern=integration",
    "test:e2e": "jest --testPathPattern=e2e",
    "test:watch": "jest --watch",
    "lint": "eslint src/**/*.ts",
    "typecheck": "tsc --noEmit"
  }
}
```

### Environment Configuration

Use environment variables with sensible defaults:

```typescript
// src/infrastructure/config/environment.ts
export const config = {
    port: parseInt(process.env.PORT || '3000'),
    database: {
        host: process.env.DB_HOST || 'localhost',
        port: parseInt(process.env.DB_PORT || '5432'),
        name: process.env.DB_NAME || 'myapp',
        user: process.env.DB_USER || 'postgres',
        password: process.env.DB_PASSWORD || ''
    },
    nodeEnv: process.env.NODE_ENV || 'development'
};
```

## Code Organization Best Practices

### Keep Files Focused

- One class per file
- File name matches class name
- Group related types in domain files

### Use Barrel Exports

```typescript
// src/orders/index.ts
export * from './domain/Order';
export * from './services/OrderService';
export * from './repositories/IOrderRepository';

// Usage
import {Order, OrderService, IOrderRepository} from './orders';
```

### Avoid Circular Dependencies

- Domain models should not import from services or repositories
- Services can import from domain and repositories
- Controllers/API layer can import from services and domain

## Type Safety

Leverage TypeScript's type system:

```typescript
// Use strict mode
// tsconfig.json
{
    "compilerOptions"
:
    {
        "strict"
    :
        true,
            "noImplicitAny"
    :
        true,
            "strictNullChecks"
    :
        true,
            "strictFunctionTypes"
    :
        true
    }
}

// Define clear types
type OrderStatus = 'pending' | 'paid' | 'shipped' | 'delivered';

interface CreateOrderRequest {
    customerId: string;
    items: OrderItem[];
}

// Use Result types for error handling
type Result<T, E = Error> =
    | { success: true; value: T }
    | { success: false; error: E };
```

## Summary

- Use TypeScript with Node.js, avoid Express
- Follow SOLID principles, especially Single Responsibility
- Organize code by domain, not technical layers
- Isolate databases behind repository interfaces
- Isolate external systems behind domain interfaces
- Use in-memory implementations for testing
- Write lots of unit tests, fewer integration tests, minimal E2E tests
- Make the system fully testable without external dependencies
- Use dependency injection via constructors
- Provide simple commands to run and test the system
