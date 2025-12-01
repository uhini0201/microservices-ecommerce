# Product Service

Product microservice built with Spring Boot, PostgreSQL, and Kafka.

## Prerequisites

- Java 17 or higher
- Maven 3.x
- Docker Desktop (for containerized deployment)
- PostgreSQL 14 (for local deployment)
- Apache Kafka (for local deployment)

## Features

- **CRUD Operations**: Create, Read, Update, and Delete products
- **Database**: PostgreSQL with JPA/Hibernate
- **Messaging**: Kafka producer for product events
- **Validation**: Input validation with Jakarta Bean Validation
- **Multi-Environment**: Separate configurations for local and Docker deployments

## API Endpoints

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| POST | `/products` | Create a new product | `{"name":"Product Name","description":"Description","price":99.99,"stock":100}` |
| GET | `/products` | Get all products | - |
| GET | `/products/{id}` | Get product by ID | - |
| PUT | `/products/{id}` | Update product | `{"name":"Updated Name","description":"Description","price":89.99,"stock":50}` |
| DELETE | `/products/{id}` | Delete product | - |

## Kafka Events

The service publishes events to Kafka:
- `product-created`: When a new product is created
- `product-updated`: When a product is updated
- `product-deleted`: When a product is deleted

## Build & Deploy

### Local Deployment

**Prerequisites**: Ensure PostgreSQL and Kafka are running (via Docker Compose infrastructure or standalone).

```powershell
# Navigate to product-service directory
cd services\product-service

# Build the application
mvn clean package -DskipTests

# Run with local profile and UTC timezone (Option 1: Foreground)
java "-Duser.timezone=UTC" -jar target/product-service-0.0.1-SNAPSHOT.jar --spring.profiles.active=local

# Run as background job (Option 2: Background)
Start-Job -ScriptBlock { java '-Duser.timezone=UTC' -jar 'C:\Users\Uhini Mukherjee\Desktop\Projects\Project\microservices-project\services\product-service\target\product-service-0.0.1-SNAPSHOT.jar' '--spring.profiles.active=local' }

# Check background jobs
Get-Job

# Stop background jobs
Get-Job | Stop-Job; Get-Job | Remove-Job
```

The service will start on `http://localhost:8083`.

### Docker Deployment

```powershell
# From the root microservices-project directory
cd microservices-project

# Build and start all services (including product-service)
docker-compose up -d --build product-service

# View logs
docker-compose logs -f product-service

# Stop the service
docker-compose stop product-service

# Remove the service
docker-compose down product-service
```

The service will be available at `http://localhost:8083`.

## Testing

### Create Product (PowerShell)

```powershell
# Option 1: Using ConvertTo-Json
Invoke-RestMethod http://localhost:8083/products -Method Post -Body (@{name='Laptop';description='High-performance laptop';price=1299.99;stock=25} | ConvertTo-Json) -ContentType 'application/json'

# Option 2: Using JSON string (recommended for reliability)
$body = '{"name":"Laptop","description":"High-performance laptop","price":1299.99,"stock":25}'
Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json'
```

### Get All Products (PowerShell)

```powershell
Invoke-RestMethod http://localhost:8083/products -Method Get
```

### Get Product by ID (PowerShell)

```powershell
Invoke-RestMethod http://localhost:8083/products/1 -Method Get
```

### Update Product (PowerShell)

```powershell
# Option 1: Using ConvertTo-Json
Invoke-RestMethod http://localhost:8083/products/1 -Method Put -Body (@{name='Gaming Laptop';description='Ultra-high-performance gaming laptop';price=1499.99;stock=15} | ConvertTo-Json) -ContentType 'application/json'

# Option 2: Using JSON string (recommended for reliability)
$body = '{"name":"Gaming Laptop","description":"Ultra-high-performance gaming laptop","price":1499.99,"stock":15}'
Invoke-RestMethod http://localhost:8083/products/1 -Method Put -Body $body -ContentType 'application/json'
```

### Delete Product (PowerShell)

```powershell
Invoke-RestMethod http://localhost:8083/products/1 -Method Delete
```

### Using curl

```bash
# Create product
curl -X POST http://localhost:8083/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Laptop","description":"High-performance laptop","price":1299.99,"stock":25}'

# Get all products
curl http://localhost:8083/products

# Get product by ID
curl http://localhost:8083/products/1

# Update product
curl -X PUT http://localhost:8083/products/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Gaming Laptop","description":"Ultra-high-performance gaming laptop","price":1499.99,"stock":15}'

# Delete product
curl -X DELETE http://localhost:8083/products/1
```

## Configuration Profiles

### application.yml (Base Configuration)
- Server port: 8083
- JPA/Hibernate settings
- Kafka producer configuration

### application-local.yml (Local Development)
- PostgreSQL: `jdbc:postgresql://localhost:5432/devdb?TimeZone=UTC`
- Kafka: `localhost:9092`

### application-docker.yml (Docker Deployment)
- PostgreSQL: `jdbc:postgresql://postgres:5432/devdb?TimeZone=UTC`
- Kafka: `kafka:29092`

## Troubleshooting

### PostgreSQL Connection Issues

If you encounter timezone errors, ensure:
1. The JDBC URL includes `?TimeZone=UTC` parameter
2. When running locally, use `-Duser.timezone=UTC` JVM argument

### Build Failures

```powershell
# Clean and rebuild
mvn clean install -DskipTests

# Check Java version
java -version  # Should be 17 or higher
```

### Docker Build Issues

```powershell
# Rebuild the Docker image
docker-compose build --no-cache product-service

# Check container logs
docker-compose logs product-service
```

### Verify Database Connection

```powershell
# Connect to PostgreSQL container
docker exec -it microservices-project-postgres-1 psql -U dev -d devdb

# Check products table
\dt
SELECT * FROM products;
```

### Verify Kafka Connection

```powershell
# Enter Kafka container
docker exec -it microservices-project-kafka-1 bash

# List topics
kafka-topics --list --bootstrap-server localhost:29092

# Consume product events
kafka-console-consumer --topic product-created --from-beginning --bootstrap-server localhost:29092
kafka-console-consumer --topic product-updated --from-beginning --bootstrap-server localhost:29092
kafka-console-consumer --topic product-deleted --from-beginning --bootstrap-server localhost:29092
```

### Check Running Services

```powershell
# Check if service is listening on port 8083
netstat -ano | findstr :8083

# Or use Test-NetConnection
Test-NetConnection -ComputerName localhost -Port 8083 -InformationLevel Quiet
```

## Complete Testing Commands

### Infrastructure Testing

#### Docker Container Health
```powershell
# List all containers
docker ps

# Check product-service container
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | Select-String "product-service"

# Inspect product-service container
docker inspect microservices-project-product-service-1

# Check container resource usage
docker stats microservices-project-product-service-1 --no-stream
```

#### PostgreSQL Testing
```powershell
# Connect to PostgreSQL
docker exec -it microservices-project-postgres-1 psql -U dev -d devdb

# Test query
docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT 1 as test;"

# List tables
docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "\dt"

# Describe products table
docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "\d products"

# Count products
docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT COUNT(*) FROM products;"

# Query all products
docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT id, name, price, stock FROM products ORDER BY created_at DESC LIMIT 10;"

# Search products by name
docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT * FROM products WHERE name LIKE '%Laptop%';"

# Get low stock products
docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT name, stock FROM products WHERE stock < 10;"
```

#### Kafka Testing
```powershell
# List all topics
docker exec microservices-project-kafka-1 kafka-topics --list --bootstrap-server localhost:9092

# Describe product-created topic
docker exec microservices-project-kafka-1 kafka-topics --describe --topic product-created --bootstrap-server localhost:9092

# Check message offsets for all product topics
docker exec microservices-project-kafka-1 kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic product-created
docker exec microservices-project-kafka-1 kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic product-updated
docker exec microservices-project-kafka-1 kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic product-deleted

# Consume limited messages from product-created
docker exec microservices-project-kafka-1 bash -c "timeout 2 kafka-console-consumer --topic product-created --from-beginning --bootstrap-server localhost:9092 --max-messages 5"

# List consumer groups
docker exec microservices-project-kafka-1 kafka-consumer-groups --bootstrap-server localhost:9092 --list

# Check notification-service consumer group for product topics
docker exec microservices-project-kafka-1 kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group notification-service-group
```

### Service Testing

#### Port and Connectivity
```powershell
# Test port 8083
Test-NetConnection localhost -Port 8083 -InformationLevel Quiet

# Detailed port test
Test-NetConnection localhost -Port 8083

# Find process on port 8083
netstat -ano | findstr :8083

# Kill process on port (if needed)
$processId = (Get-NetTCPConnection -LocalPort 8083 -ErrorAction SilentlyContinue).OwningProcess
if ($processId) { Stop-Process -Id $processId -Force }
```

#### API Endpoint Testing (PowerShell)

**Create Product**
```powershell
$body = '{"name":"Wireless Mouse","description":"Ergonomic wireless mouse","price":29.99,"stock":50}'
$product = Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json'
Write-Output "Created product ID: $($product.id)"
```

**Get All Products**
```powershell
$products = Invoke-RestMethod http://localhost:8083/products -Method Get
Write-Output "Total products: $($products.Count)"
$products | Format-Table id, name, price, stock
```

**Get Product by ID**
```powershell
Invoke-RestMethod http://localhost:8083/products/1 -Method Get | ConvertTo-Json
```

**Update Product**
```powershell
$body = '{"name":"Premium Wireless Mouse","description":"Premium ergonomic wireless mouse with USB-C","price":39.99,"stock":40}'
Invoke-RestMethod http://localhost:8083/products/1 -Method Put -Body $body -ContentType 'application/json'
```

**Delete Product**
```powershell
Invoke-RestMethod http://localhost:8083/products/1 -Method Delete
```

**Validation Tests**
```powershell
# Missing name (should fail)
$body = '{"description":"Test","price":99.99,"stock":10}'
try { Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json' } catch { Write-Output "Expected error: $_" }

# Negative price (should fail)
$body = '{"name":"Test","price":-50,"stock":10}'
try { Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json' } catch { Write-Output "Expected error: $_" }

# Negative stock (should fail)
$body = '{"name":"Test","price":99.99,"stock":-5}'
try { Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json' } catch { Write-Output "Expected error: $_" }

# Invalid JSON (should fail)
$body = 'invalid-json'
try { Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json' } catch { Write-Output "Expected error: $_" }

# Non-existent product (should return 404)
try { Invoke-RestMethod http://localhost:8083/products/9999 -Method Get } catch { Write-Output "Expected 404: $_" }
```

#### API Testing (curl)

```bash
# Create product
curl -X POST http://localhost:8083/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Mechanical Keyboard","description":"RGB mechanical keyboard","price":149.99,"stock":30}'

# Get all products
curl http://localhost:8083/products

# Get product by ID
curl http://localhost:8083/products/1

# Update product
curl -X PUT http://localhost:8083/products/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Premium Mechanical Keyboard","description":"RGB mechanical gaming keyboard","price":179.99,"stock":25}'

# Delete product
curl -X DELETE http://localhost:8083/products/1

# Pretty print JSON output
curl http://localhost:8083/products | jq
```

### Docker-Specific Testing

#### Container Management
```powershell
# View logs
docker-compose logs product-service

# Follow logs live
docker-compose logs -f product-service

# Last 100 lines
docker-compose logs --tail=100 product-service

# Logs with timestamps
docker-compose logs -t product-service

# Search for errors
docker-compose logs product-service | Select-String "ERROR|Exception|Failed"

# Search for Kafka activity
docker-compose logs product-service | Select-String "Kafka|publish|sent to topic"
```

#### Container Operations
```powershell
# Restart service
docker-compose restart product-service

# Stop service
docker-compose stop product-service

# Start service
docker-compose start product-service

# Rebuild and restart
docker-compose up -d --build product-service

# Remove container
docker-compose rm -f product-service
```

#### Execute Commands in Container
```powershell
# Get container shell
docker exec -it microservices-project-product-service-1 bash

# Check Java version
docker exec microservices-project-product-service-1 java -version

# List files in container
docker exec microservices-project-product-service-1 ls -la /app

# Check application properties
docker exec microservices-project-product-service-1 cat /app/BOOT-INF/classes/application-docker.yml
```

### Integration Testing

#### End-to-End Product Flow
```powershell
Write-Output "=== Step 1: Create Product ==="
$body = '{"name":"E2E Test Product","description":"Integration test","price":99.99,"stock":10}'
$product = Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json'
$productId = $product.id
Write-Output "Product created: ID=$productId"

Start-Sleep 2

Write-Output "`n=== Step 2: Verify in Database ==="
docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT * FROM products WHERE id = $productId;"

Write-Output "`n=== Step 3: Check Kafka Event ==="
docker exec microservices-project-kafka-1 kafka-console-consumer --bootstrap-server localhost:9092 --topic product-created --max-messages 1 --timeout-ms 2000 --from-beginning | Select-String "E2E Test Product"

Write-Output "`n=== Step 4: Verify Notification ==="
$notifs = Invoke-RestMethod http://localhost:8084/notifications/recent
$notif = $notifs | Where-Object { $_.eventType -eq 'product-created' -and $_.entityId -eq $productId.ToString() }
if ($notif) {
    Write-Output "✅ Notification found: $($notif.message)"
} else {
    Write-Output "❌ Notification not found"
}

Write-Output "`n=== Step 5: Update Product ==="
$body = '{"name":"Updated E2E Product","description":"Updated test","price":89.99,"stock":8}'
Invoke-RestMethod http://localhost:8083/products/$productId -Method Put -Body $body -ContentType 'application/json'

Start-Sleep 2

Write-Output "`n=== Step 6: Check Update Event ==="
docker exec microservices-project-kafka-1 kafka-console-consumer --bootstrap-server localhost:9092 --topic product-updated --max-messages 1 --timeout-ms 2000 --from-beginning | Select-String "$productId"

Write-Output "`n=== Step 7: Delete Product ==="
Invoke-RestMethod http://localhost:8083/products/$productId -Method Delete

Start-Sleep 2

Write-Output "`n=== Step 8: Verify Deletion ==="
try {
    Invoke-RestMethod http://localhost:8083/products/$productId -Method Get
    Write-Output "❌ Product still exists"
} catch {
    Write-Output "✅ Product successfully deleted (404)"
}

Write-Output "`n=== Step 9: Check Delete Event ==="
docker exec microservices-project-kafka-1 kafka-console-consumer --bootstrap-server localhost:9092 --topic product-deleted --max-messages 1 --timeout-ms 2000 --from-beginning | Select-String "$productId"
```

### Performance Testing

#### Bulk Product Creation
```powershell
# Create 20 products concurrently
1..20 | ForEach-Object -Parallel {
    $body = @{
        name = "Product $_"
        description = "Performance test product $_"
        price = [math]::Round((Get-Random -Minimum 10 -Maximum 500), 2)
        stock = Get-Random -Minimum 5 -Maximum 100
    } | ConvertTo-Json
    
    $result = Invoke-RestMethod -Uri http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json'
    Write-Output "Created: $($result.id) - $($result.name)"
} -ThrottleLimit 10
```

#### Response Time Testing
```powershell
# Measure GET /products response time
Measure-Command { Invoke-RestMethod http://localhost:8083/products } | Select-Object TotalMilliseconds

# Measure POST response time
$body = '{"name":"Perf Test","description":"Test","price":1.00,"stock":1}'
Measure-Command { Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json' } | Select-Object TotalMilliseconds
```

### Health Check Script
```powershell
function Test-ProductService {
    Write-Output "=== Product Service Health Check ==="
    
    # Check port
    $portOpen = Test-NetConnection localhost -Port 8083 -InformationLevel Quiet
    Write-Output "Port 8083: $(if($portOpen){'✅ Open'}else{'❌ Closed'})"
    
    # Check API
    try {
        $products = Invoke-RestMethod http://localhost:8083/products -ErrorAction Stop
        Write-Output "API /products: ✅ Responding ($($products.Count) products)"
    } catch {
        Write-Output "API /products: ❌ Failed - $_"
    }
    
    # Check database
    try {
        $count = docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT COUNT(*) FROM products;" -t
        Write-Output "Database: ✅ Connected ($($count.Trim()) products in DB)"
    } catch {
        Write-Output "Database: ❌ Failed - $_"
    }
    
    # Check Kafka topics
    $topics = docker exec microservices-project-kafka-1 kafka-topics --list --bootstrap-server localhost:9092 2>$null
    $productTopics = $topics | Select-String "product-"
    Write-Output "Kafka: ✅ $($productTopics.Count) product topics found"
}

Test-ProductService
```

## Quick Reference

| Task | Local Command | Docker Command |
|------|---------------|----------------|
| Build | `mvn clean package -DskipTests` | `docker-compose build product-service` |
| Run (Foreground) | `java "-Duser.timezone=UTC" -jar target/product-service-0.0.1-SNAPSHOT.jar --spring.profiles.active=local` | `docker-compose up -d product-service` |
| Run (Background) | `Start-Job -ScriptBlock { java '-Duser.timezone=UTC' -jar 'path\to\jar' '--spring.profiles.active=local' }` | N/A |
| Stop | `Ctrl+C` (foreground) or `Get-Job \| Stop-Job` (background) | `docker-compose stop product-service` |
| Logs | Console output | `docker-compose logs -f product-service` |
| Check Port | `netstat -ano \| findstr :8083` | Same |
| Test POST | `$body='{"name":"Test","price":99.99,"stock":10}'; Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json'` | Same |
| Test GET | `Invoke-RestMethod http://localhost:8083/products -Method Get` | Same |
| Test PUT | `$body='{"name":"Updated","price":89.99,"stock":5}'; Invoke-RestMethod http://localhost:8083/products/1 -Method Put -Body $body -ContentType 'application/json'` | Same |
| Test DELETE | `Invoke-RestMethod http://localhost:8083/products/1 -Method Delete` | Same |

## Database Schema

The `products` table is auto-created with the following structure:

```sql
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(1000),
    price DOUBLE PRECISION NOT NULL,
    stock INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL
);
```

## Technology Stack

- **Framework**: Spring Boot 3.2.6
- **Language**: Java 17
- **Database**: PostgreSQL 14
- **Messaging**: Apache Kafka
- **ORM**: Hibernate 6.4.8
- **Build Tool**: Maven 3.x
- **Containerization**: Docker
