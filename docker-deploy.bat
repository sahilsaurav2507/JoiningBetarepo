@echo off
setlocal enabledelayedexpansion

REM LawViksh Backend Docker Deployment Script for Windows
REM This script automates the deployment of the LawViksh backend using Docker

set "COMMAND=%1"
if "%COMMAND%"=="" set "COMMAND=help"

REM Colors for output (Windows 10+)
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

REM Logging function
:log
echo %BLUE%[%date% %time%]%NC% %~1
goto :eof

REM Error function
:error
echo %RED%[ERROR]%NC% %~1 >&2
goto :eof

REM Success function
:success
echo %GREEN%[SUCCESS]%NC% %~1
goto :eof

REM Warning function
:warning
echo %YELLOW%[WARNING]%NC% %~1
goto :eof

REM Check if Docker is installed
:check_docker
docker --version >nul 2>&1
if errorlevel 1 (
    call :error "Docker is not installed. Please install Docker Desktop first."
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    call :error "Docker Compose is not installed. Please install Docker Compose first."
    exit /b 1
)

call :success "Docker and Docker Compose are installed"
goto :eof

REM Check if .env file exists
:check_env_file
if not exist ".env" (
    call :warning ".env file not found. Creating from example..."
    if exist "env.example" (
        copy "env.example" ".env" >nul
        call :warning "Please edit .env file with your production values before continuing"
        exit /b 1
    ) else (
        call :error "env.example file not found. Please create a .env file manually."
        exit /b 1
    )
)
call :success "Environment file found"
goto :eof

REM Build Docker images
:build_images
call :log "Building Docker images..."
docker-compose build --no-cache
if errorlevel 1 (
    call :error "Failed to build Docker images"
    exit /b 1
)
call :success "Docker images built successfully"
goto :eof

REM Start services
:start_services
call :log "Starting services..."
docker-compose up -d
if errorlevel 1 (
    call :error "Failed to start services"
    exit /b 1
)
call :success "Services started successfully"
goto :eof

REM Check service health
:check_health
call :log "Checking service health..."
timeout /t 10 /nobreak >nul

REM Check if containers are running
docker-compose ps | findstr "Up" >nul
if errorlevel 1 (
    call :error "Some services are not running properly"
    docker-compose logs
    exit /b 1
)

REM Check health endpoint
curl -f http://localhost:8000/health >nul 2>&1
if errorlevel 1 (
    call :warning "Health check failed, but services are running"
) else (
    call :success "Application is healthy and responding"
)
goto :eof

REM Stop services
:stop_services
call :log "Stopping services..."
docker-compose down
call :success "Services stopped successfully"
goto :eof

REM Clean up
:cleanup
call :log "Cleaning up unused Docker resources..."
docker system prune -f
call :success "Cleanup completed"
goto :eof

REM Show logs
:show_logs
call :log "Showing service logs..."
docker-compose logs -f
goto :eof

REM Production deployment
:deploy_production
call :log "Starting production deployment..."

call :check_docker
if errorlevel 1 exit /b 1

call :check_env_file
if errorlevel 1 exit /b 1

REM Stop existing services
docker-compose down >nul 2>&1

REM Build and start with production compose file
call :log "Building production images..."
docker-compose -f docker-compose.prod.yml build --no-cache
if errorlevel 1 (
    call :error "Failed to build production images"
    exit /b 1
)

call :log "Starting production services..."
docker-compose -f docker-compose.prod.yml up -d
if errorlevel 1 (
    call :error "Failed to start production services"
    exit /b 1
)

call :success "Production deployment completed"
call :check_health
goto :eof

REM Development deployment
:deploy_development
call :log "Starting development deployment..."

call :check_docker
if errorlevel 1 exit /b 1

call :check_env_file
if errorlevel 1 exit /b 1

REM Stop existing services
docker-compose down >nul 2>&1

call :build_images
if errorlevel 1 exit /b 1

call :start_services
if errorlevel 1 exit /b 1

call :check_health
goto :eof

REM Main script logic
if "%COMMAND%"=="start" goto :deploy_development
if "%COMMAND%"=="deploy" goto :deploy_development
if "%COMMAND%"=="prod" goto :deploy_production
if "%COMMAND%"=="production" goto :deploy_production
if "%COMMAND%"=="stop" goto :stop_services
if "%COMMAND%"=="restart" (
    call :stop_services
    timeout /t 2 /nobreak >nul
    goto :deploy_development
)
if "%COMMAND%"=="logs" goto :show_logs
if "%COMMAND%"=="cleanup" goto :cleanup
if "%COMMAND%"=="health" goto :check_health
if "%COMMAND%"=="help" goto :show_help
goto :show_help

:show_help
echo LawViksh Backend Docker Deployment Script for Windows
echo.
echo Usage: %0 [COMMAND]
echo.
echo Commands:
echo   start, deploy    - Deploy the application (development)
echo   prod, production - Deploy the application (production)
echo   stop            - Stop all services
echo   restart         - Restart all services
echo   logs            - Show service logs
echo   cleanup         - Clean up unused Docker resources
echo   health          - Check service health
echo   help            - Show this help message
echo.
echo Examples:
echo   %0 start        # Start development deployment
echo   %0 production   # Start production deployment
echo   %0 logs         # View logs
echo.
pause
exit /b 0 