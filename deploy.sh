#!/bin/bash

# LawViksh Backend Docker Deployment Script
# Usage: ./deploy.sh [dev|prod|stop|logs|restart|clean]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
}

# Check if .env file exists
check_env() {
    if [ ! -f .env ]; then
        warning "No .env file found. Creating from env.example..."
        if [ -f env.example ]; then
            cp env.example .env
            warning "Please edit .env file with your configuration values."
        else
            error "No env.example file found. Please create a .env file manually."
            exit 1
        fi
    fi
}

# Deploy development environment
deploy_dev() {
    log "Deploying development environment..."
    check_docker
    check_env
    
    docker-compose down
    docker-compose build --no-cache
    docker-compose up -d
    
    success "Development environment deployed successfully!"
    log "Access URLs:"
    log "  API: http://localhost:8000"
    log "  Docs: http://localhost:8000/docs"
    log "  Health: http://localhost:8000/health"
}

# Deploy production environment
deploy_prod() {
    log "Deploying production environment..."
    check_docker
    check_env
    
    # Check for SSL certificates
    if [ ! -f ssl/cert.pem ] || [ ! -f ssl/key.pem ]; then
        warning "SSL certificates not found. Creating self-signed certificates..."
        mkdir -p ssl
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout ssl/key.pem -out ssl/cert.pem \
            -subj "/C=IN/ST=State/L=City/O=LawViksh/CN=www.lawvriksh.com"
    fi
    
    docker-compose -f docker-compose.prod.yml down
    docker-compose -f docker-compose.prod.yml build --no-cache
    docker-compose -f docker-compose.prod.yml up -d
    
    success "Production environment deployed successfully!"
    log "Access URLs:"
    log "  API: https://www.lawvriksh.com"
    log "  Docs: https://www.lawvriksh.com/docs"
    log "  Health: https://www.lawvriksh.com/health"
}

# Stop all containers
stop_containers() {
    log "Stopping all containers..."
    docker-compose down
    docker-compose -f docker-compose.prod.yml down
    success "All containers stopped."
}

# Show logs
show_logs() {
    if [ "$2" = "prod" ]; then
        docker-compose -f docker-compose.prod.yml logs -f
    else
        docker-compose logs -f
    fi
}

# Restart services
restart_services() {
    if [ "$2" = "prod" ]; then
        log "Restarting production services..."
        docker-compose -f docker-compose.prod.yml restart
    else
        log "Restarting development services..."
        docker-compose restart
    fi
    success "Services restarted."
}

# Clean up
clean_up() {
    log "Cleaning up Docker resources..."
    docker-compose down -v
    docker-compose -f docker-compose.prod.yml down -v
    docker system prune -f
    success "Cleanup completed."
}

# Show status
show_status() {
    log "Container Status:"
    echo ""
    echo "Development Environment:"
    docker-compose ps
    echo ""
    echo "Production Environment:"
    docker-compose -f docker-compose.prod.yml ps
}

# Main script logic
case "$1" in
    "dev")
        deploy_dev
        ;;
    "prod")
        deploy_prod
        ;;
    "stop")
        stop_containers
        ;;
    "logs")
        show_logs "$@"
        ;;
    "restart")
        restart_services "$@"
        ;;
    "clean")
        clean_up
        ;;
    "status")
        show_status
        ;;
    *)
        echo "Usage: $0 {dev|prod|stop|logs|restart|clean|status}"
        echo ""
        echo "Commands:"
        echo "  dev     - Deploy development environment"
        echo "  prod    - Deploy production environment"
        echo "  stop    - Stop all containers"
        echo "  logs    - Show logs (add 'prod' for production)"
        echo "  restart - Restart services (add 'prod' for production)"
        echo "  clean   - Clean up Docker resources"
        echo "  status  - Show container status"
        exit 1
        ;;
esac 