#!/bin/bash

echo "=== MySQL Connection Fix Script ==="
echo "This script will diagnose and fix MySQL connection issues"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Step 1: Check if Docker is running
print_status "Checking Docker status..."
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running. Starting Docker..."
    sudo systemctl start docker
    sleep 3
fi

# Step 2: Check all running containers
print_status "Checking running containers..."
docker ps

echo ""
print_status "Checking all containers (including stopped)..."
docker ps -a

# Step 3: Check MySQL container specifically
print_status "Checking MySQL container..."
MYSQL_CONTAINER=$(docker ps -a --filter "name=mysql" --format "{{.Names}}")

if [ -z "$MYSQL_CONTAINER" ]; then
    print_error "No MySQL container found. Let's create one..."
    
    # Stop existing containers
    docker-compose -f docker-compose.prod.external-mysql-linux.yml down
    
    # Create MySQL container
    docker run -d \
        --name mysql_lawviksh \
        --network host \
        -e MYSQL_ROOT_PASSWORD=your_root_password \
        -e MYSQL_DATABASE=lawviksh_db \
        -e MYSQL_USER=lawviksh_user \
        -e MYSQL_PASSWORD=your_password \
        -v mysql_data:/var/lib/mysql \
        mysql:5.7
    
    print_status "MySQL container created. Waiting for it to start..."
    sleep 30
    
    # Check if MySQL is running
    if docker ps | grep -q mysql_lawviksh; then
        print_status "MySQL container is running"
    else
        print_error "MySQL container failed to start"
        docker logs mysql_lawviksh
        exit 1
    fi
else
    print_status "MySQL container found: $MYSQL_CONTAINER"
    
    # Check if it's running
    if docker ps | grep -q "$MYSQL_CONTAINER"; then
        print_status "MySQL container is running"
    else
        print_warning "MySQL container is stopped. Starting it..."
        docker start "$MYSQL_CONTAINER"
        sleep 10
    fi
fi

# Step 4: Get MySQL container IP
print_status "Getting MySQL container IP..."
MYSQL_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mysql_lawviksh 2>/dev/null)

if [ -z "$MYSQL_IP" ]; then
    print_warning "Could not get MySQL container IP. Using host network..."
    MYSQL_IP="172.17.0.1"
fi

print_status "MySQL IP: $MYSQL_IP"

# Step 5: Test MySQL connection
print_status "Testing MySQL connection..."
if docker exec mysql_lawviksh mysql -u lawviksh_user -pyour_password -e "SELECT 1;" >/dev/null 2>&1; then
    print_status "MySQL connection successful"
else
    print_error "MySQL connection failed. Checking logs..."
    docker logs mysql_lawviksh --tail 20
fi

# Step 6: Check if database exists
print_status "Checking if database exists..."
if docker exec mysql_lawviksh mysql -u lawviksh_user -pyour_password -e "USE lawviksh_db; SHOW TABLES;" >/dev/null 2>&1; then
    print_status "Database 'lawviksh_db' exists"
else
    print_warning "Database 'lawviksh_db' does not exist. Creating it..."
    docker exec mysql_lawviksh mysql -u root -pyour_root_password -e "CREATE DATABASE IF NOT EXISTS lawviksh_db;"
    docker exec mysql_lawviksh mysql -u root -pyour_root_password -e "GRANT ALL PRIVILEGES ON lawviksh_db.* TO 'lawviksh_user'@'%';"
    docker exec mysql_lawviksh mysql -u root -pyour_root_password -e "FLUSH PRIVILEGES;"
fi

# Step 7: Update environment variables
print_status "Updating environment variables..."
cat > .env.prod << EOF
# Production Environment Variables
ENVIRONMENT=production
DEBUG=False

# Database Configuration
DB_HOST=$MYSQL_IP
DB_PORT=3306
DB_NAME=lawviksh_db
DB_USER=lawviksh_user
DB_PASSWORD=your_password

# CORS Configuration
CORS_ORIGINS=https://www.lawvriksh.com,https://lawvriksh.com,http://localhost:3000,http://localhost:3001

# Security
SECRET_KEY=your-secret-key-here-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Server Configuration
HOST=0.0.0.0
PORT=8000
EOF

print_status "Environment file updated with MySQL IP: $MYSQL_IP"

# Step 8: Restart the application
print_status "Restarting application with updated configuration..."
docker-compose -f docker-compose.prod.external-mysql-linux.yml down
docker-compose -f docker-compose.prod.external-mysql-linux.yml up -d

# Step 9: Wait and check logs
print_status "Waiting for application to start..."
sleep 10

print_status "Checking application logs..."
docker-compose -f docker-compose.prod.external-mysql-linux.yml logs --tail 20

# Step 10: Test the API
print_status "Testing API endpoint..."
sleep 5
if curl -s http://localhost/api/health >/dev/null 2>&1; then
    print_status "API is responding successfully!"
else
    print_warning "API test failed. Checking detailed logs..."
    docker-compose -f docker-compose.prod.external-mysql-linux.yml logs app
fi

echo ""
print_status "Fix script completed!"
echo ""
echo "Next steps:"
echo "1. Check the logs above for any remaining errors"
echo "2. Test your API endpoints"
echo "3. If issues persist, run: docker-compose -f docker-compose.prod.external-mysql-linux.yml logs -f"
echo ""
echo "MySQL connection details:"
echo "Host: $MYSQL_IP"
echo "Port: 3306"
echo "Database: lawviksh_db"
echo "User: lawviksh_user" 