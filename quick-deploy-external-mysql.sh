#!/bin/bash

# Quick Deploy with External MySQL
# Uses your existing working MySQL container

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

log "Quick Deploy with External MySQL"
echo "==============================="

# Step 1: Ensure MySQL container is running
log "Step 1: Starting MySQL container..."
docker start lawvriksh-mysql 2>/dev/null || {
    error "MySQL container not found. Creating it..."
    docker run --name lawvriksh-mysql \
      -e MYSQL_ROOT_PASSWORD=Sahil@123456// \
      -e MYSQL_DATABASE=lawviksh_db \
      -e MYSQL_USER=lawuser \
      -e MYSQL_PASSWORD=Sahil@123456// \
      -p 3306:3306 \
      --platform linux/amd64 \
      -d \
      mysql:8
}

# Step 2: Wait for MySQL
log "Step 2: Waiting for MySQL to be ready..."
sleep 20

# Step 3: Stop existing containers
log "Step 3: Stopping existing containers..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
docker-compose -f docker-compose.prod.light.yml down 2>/dev/null || true
docker-compose -f docker-compose.prod.external-mysql.yml down 2>/dev/null || true

# Step 4: Deploy with external MySQL
log "Step 4: Deploying application..."
docker-compose -f docker-compose.prod.external-mysql-linux.yml up -d

# Step 5: Wait and check
log "Step 5: Waiting for services to start..."
sleep 30

# Step 6: Check status
log "Step 6: Checking deployment status..."
docker-compose -f docker-compose.prod.external-mysql-linux.yml ps

# Step 7: Health check
log "Step 7: Health check..."
if curl -f -s http://localhost:8000/health > /dev/null 2>&1; then
    success "✅ Deployment successful!"
    echo ""
    log "Services running:"
    docker-compose -f docker-compose.prod.external-mysql-linux.yml ps
    echo ""
    log "MySQL container:"
    docker ps | grep lawvriksh-mysql
    echo ""
    log "Access URLs:"
    echo "  API: http://localhost:8000/api/"
    echo "  Health: http://localhost:8000/health"
    echo "  Docs: http://localhost:8000/docs"
    echo ""
    success "External MySQL deployment completed!"
else
    error "❌ Health check failed. Checking logs..."
    docker-compose -f docker-compose.prod.external-mysql-linux.yml logs app --tail=20
fi

echo ""
log "Management commands:"
echo "  Logs: docker-compose -f docker-compose.prod.external-mysql-linux.yml logs -f"
echo "  Stop: docker-compose -f docker-compose.prod.external-mysql-linux.yml down"
echo "  Restart: docker-compose -f docker-compose.prod.external-mysql-linux.yml restart"
echo "  MySQL: docker exec -it lawvriksh-mysql mysql -u root -p" 