# Microservices E-commerce Platform

This is a comprehensive microservices-based e-commerce platform built with Spring Boot and React, demonstrating modern distributed system architecture patterns.

## 🚀 Quick Start

### One-Command Startup

**Windows (PowerShell):**
```powershell
.\start.ps1
```

**Linux/Mac:**
```bash
chmod +x start.sh
./start.sh
```

This will:
1. ✅ Start all Docker microservices (API Gateway + 6 services)
2. ✅ Wait for services to initialize
3. ✅ Perform health checks
4. ✅ Start React frontend
5. ✅ Open browser at `http://localhost:3000`

### Shutdown

**Windows:**
```powershell
.\stop.ps1
```

**Linux/Mac:**
```bash
./stop.sh
```

## 📋 Prerequisites

- **Docker Desktop** (running)
- **Node.js** 16+ and npm
- **Java** 17+ (for development only)
- **Maven** 3.8+ (for development only)

## 🏗️ Architecture

### Microservices
- **API Gateway** (8080) - Spring Cloud Gateway with JWT authentication
- **Auth Service** (8086) - User authentication and JWT token management
- **User Service** (8087) - User profile management
- **Product Service** (8083) - Product catalog management
- **Order Service** (8082) - Order processing
- **Inventory Service** (8085) - Stock management
- **Notification Service** (8084) - Event notifications via SSE

### Infrastructure
- **PostgreSQL** (5432) - Primary database for all services
- **Apache Kafka** - Event-driven messaging
- **Redis** - Rate limiting and caching
- **Zookeeper** - Kafka coordination

### Frontend
- **React 18** with TypeScript
- **Material-UI 7** for components
- **React Router 7** for navigation
- **Axios** for API calls
- **Context API** for state management

## 🎯 Features

### For Users
- ✅ User registration and authentication (JWT-based)
- ✅ Browse product catalog with search and filtering
- ✅ Shopping cart with persistent storage
- ✅ Order placement and history
- ✅ User profile management
- ✅ Multi-language support (preferences)

### Technical Features
- ✅ API Gateway with circuit breakers
- ✅ JWT authentication and authorization
- ✅ Rate limiting (10-20 req/sec per service)
- ✅ Event-driven architecture with Kafka
- ✅ Service-to-service communication
- ✅ CORS configuration for frontend
- ✅ Health checks and monitoring
- ✅ Docker containerization

## 📝 API Endpoints

### Authentication
```
POST   /api/auth/register        - Register new user
POST   /api/auth/login           - Login user
POST   /api/auth/refresh-token   - Refresh access token
POST   /api/auth/logout          - Logout user
```

### Products
```
GET    /api/products             - Get all products
GET    /api/products/{id}        - Get product by ID
POST   /api/products             - Create product (ADMIN)
PUT    /api/products/{id}        - Update product (ADMIN)
DELETE /api/products/{id}        - Delete product (ADMIN)
```

### Orders
```
POST   /api/orders               - Create order
GET    /api/orders/{id}          - Get order by ID
GET    /api/orders/user          - Get user's orders
```

### User Profile
```
GET    /api/users/me             - Get current user profile
PUT    /api/users/me             - Update user profile
GET    /api/users/{username}     - Get user by username
```

### Inventory
```
GET    /api/inventory            - Get all inventory
GET    /api/inventory/{id}       - Get inventory by ID
POST   /api/inventory            - Create inventory
PUT    /api/inventory/{id}       - Update inventory
```

## 🔧 Manual Setup (Alternative)

### Backend Services

1. **Start infrastructure:**
   ```bash
   docker-compose up -d postgres kafka redis zookeeper
   ```

2. **Build all services:**
   ```bash
   cd services
   mvn clean package -DskipTests
   ```

3. **Start all services:**
   ```bash
   docker-compose up -d
   ```

### Frontend

1. **Install dependencies:**
   ```bash
   cd frontend
   npm install
   ```

2. **Start development server:**
   ```bash
   npm start
   ```

## 🧪 Testing

### Backend Testing
66 integration tests covering:
- Authentication flows
- Product CRUD operations
- Order creation and retrieval
- Inventory management
- Service-to-service communication
- API Gateway routing and authentication

See `INTEGRATION_COMPLETED.md` and `TESTING_CHECKLIST.md` for details.

### Frontend Testing
```bash
cd frontend
npm test
```

## 📚 Documentation

- **[Build and Deploy Guide](BUILD_AND_DEPLOY.md)** - Complete build, deploy, and troubleshooting reference
- **[Integration Testing](INTEGRATION_COMPLETED.md)** - Complete testing documentation
- **[Project Roadmap](PROJECT_ROADMAP.md)** - Development phases and priorities
- **[Testing Checklist](TESTING_CHECKLIST.md)** - Testing scenarios
- **[Docker Testing](DOCKER_TEST_RESULTS.md)** - Docker validation results

## 🛠️ Development

### Backend Development
Each service is a Spring Boot 3.2.6 application with:
- RESTful APIs
- PostgreSQL integration
- Kafka event publishing
- JWT authentication
- Docker support

### Frontend Development
React TypeScript application with:
- Type-safe API client
- JWT token management
- Protected routes
- Material-UI components
- Responsive design

## 🐳 Docker Commands

### View running containers:
```bash
docker ps
```

### View logs:
```bash
docker logs <container-name>
docker-compose logs -f <service-name>
```

### Restart a service:
```bash
docker-compose restart <service-name>
```

### Stop all services:
```bash
docker-compose down
```

### Remove all containers and volumes:
```bash
docker-compose down -v
```

## 🔐 Default Credentials

**Admin User:**
- Username: `admin`
- Password: `admin123`

**Test User:**
- Username: `testuser`
- Password: `test123`

## 🌐 Service URLs

- **Frontend:** http://localhost:3000
- **API Gateway:** http://localhost:8080
- **Auth Service:** http://localhost:8086
- **User Service:** http://localhost:8087
- **Product Service:** http://localhost:8083
- **Order Service:** http://localhost:8082
- **Inventory Service:** http://localhost:8085
- **Notification Service:** http://localhost:8084

## 📊 Tech Stack

### Backend
- Spring Boot 3.2.6
- Spring Cloud Gateway 2023.0.1
- Spring Security with JWT
- PostgreSQL 14
- Apache Kafka
- Redis
- Docker & Docker Compose

### Frontend
- React 18
- TypeScript 4.9
- Material-UI 7
- React Router 7
- Axios 1.13
- Context API

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is for educational purposes.

## 👥 Authors

Developed as a comprehensive demonstration of microservices architecture patterns.
