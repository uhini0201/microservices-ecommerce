# Build and Deploy Guide

Complete reference for building, deploying, and managing the Microservices E-commerce Platform.

## 📋 Table of Contents
- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Build Commands](#build-commands)
- [Docker Commands](#docker-commands)
- [Development Commands](#development-commands)
- [Production Deployment](#production-deployment)
- [Troubleshooting](#troubleshooting)

---

## 🚀 Quick Start

### One-Command Startup (Recommended)

**Windows:**
```powershell
# Start all services
.\start.ps1

# Build and start all services
.\start.ps1 -Build

# Start only specific service
.\start.ps1 -Service auth

# Build and start specific service
.\start.ps1 -Build -Service product
```

**Linux/Mac:**
```bash
# Make scripts executable (first time only)
chmod +x start.sh build.sh

# Start all services
./start.sh

# Start with build (requires manual build first)
./build.sh && ./start.sh
```

**What it does:**
1. Starts all Docker microservices (or specific service)
2. Waits for services to initialize (45 seconds)
3. Performs health checks
4. Starts React frontend (if no specific service selected)
5. Opens browser at http://localhost:3000

### One-Command Build

**Windows:**
```powershell
# Build all backend services
.\build.ps1

# Build specific service
.\build.ps1 -Service auth

# Build frontend only
.\build.ps1 -Frontend

# Build everything (backend + frontend)
.\build.ps1 -All
```

**Linux/Mac:**
```bash
# Build all backend services
./build.sh

# Build specific service
./build.sh auth

# Build frontend only
./build.sh --frontend

# Build everything (backend + frontend)
./build.sh --all
```

### One-Command Shutdown

**Windows:**
```powershell
.\stop.ps1
```

**Linux/Mac:**
```bash
./stop.sh
```

---

## 📦 Prerequisites

### Required Software
```bash
# Check versions
docker --version          # Should be 20.10+
docker-compose --version  # Should be 2.0+
node --version           # Should be 16+
npm --version            # Should be 8+
java -version            # Should be 17+ (for development)
mvn --version            # Should be 3.8+ (for development)
```

### Start Docker Desktop
- **Windows:** Start Docker Desktop from Start Menu
- **Mac:** Start Docker Desktop from Applications
- **Linux:** `sudo systemctl start docker`

---

## 🔨 Build Commands

### Using Build Scripts (Recommended)

**Build all backend services:**

Windows:
```powershell
.\build.ps1
```

Linux/Mac:
```bash
./build.sh
```

**Build specific service:**

Windows:
```powershell
.\build.ps1 -Service auth          # Auth service
.\build.ps1 -Service user          # User service
.\build.ps1 -Service product       # Product service
.\build.ps1 -Service order         # Order service
.\build.ps1 -Service inventory     # Inventory service
.\build.ps1 -Service notification  # Notification service
```

Linux/Mac:
```bash
./build.sh auth          # Auth service
./build.sh user          # User service
./build.sh product       # Product service
./build.sh order         # Order service
./build.sh inventory     # Inventory service
./build.sh notification  # Notification service
```

**Build frontend:**

Windows:
```powershell
.\build.ps1 -Frontend
```

Linux/Mac:
```bash
./build.sh --frontend
```

**Build everything:**

Windows:
```powershell
.\build.ps1 -All
```

Linux/Mac:
```bash
./build.sh --all
```

### Manual Build Commands (Maven)

**From project root:**
```bash
cd services
mvn clean package -DskipTests
```

**Build specific service:**
```bash
cd services/auth-service
mvn clean package -DskipTests
```

**Build with tests:**
```bash
mvn clean package
```

**Clean all builds:**
```bash
mvn clean
```

### Build Individual Services

**Auth Service:**
```bash
cd services/auth-service
mvn clean package -DskipTests
```

**User Service:**
```bash
cd services/user-service
mvn clean package -DskipTests
```

**Product Service:**
```bash
cd services/product-service
mvn clean package -DskipTests
```

**Order Service:**
```bash
cd services/order-service
mvn clean package -DskipTests
```

**Inventory Service:**
```bash
cd services/inventory-service
mvn clean package -DskipTests
```

**Notification Service:**
```bash
cd services/notification-service
mvn clean package -DskipTests
```

**API Gateway:**
```bash
cd services/api-gateway
mvn clean package -DskipTests
```

---

## 🐳 Docker Commands

### Start All Services

**Start all containers (detached mode):**
```bash
docker-compose up -d
```

**Start all containers (with logs):**
```bash
docker-compose up
```

**Start specific service:**
```bash
docker-compose up -d auth-service
```

### Stop Services

**Stop all containers:**
```bash
docker-compose down
```

**Stop and remove volumes:**
```bash
docker-compose down -v
```

**Stop specific service:**
```bash
docker-compose stop auth-service
```

### View Container Status

**List running containers:**
```bash
docker ps
```

**List all containers (including stopped):**
```bash
docker ps -a
```

**Formatted view:**
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### View Logs

**View logs for all services:**
```bash
docker-compose logs
```

**Follow logs (real-time):**
```bash
docker-compose logs -f
```

**View logs for specific service:**
```bash
docker-compose logs -f auth-service
```

**View last 100 lines:**
```bash
docker-compose logs --tail=100 auth-service
```

**View logs from specific container:**
```bash
docker logs microservices-project-auth-service-1
```

### Restart Services

**Restart all services:**
```bash
docker-compose restart
```

**Restart specific service:**
```bash
docker-compose restart auth-service
```

### Rebuild Services

**Rebuild all images:**
```bash
docker-compose build
```

**Rebuild and restart:**
```bash
docker-compose up -d --build
```

**Rebuild specific service:**
```bash
docker-compose build auth-service
docker-compose up -d auth-service
```

### Execute Commands in Containers

**Access container shell:**
```bash
docker exec -it microservices-project-auth-service-1 /bin/bash
```

**Run command in container:**
```bash
docker exec microservices-project-postgres-1 psql -U postgres -d authdb -c "SELECT * FROM users;"
```

### Clean Up Docker

**Remove stopped containers:**
```bash
docker container prune
```

**Remove unused images:**
```bash
docker image prune
```

**Remove unused volumes:**
```bash
docker volume prune
```

**Remove everything unused:**
```bash
docker system prune -a
```

---

## 💻 Development Commands

### Backend Development

**Run service locally (without Docker):**
```bash
cd services/auth-service
mvn spring-boot:run
```

**Run with specific profile:**
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

**Run tests:**
```bash
mvn test
```

**Run specific test:**
```bash
mvn test -Dtest=AuthServiceTest
```

### Frontend Development

**Start dev server (with hot reload):**
```bash
cd frontend
npm start  # Takes 1-2 minutes first compile, then fast hot reload
```

**Build for production (FAST):**

Windows:
```powershell
cd frontend
$env:GENERATE_SOURCEMAP="false"
npm run build
```

Linux/Mac:
```bash
cd frontend
GENERATE_SOURCEMAP=false npm run build
```

**Serve production build (instant startup):**
```bash
# Install serve (one time)
npm install -g serve

# Serve on port 3000
cd frontend
serve -s build -l 3000
```

**Run tests:**
```bash
cd frontend
npm test
```

**Note:** For slow frontend startup issues, see [FRONTEND_OPTIMIZATION.md](FRONTEND_OPTIMIZATION.md)

### Database Commands

**Access PostgreSQL:**
```bash
docker exec -it microservices-project-postgres-1 psql -U postgres
```

**List databases:**
```sql
\l
```

**Connect to database:**
```sql
\c authdb
```

**List tables:**
```sql
\dt
```

**Query users:**
```sql
SELECT * FROM users;
```

**Exit psql:**
```sql
\q
```

### Kafka Commands

**Access Kafka container:**
```bash
docker exec -it microservices-project-kafka-1 /bin/bash
```

**List topics:**
```bash
kafka-topics.sh --list --bootstrap-server localhost:9092
```

**Consume messages:**
```bash
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic order-events --from-beginning
```

### Redis Commands

**Access Redis CLI:**
```bash
docker exec -it microservices-project-redis-1 redis-cli
```

**View all keys:**
```redis
KEYS *
```

**Get value:**
```redis
GET key_name
```

**Monitor commands:**
```redis
MONITOR
```

---

## 🚀 Production Deployment

### Build Production Docker Images

**Build all services:**
```bash
docker-compose -f docker-compose.prod.yml build
```

**Push to registry:**
```bash
# Tag images
docker tag microservices-project-auth-service:latest yourusername/auth-service:1.0.0

# Push to Docker Hub
docker push yourusername/auth-service:1.0.0
```

### Frontend Production Build

**Create optimized build:**
```bash
cd frontend
npm run build
```

**The build folder is ready to be deployed.**

**Deploy to static hosting (example):**

**AWS S3:**
```bash
aws s3 sync build/ s3://your-bucket-name/ --delete
aws cloudfront create-invalidation --distribution-id YOUR_ID --paths "/*"
```

**Netlify:**
```bash
npm install -g netlify-cli
netlify deploy --prod --dir=build
```

**Vercel:**
```bash
npm install -g vercel
vercel --prod
```

### Environment Configuration

**Backend (application.yml):**
```yaml
spring:
  datasource:
    url: ${DATABASE_URL}
    username: ${DATABASE_USERNAME}
    password: ${DATABASE_PASSWORD}
  
jwt:
  secret: ${JWT_SECRET}
  expiration: 86400000

kafka:
  bootstrap-servers: ${KAFKA_SERVERS}
```

**Frontend (.env.production):**
```env
REACT_APP_API_URL=https://api.yourdomain.com/api
REACT_APP_ENV=production
```

### Kubernetes Deployment (Optional)

**Deploy to Kubernetes:**
```bash
# Create namespace
kubectl create namespace microservices

# Deploy services
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/kafka.yaml
kubectl apply -f k8s/redis.yaml
kubectl apply -f k8s/auth-service.yaml
kubectl apply -f k8s/user-service.yaml
kubectl apply -f k8s/product-service.yaml
kubectl apply -f k8s/order-service.yaml
kubectl apply -f k8s/inventory-service.yaml
kubectl apply -f k8s/notification-service.yaml
kubectl apply -f k8s/api-gateway.yaml

# Check status
kubectl get pods -n microservices
kubectl get services -n microservices
```

---

## 🔍 Troubleshooting

### Common Issues

#### Docker not running
```bash
# Check Docker status
docker info

# Start Docker Desktop (Windows/Mac)
# Or start Docker daemon (Linux)
sudo systemctl start docker
```

#### Port already in use
```bash
# Find process using port
# Windows:
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# Linux/Mac:
lsof -i :8080
kill -9 <PID>
```

#### Container won't start
```bash
# Check logs
docker-compose logs <service-name>

# Check container status
docker ps -a

# Remove and recreate
docker-compose rm -f <service-name>
docker-compose up -d <service-name>
```

#### Database connection issues
```bash
# Check PostgreSQL is running
docker ps | grep postgres

# Verify database exists
docker exec microservices-project-postgres-1 psql -U postgres -l

# Check service logs
docker-compose logs auth-service | grep -i "database\|connection"
```

#### Frontend can't connect to backend

**Windows:**
```powershell
# Check API Gateway is running
Invoke-RestMethod http://localhost:8080/actuator/health

# Check CORS configuration in gateway
docker-compose logs api-gateway | Select-String "CORS"

# Verify .env file has correct API URL
Get-Content frontend\.env

# Check browser console for errors (F12 in browser)
```

**Linux/Mac:**
```bash
# Check API Gateway is running
curl http://localhost:8080/actuator/health

# Check CORS configuration in gateway
docker-compose logs api-gateway | grep CORS

# Verify .env file has correct API URL
cat frontend/.env

# Check browser console for errors
```

#### JWT authentication fails
```bash
# Verify JWT secret is consistent across services
# Check auth-service logs
docker-compose logs auth-service | grep -i jwt

# Test login
curl -X POST http://localhost:8086/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### Health Check Endpoints

**Check service health:**
```bash
# Auth Service
curl http://localhost:8086/auth/health

# User Service
curl http://localhost:8087/users/health

# Product Service
curl http://localhost:8083/products/health

# Order Service
curl http://localhost:8082/order/health

# Inventory Service
curl http://localhost:8085/inventory/health

# API Gateway
curl http://localhost:8080/actuator/health
```

### Performance Monitoring

**Monitor resource usage:**
```bash
# Container stats
docker stats

# Specific container
docker stats microservices-project-auth-service-1
```

**Check memory usage:**
```bash
docker ps -q | xargs docker stats --no-stream
```

---

## 📊 Service Ports Reference

| Service | Port | Health Check |
|---------|------|--------------|
| Frontend | 3000 | http://localhost:3000 |
| API Gateway | 8080 | http://localhost:8080/actuator/health |
| Order Service | 8082 | http://localhost:8082/order/health |
| Product Service | 8083 | http://localhost:8083/products/health |
| Notification Service | 8084 | http://localhost:8084/notifications/health |
| Inventory Service | 8085 | http://localhost:8085/inventory/health |
| Auth Service | 8086 | http://localhost:8086/auth/health |
| User Service | 8087 | http://localhost:8087/users/health |
| PostgreSQL | 5432 | - |
| Kafka | 9092 | - |
| Redis | 6379 | - |
| Zookeeper | 2181 | - |

---

## 🔐 Default Credentials

**Admin User:**
- Username: `admin`
- Password: `admin123`
- Role: `ADMIN`

**Test User:**
- Username: `testuser`
- Password: `test123`
- Role: `USER`

**Database:**
- Username: `postgres`
- Password: `postgres`

---

## 📚 Additional Resources

- **[Integration Testing](INTEGRATION_COMPLETED.md)** - 66 comprehensive tests
- **[Testing Checklist](TESTING_CHECKLIST.md)** - Testing scenarios
- **[Project Roadmap](PROJECT_ROADMAP.md)** - Development phases
- **[Docker Test Results](DOCKER_TEST_RESULTS.md)** - Container validation

---

## 🆘 Getting Help

If you encounter issues:

1. Check container logs: `docker-compose logs -f <service-name>`
2. Verify all services are running: `docker ps`
3. Check health endpoints (see table above)
4. Review error messages in browser console
5. Ensure all prerequisites are installed and correct versions

For build/deploy specific issues, check:
- Maven build output for backend errors
- npm output for frontend errors
- Docker build logs for container issues
