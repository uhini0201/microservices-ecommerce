# Microservices E-commerce Platform - Startup Script (Windows)
param(
    [switch]$Build,
    [string]$Service = ""
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Microservices E-commerce Platform Startup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "Checking Docker status..." -ForegroundColor Yellow
try {
    $dockerInfo = docker info 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "X Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
        exit 1
    }
    Write-Host "Docker is running" -ForegroundColor Green
} catch {
    Write-Host "X Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}
Write-Host ""

# Navigate to script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Start Docker containers
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Step 1: Starting Docker Microservices" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Starting all microservices containers..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "All Docker containers started successfully" -ForegroundColor Green
} else {
    Write-Host "X Failed to start Docker containers" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Wait for services to be ready
Write-Host "Waiting for services to initialize..." -ForegroundColor Yellow
Write-Host "This may take 30-60 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 45

# Check container status
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Docker Container Status" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | Select-String "service|postgres|kafka|redis|gateway"
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Backend Services Started Successfully!" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Services are running:" -ForegroundColor Green
Write-Host "  API Gateway:     http://localhost:8080" -ForegroundColor Cyan
Write-Host "  Auth Service:    http://localhost:8086" -ForegroundColor Cyan
Write-Host "  User Service:    http://localhost:8087" -ForegroundColor Cyan
Write-Host "  Product Service: http://localhost:8083" -ForegroundColor Cyan
Write-Host "  Order Service:   http://localhost:8082" -ForegroundColor Cyan
Write-Host "  Inventory:       http://localhost:8085" -ForegroundColor Cyan
Write-Host "  Notification:    http://localhost:8084" -ForegroundColor Cyan
Write-Host ""

# Start Frontend
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Step 2: Starting React Frontend" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path "frontend")) {
    Write-Host "X Frontend directory not found" -ForegroundColor Red
    exit 1
}

Set-Location frontend

# Check if node_modules exists
if (-not (Test-Path "node_modules")) {
    Write-Host "node_modules not found. Running npm install..." -ForegroundColor Yellow
    npm install
    Write-Host ""
}

# Check if build folder exists
if (-not (Test-Path "build")) {
    Write-Host "Production build not found. Running npm run build..." -ForegroundColor Yellow
    npm run build
    Write-Host ""
}

Write-Host "Starting production server with serve..." -ForegroundColor Yellow
Write-Host "Frontend will be available at http://localhost:3000" -ForegroundColor Yellow
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Press Ctrl+C to stop all services" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Start frontend production server
npx serve -s build -l 3000
