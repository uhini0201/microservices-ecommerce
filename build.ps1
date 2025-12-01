# Microservices E-commerce Platform - Build Script (Windows)
# This script builds backend services and/or frontend
#
# Usage:
#   .\build.ps1                    - Build all services
#   .\build.ps1 -Service auth      - Build only auth service
#   .\build.ps1 -Frontend          - Build only frontend
#   .\build.ps1 -All               - Build everything (backend + frontend)

param(
    [string]$Service = "",
    [switch]$Frontend,
    [switch]$All
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Microservices E-commerce Platform Build" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Build specific service
if ($Service -ne "") {
    Write-Host "Building $Service service..." -ForegroundColor Yellow
    $servicePath = "services/$Service-service"
    
    if (-not (Test-Path $servicePath)) {
        Write-Host "✗ Service directory not found: $servicePath" -ForegroundColor Red
        Write-Host ""
        Write-Host "Available services:" -ForegroundColor Cyan
        Write-Host "  - auth" -ForegroundColor White
        Write-Host "  - user" -ForegroundColor White
        Write-Host "  - product" -ForegroundColor White
        Write-Host "  - order" -ForegroundColor White
        Write-Host "  - inventory" -ForegroundColor White
        Write-Host "  - notification" -ForegroundColor White
        Write-Host "  - api-gateway" -ForegroundColor White
        exit 1
    }
    
    Write-Host ""
    Write-Host "Maven clean package for $Service-service..." -ForegroundColor Cyan
    Set-Location $servicePath
    mvn clean package -DskipTests
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✓ $Service service built successfully" -ForegroundColor Green
        Write-Host "JAR location: $servicePath/target/" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "✗ Failed to build $Service service" -ForegroundColor Red
        exit 1
    }
    
    Set-Location $scriptPath
    
    # Build Docker image
    Write-Host ""
    Write-Host "Building Docker image for $Service-service..." -ForegroundColor Yellow
    docker-compose build $Service-service
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Docker image built successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to build Docker image" -ForegroundColor Red
        exit 1
    }
}
# Build frontend
elseif ($Frontend -or $All) {
    if ($Frontend) {
        Write-Host "Building frontend..." -ForegroundColor Yellow
    }
    
    if (-not (Test-Path "frontend")) {
        Write-Host "✗ Frontend directory not found" -ForegroundColor Red
        exit 1
    }
    
    Set-Location frontend
    
    # Install dependencies if needed
    if (-not (Test-Path "node_modules")) {
        Write-Host ""
        Write-Host "Installing npm dependencies..." -ForegroundColor Yellow
        npm install
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "✗ Failed to install dependencies" -ForegroundColor Red
            exit 1
        }
    }
    
    # Build frontend
    Write-Host ""
    Write-Host "Building React production bundle..." -ForegroundColor Cyan
    npm run build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✓ Frontend built successfully" -ForegroundColor Green
        Write-Host "Production build: frontend/build/" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Deploy to:" -ForegroundColor Yellow
        Write-Host "  - Static hosting: Upload build/ folder" -ForegroundColor White
        Write-Host "  - AWS S3: aws s3 sync build/ s3://bucket-name/" -ForegroundColor White
        Write-Host "  - Netlify: netlify deploy --prod --dir=build" -ForegroundColor White
        Write-Host "  - Vercel: vercel --prod" -ForegroundColor White
    } else {
        Write-Host ""
        Write-Host "✗ Failed to build frontend" -ForegroundColor Red
        exit 1
    }
    
    Set-Location $scriptPath
    
    # If -All flag, continue to build backend
    if (-not $All) {
        exit 0
    }
    
    Write-Host ""
}

# Build all backend services (default or with -All)
if ($Service -eq "" -and -not $Frontend) {
    Write-Host "Building all backend services..." -ForegroundColor Yellow
    
    if (-not (Test-Path "services")) {
        Write-Host "✗ Services directory not found" -ForegroundColor Red
        exit 1
    }
    
    Set-Location services
    
    $serviceDirs = @(
        "api-gateway",
        "auth-service",
        "user-service",
        "product-service",
        "order-service",
        "inventory-service",
        "notification-service"
    )
    
    $buildStartTime = Get-Date
    $successCount = 0
    $failCount = 0
    
    foreach ($dir in $serviceDirs) {
        if (Test-Path $dir) {
            Write-Host ""
            Write-Host "================================================" -ForegroundColor Cyan
            Write-Host "  Building $dir" -ForegroundColor Cyan
            Write-Host "================================================" -ForegroundColor Cyan
            
            Set-Location $dir
            $serviceStartTime = Get-Date
            
            mvn clean package -DskipTests
            
            $serviceEndTime = Get-Date
            $serviceDuration = ($serviceEndTime - $serviceStartTime).TotalSeconds
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "✓ $dir built successfully ($([math]::Round($serviceDuration, 1))s)" -ForegroundColor Green
                $successCount++
            } else {
                Write-Host ""
                Write-Host "✗ Failed to build $dir" -ForegroundColor Red
                $failCount++
            }
            
            Set-Location ..
        } else {
            Write-Host "⚠ Directory not found: $dir" -ForegroundColor Yellow
        }
    }
    
    Set-Location $scriptPath
    
    $buildEndTime = Get-Date
    $totalDuration = ($buildEndTime - $buildStartTime).TotalSeconds
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  Build Summary" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "Successful: $successCount" -ForegroundColor Green
    if ($failCount -gt 0) {
        Write-Host "Failed: $failCount" -ForegroundColor Red
    }
    Write-Host "Total time: $([math]::Round($totalDuration, 1))s" -ForegroundColor Cyan
    Write-Host ""
    
    if ($failCount -gt 0) {
        Write-Host "✗ Build completed with errors" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✓ All backend services built successfully" -ForegroundColor Green
    Write-Host ""
    
    # Build Docker images
    Write-Host "Building Docker images..." -ForegroundColor Yellow
    docker-compose build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ All Docker images built successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to build Docker images" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Build Complete" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  - Start services: .\start.ps1" -ForegroundColor White
Write-Host "  - Deploy: See BUILD_AND_DEPLOY.md" -ForegroundColor White
Write-Host ""
