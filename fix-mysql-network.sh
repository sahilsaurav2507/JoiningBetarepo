#!/bin/bash

echo "=== Fix MySQL Network Connectivity ==="
echo "The issue is that 'localhost' inside the Docker container doesn't refer to the host MySQL"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Stop the application
print_status "1. Stopping application..."
docker-compose -f docker-compose.prod.external-mysql-linux.yml down

# Get the host machine's IP address
print_status "2. Getting host machine IP..."
HOST_IP=$(hostname -I | awk '{print $1}')
print_status "Host IP: $HOST_IP"

# Get Docker bridge network IP
print_status "3. Getting Docker bridge IP..."
DOCKER_BRIDGE_IP=$(docker network inspect bridge | grep Gateway | awk -F'"' '{print $4}')
print_status "Docker bridge IP: $DOCKER_BRIDGE_IP"

# Check if MySQL container exists and get its IP
print_status "4. Checking MySQL container..."
if docker ps -a | grep -q mysql; then
    MYSQL_CONTAINER=$(docker ps -a | grep mysql | awk '{print $NF}')
    print_status "MySQL container found: $MYSQL_CONTAINER"
    
    # Get MySQL container IP
    MYSQL_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $MYSQL_CONTAINER 2>/dev/null)
    if [ -n "$MYSQL_IP" ]; then
        print_status "MySQL container IP: $MYSQL_IP"
    else
        print_warning "Could not get MySQL container IP"
        MYSQL_IP=""
    fi
else
    print_error "No MySQL container found"
    MYSQL_IP=""
fi

# Test different connection options
print_status "5. Testing MySQL connections..."

# Test 1: Host IP
print_status "Testing connection to $HOST_IP:3306..."
if timeout 5 bash -c "</dev/tcp/$HOST_IP/3306" 2>/dev/null; then
    print_status "✓ Connection to $HOST_IP:3306 successful"
    BEST_IP=$HOST_IP
elif [ -n "$MYSQL_IP" ]; then
    print_status "Testing connection to $MYSQL_IP:3306..."
    if timeout 5 bash -c "</dev/tcp/$MYSQL_IP/3306" 2>/dev/null; then
        print_status "✓ Connection to $MYSQL_IP:3306 successful"
        BEST_IP=$MYSQL_IP
    else
        print_warning "✗ Connection to $MYSQL_IP:3306 failed"
        BEST_IP=$DOCKER_BRIDGE_IP
    fi
else
    print_warning "✗ Connection to $HOST_IP:3306 failed"
    BEST_IP=$DOCKER_BRIDGE_IP
fi

print_status "Using IP: $BEST_IP"

# Create environment file with the best IP
print_status "6. Creating environment file with correct IP..."
cat > .env.prod << EOF
# Production Environment Variables
environment=production
debug=false

# Database Configuration (using the best available IP)
db_host=$BEST_IP
db_port=3306
db_name=lawviksh_db
db_user=lawviksh_user
db_password=your_password

# Security Configuration
secret_key=your-secret-key-here-change-in-production
algorithm=HS256
access_token_expire_minutes=30

# Admin Credentials
admin_username=admin
admin_password=admin123

# Server Configuration
host=0.0.0.0
port=8000

# API Configuration
api_base_url=https://www.lawvriksh.com/api
api_prefix=/api

# CORS Configuration
cors_origins=["https://www.lawvriksh.com","https://lawvriksh.com","https://app.lawvriksh.com","https://admin.lawvriksh.com"]
cors_allow_credentials=true
cors_allow_methods=["GET","POST","PUT","DELETE","OPTIONS","PATCH"]
cors_allow_headers=["*"]
cors_expose_headers=["Content-Length","Content-Type","Authorization"]
cors_max_age=86400
EOF

print_status "Environment file created with db_host=$BEST_IP"

# Test MySQL connection from inside a temporary container
print_status "7. Testing MySQL connection from Docker container..."
docker run --rm mysql:5.7 mysql -h $BEST_IP -u lawviksh_user -pyour_password -e "SELECT 1;" 2>/dev/null
if [ $? -eq 0 ]; then
    print_status "✓ MySQL connection test successful"
else
    print_warning "✗ MySQL connection test failed"
fi

# Start the application
print_status "8. Starting application..."
docker-compose -f docker-compose.prod.external-mysql-linux.yml up -d

# Wait and check logs
print_status "9. Waiting for application to start..."
sleep 15

print_status "10. Checking logs..."
docker-compose -f docker-compose.prod.external-mysql-linux.yml logs --tail 10

# Test the API
print_status "11. Testing API endpoint..."
sleep 5
if curl -s http://localhost/api/health >/dev/null 2>&1; then
    print_status "✓ API is responding successfully!"
else
    print_warning "✗ API test failed. Checking detailed logs..."
    docker-compose -f docker-compose.prod.external-mysql-linux.yml logs app --tail 5
fi

echo ""
print_status "=== Fix completed! ==="
echo ""
echo "MySQL connection details:"
echo "Host: $BEST_IP"
echo "Port: 3306"
echo "Database: lawviksh_db"
echo "User: lawviksh_user"
echo ""
echo "If you still have issues, try these alternatives:"
echo ""
echo "1. Use host network mode (if MySQL is on host):"
echo "   sed -i 's/db_host=.*/db_host=$HOST_IP/' .env.prod"
echo "   docker-compose -f docker-compose.prod.external-mysql-linux.yml restart"
echo ""
echo "2. Use Docker bridge IP:"
echo "   sed -i 's/db_host=.*/db_host=$DOCKER_BRIDGE_IP/' .env.prod"
echo "   docker-compose -f docker-compose.prod.external-mysql-linux.yml restart"
echo ""
echo "3. Check logs:"
echo "   docker-compose -f docker-compose.prod.external-mysql-linux.yml logs -f" 