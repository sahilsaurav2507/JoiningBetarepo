#!/bin/bash

# MySQL Issue Fix Script
# Usage: ./fix-mysql-issue.sh

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

log "MySQL Issue Fix Script"
echo "======================"

# Step 1: Stop all containers
log "Step 1: Stopping all containers..."
docker-compose -f docker-compose.prod.yml down
success "All containers stopped"

# Step 2: Clean up MySQL volume (optional)
echo ""
warning "Step 2: Do you want to remove MySQL volume to start fresh?"
warning "This will delete all existing database data!"
read -p "Remove MySQL volume? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Removing MySQL volume..."
    docker volume rm joiningbetarepo_mysql_data_prod 2>/dev/null || true
    success "MySQL volume removed"
else
    log "Keeping existing MySQL volume"
fi

# Step 3: Check system resources
echo ""
log "Step 3: Checking system resources..."
echo "Available memory:"
free -h
echo ""
echo "Available disk space:"
df -h

# Step 4: Start MySQL only first
echo ""
log "Step 4: Starting MySQL container only..."
docker-compose -f docker-compose.prod.yml up -d mysql

# Step 5: Wait and check MySQL status
echo ""
log "Step 5: Waiting for MySQL to start..."
sleep 30

# Check MySQL logs
echo ""
log "Checking MySQL logs..."
docker-compose -f docker-compose.prod.yml logs mysql

# Check MySQL health
echo ""
log "Checking MySQL health status..."
if docker-compose -f docker-compose.prod.yml exec mysql mysqladmin ping -h localhost -u root -p${DB_ROOT_PASSWORD:-Sahil@123} 2>/dev/null; then
    success "MySQL is healthy!"
else
    error "MySQL is still not healthy. Checking logs..."
    docker-compose -f docker-compose.prod.yml logs mysql --tail=50
    echo ""
    warning "MySQL might need more time to start. Try waiting a few more minutes."
fi

# Step 6: Start other services if MySQL is healthy
echo ""
log "Step 6: Starting other services..."
docker-compose -f docker-compose.prod.yml up -d

# Step 7: Final health check
echo ""
log "Step 7: Final health check..."
sleep 30

if curl -f -s https://www.lawvriksh.com/health > /dev/null 2>&1; then
    success "✅ All services are running successfully!"
    echo ""
    log "Service status:"
    docker-compose -f docker-compose.prod.yml ps
else
    warning "⚠️  Some services might still be starting up."
    echo ""
    log "Current service status:"
    docker-compose -f docker-compose.prod.yml ps
    echo ""
    log "Recent logs:"
    docker-compose -f docker-compose.prod.yml logs --tail=20
fi

echo ""
success "MySQL issue fix completed!"
echo ""
log "If issues persist, try these additional steps:"
echo "1. Check system resources: free -h && df -h"
echo "2. Increase swap space if memory is low"
echo "3. Check Docker logs: sudo journalctl -u docker"
echo "4. Restart Docker: sudo systemctl restart docker"
echo "5. Use MySQL 5.7 instead of 8.0 for lower resource usage" 