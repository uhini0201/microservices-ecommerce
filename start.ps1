# Microservices E-commerce Platform - Startup Script (Windows)
# This script starts all Docker containers and the React frontend
#
# Usage:
#   .\start.ps1                    - Start all services
#   .\start.ps1 -Build             - Build all services before starting
#   .\start.ps1 -Service auth      - Start only specific service
#   .\start.ps1 -Build -Service product - Build and start specific service

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
        Write-Host "✗ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}
Write-Host ""

# Navigate to script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Check if docker-compose.yml exists
if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "✗ docker-compose.yml not found in current directory" -ForegroundColor Red
    exit 1
}

# Build services if requested
if ($Build) {
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  Building Services" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    
    if ($Service -ne "") {
        Write-Host "Building $Service service..." -ForegroundColor Yellow
        $servicePath = "services/$Service-service"
        
        if (-not (Test-Path $servicePath)) {
            Write-Host "✗ Service directory not found: $servicePath" -ForegroundColor Red
            exit 1
        }
        
        Set-Location $servicePath
        Write-Host "Running Maven build in $servicePath..." -ForegroundColor Yellow
        mvn clean package -DskipTests
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ $Service service built successfully" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed to build $Service service" -ForegroundColor Red
            exit 1
        }
        
        Set-Location $scriptPath
        Write-Host ""
    } else {
        Write-Host "Building all backend services..." -ForegroundColor Yellow
        Set-Location services
        
        $serviceDirs = @("auth-service", "user-service", "product-service", "order-service", "inventory-service", "notification-service", "api-gateway")
        
        foreach ($dir in $serviceDirs) {
            if (Test-Path $dir) {
                Write-Host ""
                Write-Host "Building $dir..." -ForegroundColor Cyan
                Set-Location $dir
                mvn clean package -DskipTests
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✓ $dir built successfully" -ForegroundColor Green
                } else {
                    Write-Host "✗ Failed to build $dir" -ForegroundColor Red
                    Set-Location $scriptPath
                    exit 1
                }
                Set-Location ..
            }
        }
        
        Set-Location $scriptPath
        Write-Host ""
        Write-Host "✓ All backend services built successfully" -ForegroundColor Green
        Write-Host ""
    }
    
    # Rebuild Docker images
    Write-Host "Rebuilding Docker images..." -ForegroundColor Yellow
    if ($Service -ne "") {
        docker-compose build $Service-service
    } else {
        docker-compose build
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Docker images rebuilt successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to rebuild Docker images" -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

# Start Docker containers
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Step 1: Starting Docker Microservices" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

if ($Service -ne "") {
    Write-Host "Starting $Service service..." -ForegroundColor Yellow
    docker-compose up -d $Service-service
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ $Service service started successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to start $Service service" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Starting all microservices containers..." -ForegroundColor Yellow
    docker-compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ All Docker containers started successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to start Docker containers" -ForegroundColor Red
        exit 1
    }
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

# Health check for key services
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Step 2: Health Check" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$services = @(
    @{name="API Gateway"; port=8080; endpoint="/actuator/health"},
    @{name="Auth Service"; port=8086; endpoint="/auth/health"},
    @{name="User Service"; port=8087; endpoint="/users/health"},
    @{name="Product Service"; port=8083; endpoint="/products/health"},
    @{name="Order Service"; port=8082; endpoint="/order/health"},
    @{name="Inventory Service"; port=8085; endpoint="/inventory/health"}
)

foreach ($service in $services) {
    Write-Host -NoNewline "Checking $($service.name) (port $($service.port))... "
    
    $maxAttempts = 10
    $attempt = 0
    $ready = $false
    
    while ($attempt -lt $maxAttempts) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$($service.port)$($service.endpoint)" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-Host "✓ Ready" -ForegroundColor Green
                $ready = $true
                break
            }
        } catch {
            # Service not ready yet
        }
# Start frontend only if no specific service was requested
if ($Service -eq "") {
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  Step 3: Starting React Frontend" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""

    if (-not (Test-Path "frontend")) {
        Write-Host "✗ Frontend directory not found" -ForegroundColor Red
        exit 1
    }

    Set-Location frontend

    # Build frontend if requested
    if ($Build) {
        Write-Host "Building frontend..." -ForegroundColor Yellow
        
        # Check if node_modules exists
        if (-not (Test-Path "node_modules")) {
            Write-Host "⚠ node_modules not found. Running npm install..." -ForegroundColor Yellow
            npm install
        }
        
        Write-Host "Running production build..." -ForegroundColor Yellow
        npm run build
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Frontend built successfully" -ForegroundColor Green
            Write-Host "Production build available in: frontend/build" -ForegroundColor Cyan
        } else {
            Write-Host "✗ Failed to build frontend" -ForegroundColor Red
            exit 1
        }
        Write-Host ""
    }

    # Check if node_modules exists
    if (-not (Test-Path "node_modules")) {
        Write-Host "⚠ node_modules not found. Running npm install..." -ForegroundColor Yellow
        npm install
        Write-Host ""
    }

    Write-Host "Starting React development server..." -ForegroundColor Yellow
    Write-Host "Note: Frontend will open automatically at http://localhost:3000" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  Press Ctrl+C to stop all services" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""

    # Start frontend (this will run in foreground)
    npm start
} else {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  $Service Service Started" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "✓ $Service service is now running" -ForegroundColor Green
    Write-Host "View logs: docker-compose logs -f $Service-service" -ForegroundColor Cyan
    Write-Host "Stop service: docker-compose stop $Service-service" -ForegroundColor Cyan
    Write-Host ""
}

# This script will keep running until Ctrl+C is pressed (if frontend started)

Write-Host "Starting React development server..." -ForegroundColor Yellow
Write-Host "Note: Frontend will open automatically at http://localhost:3000" -ForegroundColor Yellow
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Press Ctrl+C to stop all services" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Start frontend (this will run in foreground)
npm start

# This script will keep running until Ctrl+C is pressed
