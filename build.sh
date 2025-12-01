#!/usr/bin/env bash

# Microservices E-commerce Platform - Build Script (Linux/Mac)
# This script builds backend services and/or frontend
#
# Usage:
#   ./build.sh                    - Build all services
#   ./build.sh auth               - Build only auth service
#   ./build.sh --frontend         - Build only frontend
#   ./build.sh --all              - Build everything (backend + frontend)

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}  Microservices E-commerce Platform Build${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""

# Navigate to script directory
cd "$(dirname "$0")"

# Parse arguments
SERVICE=""
FRONTEND=false
ALL=false

if [ "$1" == "--frontend" ]; then
    FRONTEND=true
elif [ "$1" == "--all" ]; then
    ALL=true
elif [ -n "$1" ]; then
    SERVICE="$1"
fi

# Build specific service
if [ -n "$SERVICE" ]; then
    echo -e "${YELLOW}Building $SERVICE service...${NC}"
    SERVICE_PATH="services/${SERVICE}-service"
    
    if [ ! -d "$SERVICE_PATH" ]; then
        echo -e "${RED}✗ Service directory not found: $SERVICE_PATH${NC}"
        echo ""
        echo -e "${CYAN}Available services:${NC}"
        echo -e "  ${WHITE}- auth${NC}"
        echo -e "  ${WHITE}- user${NC}"
        echo -e "  ${WHITE}- product${NC}"
        echo -e "  ${WHITE}- order${NC}"
        echo -e "  ${WHITE}- inventory${NC}"
        echo -e "  ${WHITE}- notification${NC}"
        echo -e "  ${WHITE}- api-gateway${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${CYAN}Maven clean package for ${SERVICE}-service...${NC}"
    cd "$SERVICE_PATH"
    mvn clean package -DskipTests
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ $SERVICE service built successfully${NC}"
        echo -e "${CYAN}JAR location: $SERVICE_PATH/target/${NC}"
    else
        echo ""
        echo -e "${RED}✗ Failed to build $SERVICE service${NC}"
        exit 1
    fi
    
    cd - > /dev/null
    
    # Build Docker image
    echo ""
    echo -e "${YELLOW}Building Docker image for ${SERVICE}-service...${NC}"
    docker-compose build "${SERVICE}-service"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Docker image built successfully${NC}"
    else
        echo -e "${RED}✗ Failed to build Docker image${NC}"
        exit 1
    fi

# Build frontend
elif [ "$FRONTEND" = true ] || [ "$ALL" = true ]; then
    if [ "$FRONTEND" = true ]; then
        echo -e "${YELLOW}Building frontend...${NC}"
    fi
    
    if [ ! -d "frontend" ]; then
        echo -e "${RED}✗ Frontend directory not found${NC}"
        exit 1
    fi
    
    cd frontend
    
    # Install dependencies if needed
    if [ ! -d "node_modules" ]; then
        echo ""
        echo -e "${YELLOW}Installing npm dependencies...${NC}"
        npm install
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}✗ Failed to install dependencies${NC}"
            exit 1
        fi
    fi
    
    # Build frontend
    echo ""
    echo -e "${CYAN}Building React production bundle...${NC}"
    npm run build
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ Frontend built successfully${NC}"
        echo -e "${CYAN}Production build: frontend/build/${NC}"
        echo ""
        echo -e "${YELLOW}Deploy to:${NC}"
        echo -e "  ${WHITE}- Static hosting: Upload build/ folder${NC}"
        echo -e "  ${WHITE}- AWS S3: aws s3 sync build/ s3://bucket-name/${NC}"
        echo -e "  ${WHITE}- Netlify: netlify deploy --prod --dir=build${NC}"
        echo -e "  ${WHITE}- Vercel: vercel --prod${NC}"
    else
        echo ""
        echo -e "${RED}✗ Failed to build frontend${NC}"
        exit 1
    fi
    
    cd ..
    
    # If --all flag, continue to build backend
    if [ "$ALL" = false ]; then
        exit 0
    fi
    
    echo ""
fi

# Build all backend services (default or with --all)
if [ -z "$SERVICE" ] && [ "$FRONTEND" = false ]; then
    echo -e "${YELLOW}Building all backend services...${NC}"
    
    if [ ! -d "services" ]; then
        echo -e "${RED}✗ Services directory not found${NC}"
        exit 1
    fi
    
    cd services
    
    SERVICE_DIRS=(
        "api-gateway"
        "auth-service"
        "user-service"
        "product-service"
        "order-service"
        "inventory-service"
        "notification-service"
    )
    
    BUILD_START_TIME=$(date +%s)
    SUCCESS_COUNT=0
    FAIL_COUNT=0
    
    for dir in "${SERVICE_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            echo ""
            echo -e "${CYAN}================================================${NC}"
            echo -e "${CYAN}  Building $dir${NC}"
            echo -e "${CYAN}================================================${NC}"
            
            cd "$dir"
            SERVICE_START_TIME=$(date +%s)
            
            mvn clean package -DskipTests
            
            SERVICE_END_TIME=$(date +%s)
            SERVICE_DURATION=$((SERVICE_END_TIME - SERVICE_START_TIME))
            
            if [ $? -eq 0 ]; then
                echo ""
                echo -e "${GREEN}✓ $dir built successfully (${SERVICE_DURATION}s)${NC}"
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                echo ""
                echo -e "${RED}✗ Failed to build $dir${NC}"
                FAIL_COUNT=$((FAIL_COUNT + 1))
            fi
            
            cd ..
        else
            echo -e "${YELLOW}⚠ Directory not found: $dir${NC}"
        fi
    done
    
    cd ..
    
    BUILD_END_TIME=$(date +%s)
    TOTAL_DURATION=$((BUILD_END_TIME - BUILD_START_TIME))
    
    echo ""
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}  Build Summary${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo -e "${GREEN}Successful: $SUCCESS_COUNT${NC}"
    if [ $FAIL_COUNT -gt 0 ]; then
        echo -e "${RED}Failed: $FAIL_COUNT${NC}"
    fi
    echo -e "${CYAN}Total time: ${TOTAL_DURATION}s${NC}"
    echo ""
    
    if [ $FAIL_COUNT -gt 0 ]; then
        echo -e "${RED}✗ Build completed with errors${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ All backend services built successfully${NC}"
    echo ""
    
    # Build Docker images
    echo -e "${YELLOW}Building Docker images...${NC}"
    docker-compose build
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ All Docker images built successfully${NC}"
    else
        echo -e "${RED}✗ Failed to build Docker images${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}  Build Complete${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  ${WHITE}- Start services: ./start.sh${NC}"
echo -e "  ${WHITE}- Deploy: See BUILD_AND_DEPLOY.md${NC}"
echo ""
