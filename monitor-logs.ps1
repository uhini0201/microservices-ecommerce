#!/usr/bin/env pwsh
# Script to continuously monitor and save logs in real-time

param(
    [int]$Interval = 1,  # Update interval in seconds (default: 1)
    [switch]$Backend,
    [switch]$Frontend,
    [switch]$All
)

$projectRoot = $PSScriptRoot
$logsDir = Join-Path $projectRoot "logs"
$backendLogsDir = Join-Path $logsDir "backend"
$frontendLogsDir = Join-Path $logsDir "frontend"
$liveLogsDir = Join-Path $logsDir "live"

# Ensure log directories exist
if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir | Out-Null }
if (-not (Test-Path $backendLogsDir)) { New-Item -ItemType Directory -Path $backendLogsDir | Out-Null }
if (-not (Test-Path $frontendLogsDir)) { New-Item -ItemType Directory -Path $frontendLogsDir | Out-Null }
if (-not (Test-Path $liveLogsDir)) { New-Item -ItemType Directory -Path $liveLogsDir | Out-Null }

$services = @(
    "api-gateway",
    "auth-service",
    "user-service",
    "product-service",
    "order-service",
    "inventory-service",
    "notification-service"
)

$infrastructure = @(
    "postgres",
    "kafka",
    "redis",
    "zookeeper"
)

# Track last log position for each service
$lastPositions = @{}

function Initialize-LogTracking {
    foreach ($service in ($services + $infrastructure)) {
        $lastPositions[$service] = 0
    }
}

function Get-NewLogLines {
    param(
        [string]$ServiceName
    )
    
    $containerName = "microservices-project-$ServiceName-1"
    
    try {
        # Get all logs
        $allLogs = docker logs $containerName 2>&1 | Out-String
        $lines = $allLogs -split "`n"
        
        # Get new lines since last check
        $currentLineCount = $lines.Count
        $lastCount = $lastPositions[$ServiceName]
        
        if ($currentLineCount -gt $lastCount) {
            $newLines = $lines[$lastCount..($currentLineCount - 1)]
            $lastPositions[$ServiceName] = $currentLineCount
            return $newLines
        }
        
        return @()
    } catch {
        return @()
    }
}

function Save-LiveLogs {
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    
    foreach ($service in ($services + $infrastructure)) {
        $containerName = "microservices-project-$service-1"
        $logFile = Join-Path $liveLogsDir "${service}_live.log"
        
        try {
            # Append new logs to live log file
            docker logs $containerName 2>&1 | Out-File -FilePath $logFile -Encoding UTF8
        } catch {
            # Service might not be running
        }
    }
}

function Monitor-Logs {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  LIVE LOG MONITORING STARTED" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Update Interval: $Interval second(s)" -ForegroundColor Yellow
    Write-Host "Live logs location: logs/live/" -ForegroundColor White
    Write-Host ""
    Write-Host "Monitoring services:" -ForegroundColor Yellow
    foreach ($service in $services) {
        Write-Host "  - $service" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "Infrastructure components:" -ForegroundColor Yellow
    foreach ($infra in $infrastructure) {
        Write-Host "  - $infra" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    $iteration = 0
    
    try {
        while ($true) {
            $iteration++
            $timestamp = Get-Date -Format "HH:mm:ss"
            
            # Save all logs
            foreach ($service in ($services + $infrastructure)) {
                $containerName = "microservices-project-$service-1"
                $logFile = Join-Path $liveLogsDir "${service}_live.log"
                
                try {
                    docker logs $containerName 2>&1 | Out-File -FilePath $logFile -Encoding UTF8
                } catch {
                    # Service might not be running
                }
            }
            
            # Show progress
            if ($iteration % 10 -eq 0) {
                Write-Host "[$timestamp] Logs updated (iteration $iteration)" -ForegroundColor Gray
            }
            
            # Wait for next interval
            Start-Sleep -Seconds $Interval
        }
    } finally {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "  LIVE LOG MONITORING STOPPED" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Total iterations: $iteration" -ForegroundColor White
        Write-Host "Live logs saved to: $liveLogsDir" -ForegroundColor Green
        Write-Host ""
        
        # Create final snapshot
        $snapshotTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        foreach ($service in ($services + $infrastructure)) {
            $liveLogFile = Join-Path $liveLogsDir "${service}_live.log"
            $snapshotFile = Join-Path $backendLogsDir "${service}_${snapshotTime}.log"
            
            if (Test-Path $liveLogFile) {
                Copy-Item -Path $liveLogFile -Destination $snapshotFile
            }
        }
        
        Write-Host "Final snapshot saved with timestamp: $snapshotTime" -ForegroundColor Green
        Write-Host ""
    }
}

# Main execution
Initialize-LogTracking

if ($All -or (-not $Backend -and -not $Frontend)) {
    Monitor-Logs
} elseif ($Backend) {
    Monitor-Logs
} elseif ($Frontend) {
    Write-Host "Frontend live logging not yet implemented." -ForegroundColor Yellow
    Write-Host "Frontend logs are in browser console." -ForegroundColor Yellow
}
