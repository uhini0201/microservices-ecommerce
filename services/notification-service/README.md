# Notification Service

Real-time notification service built with Spring Boot, Server-Sent Events (SSE), PostgreSQL, and Kafka consumers.

## Features

- **Server-Sent Events (SSE)**: Real-time streaming of notifications to connected clients
- **Kafka Consumer**: Consumes events from order-service and product-service
- **Notification History**: Stores all notifications in PostgreSQL database
- **REST API**: Retrieve recent notifications and filter by event type
- **CORS Enabled**: Ready for frontend integration

## Consumed Kafka Topics

- `order-created`: When a new order is created
- `product-created`: When a new product is added
- `product-updated`: When a product is updated
- `product-deleted`: When a product is deleted

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/notifications/stream` | SSE endpoint for real-time notifications (keeps connection open) |
| GET | `/notifications/recent` | Get last 100 notifications |
| GET | `/notifications/type/{eventType}` | Get notifications filtered by event type |
| GET | `/notifications/health` | Health check endpoint |

## Build & Deploy

### Local Deployment

**Prerequisites**: Ensure PostgreSQL and Kafka are running (via Docker Compose infrastructure).

```powershell
# Navigate to notification-service directory
cd services\notification-service

# Build the application
mvn clean package -DskipTests

# Run with local profile and UTC timezone (Foreground)
# IMPORTANT: Use quoted arguments with & operator to avoid PowerShell parsing errors
& java "-Duser.timezone=UTC" -jar "target\notification-service-0.0.1-SNAPSHOT.jar" "--spring.profiles.active=local"

# Run as background job (Option 2: Background)
Start-Job -Name 'notif-svc' -ScriptBlock { 
    Set-Location 'C:\Users\Uhini Mukherjee\Desktop\Projects\Project\microservices-project\services\notification-service'
    & java "-Duser.timezone=UTC" -jar "target\notification-service-0.0.1-SNAPSHOT.jar" "--spring.profiles.active=local"
}

# Check background jobs
Get-Job

# Stop background jobs
Get-Job | Stop-Job; Get-Job | Remove-Job
```

The service will start on `http://localhost:8084`.

### Docker Deployment

```powershell
# From the root microservices-project directory
cd microservices-project

# Build and start notification service
docker-compose up -d --build notification-service

# View logs
docker-compose logs -f notification-service

# Stop the service
docker-compose stop notification-service
```

The service will be available at `http://localhost:8084`.

### Start All Services

```powershell
# Start all services together
docker-compose up -d

# View logs for all services
docker-compose logs -f order-service product-service notification-service

# Stop all services
docker-compose down
```

## Testing

### Test SSE Connection (PowerShell)

```powershell
# Connect to SSE stream (this will keep connection open)
Invoke-WebRequest -Uri "http://localhost:8084/notifications/stream" -UseBasicParsing
```

**Note**: The connection will remain open and display events as they occur. Press `Ctrl+C` to disconnect.

### Test SSE with curl (bash/WSL)

```bash
# Connect to SSE stream
curl -N http://localhost:8084/notifications/stream

# Or with verbose output
curl -N -v http://localhost:8084/notifications/stream
```

### Browser Test

Open your browser and navigate to:
```
http://localhost:8084/notifications/stream
```

The page will remain loading, and events will appear as they occur.

### Better: Use HTML Test Page

See `test-sse.html` in this directory for a proper browser-based SSE client.

### Get Recent Notifications

```powershell
# Get last 100 notifications
Invoke-RestMethod http://localhost:8084/notifications/recent -Method Get

# Get only order-created notifications
Invoke-RestMethod http://localhost:8084/notifications/type/order-created -Method Get

# Get only product-created notifications
Invoke-RestMethod http://localhost:8084/notifications/type/product-created -Method Get
```

### Trigger Notifications

Create orders or products to trigger notifications:

```powershell
# Create a product (triggers product-created notification)
$body = '{"name":"Test Product","price":99.99,"stock":50}'
Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json'

# Create an order (triggers order-created notification)
$body = '{"customer":"test-user","amount":199.99}'
Invoke-RestMethod http://localhost:8082/orders -Method Post -Body $body -ContentType 'application/json'

# Update a product (triggers product-updated notification)
$body = '{"name":"Updated Product","price":89.99,"stock":40}'
Invoke-RestMethod http://localhost:8083/products/1 -Method Put -Body $body -ContentType 'application/json'

# Delete a product (triggers product-deleted notification)
Invoke-RestMethod http://localhost:8083/products/1 -Method Delete
```

After each action, connected SSE clients will receive the notification in real-time!

## Configuration Profiles

### application.yml (Base Configuration)
- Server port: 8084
- JPA/Hibernate settings
- Kafka consumer configuration with JSON deserializer

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

### Kafka Consumer Not Receiving Messages

```powershell
# Check Kafka topics
docker exec microservices-project-kafka-1 kafka-topics --list --bootstrap-server localhost:29092

# Check consumer group
docker exec microservices-project-kafka-1 kafka-consumer-groups --bootstrap-server localhost:29092 --describe --group notification-service-group

# View service logs
docker-compose logs -f notification-service
```

### SSE Connection Issues

If SSE is not working:
1. Ensure CORS is enabled in the controller
2. Check that the client is using `text/event-stream` content type
3. Verify no proxy/firewall is buffering the connection

### Build Failures

```powershell
# Clean and rebuild
mvn clean install -DskipTests

# Check Java version
java -version  # Should be 17 or higher
```

### Verify Database Connection

```powershell
# Connect to PostgreSQL container
docker exec -it microservices-project-postgres-1 psql -U dev -d devdb

# Check notifications table
\dt
SELECT * FROM notifications ORDER BY created_at DESC LIMIT 10;
```

## SSE Event Format

Events are sent in the following JSON format:

```json
{
  "eventType": "product-created",
  "entityId": "123",
  "message": "New product 'Laptop' added at $1299.99",
  "payload": {
    "id": 123,
    "name": "Laptop",
    "description": "High-performance laptop",
    "price": 1299.99,
    "stock": 25,
    "createdAt": "2025-11-30T10:00:00Z"
  },
  "timestamp": "2025-11-30T10:00:01.123456Z"
}
```

## Integration with Frontend

### JavaScript Example

```javascript
const eventSource = new EventSource('http://localhost:8084/notifications/stream');

eventSource.addEventListener('notification', (event) => {
    const notification = JSON.parse(event.data);
    console.log('Received notification:', notification);
    
    // Update UI
    displayNotification(notification.message);
});

eventSource.onerror = (error) => {
    console.error('SSE error:', error);
    eventSource.close();
};
```

### React Example

```javascript
useEffect(() => {
    const eventSource = new EventSource('http://localhost:8084/notifications/stream');
    
    eventSource.addEventListener('notification', (event) => {
        const notification = JSON.parse(event.data);
        setNotifications(prev => [notification, ...prev]);
    });
    
    return () => eventSource.close();
}, []);
```

## Database Schema

The `notifications` table is auto-created with the following structure:

```sql
CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    event_type VARCHAR(255) NOT NULL,
    entity_id VARCHAR(255) NOT NULL,
    message VARCHAR(2000),
    payload VARCHAR(5000),
    created_at TIMESTAMP NOT NULL
);
```

## Technology Stack

- **Framework**: Spring Boot 3.2.6
- **Language**: Java 17
- **Database**: PostgreSQL 14
- **Messaging**: Apache Kafka (Consumer)
- **Real-Time**: Server-Sent Events (SSE)
- **ORM**: Hibernate 6.4.8
- **Build Tool**: Maven 3.x
- **Containerization**: Docker

## Architecture Flow

```
Order/Product Service
    ↓ (Kafka Publish)
Kafka Topics (order-created, product-created, etc.)
    ↓ (Kafka Consumer)
Notification Service
    ↓ (Save to DB + SSE Broadcast)
Connected Clients (Browsers/Apps)
```

## Performance Notes

- SSE connections are long-lived (Long.MAX_VALUE timeout)
- `CopyOnWriteArrayList` used for thread-safe emitter management
- Dead connections are automatically removed on error/timeout
- Service can handle multiple concurrent SSE connections
- Notifications are persisted before broadcasting

## Troubleshooting

### Issue: Java fails with "Could not find or load main class .timezone=UTC"

**Cause**: PowerShell incorrectly parses the `-D` JVM argument without proper quoting.

**Solution**: Use the call operator `&` and wrap arguments in double quotes:
```powershell
# ❌ WRONG (will fail)
java -Duser.timezone=UTC -jar target/notification-service-0.0.1-SNAPSHOT.jar

# ✅ CORRECT
& java "-Duser.timezone=UTC" -jar "target\notification-service-0.0.1-SNAPSHOT.jar" "--spring.profiles.active=local"
```

### Issue: Kafka consumers not receiving messages

**Symptoms**: 
- Service starts successfully
- Port 8084 responds
- `/notifications/recent` returns empty array
- Kafka consumer group shows CURRENT-OFFSET as `-` (null)

**Cause**: Missing JsonDeserializer configuration for deserializing to HashMap.

**Solution**: Ensure `KafkaConsumerConfig.java` includes:
```java
props.put(JsonDeserializer.VALUE_DEFAULT_TYPE, "java.util.HashMap");
props.put(JsonDeserializer.USE_TYPE_INFO_HEADERS, false);
props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, true);
```

**Verify Kafka Consumer Group**:
```powershell
# Check consumer group lag
docker exec microservices-project-kafka-1 kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group notification-service-group

# Should show CURRENT-OFFSET with numbers (not -)
# LAG should be 0 when caught up
```

### Issue: SSE connection fails in browser

**Symptoms**: Browser console shows "ERR_CONNECTION_REFUSED" or "net::ERR_CONNECTION_REFUSED"

**Causes & Solutions**:
1. **Service not running**: Check `Test-NetConnection localhost -Port 8084`
2. **Service crashed**: Check background job status with `Get-Job`
3. **Port conflict**: Check `netstat -ano | findstr :8084` and kill conflicting processes
4. **Startup still in progress**: Wait 30-40 seconds for Spring Boot + Hibernate initialization

**Debug Steps**:
```powershell
# 1. Check port
Test-NetConnection localhost -Port 8084 -InformationLevel Quiet

# 2. Check health endpoint
Invoke-RestMethod http://localhost:8084/notifications/health

# 3. Check job status
Get-Job | Where-Object { $_.Name -like '*notif*' }

# 4. View job output for errors
Get-Job -Name 'notif-svc' | Receive-Job -Keep | Select-Object -Last 50
```

### Issue: Notifications not appearing in test-sse.html

**Solution**: 
1. Ensure both product-service (8083) and notification-service (8084) are running
2. Refresh the browser page (the page auto-connects on load)
3. Click "Load Recent" to see historical notifications
4. Create a test product:
```powershell
$body = '{"name":"Test","price":1.99,"stock":1}'
Invoke-RestMethod -Uri http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json'
```

## Complete Testing Commands

### Infrastructure Testing

#### Docker Container Health
```powershell
# List all containers
docker ps

# Check notification-service container
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | Select-String "notification-service"

# Inspect notification-service container
docker inspect microservices-project-notification-service-1

# Check container resource usage
docker stats microservices-project-notification-service-1 --no-stream
```

#### PostgreSQL Testing
```powershell
# Connect to PostgreSQL
docker exec -it microservices-project-postgres-1 psql -U dev -d devdb

# Test query
docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT 1 as test;"

# List tables
docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "\dt"

# Describe notifications table
docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "\d notifications"

# Count notifications
docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT COUNT(*) FROM notifications;"

# Query all notifications
docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT id, event_type, message, created_at FROM notifications ORDER BY created_at DESC LIMIT 20;"

# Count by event type
docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT event_type, COUNT(*) as count FROM notifications GROUP BY event_type ORDER BY count DESC;"

# Get recent product-created notifications
docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT * FROM notifications WHERE event_type = 'product-created' ORDER BY created_at DESC LIMIT 10;"

# Get recent order-created notifications
docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT * FROM notifications WHERE event_type = 'order-created' ORDER BY created_at DESC LIMIT 10;"
```

#### Kafka Testing
```powershell
# List all topics
docker exec microservices-project-kafka-1 kafka-topics --list --bootstrap-server localhost:9092

# Check consumer groups
docker exec microservices-project-kafka-1 kafka-consumer-groups --bootstrap-server localhost:9092 --list

# Describe notification-service-group (CRITICAL)
docker exec microservices-project-kafka-1 kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group notification-service-group

# Expected output: CURRENT-OFFSET should be numbers (not -), LAG should be 0 when caught up

# Check message offsets for each topic
docker exec microservices-project-kafka-1 kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic order-created
docker exec microservices-project-kafka-1 kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic product-created
docker exec microservices-project-kafka-1 kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic product-updated
docker exec microservices-project-kafka-1 kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic product-deleted

# Sample messages from order-created topic
docker exec microservices-project-kafka-1 bash -c "timeout 2 kafka-console-consumer --topic order-created --from-beginning --bootstrap-server localhost:9092 --max-messages 3"

# Sample messages from product-created topic
docker exec microservices-project-kafka-1 bash -c "timeout 2 kafka-console-consumer --topic product-created --from-beginning --bootstrap-server localhost:9092 --max-messages 3"
```

### Service Testing

#### Port and Connectivity
```powershell
# Test port 8084
Test-NetConnection localhost -Port 8084 -InformationLevel Quiet

# Detailed port test
Test-NetConnection localhost -Port 8084

# Find process on port 8084
netstat -ano | findstr :8084

# Kill process on port (if needed)
$processId = (Get-NetTCPConnection -LocalPort 8084 -ErrorAction SilentlyContinue).OwningProcess
if ($processId) { Stop-Process -Id $processId -Force }
```

#### API Endpoint Testing (PowerShell)

**Health Check**
```powershell
Invoke-RestMethod http://localhost:8084/notifications/health -Method Get
```

**Get Recent Notifications**
```powershell
$notifications = Invoke-RestMethod http://localhost:8084/notifications/recent -Method Get
Write-Output "Total recent notifications: $($notifications.Count)"
$notifications | Select-Object -First 10 | Format-Table id, eventType, message, timestamp
```

**Get by Event Type**
```powershell
# Product-created notifications
Invoke-RestMethod http://localhost:8084/notifications/type/product-created | Select-Object -First 5

# Product-updated notifications
Invoke-RestMethod http://localhost:8084/notifications/type/product-updated | Select-Object -First 5

# Product-deleted notifications
Invoke-RestMethod http://localhost:8084/notifications/type/product-deleted | Select-Object -First 5

# Order-created notifications
Invoke-RestMethod http://localhost:8084/notifications/type/order-created | Select-Object -First 5
```

**SSE Testing**
```powershell
# Connect to SSE stream (will stay connected, press Ctrl+C to stop)
Invoke-WebRequest -Uri "http://localhost:8084/notifications/stream" -UseBasicParsing

# Alternative: Using curl (if available)
curl -N http://localhost:8084/notifications/stream

# Best: Open test-sse.html in browser
Start-Process "http://localhost:8084/../test-sse.html"  # Adjust path if needed
```

#### API Testing (curl)

```bash
# Health check
curl http://localhost:8084/notifications/health

# Recent notifications
curl http://localhost:8084/notifications/recent

# Filter by event type
curl http://localhost:8084/notifications/type/product-created
curl http://localhost:8084/notifications/type/order-created

# SSE stream (stays connected)
curl -N http://localhost:8084/notifications/stream

# Pretty print JSON
curl http://localhost:8084/notifications/recent | jq
```

### Docker-Specific Testing

#### Container Management
```powershell
# View logs
docker-compose logs notification-service

# Follow logs live
docker-compose logs -f notification-service

# Last 100 lines
docker-compose logs --tail=100 notification-service

# Logs with timestamps
docker-compose logs -t notification-service

# Search for errors
docker-compose logs notification-service | Select-String "ERROR|Exception|Failed"

# Search for Kafka activity
docker-compose logs notification-service | Select-String "Kafka|consume|listener"

# Search for SSE connections
docker-compose logs notification-service | Select-String "SSE|stream|emitter"
```

#### Container Operations
```powershell
# Restart service
docker-compose restart notification-service

# Stop service
docker-compose stop notification-service

# Start service
docker-compose start notification-service

# Rebuild and restart
docker-compose up -d --build notification-service

# Remove container
docker-compose rm -f notification-service
```

#### Execute Commands in Container
```powershell
# Get container shell
docker exec -it microservices-project-notification-service-1 bash

# Check Java version
docker exec microservices-project-notification-service-1 java -version

# List files in container
docker exec microservices-project-notification-service-1 ls -la /app

# Check application properties
docker exec microservices-project-notification-service-1 cat /app/BOOT-INF/classes/application-docker.yml
```

### Integration Testing

#### End-to-End Notification Flow
```powershell
Write-Output "=== Step 1: Check Baseline ==="
$baseline = (Invoke-RestMethod http://localhost:8084/notifications/recent).Count
Write-Output "Current notifications: $baseline"

Write-Output "`n=== Step 2: Create Product ==="
$body = '{"name":"E2E Notification Test","description":"Testing notification flow","price":49.99,"stock":15}'
$product = Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json'
$productId = $product.id
Write-Output "Product created: ID=$productId, Name=$($product.name)"

Start-Sleep 3

Write-Output "`n=== Step 3: Verify product-created Notification ==="
$notifs = Invoke-RestMethod http://localhost:8084/notifications/recent
$newNotifs = $notifs | Where-Object { $_.entityId -eq $productId.ToString() }
if ($newNotifs.Count -gt 0) {
    Write-Output "✅ Notification found:"
    $newNotifs[0] | Format-List eventType, message, timestamp
} else {
    Write-Output "❌ Notification not found"
}

Write-Output "`n=== Step 4: Update Product ==="
$body = '{"name":"Updated E2E Test","description":"Updated","price":39.99,"stock":12}'
Invoke-RestMethod http://localhost:8083/products/$productId -Method Put -Body $body -ContentType 'application/json'

Start-Sleep 3

Write-Output "`n=== Step 5: Verify product-updated Notification ==="
$updateNotifs = Invoke-RestMethod http://localhost:8084/notifications/type/product-updated
$updateNotif = $updateNotifs | Where-Object { $_.entityId -eq $productId.ToString() } | Select-Object -First 1
if ($updateNotif) {
    Write-Output "✅ Update notification found: $($updateNotif.message)"
} else {
    Write-Output "❌ Update notification not found"
}

Write-Output "`n=== Step 6: Delete Product ==="
Invoke-RestMethod http://localhost:8083/products/$productId -Method Delete

Start-Sleep 3

Write-Output "`n=== Step 7: Verify product-deleted Notification ==="
$deleteNotifs = Invoke-RestMethod http://localhost:8084/notifications/type/product-deleted
$deleteNotif = $deleteNotifs | Where-Object { $_.entityId -eq $productId.ToString() } | Select-Object -First 1
if ($deleteNotif) {
    Write-Output "✅ Delete notification found: $($deleteNotif.message)"
} else {
    Write-Output "❌ Delete notification not found"
}

Write-Output "`n=== Step 8: Create Order ==="
$body = '{"customer":"e2e-test-user","amount":99.99}'
$order = Invoke-RestMethod http://localhost:8082/orders -Method Post -Body $body -ContentType 'application/json'
$orderId = $order.id

Start-Sleep 3

Write-Output "`n=== Step 9: Verify order-created Notification ==="
$orderNotifs = Invoke-RestMethod http://localhost:8084/notifications/type/order-created
$orderNotif = $orderNotifs | Where-Object { $_.entityId -eq $orderId.ToString() } | Select-Object -First 1
if ($orderNotif) {
    Write-Output "✅ Order notification found: $($orderNotif.message)"
} else {
    Write-Output "❌ Order notification not found"
}

Write-Output "`n=== Final Count ==="
$final = (Invoke-RestMethod http://localhost:8084/notifications/recent).Count
Write-Output "Baseline: $baseline, Final: $final, New: $($final - $baseline)"
```

#### SSE Real-Time Test
```powershell
# Step 1: Open test-sse.html in browser (or keep it open)
# Step 2: Run this script to generate events while watching SSE

Write-Output "Generating 5 events in 10 seconds..."
1..5 | ForEach-Object {
    $body = @{
        name = "SSE Test Product $_"
        description = "Testing real-time SSE"
        price = Get-Random -Minimum 10 -Maximum 100
        stock = Get-Random -Minimum 5 -Maximum 50
    } | ConvertTo-Json
    
    Write-Output "Creating product $_..."
    Invoke-RestMethod -Uri http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json' | Out-Null
    Start-Sleep 2
}
Write-Output "Done! Check test-sse.html for real-time notifications."
```

### Performance Testing

#### Bulk Notification Generation
```powershell
# Create 10 products quickly to test notification throughput
1..10 | ForEach-Object -Parallel {
    $body = @{
        name = "Performance Test Product $_"
        description = "Perf test"
        price = 19.99
        stock = 10
    } | ConvertTo-Json
    
    Invoke-RestMethod -Uri http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json' | Out-Null
} -ThrottleLimit 5

Start-Sleep 5

# Check notification count
$count = (Invoke-RestMethod http://localhost:8084/notifications/recent).Count
Write-Output "Total notifications: $count"
```

#### Response Time Testing
```powershell
# Measure /recent endpoint response time
Measure-Command { Invoke-RestMethod http://localhost:8084/notifications/recent } | Select-Object TotalMilliseconds

# Measure /type/{eventType} response time
Measure-Command { Invoke-RestMethod http://localhost:8084/notifications/type/product-created } | Select-Object TotalMilliseconds
```

### Health Check Script
```powershell
function Test-NotificationService {
    Write-Output "=== Notification Service Health Check ==="
    
    # Check port
    $portOpen = Test-NetConnection localhost -Port 8084 -InformationLevel Quiet
    Write-Output "Port 8084: $(if($portOpen){'✅ Open'}else{'❌ Closed'})"
    
    # Check API
    try {
        $health = Invoke-RestMethod http://localhost:8084/notifications/health -ErrorAction Stop
        Write-Output "API /health: ✅ $health"
    } catch {
        Write-Output "API /health: ❌ Failed - $_"
    }
    
    # Check notifications endpoint
    try {
        $notifs = Invoke-RestMethod http://localhost:8084/notifications/recent -ErrorAction Stop
        Write-Output "API /recent: ✅ Responding ($($notifs.Count) notifications)"
    } catch {
        Write-Output "API /recent: ❌ Failed - $_"
    }
    
    # Check database
    try {
        $count = docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT COUNT(*) FROM notifications;" -t
        Write-Output "Database: ✅ Connected ($($count.Trim()) notifications in DB)"
    } catch {
        Write-Output "Database: ❌ Failed - $_"
    }
    
    # Check Kafka consumer group
    try {
        $consumerGroup = docker exec microservices-project-kafka-1 kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group notification-service-group 2>$null
        $hasOffset = $consumerGroup | Select-String "CURRENT-OFFSET" | Select-String -NotMatch " - "
        if ($hasOffset) {
            Write-Output "Kafka: ✅ Consumer group active (consuming messages)"
        } else {
            Write-Output "Kafka: ⚠️ Consumer group registered but CURRENT-OFFSET is null"
        }
    } catch {
        Write-Output "Kafka: ❌ Failed - $_"
    }
    
    # Check notification distribution
    try {
        $distribution = docker exec microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT event_type, COUNT(*) FROM notifications GROUP BY event_type;" -t
        Write-Output "`nNotification Distribution:"
        Write-Output $distribution
    } catch {
        Write-Output "Distribution: ❌ Failed"
    }
}

Test-NotificationService
```

### Debugging Commands

#### Check Kafka Consumer Status
```powershell
# Detailed consumer group info
docker exec microservices-project-kafka-1 kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group notification-service-group

# Look for:
# - CURRENT-OFFSET should be numbers (not -)
# - LAG should be 0 (caught up) or low positive number
# - GROUP-INSTANCE should show consumer instances

# If CURRENT-OFFSET is -, check KafkaConsumerConfig.java for these properties:
# JsonDeserializer.VALUE_DEFAULT_TYPE = "java.util.HashMap"
# JsonDeserializer.USE_TYPE_INFO_HEADERS = false
# ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG = true
```

#### Check SSE Connections
```powershell
# Check logs for SSE activity
docker-compose logs --tail=50 notification-service | Select-String "SSE|stream|emitter"

# Count active connections (check logs for connection messages)
docker-compose logs notification-service | Select-String "SSE connection opened" | Measure-Object | Select-Object Count
```

#### Check Service Startup
```powershell
# View full startup logs
docker-compose logs notification-service | Select-String "Started|Tomcat|Hibernate|Kafka"

# Check for errors during startup
docker-compose logs notification-service | Select-String "ERROR|WARN|Exception" | Select-Object -First 20
```

## Quick Reference

| Task | Command |
|------|---------|
| Build | `mvn clean package -DskipTests` |
| Run Local (Foreground) | `& java "-Duser.timezone=UTC" -jar "target\notification-service-0.0.1-SNAPSHOT.jar" "--spring.profiles.active=local"` |
| Run Local (Background) | `Start-Job -Name 'notif-svc' -ScriptBlock { Set-Location 'path\to\notification-service'; & java "-Duser.timezone=UTC" -jar "target\notification-service-0.0.1-SNAPSHOT.jar" "--spring.profiles.active=local" }` |
| Run Docker | `docker-compose up -d notification-service` |
| View Logs | `docker-compose logs -f notification-service` |
| Check Port | `Test-NetConnection localhost -Port 8084 -InformationLevel Quiet` |
| Health Check | `Invoke-RestMethod http://localhost:8084/notifications/health` |
| Recent Notifications | `Invoke-RestMethod http://localhost:8084/notifications/recent` |
| Test SSE | Open `test-sse.html` in browser or `curl -N http://localhost:8084/notifications/stream` |
| Get History | `Invoke-RestMethod http://localhost:8084/notifications/recent` |
| Check Port | `netstat -ano \| findstr :8084` |
| Check Kafka Consumer | `docker exec microservices-project-kafka-1 kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group notification-service-group` |
| Health Check Script | Run `Test-NotificationService` function above |
