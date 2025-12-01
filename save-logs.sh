#!/bin/bash
# Script to save logs for all services

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS_DIR="$PROJECT_ROOT/logs"
BACKEND_LOGS_DIR="$LOGS_DIR/backend"
FRONTEND_LOGS_DIR="$LOGS_DIR/frontend"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Ensure log directories exist
mkdir -p "$LOGS_DIR"
mkdir -p "$BACKEND_LOGS_DIR"
mkdir -p "$FRONTEND_LOGS_DIR"

save_backend_logs() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${YELLOW}  SAVING BACKEND LOGS${NC}"
    echo -e "${CYAN}========================================${NC}\n"

    SERVICES=(
        "api-gateway"
        "auth-service"
        "user-service"
        "product-service"
        "order-service"
        "inventory-service"
        "notification-service"
        "postgres"
        "kafka"
        "redis"
        "zookeeper"
    )

    for SERVICE in "${SERVICES[@]}"; do
        CONTAINER_NAME="microservices-project-${SERVICE}-1"
        LOG_FILE="$BACKEND_LOGS_DIR/${SERVICE}_${TIMESTAMP}.log"
        
        echo -e "Saving logs for ${SERVICE}..."
        
        if docker logs "$CONTAINER_NAME" > "$LOG_FILE" 2>&1; then
            FILE_SIZE=$(du -h "$LOG_FILE" | cut -f1)
            echo -e "  ${GREEN}✓ Saved to: logs/backend/${SERVICE}_${TIMESTAMP}.log ($FILE_SIZE)${NC}"
        else
            echo -e "  ${RED}✗ Failed to save logs for ${SERVICE}${NC}"
        fi
    done

    echo -e "\n${GREEN}✓ Backend logs saved to: $BACKEND_LOGS_DIR${NC}"
}

save_frontend_logs() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${YELLOW}  SAVING FRONTEND LOGS${NC}"
    echo -e "${CYAN}========================================${NC}\n"

    FRONTEND_LOG_FILE="$FRONTEND_LOGS_DIR/frontend_${TIMESTAMP}.log"
    
    # Save browser console logs instructions
    INSTRUCTIONS_FILE="$FRONTEND_LOGS_DIR/frontend_${TIMESTAMP}_instructions.txt"
    cat > "$INSTRUCTIONS_FILE" << EOF
Frontend Logs - $TIMESTAMP
========================================

To save browser console logs:
1. Open Developer Tools (F12)
2. Go to Console tab
3. Right-click and select "Save as..."

To save network logs:
1. Open Developer Tools (F12)
2. Go to Network tab
3. Right-click and select "Save all as HAR"

To check frontend build logs:
- Check: frontend/npm-debug.log (if exists)
- Check: frontend/build output

Frontend server process logs are ephemeral.
Consider using 'npm start > logs/frontend/npm.log 2>&1' when starting.
EOF

    echo -e "${GREEN}✓ Frontend logging instructions saved to: logs/frontend/frontend_${TIMESTAMP}_instructions.txt${NC}"
    
    echo -e "\n${YELLOW}Note: Frontend logs are primarily in browser console.${NC}"
    echo -e "${YELLOW}For server logs, restart frontend with:${NC}"
    echo -e "${GRAY}  serve -s build -l 3000 > logs/frontend/frontend_${TIMESTAMP}.log 2>&1 &${NC}"
}

# Parse arguments
BACKEND=false
FRONTEND=false
ALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --backend|-b)
            BACKEND=true
            shift
            ;;
        --frontend|-f)
            FRONTEND=true
            shift
            ;;
        --all|-a)
            ALL=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--backend|-b] [--frontend|-f] [--all|-a]"
            exit 1
            ;;
    esac
done

# Main execution
echo -e "\n${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     MICROSERVICES LOG SAVER            ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"

if [ "$ALL" = true ] || ([ "$BACKEND" = false ] && [ "$FRONTEND" = false ]); then
    save_backend_logs
    save_frontend_logs
else
    if [ "$BACKEND" = true ]; then
        save_backend_logs
    fi
    if [ "$FRONTEND" = true ]; then
        save_frontend_logs
    fi
fi

echo -e "\n${CYAN}========================================${NC}"
echo -e "${GREEN}  LOGS SAVED SUCCESSFULLY!${NC}"
echo -e "${CYAN}========================================${NC}\n"
echo -e "Log location: ${LOGS_DIR}"
echo -e "${GRAY}Timestamp: ${TIMESTAMP}${NC}\n"

# Create a summary file
SUMMARY_FILE="$LOGS_DIR/logs_summary_${TIMESTAMP}.txt"
cat > "$SUMMARY_FILE" << EOF
Logs Summary - $TIMESTAMP
========================================

Backend Logs:
$(if [ "$BACKEND" = true ] || [ "$ALL" = true ] || ([ "$BACKEND" = false ] && [ "$FRONTEND" = false ]); then
    ls -lh "$BACKEND_LOGS_DIR"/*${TIMESTAMP}.log 2>/dev/null | awk '{print "  - " $9 " (" $5 ")"}'
fi)

Frontend Logs:
$(if [ "$FRONTEND" = true ] || [ "$ALL" = true ] || ([ "$BACKEND" = false ] && [ "$FRONTEND" = false ]); then
    ls -lh "$FRONTEND_LOGS_DIR"/*${TIMESTAMP}* 2>/dev/null | awk '{print "  - " $9}'
fi)

Total Log Files: $(
    COUNT=0
    if [ "$BACKEND" = true ] || [ "$ALL" = true ] || ([ "$BACKEND" = false ] && [ "$FRONTEND" = false ]); then
        COUNT=$((COUNT + $(ls "$BACKEND_LOGS_DIR"/*${TIMESTAMP}.log 2>/dev/null | wc -l)))
    fi
    if [ "$FRONTEND" = true ] || [ "$ALL" = true ] || ([ "$BACKEND" = false ] && [ "$FRONTEND" = false ]); then
        COUNT=$((COUNT + $(ls "$FRONTEND_LOGS_DIR"/*${TIMESTAMP}* 2>/dev/null | wc -l)))
    fi
    echo $COUNT
)
EOF

echo -e "${CYAN}Summary saved to: logs/logs_summary_${TIMESTAMP}.txt${NC}\n"
