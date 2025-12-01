#!/usr/bin/env pwsh
# Script to save logs for all services

param(
    [switch]$Frontend,
    [switch]$Backend,
    [switch]$All
)

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$projectRoot = $PSScriptRoot
$logsDir = Join-Path $projectRoot "logs"
$backendLogsDir = Join-Path $logsDir "backend"
$frontendLogsDir = Join-Path $logsDir "frontend"

# Ensure log directories exist
if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir | Out-Null }
if (-not (Test-Path $backendLogsDir)) { New-Item -ItemType Directory -Path $backendLogsDir | Out-Null }
if (-not (Test-Path $frontendLogsDir)) { New-Item -ItemType Directory -Path $frontendLogsDir | Out-Null }

function Save-BackendLogs {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  SAVING BACKEND LOGS" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    $services = @(
        "api-gateway",
        "auth-service",
        "user-service",
        "product-service",
        "order-service",
        "inventory-service",
        "notification-service",
        "postgres",
        "kafka",
        "redis",
        "zookeeper"
    )

    foreach ($service in $services) {
        $containerName = "microservices-project-$service-1"
        $logFile = Join-Path $backendLogsDir "${service}_${timestamp}.log"
        
        Write-Host "Saving logs for $service..." -ForegroundColor White
        
        try {
            docker logs $containerName > $logFile 2>&1
            $fileSize = (Get-Item $logFile).Length
            $fileSizeKB = [math]::Round($fileSize / 1KB, 2)
            Write-Host "  Saved to: logs/backend/${service}_${timestamp}.log (${fileSizeKB} KB)" -ForegroundColor Green
        } catch {
            Write-Host "  Failed to save logs for $service" -ForegroundColor Red
        }
    }

    Write-Host ""
    Write-Host "Backend logs saved to: $backendLogsDir" -ForegroundColor Green
}

function Save-FrontendLogs {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  SAVING FRONTEND LOGS" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    # Save browser console logs instructions
    $instructionsFile = Join-Path $frontendLogsDir "frontend_${timestamp}_instructions.txt"
    $instructions = @"
Frontend Logs - $timestamp
========================================

To save browser console logs:
1. Open Developer Tools (F12)
2. Go to Console tab
3. Right-click and select 'Save as...'

To save network logs:
1. Open Developer Tools (F12)
2. Go to Network tab
3. Right-click and select 'Save all as HAR'

To check frontend build logs:
- Check: frontend/npm-debug.log (if exists)
- Check: frontend/build output

Frontend server process logs are ephemeral.
For server logs, redirect output when starting:
  serve -s build -l 3000 > logs/frontend/frontend_TIMESTAMP.log 2>&1
"@
    
    $instructions | Out-File -FilePath $instructionsFile -Encoding UTF8

    Write-Host "Frontend logging instructions saved to: logs/frontend/frontend_${timestamp}_instructions.txt" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Note: Frontend logs are primarily in browser console." -ForegroundColor Yellow
    Write-Host "For server logs, redirect output when starting the frontend server" -ForegroundColor Yellow
}

# Main execution
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    MICROSERVICES LOG SAVER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($All -or (-not $Frontend -and -not $Backend)) {
    Save-BackendLogs
    Save-FrontendLogs
} else {
    if ($Backend) {
        Save-BackendLogs
    }
    if ($Frontend) {
        Save-FrontendLogs
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  LOGS SAVED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Log location: $logsDir" -ForegroundColor White
Write-Host "Timestamp: $timestamp" -ForegroundColor Gray
Write-Host ""

# Create a summary file
$summaryFile = Join-Path $logsDir "logs_summary_${timestamp}.txt"
$summary = "Logs Summary - $timestamp`n"
$summary += "========================================`n`n"

if ($Backend -or $All -or (-not $Frontend -and -not $Backend)) {
    $summary += "Backend Logs:`n"
    Get-ChildItem $backendLogsDir -Filter "*${timestamp}.log" | ForEach-Object {
        $size = [math]::Round($_.Length / 1KB, 2)
        $summary += "  - $($_.Name) ($size KB)`n"
    }
    $summary += "`n"
}

if ($Frontend -or $All -or (-not $Frontend -and -not $Backend)) {
    $summary += "Frontend Logs:`n"
    Get-ChildItem $frontendLogsDir -Filter "*${timestamp}*" | ForEach-Object {
        $summary += "  - $($_.Name)`n"
    }
    $summary += "`n"
}

$totalCount = 0
if ($Backend -or $All -or (-not $Frontend -and -not $Backend)) { 
    $totalCount += (Get-ChildItem $backendLogsDir -Filter "*${timestamp}.log").Count 
}
if ($Frontend -or $All -or (-not $Frontend -and -not $Backend)) { 
    $totalCount += (Get-ChildItem $frontendLogsDir -Filter "*${timestamp}*").Count 
}

$summary += "Total Log Files: $totalCount`n"

$summary | Out-File -FilePath $summaryFile -Encoding UTF8

Write-Host "Summary saved to: logs/logs_summary_${timestamp}.txt" -ForegroundColor Cyan
Write-Host ""
