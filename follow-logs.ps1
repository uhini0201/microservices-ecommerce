#!/usr/bin/env pwsh
# Script to follow logs in real-time and save to files

param(
    [string]$Service = "all",  # Specific service or "all"
    [switch]$SaveToFile = $true
)

$projectRoot = $PSScriptRoot
$logsDir = Join-Path $projectRoot "logs"
$liveLogsDir = Join-Path $logsDir "live"

# Ensure log directories exist
if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir | Out-Null }
if (-not (Test-Path $liveLogsDir)) { New-Item -ItemType Directory -Path $liveLogsDir | Out-Null }

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

function Start-LiveLogging {
    param([string]$ServiceName)
    
    $containerName = "microservices-project-$ServiceName-1"
    $logFile = Join-Path $liveLogsDir "${ServiceName}_live.log"
    
    Write-Host "Starting live logging for: $ServiceName" -ForegroundColor Green
    Write-Host "  Container: $containerName" -ForegroundColor Gray
    Write-Host "  Log file: logs/live/${ServiceName}_live.log" -ForegroundColor Gray
    Write-Host ""
    
    # Start docker logs in background and redirect to file
    $job = Start-Job -ScriptBlock {
        param($container, $logPath)
        docker logs -f $container 2>&1 | Out-File -FilePath $logPath -Encoding UTF8 -Append
    } -ArgumentList $containerName, $logFile
    
    return $job
}

# Main execution
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  LIVE LOG STREAMING" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$jobs = @()

if ($Service -eq "all") {
    Write-Host "Starting live logging for all services..." -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($svc in $services) {
        $job = Start-LiveLogging -ServiceName $svc
        $jobs += $job
    }
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "All services are now being monitored!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Live logs location: logs/live/" -ForegroundColor White
    Write-Host "Press Ctrl+C to stop all monitoring" -ForegroundColor Yellow
    Write-Host ""
    
    # Wait for jobs (until user cancels)
    try {
        Wait-Job -Job $jobs
    } finally {
        Write-Host ""
        Write-Host "Stopping all log monitoring jobs..." -ForegroundColor Yellow
        Stop-Job -Job $jobs
        Remove-Job -Job $jobs
        Write-Host "Live logging stopped." -ForegroundColor Green
    }
} else {
    if ($services -contains $Service) {
        $job = Start-LiveLogging -ServiceName $Service
        
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "Monitoring $Service" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor Yellow
        Write-Host ""
        
        try {
            Wait-Job -Job $job
        } finally {
            Write-Host ""
            Write-Host "Stopping log monitoring..." -ForegroundColor Yellow
            Stop-Job -Job $job
            Remove-Job -Job $job
            Write-Host "Live logging stopped." -ForegroundColor Green
        }
    } else {
        Write-Host "Error: Service '$Service' not found" -ForegroundColor Red
        Write-Host ""
        Write-Host "Available services:" -ForegroundColor Yellow
        foreach ($svc in $services) {
            Write-Host "  - $svc" -ForegroundColor White
        }
    }
}
