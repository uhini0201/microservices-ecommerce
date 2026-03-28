# Microservices E-commerce Platform - Shutdown Script (Windows)
# This script stops all Docker containers and the React frontend

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Microservices E-commerce Platform Shutdown" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Stop frontend if running
Write-Host "Stopping frontend (if running)..." -ForegroundColor Yellow

# Check for both development server (react-scripts) and production server (serve)
$nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue

if ($nodeProcesses) {
    Write-Host "Found Node.js process(es). Stopping all..." -ForegroundColor Yellow
    $nodeProcesses | Stop-Process -Force
    Write-Host "✓ Frontend stopped" -ForegroundColor Green
} else {
    Write-Host "⚠ No running Node.js processes found" -ForegroundColor Yellow
}
Write-Host ""

# Stop Docker containers
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Stopping Docker Containers" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

if (Test-Path "docker-compose.yml") {
    Write-Host "Stopping all Docker containers..." -ForegroundColor Yellow
    docker-compose down
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ All Docker containers stopped successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to stop Docker containers" -ForegroundColor Red
    }
} else {
    Write-Host "✗ docker-compose.yml not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Shutdown Complete" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "All services have been stopped." -ForegroundColor Green
Write-Host "To restart, run: .\start.ps1" -ForegroundColor Cyan
