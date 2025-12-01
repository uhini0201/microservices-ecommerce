#!/usr/bin/env pwsh
# Script to tail and continuously update log files in real-time

param(
    [int]$UpdateInterval = 1,  # Update interval in seconds
    [int]$TailLines = 100      # Number of recent lines to keep per update
)

$projectRoot = $PSScriptRoot
$logsDir = Join-Path $projectRoot "logs"
$liveLogsDir = Join-Path $logsDir "live"

# Ensure directories exist
if (-not (Test-Path $liveLogsDir)) { 
    New-Item -ItemType Directory -Path $liveLogsDir -Force | Out-Null 
}

$services = @(
    @{Name="api-gateway"; Color="Cyan"},
    @{Name="auth-service"; Color="Green"},
    @{Name="user-service"; Color="Yellow"},
    @{Name="product-service"; Color="Magenta"},
    @{Name="order-service"; Color="Blue"},
    @{Name="inventory-service"; Color="DarkCyan"},
    @{Name="notification-service"; Color="DarkGreen"}
)

$infrastructure = @(
    @{Name="postgres"; Color="DarkYellow"},
    @{Name="kafka"; Color="DarkMagenta"},
    @{Name="redis"; Color="DarkRed"},
    @{Name="zookeeper"; Color="DarkGray"}
)

$allComponents = $services + $infrastructure

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  REAL-TIME LOG MONITOR & UPDATER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Update Interval: $UpdateInterval second(s)" -ForegroundColor Yellow
Write-Host "Logs Directory: logs/live/" -ForegroundColor White
Write-Host ""
Write-Host "Monitoring:" -ForegroundColor Yellow
foreach ($comp in $allComponents) {
    Write-Host "  - $($comp.Name)" -ForegroundColor $comp.Color
}
Write-Host ""
Write-Host "Press Ctrl+C to stop" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$iteration = 0
$startTime = Get-Date

try {
    while ($true) {
        $iteration++
        $currentTime = Get-Date -Format "HH:mm:ss"
        
        foreach ($comp in $allComponents) {
            $containerName = "microservices-project-$($comp.Name)-1"
            $logFile = Join-Path $liveLogsDir "$($comp.Name).log"
            
            try {
                # Get latest logs and save to file
                docker logs --tail $TailLines $containerName 2>&1 | Out-File -FilePath $logFile -Encoding UTF8
            } catch {
                # Container might not be running
            }
        }
        
        # Show status every 5 iterations
        if ($iteration % 5 -eq 0) {
            $elapsed = ((Get-Date) - $startTime).ToString("hh\:mm\:ss")
            Write-Host "[$currentTime] Updated all logs (iteration: $iteration, elapsed: $elapsed)" -ForegroundColor Gray
        }
        
        Start-Sleep -Seconds $UpdateInterval
    }
}
finally {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  LOG MONITORING STOPPED" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    Write-Host "Summary:" -ForegroundColor Yellow
    Write-Host "  Total iterations: $iteration" -ForegroundColor White
    Write-Host "  Duration: $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor White
    Write-Host "  Logs saved to: $liveLogsDir" -ForegroundColor Green
    Write-Host ""
    
    # Create timestamped backup
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $backupDir = Join-Path $logsDir "snapshots"
    $snapshotDir = Join-Path $backupDir $timestamp
    
    if (-not (Test-Path $snapshotDir)) {
        New-Item -ItemType Directory -Path $snapshotDir -Force | Out-Null
    }
    
    Write-Host "Creating snapshot backup..." -ForegroundColor Yellow
    Get-ChildItem $liveLogsDir -Filter "*.log" | ForEach-Object {
        Copy-Item $_.FullName -Destination $snapshotDir
    }
    
    Write-Host "  Snapshot saved: logs/snapshots/$timestamp/" -ForegroundColor Green
    Write-Host ""
}
