# Logs Directory

This directory contains saved logs for frontend and backend services.

## Directory Structure

```
logs/
├── backend/           # Backend microservices logs
│   ├── api-gateway_YYYY-MM-DD_HH-MM-SS.log
│   ├── auth-service_YYYY-MM-DD_HH-MM-SS.log
│   ├── user-service_YYYY-MM-DD_HH-MM-SS.log
│   ├── product-service_YYYY-MM-DD_HH-MM-SS.log
│   ├── order-service_YYYY-MM-DD_HH-MM-SS.log
│   ├── inventory-service_YYYY-MM-DD_HH-MM-SS.log
│   ├── notification-service_YYYY-MM-DD_HH-MM-SS.log
│   ├── postgres_YYYY-MM-DD_HH-MM-SS.log
│   ├── kafka_YYYY-MM-DD_HH-MM-SS.log
│   ├── redis_YYYY-MM-DD_HH-MM-SS.log
│   └── zookeeper_YYYY-MM-DD_HH-MM-SS.log
├── frontend/          # Frontend logs and instructions
│   ├── frontend_YYYY-MM-DD_HH-MM-SS.log
│   └── frontend_YYYY-MM-DD_HH-MM-SS_instructions.txt
└── logs_summary_YYYY-MM-DD_HH-MM-SS.txt
```

## Usage

### 🔴 Live Real-Time Logging (Recommended)

**Monitor and auto-update all logs every second:**

**Windows:**
```powershell
.\live-logs.ps1
```

This will:
- Update log files every 1 second (default)
- Save to `logs/live/` directory
- Create automatic snapshot on exit to `logs/snapshots/TIMESTAMP/`
- Show progress updates every 5 iterations
- Press Ctrl+C to stop and save final snapshot

**Custom update interval (e.g., every 2 seconds):**
```powershell
.\live-logs.ps1 -UpdateInterval 2
```

**Custom tail lines (default 100):**
```powershell
.\live-logs.ps1 -TailLines 200
```

### 📸 One-Time Snapshot Logs

**Save All Logs (Backend + Frontend):**

**Windows:**
```powershell
.\save-logs.ps1
# or
.\save-logs.ps1 -All
```

**Linux/Mac:**
```bash
./save-logs.sh
# or
./save-logs.sh --all
```

**Save Backend Logs Only:**

**Windows:**
```powershell
.\save-logs.ps1 -Backend
```

**Linux/Mac:**
```bash
./save-logs.sh --backend
```

**Save Frontend Logs Only:**

**Windows:**
```powershell
.\save-logs.ps1 -Frontend
```

**Linux/Mac:**
```bash
./save-logs.sh --frontend
```

## Backend Logs

Backend logs are automatically captured from Docker containers and saved to `logs/backend/`.

Each service log includes:
- Application startup logs
- Request/response logs
- Error traces
- Spring Boot actuator logs
- Database connection logs

## Frontend Logs

Frontend logs are primarily captured in the browser console. The script creates an instructions file for saving:

1. **Browser Console Logs:**
   - Open Developer Tools (F12)
   - Go to Console tab
   - Right-click and select "Save as..."

2. **Network Logs:**
   - Open Developer Tools (F12)
   - Go to Network tab
   - Right-click and select "Save all as HAR"

3. **Frontend Server Logs:**
   To capture server logs, start the frontend with output redirection:
   ```bash
   serve -s build -l 3000 > logs/frontend/frontend_$(date +%Y-%m-%d_%H-%M-%S).log 2>&1 &
   ```

## 🧹 Log Cleanup

Logs are timestamped and accumulate over time. Use the cleanup script to manage disk space:

### Automated Cleanup Script

**Preview what will be deleted (Dry Run):**

**Windows:**
```powershell
.\clean-logs.ps1 -DryRun
```

**Linux/Mac:**
```bash
./clean-logs.sh --dry-run
```

**Delete logs older than 1 day (default):**

**Windows:**
```powershell
.\clean-logs.ps1
```

**Linux/Mac:**
```bash
./clean-logs.sh
```

**Delete logs older than 7 days:**

**Windows:**
```powershell
.\clean-logs.ps1 -DaysOld 7
```

**Linux/Mac:**
```bash
./clean-logs.sh --days 7
```

**Delete ALL logs:**

**Windows:**
```powershell
.\clean-logs.ps1 -All
```

**Linux/Mac:**
```bash
./clean-logs.sh --all
```

The cleanup script will:
- ✅ Delete old log files from `logs/backend/`
- ✅ Delete old log files from `logs/frontend/`
- ✅ Delete old log files from `logs/live/`
- ✅ Delete old snapshot directories from `logs/snapshots/`
- ✅ Delete old summary files from `logs/`
- ✅ Show how much disk space was freed
- ✅ Support dry-run mode to preview changes

## Viewing Logs

### View Recent Logs

**Windows:**
```powershell
# View latest backend service log
Get-Content logs/backend/api-gateway_*.log | Select-Object -Last 50

# Monitor logs in real-time
Get-Content logs/backend/api-gateway_*.log -Wait -Tail 50
```

**Linux/Mac:**
```bash
# View latest backend service log
tail -n 50 logs/backend/api-gateway_*.log

# Monitor logs in real-time
tail -f logs/backend/api-gateway_*.log
```

### Search Logs

**Windows:**
```powershell
# Search for errors
Get-ChildItem -Path "logs/backend" -Filter "*.log" | Select-String "ERROR"

# Search specific service
Get-Content logs/backend/order-service_*.log | Select-String "exception" -Context 5
```

**Linux/Mac:**
```bash
# Search for errors
grep -r "ERROR" logs/backend/

# Search specific service
grep -A 5 -B 5 "exception" logs/backend/order-service_*.log
```

## Log Levels

Backend services use Spring Boot logging with the following levels:
- **TRACE**: Most detailed
- **DEBUG**: Detailed information for debugging
- **INFO**: General information (default)
- **WARN**: Warning messages
- **ERROR**: Error messages
- **FATAL**: Critical errors

## Troubleshooting

### Logs Not Being Saved

1. Ensure Docker containers are running:
   ```bash
   docker ps
   ```

2. Check container names match the expected pattern:
   ```bash
   docker ps --format "{{.Names}}"
   ```

3. Verify log directory permissions:
   ```bash
   ls -la logs/
   ```

### Large Log Files

If log files become too large:

1. Enable log rotation in Spring Boot (`application.yml`):
   ```yaml
   logging:
     file:
       name: logs/app.log
       max-size: 10MB
       max-history: 10
   ```

2. Use Docker log rotation in `docker-compose.yml`:
   ```yaml
   logging:
     driver: "json-file"
     options:
       max-size: "10m"
       max-file: "3"
   ```

## Notes

- Log files are excluded from Git via `.gitignore`
- Each log save creates a timestamped summary file
- Backend logs capture stderr and stdout
- Frontend logs require manual browser export for console output
