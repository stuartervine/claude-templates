# TypeScript Web Development Principles

## Core Philosophy

Build web applications using TypeScript, React, and modern tooling with a focus on domain-driven organization, testable service layers, and simple dependency injection through props. Avoid over-engineered state management solutions.

## Build Tools

### Preferred Tools
- **esbuild** - Fast, simple bundler and minifier
- **TypeScript** - For type safety and better developer experience
- **npm scripts** - Simple, transparent build commands
- **vite.dev** - is ok

### Avoid
- **webpack** - Too complicated and slow
- **create-react-app** - Opinionated and hides configuration
- **next.js** - Over-engineered for most use cases

## Framework and Libraries

### Use
- **React** - UI library
- **React Router** - Client-side routing
- **styled-components** - Component-scoped styling
- **jest** - Testing framework

### Avoid
- **Redux** - Overly complex state management
- **Context API / Context Providers** - Creates tight coupling and makes testing harder
- **State management libraries** - Most apps don't need them

## State Management Philosophy

### Keep State Local and Minimal

Components should only hold state they absolutely need:

```typescript
// Good: Minimal local state
const LoginForm: React.FC<{ authService: AuthService }> = ({ authService }) => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState<string | null>(null);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            await authService.login(email, password);
        } catch (err) {
            setError(err.message);
        }
    };

    return (
        <form onSubmit={handleSubmit}>
            {/* form fields */}
        </form>
    );
};

// Bad: Unnecessary state management
const LoginForm: React.FC = () => {
    const dispatch = useDispatch();
    const { email, password, error } = useSelector(state => state.login);
    // Too much ceremony for simple form state
};
```

### Use Custom Hooks for Shared Stateful Logic

Extract reusable stateful behavior into custom hooks:

```typescript
// Custom hook for data fetching
function useOrders(orderService: OrderService) {
    const [orders, setOrders] = useState<Order[]>([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<Error | null>(null);

    const fetchOrders = async () => {
        setLoading(true);
        try {
            const data = await orderService.getOrders();
            setOrders(data);
            setError(null);
        } catch (err) {
            setError(err as Error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchOrders();
    }, []);

    return { orders, loading, error, refetch: fetchOrders };
}

// Usage in component
const OrderList: React.FC<{ orderService: OrderService }> = ({ orderService }) => {
    const { orders, loading, error, refetch } = useOrders(orderService);

    if (loading) return <Spinner />;
    if (error) return <ErrorMessage error={error} />;

    return (
        <div>
            {orders.map(order => <OrderCard key={order.id} order={order} />)}
            <button onClick={refetch}>Refresh</button>
        </div>
    );
};
```

## Dependency Injection via Props

Inject dependencies through JSX element properties instead of using Context or global state:

```typescript
// Service interfaces
interface OrderService {
    getOrders(): Promise<Order[]>;
    createOrder(order: CreateOrderRequest): Promise<Order>;
}

interface PaymentService {
    processPayment(orderId: string, paymentDetails: PaymentDetails): Promise<void>;
}

// Component with injected dependencies
interface CheckoutPageProps {
    orderService: OrderService;
    paymentService: PaymentService;
}

const CheckoutPage: React.FC<CheckoutPageProps> = ({ orderService, paymentService }) => {
    const [cart, setCart] = useState<CartItem[]>([]);

    const handleCheckout = async () => {
        const order = await orderService.createOrder({ items: cart });
        await paymentService.processPayment(order.id, paymentDetails);
    };

    return (
        <div>
            <CartSummary items={cart} />
            <CheckoutButton onClick={handleCheckout} />
        </div>
    );
};

// Root application wires up real implementations
const App: React.FC = () => {
    const orderService = new HttpOrderService();
    const paymentService = new StripePaymentService();

    return (
        <Router>
            <Routes>
                <Route
                    path="/checkout"
                    element={<CheckoutPage
                        orderService={orderService}
                        paymentService={paymentService}
                    />}
                />
            </Routes>
        </Router>
    );
};
```

## Domain-Driven Folder Structure

Organize code by domain features, not technical layers:

```
src/
├── orders/
│   ├── components/
│   │   ├── OrderCard/
│   │   │   ├── OrderCard.tsx
│   │   │   └── OrderCard.styles.ts
│   │   └── OrderList/
│   │       ├── OrderList.tsx
│   │       └── OrderList.styles.ts
│   ├── services/
│   │   ├── OrderService.ts
│   │   ├── HttpOrderService.ts
│   │   └── MockOrderService.ts
│   ├── hooks/
│   │   └── useOrders.ts
│   ├── types/
│   │   ├── Order.ts
│   │   ├── OrderStatus.ts
│   │   └── CreateOrderRequest.ts
│   ├── pages/
│   │   ├── OrderListPage.tsx
│   │   └── OrderDetailPage.tsx
│   └── __tests__/
│       ├── OrderService.test.ts
│       └── HttpOrderService.test.ts
├── checkout/
│   ├── components/
│   ├── services/
│   ├── hooks/
│   ├── types/
│   └── pages/
├── shared/
│   ├── components/
│   │   ├── Button/
│   │   ├── Input/
│   │   └── Card/
│   ├── hooks/
│   └── types/
└── App.tsx
```

### Feature Folder Guidelines

- **components/** - React components specific to this domain
- **services/** - API clients and business logic for this domain
- **hooks/** - Custom hooks for stateful behavior
- **types/** - TypeScript types and interfaces for this domain
- **pages/** - Top-level page components that compose other components
- **__tests__/** - Tests for services (NOT components)

## API Client Pattern

Create a dedicated API client for each major domain:

```typescript
// orders/services/OrderService.ts
interface OrderService {
    getOrders(): Promise<Order[]>;
    getOrderById(id: string): Promise<Order>;
    createOrder(request: CreateOrderRequest): Promise<Order>;
    cancelOrder(id: string): Promise<void>;
}

// orders/services/HttpOrderService.ts
class HttpOrderService implements OrderService {
    constructor(private baseUrl: string) {}

    async getOrders(): Promise<Order[]> {
        const response = await fetch(`${this.baseUrl}/orders`);
        if (!response.ok) throw new Error('Failed to fetch orders');
        return response.json();
    }

    async getOrderById(id: string): Promise<Order> {
        const response = await fetch(`${this.baseUrl}/orders/${id}`);
        if (!response.ok) throw new Error('Failed to fetch order');
        return response.json();
    }

    async createOrder(request: CreateOrderRequest): Promise<Order> {
        const response = await fetch(`${this.baseUrl}/orders`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(request)
        });
        if (!response.ok) throw new Error('Failed to create order');
        return response.json();
    }

    async cancelOrder(id: string): Promise<void> {
        const response = await fetch(`${this.baseUrl}/orders/${id}/cancel`, {
            method: 'POST'
        });
        if (!response.ok) throw new Error('Failed to cancel order');
    }
}

// orders/services/MockOrderService.ts
class MockOrderService implements OrderService {
    private orders: Order[] = [];

    async getOrders(): Promise<Order[]> {
        return [...this.orders];
    }

    async getOrderById(id: string): Promise<Order> {
        const order = this.orders.find(o => o.id === id);
        if (!order) throw new Error('Order not found');
        return order;
    }

    async createOrder(request: CreateOrderRequest): Promise<Order> {
        const order: Order = {
            id: `order-${Date.now()}`,
            ...request,
            status: 'pending',
            createdAt: new Date()
        };
        this.orders.push(order);
        return order;
    }

    async cancelOrder(id: string): Promise<void> {
        const order = this.orders.find(o => o.id === id);
        if (order) order.status = 'cancelled';
    }
}
```

## Component Design

### Keep Components Concise

Components should be focused and do one thing well:

```typescript
// Good: Focused component
const OrderCard: React.FC<{ order: Order }> = ({ order }) => {
    return (
        <Card>
            <OrderHeader>Order #{order.id}</OrderHeader>
            <OrderStatus status={order.status} />
            <OrderTotal amount={order.total} />
        </Card>
    );
};

// Bad: Component doing too much
const OrderCard: React.FC<{ orderId: string; orderService: OrderService }> = ({ orderId, orderService }) => {
    const [order, setOrder] = useState<Order>();
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        // Fetching data
        // Formatting data
        // Handling errors
        // Too much responsibility
    }, [orderId]);

    return <div>{/* complex rendering logic */}</div>;
};
```

### Extract Larger Components

For complex components, create dedicated folders:

```
orders/components/OrderSummary/
├── OrderSummary.tsx
├── OrderSummary.styles.ts
├── OrderSummaryHeader.tsx
└── OrderSummaryItems.tsx
```

## Styling with styled-components

Use styled-components for component-scoped styling:

```typescript
// OrderCard.styles.ts
import styled from 'styled-components';

export const Card = styled.div`
    background: white;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 16px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
`;

export const OrderHeader = styled.h3`
    margin: 0 0 12px 0;
    font-size: 18px;
    font-weight: 600;
    color: #333;
`;

export const OrderTotal = styled.div<{ amount: number }>`
    font-size: 20px;
    font-weight: bold;
    color: ${props => props.amount > 100 ? '#e74c3c' : '#27ae60'};
`;

// OrderCard.tsx
import { Card, OrderHeader, OrderTotal } from './OrderCard.styles';

const OrderCard: React.FC<{ order: Order }> = ({ order }) => {
    return (
        <Card>
            <OrderHeader>Order #{order.id}</OrderHeader>
            <OrderTotal amount={order.total}>${order.total}</OrderTotal>
        </Card>
    );
};
```

## Shared Component Library

Extract reusable components into a shared library:

```
src/shared/components/
├── Button/
│   ├── Button.tsx
│   └── Button.styles.ts
├── Input/
│   ├── Input.tsx
│   └── Input.styles.ts
├── Card/
│   ├── Card.tsx
│   └── Card.styles.ts
└── Spinner/
    ├── Spinner.tsx
    └── Spinner.styles.ts
```

```typescript
// shared/components/Button/Button.tsx
import { StyledButton } from './Button.styles';

interface ButtonProps {
    variant?: 'primary' | 'secondary' | 'danger';
    onClick?: () => void;
    disabled?: boolean;
    children: React.ReactNode;
}

export const Button: React.FC<ButtonProps> = ({
    variant = 'primary',
    onClick,
    disabled,
    children
}) => {
    return (
        <StyledButton variant={variant} onClick={onClick} disabled={disabled}>
            {children}
        </StyledButton>
    );
};
```

## Testing Strategy

### Only Test Service Layers

Do NOT write tests for JSX components. Focus on testing service layers:

```typescript
// orders/__tests__/HttpOrderService.test.ts
describe('HttpOrderService', () => {
    let service: HttpOrderService;
    let fetchMock: jest.Mock;

    beforeEach(() => {
        fetchMock = jest.fn();
        global.fetch = fetchMock;
        service = new HttpOrderService('http://api.example.com');
    });

    it('should fetch orders successfully', async () => {
        const mockOrders: Order[] = [
            { id: '1', customerId: 'c1', total: 100, status: 'pending' }
        ];

        fetchMock.mockResolvedValue({
            ok: true,
            json: async () => mockOrders
        });

        const orders = await service.getOrders();

        expect(orders).toEqual(mockOrders);
        expect(fetchMock).toHaveBeenCalledWith('http://api.example.com/orders');
    });

    it('should throw error when fetch fails', async () => {
        fetchMock.mockResolvedValue({
            ok: false,
            status: 500
        });

        await expect(service.getOrders()).rejects.toThrow('Failed to fetch orders');
    });
});

// orders/__tests__/OrderService.test.ts
describe('OrderService business logic', () => {
    let orderService: MockOrderService;

    beforeEach(() => {
        orderService = new MockOrderService();
    });

    it('should create order with correct properties', async () => {
        const request: CreateOrderRequest = {
            customerId: 'customer-1',
            items: [{ productId: 'p1', quantity: 2, price: 50 }]
        };

        const order = await orderService.createOrder(request);

        expect(order.id).toBeDefined();
        expect(order.customerId).toBe('customer-1');
        expect(order.status).toBe('pending');
    });

    it('should cancel order', async () => {
        const order = await orderService.createOrder({
            customerId: 'c1',
            items: []
        });

        await orderService.cancelOrder(order.id);
        const cancelled = await orderService.getOrderById(order.id);

        expect(cancelled.status).toBe('cancelled');
    });
});
```

## Build Configuration

### Simple esbuild Setup

```javascript
// build.js
const esbuild = require('esbuild');

esbuild.build({
    entryPoints: ['src/index.tsx'],
    bundle: true,
    minify: process.env.NODE_ENV === 'production',
    sourcemap: true,
    outfile: 'dist/bundle.js',
    loader: {
        '.tsx': 'tsx',
        '.ts': 'ts'
    },
    define: {
        'process.env.NODE_ENV': `"${process.env.NODE_ENV || 'development'}"`
    }
}).catch(() => process.exit(1));
```

### Package.json Scripts

```json
{
  "scripts": {
    "dev": "esbuild src/index.tsx --bundle --outfile=dist/bundle.js --servedir=public --watch",
    "build": "NODE_ENV=production node build.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "lint": "eslint src/**/*.{ts,tsx}",
    "typecheck": "tsc --noEmit",
    "deploy": "npm run build && npm run deploy:target"
  }
}
```

## Deployment

### Simple Deployment Script

Provide an easy deployment command based on your target:

```json
{
  "scripts": {
    "deploy:s3": "aws s3 sync dist/ s3://your-bucket-name --delete",
    "deploy:netlify": "netlify deploy --prod --dir=dist",
    "deploy:vercel": "vercel --prod",
    "deploy": "npm run build && npm run deploy:s3"
  }
}
```

### Environment-Specific Configuration

```typescript
// src/config.ts
export const config = {
    apiBaseUrl: process.env.API_BASE_URL || 'http://localhost:3000',
    environment: process.env.NODE_ENV || 'development',
    enableAnalytics: process.env.ENABLE_ANALYTICS === 'true'
};
```

## Summary

- Use **esbuild** for fast, simple builds (avoid webpack)
- Use **React** and **React Router** (avoid Redux, Context API)
- Inject dependencies via **props**, not Context
- Keep component state **minimal and local**
- Use **custom hooks** for shared stateful logic
- Organize by **domain features**, not technical layers
- Extract **API clients** for each domain
- Use **styled-components** for styling
- Build a **shared component library** for reusable UI
- Only test **service layers**, not JSX components
- Keep build and deployment **simple** with clear commands
