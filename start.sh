#!/usr/bin/env bash

# Microservices E-commerce Platform - Startup Script (Linux/Mac)
# This script starts all Docker containers and the React frontend

set -e  # Exit on error

echo "================================================"
echo "  Microservices E-commerce Platform Startup"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Docker is running
echo "Checking Docker status..."
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}✗ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker is running${NC}"
echo ""

# Navigate to project root
cd "$(dirname "$0")"

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}✗ docker-compose.yml not found in current directory${NC}"
    exit 1
fi

# Start Docker containers
echo "================================================"
echo "  Step 1: Starting Docker Microservices"
echo "================================================"
echo ""
echo "Starting all microservices containers..."
docker-compose up -d

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ All Docker containers started successfully${NC}"
else
    echo -e "${RED}✗ Failed to start Docker containers${NC}"
    exit 1
fi
echo ""

# Wait for services to be ready
echo "Waiting for services to initialize..."
echo "This may take 30-60 seconds..."
sleep 45

# Check container status
echo ""
echo "================================================"
echo "  Docker Container Status"
echo "================================================"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "service|postgres|kafka|redis|gateway"
echo ""

# Start live logging in background
echo "================================================"
echo "  Step 2: Starting Live Log Monitoring"
echo "================================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_SCRIPT="$SCRIPT_DIR/live-logs.sh"

if [ -f "$LOG_SCRIPT" ]; then
    echo "Starting live log monitoring in background..."
    chmod +x "$LOG_SCRIPT"
    nohup "$LOG_SCRIPT" 2 100 > /dev/null 2>&1 &
    LOG_PID=$!
    echo "$LOG_PID" > "$SCRIPT_DIR/.live-logs.pid"
    echo -e "${GREEN}✓ Live logging started (logs/live/)${NC}"
    echo -e "  View logs: tail -f logs/live/<service>.log"
else
    echo -e "${YELLOW}⚠ live-logs.sh not found, skipping live logging${NC}"
fi
echo ""

# Health check for key services
echo "================================================"
echo "  Step 3: Health Check"
echo "================================================"
echo ""

services=(
    "API Gateway:8080:/actuator/health"
    "Auth Service:8086:/auth/health"
    "User Service:8087:/users/health"
    "Product Service:8083:/products/health"
    "Order Service:8082:/order/health"
    "Inventory Service:8085:/inventory/health"
)

for service in "${services[@]}"; do
    IFS=':' read -r name port endpoint <<< "$service"
    echo -n "Checking $name (port $port)... "
    
    max_attempts=10
    attempt=0
    while [ $attempt -lt $max_attempts ]; do
        if curl -s "http://localhost:$port$endpoint" > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Ready${NC}"
            break
        fi
        attempt=$((attempt + 1))
        if [ $attempt -eq $max_attempts ]; then
            echo -e "${YELLOW}⚠ Not responding (may still be starting)${NC}"
        else
            sleep 3
        fi
    done
done
echo ""

# Cleanup function
cleanup() {
    echo ""
    echo "Stopping live log monitoring..."
    if [ -f "$SCRIPT_DIR/.live-logs.pid" ]; then
        LOG_PID=$(cat "$SCRIPT_DIR/.live-logs.pid")
        kill $LOG_PID 2>/dev/null || true
        rm "$SCRIPT_DIR/.live-logs.pid"
        echo -e "${GREEN}✓ Live logging stopped${NC}"
    fi
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start frontend
echo "================================================"
echo "  Step 4: Starting React Frontend"
echo "================================================"
echo ""

if [ ! -d "frontend" ]; then
    echo -e "${RED}✗ Frontend directory not found${NC}"
    exit 1
fi

cd frontend

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}⚠ node_modules not found. Running npm install...${NC}"
    npm install
    echo ""
fi

echo "Starting React development server..."
echo -e "${YELLOW}Note: Frontend will open automatically at http://localhost:3000${NC}"
echo ""

# Start frontend (this will run in foreground)
npm start

# This script will keep running until Ctrl+C is pressed
