#!/bin/bash
# Script to tail and continuously update log files in real-time (Linux/Mac)

UPDATE_INTERVAL=${1:-1}  # Update interval in seconds (default: 1)
TAIL_LINES=${2:-100}      # Number of recent lines to keep per update (default: 100)

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS_DIR="$PROJECT_ROOT/logs"
LIVE_LOGS_DIR="$LOGS_DIR/live"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
GRAY='\033[0;37m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Ensure directories exist
mkdir -p "$LIVE_LOGS_DIR"

SERVICES=(
    "api-gateway"
    "auth-service"
    "user-service"
    "product-service"
    "order-service"
    "inventory-service"
    "notification-service"
)

INFRASTRUCTURE=(
    "postgres"
    "kafka"
    "redis"
    "zookeeper"
)

ALL_COMPONENTS=("${SERVICES[@]}" "${INFRASTRUCTURE[@]}")

echo -e "\n${CYAN}========================================${NC}"
echo -e "${CYAN}  REAL-TIME LOG MONITOR & UPDATER${NC}"
echo -e "${CYAN}========================================${NC}\n"
echo -e "${YELLOW}Update Interval: ${UPDATE_INTERVAL} second(s)${NC}"
echo -e "Logs Directory: ${LIVE_LOGS_DIR}\n"
echo -e "${YELLOW}Monitoring:${NC}"

for comp in "${ALL_COMPONENTS[@]}"; do
    echo -e "  - ${comp}"
done

echo -e "\n${RED}Press Ctrl+C to stop${NC}"
echo -e "${CYAN}========================================${NC}\n"

ITERATION=0
START_TIME=$(date +%s)

cleanup() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${YELLOW}  LOG MONITORING STOPPED${NC}"
    echo -e "${CYAN}========================================${NC}\n"
    
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    HOURS=$((DURATION / 3600))
    MINUTES=$(((DURATION % 3600) / 60))
    SECONDS=$((DURATION % 60))
    
    echo -e "${YELLOW}Summary:${NC}"
    echo -e "  Total iterations: ${ITERATION}"
    printf "  Duration: %02d:%02d:%02d\n" $HOURS $MINUTES $SECONDS
    echo -e "  ${GREEN}Logs saved to: ${LIVE_LOGS_DIR}${NC}\n"
    
    # Create timestamped backup
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    BACKUP_DIR="$LOGS_DIR/snapshots"
    SNAPSHOT_DIR="$BACKUP_DIR/$TIMESTAMP"
    
    mkdir -p "$SNAPSHOT_DIR"
    
    echo -e "${YELLOW}Creating snapshot backup...${NC}"
    cp "$LIVE_LOGS_DIR"/*.log "$SNAPSHOT_DIR/" 2>/dev/null
    
    echo -e "  ${GREEN}Snapshot saved: logs/snapshots/$TIMESTAMP/${NC}\n"
    exit 0
}

trap cleanup SIGINT SIGTERM

while true; do
    ITERATION=$((ITERATION + 1))
    CURRENT_TIME=$(date +"%H:%M:%S")
    
    for comp in "${ALL_COMPONENTS[@]}"; do
        CONTAINER_NAME="microservices-project-${comp}-1"
        LOG_FILE="$LIVE_LOGS_DIR/${comp}.log"
        
        # Get latest logs and save to file
        docker logs --tail $TAIL_LINES "$CONTAINER_NAME" > "$LOG_FILE" 2>&1 || true
    done
    
    # Show status every 5 iterations
    if [ $((ITERATION % 5)) -eq 0 ]; then
        ELAPSED_TIME=$(($(date +%s) - START_TIME))
        ELAPSED_HOURS=$((ELAPSED_TIME / 3600))
        ELAPSED_MINUTES=$(((ELAPSED_TIME % 3600) / 60))
        ELAPSED_SECONDS=$((ELAPSED_TIME % 60))
        printf "${GRAY}[%s] Updated all logs (iteration: %d, elapsed: %02d:%02d:%02d)${NC}\n" \
            "$CURRENT_TIME" "$ITERATION" "$ELAPSED_HOURS" "$ELAPSED_MINUTES" "$ELAPSED_SECONDS"
    fi
    
    sleep $UPDATE_INTERVAL
done
