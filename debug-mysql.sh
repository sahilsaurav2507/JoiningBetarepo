#!/bin/bash

# MySQL Container Debugging Script
# Usage: ./debug-mysql.sh

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

log "MySQL Container Debugging Script"
echo "=================================="

# Check if containers are running
log "1. Checking container status..."
docker-compose -f docker-compose.prod.yml ps

echo ""

# Check MySQL container logs
log "2. Checking MySQL container logs..."
docker-compose -f docker-compose.prod.yml logs mysql

echo ""

# Check if MySQL container exists
log "3. Checking MySQL container details..."
if docker ps -a | grep -q "lawviksh_mysql_prod"; then
    success "MySQL container exists"
    docker inspect lawviksh_mysql_prod | grep -E "(Status|State|Health)"
else
    error "MySQL container not found"
fi

echo ""

# Check system resources
log "4. Checking system resources..."
echo "Memory usage:"
free -h
echo ""
echo "Disk usage:"
df -h
echo ""
echo "Docker disk usage:"
docker system df

echo ""

# Check Docker daemon
log "5. Checking Docker daemon status..."
sudo systemctl status docker --no-pager -l

echo ""

# Check if ports are in use
log "6. Checking port conflicts..."
sudo lsof -i :3306 || echo "Port 3306 is free"

echo ""

# Check volumes
log "7. Checking Docker volumes..."
docker volume ls | grep lawviksh

echo ""

# Provide solutions
log "8. Suggested solutions:"
echo ""

warning "Solution 1: Increase MySQL startup timeout"
echo "Edit docker-compose.prod.yml and increase healthcheck timeout:"
echo "  healthcheck:"
echo "    test: [\"CMD\", \"mysqladmin\", \"ping\", \"-h\", \"localhost\"]"
echo "    timeout: 60s"
echo "    retries: 20"
echo "    start_period: 60s"
echo ""

warning "Solution 2: Check MySQL configuration"
echo "The issue might be with MySQL configuration. Try these steps:"
echo "1. Stop all containers: docker-compose -f docker-compose.prod.yml down"
echo "2. Remove MySQL volume: docker volume rm joiningbetarepo_mysql_data_prod"
echo "3. Start MySQL only: docker-compose -f docker-compose.prod.yml up mysql"
echo "4. Check logs: docker-compose -f docker-compose.prod.yml logs mysql"
echo ""

warning "Solution 3: Increase system resources"
echo "If you're on a low-resource system, try:"
echo "1. Increase swap space"
echo "2. Reduce MySQL memory limits in docker-compose.prod.yml"
echo "3. Use MySQL 5.7 instead of 8.0"
echo ""

warning "Solution 4: Fix permissions"
echo "Try fixing Docker permissions:"
echo "sudo chown -R $USER:$USER /var/lib/docker"
echo "sudo usermod -aG docker $USER"
echo ""

# Quick fix commands
log "9. Quick fix commands:"
echo ""
echo "# Stop all containers"
echo "docker-compose -f docker-compose.prod.yml down"
echo ""
echo "# Remove MySQL volume (WARNING: This will delete all data)"
echo "docker volume rm joiningbetarepo_mysql_data_prod"
echo ""
echo "# Start MySQL only to debug"
echo "docker-compose -f docker-compose.prod.yml up mysql"
echo ""
echo "# Check MySQL logs in real-time"
echo "docker-compose -f docker-compose.prod.yml logs -f mysql"
echo ""
echo "# Access MySQL container shell"
echo "docker-compose -f docker-compose.prod.yml exec mysql bash"
echo ""

# Check environment variables
log "10. Checking environment variables..."
if [ -f ".env" ]; then
    echo "Environment file exists"
    grep -E "DB_|MYSQL_" .env || echo "No database environment variables found"
else
    error "No .env file found"
fi

echo ""

success "Debugging complete. Check the output above for issues and solutions." 