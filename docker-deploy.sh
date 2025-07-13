#!/bin/bash

# LawViksh Backend Docker Deployment Script
# This script automates the deployment of the LawViksh backend using Docker

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

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
    
    success "Docker and Docker Compose are installed"
}

# Check if .env file exists
check_env_file() {
    if [ ! -f .env ]; then
        warning ".env file not found. Creating from example..."
        if [ -f env.example ]; then
            cp env.example .env
            warning "Please edit .env file with your production values before continuing"
            exit 1
        else
            error "env.example file not found. Please create a .env file manually."
            exit 1
        fi
    fi
    success "Environment file found"
}

# Build Docker images
build_images() {
    log "Building Docker images..."
    docker-compose build --no-cache
    success "Docker images built successfully"
}

# Start services
start_services() {
    log "Starting services..."
    docker-compose up -d
    success "Services started successfully"
}

# Check service health
check_health() {
    log "Checking service health..."
    
    # Wait for services to be ready
    sleep 10
    
    # Check if containers are running
    if ! docker-compose ps | grep -q "Up"; then
        error "Some services are not running properly"
        docker-compose logs
        exit 1
    fi
    
    # Check health endpoint
    if curl -f http://localhost:8000/health > /dev/null 2>&1; then
        success "Application is healthy and responding"
    else
        warning "Health check failed, but services are running"
    fi
}

# Stop services
stop_services() {
    log "Stopping services..."
    docker-compose down
    success "Services stopped successfully"
}

# Clean up
cleanup() {
    log "Cleaning up unused Docker resources..."
    docker system prune -f
    success "Cleanup completed"
}

# Show logs
show_logs() {
    log "Showing service logs..."
    docker-compose logs -f
}

# Production deployment
deploy_production() {
    log "Starting production deployment..."
    
    check_docker
    check_env_file
    
    # Stop existing services
    docker-compose down 2>/dev/null || true
    
    # Build and start with production compose file
    log "Building production images..."
    docker-compose -f docker-compose.prod.yml build --no-cache
    
    log "Starting production services..."
    docker-compose -f docker-compose.prod.yml up -d
    
    success "Production deployment completed"
    check_health
}

# Development deployment
deploy_development() {
    log "Starting development deployment..."
    
    check_docker
    check_env_file
    
    # Stop existing services
    docker-compose down 2>/dev/null || true
    
    build_images
    start_services
    check_health
}

# Main script logic
case "${1:-help}" in
    "start"|"deploy")
        deploy_development
        ;;
    "prod"|"production")
        deploy_production
        ;;
    "stop")
        stop_services
        ;;
    "restart")
        stop_services
        sleep 2
        deploy_development
        ;;
    "logs")
        show_logs
        ;;
    "cleanup")
        cleanup
        ;;
    "health")
        check_health
        ;;
    "help"|*)
        echo "LawViksh Backend Docker Deployment Script"
        echo ""
        echo "Usage: $0 [COMMAND]"
        echo ""
        echo "Commands:"
        echo "  start, deploy    - Deploy the application (development)"
        echo "  prod, production - Deploy the application (production)"
        echo "  stop            - Stop all services"
        echo "  restart         - Restart all services"
        echo "  logs            - Show service logs"
        echo "  cleanup         - Clean up unused Docker resources"
        echo "  health          - Check service health"
        echo "  help            - Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 start        # Start development deployment"
        echo "  $0 production   # Start production deployment"
        echo "  $0 logs         # View logs"
        ;;
esac 