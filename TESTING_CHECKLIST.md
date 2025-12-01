# Microservices Testing Checklist

## Infrastructure Services

### Zookeeper
- [ ] **Status Check**: `docker ps | findstr zookeeper`
  - Expected: Container running on port 2181
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

### Kafka
- [ ] **Status Check**: `docker ps | findstr kafka`
  - Expected: Container running on ports 9092, 29092
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
- [ ] **List Topics**: `docker exec microservices-project-kafka-1 kafka-topics --list --bootstrap-server localhost:29092`
  - Expected: Topics exist (order-created, product-created, product-updated, product-deleted)
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
- [ ] **Check Topic Offsets**: `docker exec microservices-project-kafka-1 kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:29092 --topic product-created`
  - Expected: Shows message count
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

### PostgreSQL
- [ ] **Status Check**: `docker ps | findstr postgres`
  - Expected: Container running on port 5432
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
- [ ] **Database Connection**: `docker exec -it microservices-project-postgres-1 psql -U dev -d devdb -c "\dt"`
  - Expected: Shows tables (orders, products)
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
- [ ] **Query Orders Table**: `docker exec -it microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT * FROM orders;"`
  - Expected: Returns order records
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
- [ ] **Query Products Table**: `docker exec -it microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT * FROM products;"`
  - Expected: Returns product records
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

---

## Order Service (Port 8082)

### Local Build & Run
- [ ] **Maven Build**: `cd services\order-service; mvn clean package -DskipTests`
  - Expected: BUILD SUCCESS
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
- [ ] **Start Service**: `java "-Duser.timezone=UTC" -jar target/order-service-0.0.1-SNAPSHOT.jar --spring.profiles.active=local`
  - Expected: Application started on port 8082
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
- [ ] **Port Check**: `netstat -ano | findstr :8082`
  - Expected: Port 8082 is listening
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

### Docker Build & Run
- [ ] **Docker Build**: `docker-compose build order-service`
  - Expected: Image built successfully
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
- [ ] **Docker Start**: `docker-compose up -d order-service`
  - Expected: Container started
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
- [ ] **Container Check**: `docker ps | findstr order-service`
  - Expected: Container running
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
- [ ] **Service Logs**: `docker-compose logs --tail=20 order-service`
  - Expected: No errors, "Started OrderServiceApplication"
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

### API Endpoints Testing
- [ ] **POST /orders - Create Order**
  ```powershell
  $body = '{"customer":"alice","amount":199.99}'; Invoke-RestMethod http://localhost:8082/orders -Method Post -Body $body -ContentType 'application/json'
  ```
  - Expected: Returns order with id, customer, amount, status, createdAt
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **GET /orders/{id} - Get Order by ID**
  ```powershell
  Invoke-RestMethod http://localhost:8082/orders/1 -Method Get
  ```
  - Expected: Returns order details
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Input Validation - Missing Customer**
  ```powershell
  $body = '{"amount":199.99}'; Invoke-RestMethod http://localhost:8082/orders -Method Post -Body $body -ContentType 'application/json'
  ```
  - Expected: 400 Bad Request with validation error
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Input Validation - Negative Amount**
  ```powershell
  $body = '{"customer":"test","amount":-50}'; Invoke-RestMethod http://localhost:8082/orders -Method Post -Body $body -ContentType 'application/json'
  ```
  - Expected: 400 Bad Request with validation error
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

### Kafka Integration
- [ ] **Order Created Event Published**
  ```powershell
  docker exec microservices-project-kafka-1 kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:29092 --topic order-created
  ```
  - Expected: Shows message count > 0
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Consume Order Events** (limited messages)
  ```powershell
  docker exec microservices-project-kafka-1 bash -c "timeout 2 kafka-console-consumer --topic order-created --from-beginning --bootstrap-server localhost:29092 --max-messages 5"
  ```
  - Expected: Shows order JSON messages
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

---

## Product Service (Port 8083)

### Local Build & Run
- [ ] **Maven Build**: `cd services\product-service; mvn clean package -DskipTests`
  - Expected: BUILD SUCCESS
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
- [ ] **Start Service (Background)**: `Start-Job -ScriptBlock { java '-Duser.timezone=UTC' -jar 'path\to\jar' '--spring.profiles.active=local' }`
  - Expected: Application started on port 8083
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
- [ ] **Port Check**: `netstat -ano | findstr :8083`
  - Expected: Port 8083 is listening
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

### Docker Build & Run
- [ ] **Docker Build**: `docker-compose build product-service`
  - Expected: Image built successfully
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
- [ ] **Docker Start**: `docker-compose up -d product-service`
  - Expected: Container started
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
- [ ] **Container Check**: `docker ps | findstr product-service`
  - Expected: Container running
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
- [ ] **Service Logs**: `docker-compose logs --tail=20 product-service`
  - Expected: No errors, "Started ProductServiceApplication"
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

### API Endpoints Testing
- [ ] **POST /products - Create Product**
  ```powershell
  $body = '{"name":"Laptop","description":"High-performance laptop","price":1299.99,"stock":25}'; Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json'
  ```
  - Expected: Returns product with id, name, description, price, stock, createdAt
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **GET /products - Get All Products**
  ```powershell
  Invoke-RestMethod http://localhost:8083/products -Method Get
  ```
  - Expected: Returns array of products
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **GET /products/{id} - Get Product by ID**
  ```powershell
  Invoke-RestMethod http://localhost:8083/products/1 -Method Get
  ```
  - Expected: Returns product details
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **PUT /products/{id} - Update Product**
  ```powershell
  $body = '{"name":"Gaming Laptop","description":"Ultra-high-performance gaming laptop","price":1499.99,"stock":15}'; Invoke-RestMethod http://localhost:8083/products/1 -Method Put -Body $body -ContentType 'application/json'
  ```
  - Expected: Returns updated product
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **DELETE /products/{id} - Delete Product**
  ```powershell
  Invoke-RestMethod http://localhost:8083/products/1 -Method Delete
  ```
  - Expected: 204 No Content
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Input Validation - Missing Name**
  ```powershell
  $body = '{"price":99.99,"stock":10}'; Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json'
  ```
  - Expected: 400 Bad Request with validation error
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Input Validation - Negative Price**
  ```powershell
  $body = '{"name":"Test","price":-50,"stock":10}'; Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json'
  ```
  - Expected: 400 Bad Request with validation error
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Input Validation - Negative Stock**
  ```powershell
  $body = '{"name":"Test","price":99.99,"stock":-5}'; Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json'
  ```
  - Expected: 400 Bad Request with validation error
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

### Kafka Integration
- [ ] **Product Created Event Published**
  ```powershell
  docker exec microservices-project-kafka-1 kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:29092 --topic product-created
  ```
  - Expected: Shows message count > 0
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Product Updated Event Published**
  ```powershell
  docker exec microservices-project-kafka-1 kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:29092 --topic product-updated
  ```
  - Expected: Shows message count > 0
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Product Deleted Event Published**
  ```powershell
  docker exec microservices-project-kafka-1 kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:29092 --topic product-deleted
  ```
  - Expected: Shows message count > 0
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Consume Product Events** (limited messages)
  ```powershell
  docker exec microservices-project-kafka-1 bash -c "timeout 2 kafka-console-consumer --topic product-created --from-beginning --bootstrap-server localhost:29092 --max-messages 5"
  ```
  - Expected: Shows product JSON messages
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

---

## Integration Tests

### Multi-Service Startup
- [ ] **Start All Services**: `docker-compose up -d`
  - Expected: All containers start (zookeeper, kafka, postgres, order-service, product-service)
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Verify All Containers Running**: `docker ps`
  - Expected: 5 containers running
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

### Cross-Service Tests
- [ ] **Create Product and Order**
  ```powershell
  # Create product
  $body = '{"name":"Monitor","price":399.99,"stock":20}'; Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json'
  
  # Create order
  $body = '{"customer":"bob","amount":399.99}'; Invoke-RestMethod http://localhost:8082/orders -Method Post -Body $body -ContentType 'application/json'
  ```
  - Expected: Both requests succeed
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Verify Both Services Share Same Database**
  ```powershell
  docker exec -it microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT COUNT(*) FROM products; SELECT COUNT(*) FROM orders;"
  ```
  - Expected: Shows count of products and orders
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

---

## Notification Service (Port 8084)

### Local Build & Run
- [ ] **Maven Build**: `cd services\notification-service; mvn clean package -DskipTests`
  - Expected: BUILD SUCCESS
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
  
- [ ] **Start Service (IMPORTANT: Use proper PowerShell quoting)**
  ```powershell
  & java "-Duser.timezone=UTC" -jar "target\notification-service-0.0.1-SNAPSHOT.jar" "--spring.profiles.active=local"
  ```
  - Expected: Application started on port 8084
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
  - **Common Error**: `Could not find or load main class .timezone=UTC` → Use `&` operator and quoted arguments
  
- [ ] **Start as Background Job**
  ```powershell
  Start-Job -Name 'notif-svc' -ScriptBlock { 
      Set-Location 'C:\path\to\notification-service'
      & java "-Duser.timezone=UTC" -jar "target\notification-service-0.0.1-SNAPSHOT.jar" "--spring.profiles.active=local"
  }
  ```
  - Expected: Job starts successfully
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
  
- [ ] **Port Check**: `Test-NetConnection localhost -Port 8084 -InformationLevel Quiet`
  - Expected: Returns True
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

### Docker Build & Run
- [ ] **Docker Build**: `docker-compose build notification-service`
  - Expected: Image built successfully
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
  
- [ ] **Docker Start**: `docker-compose up -d notification-service`
  - Expected: Container started
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
  
- [ ] **Container Check**: `docker ps | findstr notification-service`
  - Expected: Container running
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
  
- [ ] **Service Logs**: `docker-compose logs --tail=50 notification-service`
  - Expected: No errors, "Started NotificationServiceApplication", Kafka consumers subscribed
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

### API Endpoints Testing
- [ ] **GET /notifications/health - Health Check**
  ```powershell
  Invoke-RestMethod http://localhost:8084/notifications/health
  ```
  - Expected: "Notification service is running"
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **GET /notifications/recent - Get Recent Notifications**
  ```powershell
  Invoke-RestMethod http://localhost:8084/notifications/recent
  ```
  - Expected: Returns array of notifications (may be empty initially)
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **GET /notifications/type/{eventType} - Filter by Event Type**
  ```powershell
  Invoke-RestMethod http://localhost:8084/notifications/type/product-created
  ```
  - Expected: Returns filtered notifications
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **GET /notifications/stream - SSE Endpoint (Browser Test)**
  - Open `test-sse.html` in browser or navigate to `http://localhost:8084/notifications/stream`
  - Expected: Page shows "Connected" status (green dot)
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

### Kafka Consumer Testing
- [ ] **Verify Consumer Group Registration**
  ```powershell
  docker exec microservices-project-kafka-1 kafka-consumer-groups --bootstrap-server localhost:9092 --list
  ```
  - Expected: Shows "notification-service-group"
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Check Consumer Group Lag**
  ```powershell
  docker exec microservices-project-kafka-1 kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group notification-service-group
  ```
  - Expected: Shows 4 consumers (product-created, product-updated, product-deleted, order-created)
  - Expected: CURRENT-OFFSET shows numbers (not `-`), LAG = 0 when caught up
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail
  - **Common Issue**: If CURRENT-OFFSET is `-`, consumers aren't consuming. Check KafkaConsumerConfig for JsonDeserializer settings.

- [ ] **Trigger Notification by Creating Product**
  ```powershell
  $body = '{"name":"Notification Test","price":1.11,"stock":1}'; Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json'
  Start-Sleep 3
  Invoke-RestMethod http://localhost:8084/notifications/recent | Select-Object -First 1
  ```
  - Expected: New notification appears with eventType "product-created"
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Verify Notification Saved to Database**
  ```powershell
  docker exec -it microservices-project-postgres-1 psql -U dev -d devdb -c "SELECT COUNT(*) FROM notification_events;"
  ```
  - Expected: Count > 0
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

### SSE Real-Time Testing
- [ ] **Open test-sse.html in Browser**
  - Navigate to `C:\path\to\notification-service\test-sse.html`
  - Expected: Status shows "Connected" (green dot)
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Load Recent Notifications**
  - Click "Load Recent" button in test-sse.html
  - Expected: Past notifications load and display
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Receive Real-Time Notification**
  - Keep test-sse.html open
  - Create a product: `$body = '{"name":"Live Test","price":5.55,"stock":5}'; Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json'`
  - Expected: Notification appears in browser immediately (green card with product-created)
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Multiple Event Types**
  - Update a product: `$body = '{"name":"Updated","price":6.66,"stock":6}'; Invoke-RestMethod http://localhost:8083/products/1 -Method Put -Body $body -ContentType 'application/json'`
  - Expected: Orange notification card appears (product-updated)
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Statistics Counter**
  - Expected: Total Received, Orders, Products counters increment correctly
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

### Known Issues & Fixes
- [ ] **Issue: "Could not find or load main class .timezone=UTC"**
  - **Cause**: PowerShell parsing error with `-D` arguments
  - **Fix**: Use `& java "-Duser.timezone=UTC"` with call operator and quotes
  - Status: ⚠️ Documented

- [ ] **Issue: Kafka consumers not receiving messages (CURRENT-OFFSET = `-`)**
  - **Cause**: Missing JsonDeserializer configuration
  - **Fix**: Added `VALUE_DEFAULT_TYPE`, `USE_TYPE_INFO_HEADERS`, `ENABLE_AUTO_COMMIT_CONFIG` to KafkaConsumerConfig
  - Status: ✅ Fixed

- [ ] **Issue: SSE connection refused in browser**
  - **Cause**: Service not running or port conflict
  - **Fix**: Check port with `Test-NetConnection`, verify job status, wait 30-40s for startup
  - Status: ⚠️ Documented

---

## Performance & Load Tests

- [ ] **Concurrent Requests - Order Service**
  - Create 10 orders simultaneously
  - Expected: All succeed without errors
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Concurrent Requests - Product Service**
  - Create 10 products simultaneously
  - Expected: All succeed without errors
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Database Connection Pool**
  - Expected: Services handle multiple concurrent DB connections
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

---

## Cleanup & Restart Tests

- [ ] **Stop All Services**: `docker-compose down`
  - Expected: All containers stopped and removed
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Restart Services**: `docker-compose up -d`
  - Expected: Services restart successfully
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Data Persistence**
  - Expected: Data still exists after restart
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Stop Individual Service**: `docker-compose stop product-service`
  - Expected: Only product-service stops
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Restart Individual Service**: `docker-compose start product-service`
  - Expected: product-service restarts successfully
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

---

## Error Handling Tests

- [ ] **Service Unavailable - Database Down**
  - Stop postgres, try to create order/product
  - Expected: Connection error, service handles gracefully
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Service Unavailable - Kafka Down**
  - Stop kafka, try to create order/product
  - Expected: Operation succeeds but Kafka event fails gracefully
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Invalid JSON Request**
  ```powershell
  $body = 'invalid-json'; Invoke-RestMethod http://localhost:8083/products -Method Post -Body $body -ContentType 'application/json'
  ```
  - Expected: 400 Bad Request
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

- [ ] **Get Non-Existent Resource**
  ```powershell
  Invoke-RestMethod http://localhost:8083/products/9999 -Method Get
  ```
  - Expected: 404 Not Found or error message
  - Status: ⬜ Not Tested / ✅ Pass / ❌ Fail

---

## Legend
- ⬜ Not Tested
- ✅ Pass
- ❌ Fail
- ⚠️ Warning/Partial Pass

## Test Results Summary
| Category | Total Tests | Passed | Failed | Not Tested |
|----------|-------------|--------|--------|------------|
| Infrastructure | 0 | 0 | 0 | 0 |
| Order Service | 0 | 0 | 0 | 0 |
| Product Service | 0 | 0 | 0 | 0 |
| Integration | 0 | 0 | 0 | 0 |
| Performance | 0 | 0 | 0 | 0 |
| Error Handling | 0 | 0 | 0 | 0 |
| **TOTAL** | **0** | **0** | **0** | **0** |

## Notes
- Update status checkboxes as tests are performed
- Add actual results and timestamps in notes section
- Document any deviations from expected results
