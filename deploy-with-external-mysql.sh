#!/bin/bash

# Deploy with External MySQL Script
# This script uses the manually created MySQL container

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

log "Deploying with External MySQL Container"
echo "======================================"

# Step 1: Check if external MySQL container exists
log "Step 1: Checking external MySQL container..."
if docker ps -a | grep -q "lawvriksh-mysql"; then
    success "External MySQL container found"
else
    error "External MySQL container not found. Please create it first:"
    echo ""
    echo "docker run --name lawvriksh-mysql \\"
    echo "  -e MYSQL_ROOT_PASSWORD=Sahil@123456// \\"
    echo "  -e MYSQL_DATABASE=lawviksh_db \\"
    echo "  -e MYSQL_USER=lawuser \\"
    echo "  -e MYSQL_PASSWORD=Sahil@123456// \\"
    echo "  -p 3306:3306 \\"
    echo "  --platform linux/amd64 \\"
    echo "  -d \\"
    echo "  mysql:8"
    echo ""
    exit 1
fi

# Step 2: Start external MySQL container
log "Step 2: Starting external MySQL container..."
docker start lawvriksh-mysql
success "External MySQL container started"

# Step 3: Wait for MySQL to be ready
log "Step 3: Waiting for MySQL to be ready..."
sleep 30

# Step 4: Test MySQL connection
log "Step 4: Testing MySQL connection..."
if docker exec lawvriksh-mysql mysqladmin ping -h localhost -u root -pSahil@123456// > /dev/null 2>&1; then
    success "MySQL connection successful"
else
    error "MySQL connection failed. Please check the container logs:"
    docker logs lawvriksh-mysql
    exit 1
fi

# Step 5: Stop any existing containers
log "Step 5: Stopping existing containers..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
docker-compose -f docker-compose.prod.light.yml down 2>/dev/null || true
success "Existing containers stopped"

# Step 6: Deploy application with external MySQL
log "Step 6: Deploying application with external MySQL..."
docker-compose -f docker-compose.prod.external-mysql.yml up -d

# Step 7: Wait for services to start
log "Step 7: Waiting for services to start..."
sleep 30

# Step 8: Check service status
log "Step 8: Checking service status..."
docker-compose -f docker-compose.prod.external-mysql.yml ps

# Step 9: Health check
log "Step 9: Performing health check..."
if curl -f -s http://localhost:8000/health > /dev/null 2>&1; then
    success "✅ Application deployed successfully with external MySQL!"
    echo ""
    log "Service Status:"
    docker-compose -f docker-compose.prod.external-mysql.yml ps
    echo ""
    log "MySQL Container Status:"
    docker ps | grep lawvriksh-mysql
    echo ""
    log "Access URLs:"
    echo "  API: http://localhost:8000/api/"
    echo "  Health: http://localhost:8000/health"
    echo "  Docs: http://localhost:8000/docs"
    echo ""
    log "Database Connection:"
    echo "  Host: host.docker.internal:3306"
    echo "  Database: lawviksh_db"
    echo "  User: root"
    echo ""
    success "External MySQL deployment completed successfully!"
else
    error "❌ Health check failed. Checking logs..."
    docker-compose -f docker-compose.prod.external-mysql.yml logs app
    exit 1
fi

echo ""
log "Useful commands:"
echo "  View logs: docker-compose -f docker-compose.prod.external-mysql.yml logs -f"
echo "  Stop services: docker-compose -f docker-compose.prod.external-mysql.yml down"
echo "  Restart services: docker-compose -f docker-compose.prod.external-mysql.yml restart"
echo "  MySQL logs: docker logs lawvriksh-mysql"
echo "  Access MySQL: docker exec -it lawvriksh-mysql mysql -u root -p" 