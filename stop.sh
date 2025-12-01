#!/usr/bin/env bash

# Microservices E-commerce Platform - Shutdown Script (Linux/Mac)
# This script stops all Docker containers and the React frontend

set -e  # Exit on error

echo "================================================"
echo "  Microservices E-commerce Platform Shutdown"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Navigate to script directory
cd "$(dirname "$0")"

# Stop frontend if running
echo -e "${YELLOW}Stopping frontend (if running)...${NC}"
pkill -f "react-scripts start" 2>/dev/null && echo -e "${GREEN}✓ Frontend stopped${NC}" || echo -e "${YELLOW}⚠ No running frontend process found${NC}"
echo ""

# Stop Docker containers
echo "================================================"
echo "  Stopping Docker Containers"
echo "================================================"
echo ""

if [ -f "docker-compose.yml" ]; then
    echo -e "${YELLOW}Stopping all Docker containers...${NC}"
    docker-compose down
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ All Docker containers stopped successfully${NC}"
    else
        echo -e "${RED}✗ Failed to stop Docker containers${NC}"
    fi
else
    echo -e "${RED}✗ docker-compose.yml not found${NC}"
fi

echo ""
echo "================================================"
echo "  Shutdown Complete"
echo "================================================"
echo ""
echo -e "${GREEN}All services have been stopped.${NC}"
echo -e "${YELLOW}To restart, run: ./start.sh${NC}"
