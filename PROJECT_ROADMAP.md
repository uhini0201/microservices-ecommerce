# Microservices Project - Development Roadmap

**Last Updated**: November 30, 2025  
**Status**: Phase 1 Complete ✅

---

## Completed Features ✅

### Phase 1: Core Services & Infrastructure
- ✅ **Order Service** (Port 8082)
  - CRUD operations for orders
  - Kafka producer for `order-created` events
  - PostgreSQL integration
  - Docker deployment

- ✅ **Product Service** (Port 8083)
  - Full CRUD operations (Create, Read, Update, Delete)
  - Kafka producer for `product-created`, `product-updated`, `product-deleted` events
  - Stock management (basic)
  - PostgreSQL integration
  - Docker deployment

- ✅ **Notification Service** (Port 8084)
  - Kafka consumer for all order/product events
  - Real-time Server-Sent Events (SSE) streaming
  - Notification history storage
  - REST API for retrieving notifications
  - Beautiful browser test page (test-sse.html)
  - Docker deployment

- ✅ **Infrastructure**
  - Docker Compose configuration for all services
  - Apache Kafka + Zookeeper for event streaming
  - PostgreSQL for data persistence
  - Multi-profile configuration (local, docker)
  - Complete testing checklist

- ✅ **Documentation**
  - Service READMEs with troubleshooting guides
  - Docker test results documentation
  - Comprehensive testing checklist
  - Known issues and fixes documented

---

## Priority Roadmap (Ordered by Implementation Sequence)

### 🎯 Priority 1: Service Integration & Business Logic

#### 1.1 Wire product-service → order-service ✅ **COMPLETED**
**Complexity**: Medium  
**Time Estimate**: 2-3 hours (Actual: 2.5 hours)  
**Dependencies**: None (uses existing services)  
**Completed**: November 30, 2024

**Objective**: Make order-service validate products before creating orders

**What We'll Build**:
- Order service calls product service via REST API
- Validate product exists before creating order
- Fetch actual product price (don't trust client input)
- Check product stock availability
- Calculate order total based on product price
- Handle product-service downtime gracefully

**Technical Details**:
- Add RestTemplate/WebClient to order-service
- Implement synchronous HTTP calls to product-service
- Add circuit breaker pattern (Resilience4j) for fault tolerance
- Error handling: ProductNotFoundException, OutOfStockException
- Update Order entity: add `productId`, `productName`, `quantity`, `totalAmount`
- Validation: Ensure product exists and has sufficient stock

**API Changes**:
```json
// New order creation request
POST /orders
{
  "customer": "john",
  "productId": 5,
  "quantity": 2
}

// Response includes calculated details
{
  "id": 1,
  "customer": "john",
  "productId": 5,
  "productName": "Laptop",
  "quantity": 2,
  "unitPrice": 1299.99,
  "totalAmount": 2599.98,
  "status": "CREATED",
  "createdAt": "2025-11-30T10:00:00Z"
}
```

**Testing**:
- Order with valid product → Success
- Order with non-existent product → 404 error
- Order with insufficient stock → 400 error
- Product service down → Graceful degradation with error message

**Benefits**:
- ✅ Data integrity (orders reference real products)
- ✅ Price consistency (server-side calculation)
- ✅ Stock awareness (prevent overselling)
- ✅ Foundation for inventory service

---

#### 1.2 Inventory Service 📦 ✅ **COMPLETED**
**Complexity**: Medium-High  
**Time Estimate**: 3-4 hours (Actual: 3 hours)  
**Dependencies**: Requires 1.1 (wired services)  
**Completed**: November 30, 2024  
**Documentation**: See INVENTORY_SERVICE_COMPLETED.md

**Objective**: Separate stock management from product-service with reservation logic

**What We'll Build**:
- New microservice for inventory management
- Reserve stock when order created (prevent overselling)
- Release stock when order cancelled/failed
- Track inventory across multiple warehouses (optional)
- Low stock alerts via Kafka

**Database Schema**:
```sql
-- inventory_items table
id, product_id, warehouse_id, available_stock, reserved_stock, total_stock, created_at, updated_at

-- inventory_reservations table
id, product_id, order_id, quantity, status (RESERVED/RELEASED/EXPIRED), reserved_at, expires_at
```

**Kafka Events**:
- Consumes: `order-created`, `order-cancelled`, `order-completed`, `order-failed`
- Produces: `stock-reserved`, `stock-released`, `low-stock-alert`, `stock-updated`

**API Endpoints**:
- `POST /inventory/reserve` - Reserve stock for order
- `POST /inventory/release` - Release reserved stock
- `GET /inventory/product/{productId}` - Get inventory details
- `PUT /inventory/restock` - Add stock (admin)
- `GET /inventory/low-stock` - Get products with low stock

**Business Rules**:
- Stock reservation expires after 15 minutes if order not completed
- Low stock alert when available < 10% of total
- Support multiple warehouses (location-based fulfillment)
- FIFO reservation release on cancellation

**Integration Flow**:
1. Order service creates order → Calls inventory service to reserve stock
2. If reservation succeeds → Order confirmed
3. If reservation fails → Order rejected with "Out of Stock"
4. On order cancellation → Release reserved stock
5. On order completion → Decrease total stock (items shipped)

**Testing**:
- Reserve stock successfully
- Reserve fails (insufficient stock)
- Concurrent reservations (race condition handling)
- Reservation expiration (automatic release after timeout)
- Low stock alerts triggered

**Benefits**:
- ✅ Prevent overselling (race condition handling)
- ✅ Separation of concerns (inventory vs product catalog)
- ✅ Support for complex inventory scenarios (warehouses, backordering)
- ✅ Audit trail for all stock movements

---

### 🔐 Priority 2: Security & Authentication

#### 2.1 Auth Service (JWT) 🔑 ⚡ **NEXT UP**
**Complexity**: High  
**Time Estimate**: 4-5 hours  
**Dependencies**: None (independent service)

**Objective**: Secure all microservices with JWT-based authentication

**What We'll Build**:
- User registration and login
- JWT token generation and validation
- Role-based access control (ADMIN, USER, GUEST)
- Token refresh mechanism
- Spring Security integration for all services

**Database Schema**:
```sql
-- users table
id, username, email, password_hash, role, enabled, created_at, updated_at

-- refresh_tokens table
id, user_id, token, expires_at, created_at
```

**API Endpoints**:
- `POST /auth/register` - User registration
- `POST /auth/login` - User login (returns JWT + refresh token)
- `POST /auth/refresh` - Refresh expired JWT
- `POST /auth/logout` - Invalidate tokens
- `GET /auth/validate` - Validate JWT token (for other services)
- `GET /auth/me` - Get current user info

**Security Rules**:
- **Product Service**:
  - GET /products → Public (no auth)
  - POST/PUT/DELETE /products → ADMIN only
- **Order Service**:
  - POST /orders → Authenticated users (own orders only)
  - GET /orders/{id} → Owner or ADMIN
  - GET /orders → ADMIN only (all orders)
- **Inventory Service**:
  - GET /inventory → ADMIN only
  - POST /inventory/reserve → System (internal service calls)
- **Notification Service**:
  - All endpoints → Authenticated users

**JWT Claims**:
```json
{
  "sub": "user123",
  "username": "john_doe",
  "role": "USER",
  "email": "john@example.com",
  "iat": 1701350400,
  "exp": 1701354000
}
```

**Integration**:
- All services add Spring Security dependency
- Services validate JWT on each request (via auth-service or shared secret)
- Gateway intercepts requests and adds user context

**Testing**:
- Register new user
- Login with valid credentials
- Login with invalid credentials → 401
- Access protected endpoint without token → 403
- Access protected endpoint with valid token → Success
- Access protected endpoint with expired token → 401
- Token refresh flow
- Role-based access control

**Benefits**:
- ✅ Secure all endpoints
- ✅ User authentication and authorization
- ✅ Prevent unauthorized access
- ✅ Audit trail (who did what)

---

### 🎨 Priority 3: User Interface

#### 3.1 Frontend (React) 💻
**Complexity**: High  
**Time Estimate**: 6-8 hours  
**Dependencies**: Auth service recommended (but not required)

**Objective**: Build a modern web interface for the microservices

**What We'll Build**:

**Pages**:
1. **Product Catalog** (`/products`)
   - Grid/List view of all products
   - Search and filter (by name, price range, stock)
   - Sort (price, name, date)
   - Product details modal
   - Add to cart (if cart feature added)

2. **Product Management** (`/admin/products`) - ADMIN only
   - Create new product form
   - Edit existing product
   - Delete product (with confirmation)
   - Bulk actions (import CSV, export)

3. **Order Management** (`/orders`)
   - Create new order form (select product, quantity)
   - Order history (user's orders)
   - Order details with status tracking

4. **Admin Dashboard** (`/admin/orders`) - ADMIN only
   - All orders list
   - Order status management
   - Analytics (total orders, revenue, etc.)

5. **Real-Time Notifications** (sidebar/toast)
   - SSE connection to notification-service
   - Live updates for new products, orders, stock changes
   - Toast notifications with color coding
   - Notification history panel

6. **Login/Register** (`/login`, `/register`)
   - User authentication forms
   - JWT token management
   - Protected route handling

**Tech Stack**:
- React 18 with TypeScript
- React Router for navigation
- Axios for HTTP requests
- EventSource API for SSE
- Tailwind CSS or Material-UI for styling
- React Query for state management
- Zustand/Redux for global state

**Features**:
- Responsive design (mobile-friendly)
- Loading states and skeletons
- Error handling with user-friendly messages
- Form validation
- Real-time updates (SSE)
- Dark mode toggle
- Pagination for large lists

**Directory Structure**:
```
frontend/
├── public/
├── src/
│   ├── components/
│   │   ├── products/
│   │   ├── orders/
│   │   ├── notifications/
│   │   ├── auth/
│   │   └── common/
│   ├── pages/
│   ├── services/
│   │   ├── api.ts
│   │   ├── authService.ts
│   │   ├── sseService.ts
│   │   └── productService.ts
│   ├── hooks/
│   ├── types/
│   ├── utils/
│   └── App.tsx
├── package.json
├── tsconfig.json
└── vite.config.ts (or webpack config)
```

**Testing**:
- Component unit tests (Jest + React Testing Library)
- Integration tests for flows
- E2E tests (Cypress/Playwright)
- Accessibility testing

**Benefits**:
- ✅ User-friendly interface
- ✅ Real-time updates
- ✅ Complete product/order management
- ✅ Professional presentation of backend services

---

### 🚀 Priority 4: DevOps & Automation

#### 4.1 CI/CD Pipeline (GitHub Actions) ⚙️
**Complexity**: Medium  
**Time Estimate**: 3-4 hours  
**Dependencies**: None (enhances existing project)

**Objective**: Automate build, test, and deployment processes

**What We'll Build**:

**Workflows**:

1. **Build & Test** (`.github/workflows/build.yml`)
   - Trigger: On push to any branch, PR creation
   - Steps:
     - Checkout code
     - Set up JDK 17
     - Cache Maven dependencies
     - Build all services (`mvn clean package`)
     - Run unit tests
     - Run integration tests
     - Upload test reports
     - SonarQube code analysis (optional)

2. **Docker Build & Push** (`.github/workflows/docker.yml`)
   - Trigger: On push to `main` branch, manual trigger
   - Steps:
     - Build Docker images for all services
     - Tag images with version (git SHA + latest)
     - Push to Docker Hub / GitHub Container Registry
     - Scan images for vulnerabilities (Trivy)

3. **Deploy to Staging** (`.github/workflows/deploy-staging.yml`)
   - Trigger: On successful merge to `main`
   - Steps:
     - Pull latest Docker images
     - Run database migrations
     - Deploy to staging environment (docker-compose)
     - Run smoke tests
     - Notify team (Slack/Discord webhook)

4. **Deploy to Production** (`.github/workflows/deploy-prod.yml`)
   - Trigger: Manual approval + tag creation
   - Steps:
     - Same as staging but with additional checks
     - Blue-green deployment
     - Automatic rollback on failure

**Additional Workflows**:
- **Dependency Update** - Dependabot for automated dependency PRs
- **Security Scan** - Weekly OWASP dependency check
- **Performance Test** - Nightly load tests with JMeter
- **Documentation** - Auto-generate and deploy API docs

**Secrets & Configuration**:
```yaml
# GitHub Secrets needed:
DOCKER_USERNAME
DOCKER_PASSWORD
SONAR_TOKEN
DATABASE_URL
SLACK_WEBHOOK_URL
```

**Benefits**:
- ✅ Automated testing (catch bugs early)
- ✅ Consistent builds
- ✅ Faster deployments
- ✅ Version tracking
- ✅ Rollback capability

---

## Advanced Features (Future Enhancements)

### Phase 2: Scalability & Resilience
- **API Gateway** (Spring Cloud Gateway) - Single entry point, routing, rate limiting
- **Service Discovery** (Eureka) - Dynamic service registration and discovery
- **Config Server** (Spring Cloud Config) - Centralized configuration management
- **Circuit Breaker** (Resilience4j) - Fault tolerance and graceful degradation
- **Distributed Tracing** (Zipkin/Jaeger) - Request tracing across services
- **Caching** (Redis) - Improve performance for frequent reads

### Phase 3: Observability & Monitoring
- **Centralized Logging** (ELK Stack) - Elasticsearch, Logstash, Kibana
- **Metrics & Monitoring** (Prometheus + Grafana) - Dashboards and alerts
- **Health Checks** - Liveness and readiness probes for Kubernetes
- **APM** (Application Performance Monitoring) - New Relic / DataDog

### Phase 4: Advanced Business Features
- **Payment Service** - Stripe/PayPal integration for payment processing
- **Shipping Service** - Track order fulfillment and shipping
- **Analytics Service** - Business intelligence, reports, data warehouse
- **Email Service** - Transactional emails (order confirmation, shipping updates)
- **Search Service** (Elasticsearch) - Full-text search for products
- **Recommendation Service** - ML-based product recommendations

### Phase 5: Enterprise Features
- **Multi-tenancy** - Support multiple organizations/tenants
- **Audit Logging** - Complete audit trail for compliance
- **Data Privacy** (GDPR) - User data export, deletion, consent management
- **Rate Limiting** - API throttling and quota management
- **Webhooks** - Allow external systems to subscribe to events
- **GraphQL API** - Alternative to REST for flexible queries

---

## Technical Debt & Improvements

### High Priority
- [ ] Add comprehensive unit tests (target: 80% coverage)
- [ ] Add integration tests with TestContainers
- [ ] Implement proper exception handling across all services
- [ ] Add API documentation (Swagger/OpenAPI)
- [ ] Implement health checks for all services
- [ ] Add database migrations (Flyway/Liquibase)

### Medium Priority
- [ ] Optimize Docker images (multi-stage builds, smaller base images)
- [ ] Add request validation (Bean Validation)
- [ ] Implement pagination for all list endpoints
- [ ] Add CORS configuration
- [ ] Standardize error responses across services
- [ ] Add request logging and correlation IDs

### Low Priority
- [ ] Add Docker resource limits in docker-compose
- [ ] Create Kubernetes manifests
- [ ] Add API versioning (v1, v2)
- [ ] Implement soft delete for entities
- [ ] Add database connection pooling configuration
- [ ] Create load testing scripts

---

## Implementation Order (Recommended)

1. ✅ **Core Services** (order, product) - COMPLETE
2. ✅ **Notification Service + SSE** - COMPLETE
3. ✅ **Docker Compose Setup** - COMPLETE
4. 🎯 **Wire Services Together** - NEXT (2-3 hours)
5. **Inventory Service** (3-4 hours)
6. **Auth Service** (4-5 hours)
7. **Frontend (React)** (6-8 hours)
8. **CI/CD Pipeline** (3-4 hours)
9. **API Gateway** (2-3 hours)
10. **Advanced Features** (as needed)

**Total Time for Remaining Priority Items**: ~20-25 hours

---

## Success Metrics

### Phase 1 ✅
- [x] 3 working microservices
- [x] Event-driven architecture with Kafka
- [x] Real-time notifications via SSE
- [x] Docker deployment
- [x] Zero critical bugs

### Phase 2 (Current Sprint)
- [ ] Service-to-service communication working
- [ ] Stock management implemented
- [ ] All endpoints secured with JWT
- [ ] Working frontend application
- [ ] Automated CI/CD pipeline

### Phase 3 (Future)
- [ ] 95%+ uptime
- [ ] <200ms average response time
- [ ] Handle 1000+ concurrent users
- [ ] Full test coverage
- [ ] Production deployment on cloud

---

## Resources & Documentation

### Current Documentation
- ✅ Service READMEs with troubleshooting
- ✅ Docker test results
- ✅ Testing checklist
- ✅ Known issues and fixes

### Needed Documentation
- [ ] Architecture diagrams (C4 model)
- [ ] API documentation (Swagger)
- [ ] Deployment guide
- [ ] Contributing guide
- [ ] User manual

---

## Notes & Decisions

### Technology Choices
- **Spring Boot 3.2.6**: Modern framework with excellent ecosystem
- **PostgreSQL**: Reliable RDBMS, good for structured data
- **Apache Kafka**: Industry-standard for event streaming
- **Docker**: Containerization for consistent environments
- **SSE vs WebSocket**: SSE chosen for simplicity (server-to-client only)

### Architecture Decisions
- **Event-Driven**: Loose coupling, scalability, audit trail
- **Microservices**: Independent deployment, technology flexibility
- **Shared Database**: Simplicity for MVP (will refactor to separate DBs in Phase 3)

### Lessons Learned
- PowerShell argument escaping requires careful quoting
- JsonDeserializer configuration critical for Kafka consumers
- Spring Boot startup time increases with Kafka consumers (30-40s normal)
- SSE connections require long-lived HTTP (works great for real-time updates)

---

**Last Updated**: November 30, 2025  
**Next Review**: After completing Priority 1 items
