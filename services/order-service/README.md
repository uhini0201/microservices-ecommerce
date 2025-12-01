# order-service

Spring Boot microservice that stores orders and publishes `order-created` events to Kafka.

## Prerequisites

- Java 17+
- Maven 3.6+
- Docker & Docker Compose (for containerized deployment)
- Running PostgreSQL (port 5432) and Kafka (port 9092) for local development

## Build & Deploy Commands

### Local Development

#### 1. Start Infrastructure (Docker Compose)
```powershell
# From project root directory
cd microservices-project
docker-compose up -d
```

Verify services are running:
```powershell
docker ps
# Should show: zookeeper, kafka, postgres containers
```

#### 2. Build the Application
```powershell
cd services/order-service
mvn clean package -DskipTests
```

#### 3. Run Locally (Windows)
```powershell
java "-Duser.timezone=UTC" -jar target/order-service-0.0.1-SNAPSHOT.jar --spring.profiles.active=local
```

**Note:** The `-Duser.timezone=UTC` flag is required on Windows to avoid PostgreSQL timezone compatibility issues.

#### 4. Run Locally (Linux/Mac)
```bash
java -Duser.timezone=UTC -jar target/order-service-0.0.1-SNAPSHOT.jar --spring.profiles.active=local
```

### Docker Deployment

#### 1. Build Docker Image
```powershell
cd services/order-service
docker build -t order-service:dev .
```

#### 2. Run Container
```powershell
docker run -d `
  --name order-service `
  --network microservices-project_default `
  -p 8082:8082 `
  order-service:dev
```

#### 3. View Logs
```powershell
docker logs order-service
# or follow logs
docker logs -f order-service
```

#### 4. Stop Container
```powershell
docker stop order-service
docker rm order-service
```

## Testing

### Create an Order (PowerShell)
```powershell
Invoke-RestMethod -Uri "http://localhost:8082/orders" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"customer":"alice","amount":49.99}'
```

### Create an Order (curl)
```bash
curl -X POST http://localhost:8082/orders \
  -H "Content-Type: application/json" \
  -d '{"customer":"alice","amount":49.99}'
```

### Get Order by ID
```powershell
Invoke-RestMethod -Uri "http://localhost:8082/orders/1" -Method GET
```

### Check Database
```powershell
docker exec -it microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT * FROM orders;"
```

### Consume Kafka Messages
```powershell
docker exec -it microservices-project-kafka-1 kafka-console-consumer `
  --bootstrap-server localhost:9092 `
  --topic order-created `
  --from-beginning
```

## Complete Testing Commands

### Infrastructure Testing

#### Check Docker Containers
```powershell
# List all containers
docker ps

# Check specific services
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | Select-String "order-service|kafka|postgres|zookeeper"
```

#### Test PostgreSQL Connection
```powershell
# Connect to PostgreSQL
docker exec -it microservices-project-postgres-1 psql -U dev -d devdb

# Run test query
docker exec -it microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT 1 as test;"

# List tables
docker exec -it microservices-project-postgres-1 psql -U dev -d devdb -c "\dt"

# Check orders table structure
docker exec -it microservices-project-postgres-1 psql -U dev -d devdb -c "\d orders"

# Count orders
docker exec -it microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT COUNT(*) FROM orders;"

# Query all orders
docker exec -it microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT * FROM orders ORDER BY created_at DESC LIMIT 10;"
```

#### Test Kafka
```powershell
# List all topics
docker exec microservices-project-kafka-1 kafka-topics --list --bootstrap-server localhost:9092

# Describe order-created topic
docker exec microservices-project-kafka-1 kafka-topics --describe --topic order-created --bootstrap-server localhost:9092

# Check message count (offset)
docker exec microservices-project-kafka-1 kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic order-created

# Consume messages (limited)
docker exec microservices-project-kafka-1 bash -c "timeout 2 kafka-console-consumer --topic order-created --from-beginning --bootstrap-server localhost:9092 --max-messages 5"

# List consumer groups
docker exec microservices-project-kafka-1 kafka-consumer-groups --bootstrap-server localhost:9092 --list

# Check consumer group lag
docker exec microservices-project-kafka-1 kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group notification-service-group
```

### Service Testing

#### Check Port Availability
```powershell
# Test if port 8082 is listening
Test-NetConnection localhost -Port 8082 -InformationLevel Quiet

# Detailed port check
Test-NetConnection localhost -Port 8082

# Find process using port 8082
netstat -ano | findstr :8082
```

#### API Testing (PowerShell)

**Create Order**
```powershell
$body = '{"customer":"test-user","amount":99.99}'
Invoke-RestMethod -Uri http://localhost:8082/orders -Method Post -Body $body -ContentType 'application/json'
```

**Get Order by ID**
```powershell
Invoke-RestMethod -Uri http://localhost:8082/orders/1 -Method Get
```

**Validation Tests**
```powershell
# Missing customer (should fail)
$body = '{"amount":99.99}'
Invoke-RestMethod -Uri http://localhost:8082/orders -Method Post -Body $body -ContentType 'application/json'

# Negative amount (should fail)
$body = '{"customer":"test","amount":-50}'
Invoke-RestMethod -Uri http://localhost:8082/orders -Method Post -Body $body -ContentType 'application/json'

# Invalid JSON (should fail)
$body = 'invalid-json'
Invoke-RestMethod -Uri http://localhost:8082/orders -Method Post -Body $body -ContentType 'application/json'
```

#### API Testing (curl)

**Create Order**
```bash
curl -X POST http://localhost:8082/orders \
  -H "Content-Type: application/json" \
  -d '{"customer":"test-user","amount":99.99}'
```

**Get Order**
```bash
curl http://localhost:8082/orders/1
```

### Docker-Specific Testing

#### View Service Logs
```powershell
# View all logs
docker-compose logs order-service

# Follow logs (live)
docker-compose logs -f order-service

# Last 50 lines
docker-compose logs --tail=50 order-service

# Logs with timestamps
docker-compose logs -t order-service

# Search logs for errors
docker-compose logs order-service | Select-String "ERROR|Exception"
```

#### Restart Service
```powershell
# Restart order-service only
docker-compose restart order-service

# Stop and start
docker-compose stop order-service
docker-compose start order-service

# Rebuild and restart
docker-compose up -d --build order-service
```

#### Execute Commands in Container
```powershell
# Get container shell
docker exec -it microservices-project-order-service-1 bash

# Check Java version
docker exec microservices-project-order-service-1 java -version

# Check application logs inside container
docker exec microservices-project-order-service-1 ls -la /app
```

### Performance Testing

#### Concurrent Requests Test
```powershell
# Create 10 orders concurrently
1..10 | ForEach-Object -Parallel {
    $body = "{`"customer`":`"user$_`",`"amount`":$(Get-Random -Minimum 10 -Maximum 200)}"
    Invoke-RestMethod -Uri http://localhost:8082/orders -Method Post -Body $body -ContentType 'application/json'
} -ThrottleLimit 10
```

### Integration Testing

#### End-to-End Flow Test
```powershell
# 1. Create order
Write-Output "=== Creating Order ==="
$body = '{"customer":"integration-test","amount":150.00}'
$order = Invoke-RestMethod -Uri http://localhost:8082/orders -Method Post -Body $body -ContentType 'application/json'
Write-Output "Order created: ID = $($order.id)"

# 2. Wait for Kafka processing
Start-Sleep 2

# 3. Verify in database
Write-Output "`n=== Verifying in Database ==="
docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT * FROM orders WHERE id = $($order.id);"

# 4. Check Kafka message
Write-Output "`n=== Checking Kafka Topic ==="
docker exec microservices-project-kafka-1 kafka-console-consumer --bootstrap-server localhost:9092 --topic order-created --max-messages 1 --timeout-ms 2000 --from-beginning | Select-String "integration-test"

# 5. Check notification service received event
Write-Output "`n=== Checking Notifications ==="
Invoke-RestMethod http://localhost:8084/notifications/recent | Where-Object { $_.eventType -eq 'order-created' -and $_.entityId -eq $order.id.ToString() }
```

### Health Checks

#### Service Health
```powershell
# Check if service is responding
try {
    $response = Invoke-RestMethod http://localhost:8082/orders/1 -ErrorAction Stop
    Write-Output "✅ Service is healthy"
} catch {
    Write-Output "❌ Service is down: $_"
}

# Check all components
$checks = @{
    "Order Service (8082)" = "http://localhost:8082/orders"
    "Product Service (8083)" = "http://localhost:8083/products"
    "Notification Service (8084)" = "http://localhost:8084/notifications/health"
}

foreach ($check in $checks.GetEnumerator()) {
    try {
        Invoke-RestMethod $check.Value -ErrorAction Stop | Out-Null
        Write-Output "✅ $($check.Key)"
    } catch {
        Write-Output "❌ $($check.Key)"
    }
}
```

## Configuration Profiles

### Local Profile (`application-local.yml`)
- PostgreSQL: `localhost:5432`
- Kafka: `localhost:9092`
- Used for development on host machine

### Docker Profile (`application-docker.yml`)
- PostgreSQL: `postgres:5432`
- Kafka: `kafka:29092`
- Used when running in Docker containers

## Troubleshooting

### Port Already in Use
```powershell
# Find process using port 8082
netstat -ano | findstr :8082
# Kill the process
taskkill /PID <process_id> /F
```

### PostgreSQL Connection Issues
- Ensure PostgreSQL container is running: `docker ps`
- Check PostgreSQL logs: `docker logs microservices-project-postgres-1`
- Verify credentials in `application-local.yml` or `application-docker.yml`

### Kafka Connection Issues
- Ensure Kafka and Zookeeper are running
- Check Kafka logs: `docker logs microservices-project-kafka-1`
- Verify bootstrap-servers configuration

## Quick Reference

| Environment | PostgreSQL | Kafka | Build Command | Run Command |
|-------------|------------|-------|---------------|-------------|
| **Local** | localhost:5432 | localhost:9092 | `mvn clean package -DskipTests` | `java "-Duser.timezone=UTC" -jar target/order-service-0.0.1-SNAPSHOT.jar --spring.profiles.active=local` |
| **Docker** | postgres:5432 | kafka:29092 | `docker build -t order-service:dev .` | `docker run -d --name order-service --network microservices-project_default -p 8082:8082 order-service:dev` |
