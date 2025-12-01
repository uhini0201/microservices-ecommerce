#!/bin/bash
# Script to clean up old log files (older than 1 day)

DAYS_OLD=1
DRY_RUN=false
DELETE_ALL=false

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --days|-d)
            DAYS_OLD="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --all)
            DELETE_ALL=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --days, -d N    Delete logs older than N days (default: 1)"
            echo "  --dry-run       Show what would be deleted without deleting"
            echo "  --all           Delete all logs regardless of age"
            echo "  --help, -h      Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS_DIR="$PROJECT_ROOT/logs"

echo -e "\n${CYAN}========================================${NC}"
echo -e "${YELLOW}  LOG CLEANUP UTILITY${NC}"
echo -e "${CYAN}========================================${NC}\n"

if [ ! -d "$LOGS_DIR" ]; then
    echo -e "${YELLOW}No logs directory found. Nothing to clean.${NC}\n"
    exit 0
fi

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}DRY RUN MODE - No files will be deleted${NC}\n"
fi

DELETED_COUNT=0
FREED_SPACE=0

cleanup_directory() {
    local DIR=$1
    local LABEL=$2
    
    if [ ! -d "$DIR" ]; then
        return
    fi
    
    echo -e "${CYAN}Scanning: ${LABEL}${NC}"
    
    if [ "$DELETE_ALL" = true ]; then
        FILES=$(find "$DIR" -type f)
        FILE_COUNT=$(echo "$FILES" | grep -c .)
        echo -e "  Found: ${FILE_COUNT} files (all will be deleted)"
    else
        FILES=$(find "$DIR" -type f -mtime +$DAYS_OLD)
        FILE_COUNT=$(echo "$FILES" | grep -c . 2>/dev/null || echo 0)
        echo -e "  Found: ${FILE_COUNT} files older than ${DAYS_OLD} day(s)"
    fi
    
    if [ -z "$FILES" ] || [ "$FILE_COUNT" -eq 0 ]; then
        echo -e "${GRAY}  No files to delete${NC}\n"
        return
    fi
    
    while IFS= read -r file; do
        if [ -z "$file" ]; then
            continue
        fi
        
        FILE_SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
        FREED_SPACE=$((FREED_SPACE + FILE_SIZE))
        FILE_SIZE_KB=$(echo "scale=2; $FILE_SIZE / 1024" | bc)
        FILE_NAME=$(basename "$file")
        AGE=$(find "$file" -mtime +0 -printf "%A@\n" 2>/dev/null || echo "0")
        
        if [ "$DRY_RUN" = true ]; then
            echo -e "${GRAY}  [DRY RUN] Would delete: ${FILE_NAME} (${FILE_SIZE_KB} KB)${NC}"
        else
            echo -e "${RED}  Deleting: ${FILE_NAME} (${FILE_SIZE_KB} KB)${NC}"
            rm -f "$file"
            DELETED_COUNT=$((DELETED_COUNT + 1))
        fi
    done <<< "$FILES"
    
    echo ""
}

# Show cleanup criteria
echo -e "${YELLOW}Cleanup criteria:${NC}"
if [ "$DELETE_ALL" = true ]; then
    echo -e "${RED}  Delete ALL logs${NC}"
else
    echo -e "  Delete logs older than: ${DAYS_OLD} day(s)"
    CUTOFF_DATE=$(date -d "$DAYS_OLD days ago" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -v-${DAYS_OLD}d "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
    echo -e "${GRAY}  Cutoff date: ${CUTOFF_DATE}${NC}"
fi
echo ""

# Clean different log directories
cleanup_directory "$LOGS_DIR/backend" "Backend Logs (logs/backend/)"
cleanup_directory "$LOGS_DIR/frontend" "Frontend Logs (logs/frontend/)"
cleanup_directory "$LOGS_DIR/live" "Live Logs (logs/live/)"

# Clean snapshots
if [ -d "$LOGS_DIR/snapshots" ]; then
    echo -e "${CYAN}Scanning: Snapshots (logs/snapshots/)${NC}"
    
    if [ "$DELETE_ALL" = true ]; then
        SNAPSHOT_DIRS=$(find "$LOGS_DIR/snapshots" -mindepth 1 -maxdepth 1 -type d)
    else
        SNAPSHOT_DIRS=$(find "$LOGS_DIR/snapshots" -mindepth 1 -maxdepth 1 -type d -mtime +$DAYS_OLD)
    fi
    
    SNAPSHOT_COUNT=$(echo "$SNAPSHOT_DIRS" | grep -c . 2>/dev/null || echo 0)
    
    if [ "$DELETE_ALL" = true ]; then
        echo -e "  Found: ${SNAPSHOT_COUNT} snapshot directories (all will be deleted)"
    else
        echo -e "  Found: ${SNAPSHOT_COUNT} snapshot directories older than ${DAYS_OLD} day(s)"
    fi
    
    if [ ! -z "$SNAPSHOT_DIRS" ] && [ "$SNAPSHOT_COUNT" -gt 0 ]; then
        while IFS= read -r dir; do
            if [ -z "$dir" ]; then
                continue
            fi
            
            DIR_SIZE=$(du -sk "$dir" | cut -f1)
            DIR_SIZE=$((DIR_SIZE * 1024))
            FREED_SPACE=$((FREED_SPACE + DIR_SIZE))
            DIR_SIZE_KB=$(echo "scale=2; $DIR_SIZE / 1024" | bc)
            DIR_NAME=$(basename "$dir")
            
            if [ "$DRY_RUN" = true ]; then
                echo -e "${GRAY}  [DRY RUN] Would delete directory: ${DIR_NAME} (${DIR_SIZE_KB} KB)${NC}"
            else
                echo -e "${RED}  Deleting directory: ${DIR_NAME} (${DIR_SIZE_KB} KB)${NC}"
                rm -rf "$dir"
                DELETED_COUNT=$((DELETED_COUNT + 1))
            fi
        done <<< "$SNAPSHOT_DIRS"
    else
        echo -e "${GRAY}  No directories to delete${NC}"
    fi
    echo ""
fi

# Clean summary files
if [ "$DELETE_ALL" = true ]; then
    SUMMARY_FILES=$(find "$LOGS_DIR" -maxdepth 1 -name "logs_summary_*.txt")
else
    SUMMARY_FILES=$(find "$LOGS_DIR" -maxdepth 1 -name "logs_summary_*.txt" -mtime +$DAYS_OLD)
fi

SUMMARY_COUNT=$(echo "$SUMMARY_FILES" | grep -c . 2>/dev/null || echo 0)

if [ ! -z "$SUMMARY_FILES" ] && [ "$SUMMARY_COUNT" -gt 0 ]; then
    echo -e "${CYAN}Scanning: Summary Files (logs/)${NC}"
    echo -e "  Found: ${SUMMARY_COUNT} summary files"
    
    while IFS= read -r file; do
        if [ -z "$file" ]; then
            continue
        fi
        
        FILE_SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
        FREED_SPACE=$((FREED_SPACE + FILE_SIZE))
        FILE_SIZE_KB=$(echo "scale=2; $FILE_SIZE / 1024" | bc)
        FILE_NAME=$(basename "$file")
        
        if [ "$DRY_RUN" = true ]; then
            echo -e "${GRAY}  [DRY RUN] Would delete: ${FILE_NAME} (${FILE_SIZE_KB} KB)${NC}"
        else
            echo -e "${RED}  Deleting: ${FILE_NAME} (${FILE_SIZE_KB} KB)${NC}"
            rm -f "$file"
            DELETED_COUNT=$((DELETED_COUNT + 1))
        fi
    done <<< "$SUMMARY_FILES"
    echo ""
fi

# Summary
echo -e "${CYAN}========================================${NC}"
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}  DRY RUN SUMMARY${NC}"
else
    echo -e "${GREEN}  CLEANUP COMPLETE${NC}"
fi
echo -e "${CYAN}========================================${NC}\n"

FREED_SPACE_MB=$(echo "scale=2; $FREED_SPACE / 1048576" | bc)

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Would delete: ${DELETED_COUNT} items${NC}"
    echo -e "${YELLOW}Would free: ${FREED_SPACE_MB} MB${NC}\n"
else
    if [ "$DELETED_COUNT" -gt 0 ]; then
        echo -e "${GREEN}Deleted: ${DELETED_COUNT} items${NC}"
        echo -e "${GREEN}Freed: ${FREED_SPACE_MB} MB${NC}\n"
    else
        echo -e "${GRAY}No files to delete${NC}\n"
    fi
fi

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}To actually delete these files, run without --dry-run:${NC}"
    echo -e "${GRAY}  ./clean-logs.sh${NC}\n"
fi
