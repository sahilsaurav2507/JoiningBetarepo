@echo off
setlocal enabledelayedexpansion

REM LawViksh Backend Docker Deployment Script for Windows
REM Usage: docker-deploy.bat [dev|prod|stop|logs|restart|clean]

set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

echo %BLUE%LawViksh Backend Docker Deployment Script%NC%
echo ================================================

if "%1"=="" goto usage

if "%1"=="dev" goto deploy_dev
if "%1"=="prod" goto deploy_prod
if "%1"=="stop" goto stop_containers
if "%1"=="logs" goto show_logs
if "%1"=="restart" goto restart_services
if "%1"=="clean" goto clean_up
if "%1"=="status" goto show_status
goto usage

:deploy_dev
echo %BLUE%Deploying development environment...%NC%
docker-compose down
docker-compose build --no-cache
docker-compose up -d
echo %GREEN%Development environment deployed successfully!%NC%
echo %BLUE%Access URLs:%NC%
echo   API: http://localhost:8000
echo   Docs: http://localhost:8000/docs
echo   Health: http://localhost:8000/health
goto end

:deploy_prod
echo %BLUE%Deploying production environment...%NC%
if not exist "ssl\cert.pem" (
    echo %YELLOW%SSL certificates not found. Creating self-signed certificates...%NC%
    mkdir ssl 2>nul
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ssl\key.pem -out ssl\cert.pem -subj "/C=IN/ST=State/L=City/O=LawViksh/CN=www.lawvriksh.com"
)
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d
echo %GREEN%Production environment deployed successfully!%NC%
echo %BLUE%Access URLs:%NC%
echo   API: https://www.lawvriksh.com
echo   Docs: https://www.lawvriksh.com/docs
echo   Health: https://www.lawvriksh.com/health
goto end

:stop_containers
echo %BLUE%Stopping all containers...%NC%
docker-compose down
docker-compose -f docker-compose.prod.yml down
echo %GREEN%All containers stopped.%NC%
goto end

:show_logs
if "%2"=="prod" (
    docker-compose -f docker-compose.prod.yml logs -f
) else (
    docker-compose logs -f
)
goto end

:restart_services
if "%2"=="prod" (
    echo %BLUE%Restarting production services...%NC%
    docker-compose -f docker-compose.prod.yml restart
) else (
    echo %BLUE%Restarting development services...%NC%
    docker-compose restart
)
echo %GREEN%Services restarted.%NC%
goto end

:clean_up
echo %BLUE%Cleaning up Docker resources...%NC%
docker-compose down -v
docker-compose -f docker-compose.prod.yml down -v
docker system prune -f
echo %GREEN%Cleanup completed.%NC%
goto end

:show_status
echo %BLUE%Container Status:%NC%
echo.
echo Development Environment:
docker-compose ps
echo.
echo Production Environment:
docker-compose -f docker-compose.prod.yml ps
goto end

:usage
echo Usage: %0 {dev^|prod^|stop^|logs^|restart^|clean^|status}
echo.
echo Commands:
echo   dev     - Deploy development environment
echo   prod    - Deploy production environment
echo   stop    - Stop all containers
echo   logs    - Show logs (add 'prod' for production)
echo   restart - Restart services (add 'prod' for production)
echo   clean   - Clean up Docker resources
echo   status  - Show container status
goto end

:end
pause 