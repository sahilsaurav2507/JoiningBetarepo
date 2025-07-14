#!/bin/bash

set -e

echo "=== LawViksh Backend: Update & Redeploy ==="

# Pull latest code
echo "1. Pulling latest code from git..."
git pull

echo "2. Building Docker images..."
docker-compose -f docker-compose.prod.external-mysql-linux.yml build

echo "3. Restarting containers..."
docker-compose -f docker-compose.prod.external-mysql-linux.yml up -d

echo "4. Checking logs..."
docker-compose -f docker-compose.prod.external-mysql-linux.yml logs --tail 20

echo "=== Update & Redeploy Complete ==="
echo "Check your API at: https://www.lawvriksh.com/api/" 