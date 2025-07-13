#!/bin/bash

echo "=== Quick MySQL Connection Fix ==="
echo ""

# Stop current deployment
echo "1. Stopping current deployment..."
docker-compose -f docker-compose.prod.external-mysql-linux.yml down

# Check if MySQL container exists
echo "2. Checking MySQL container..."
if ! docker ps -a | grep -q mysql; then
    echo "Creating MySQL container..."
    docker run -d \
        --name mysql_lawviksh \
        --network host \
        -e MYSQL_ROOT_PASSWORD=your_root_password \
        -e MYSQL_DATABASE=lawviksh_db \
        -e MYSQL_USER=lawviksh_user \
        -e MYSQL_PASSWORD=your_password \
        -v mysql_data:/var/lib/mysql \
        mysql:5.7
    
    echo "Waiting for MySQL to start..."
    sleep 30
else
    echo "MySQL container found. Starting if stopped..."
    docker start mysql_lawviksh 2>/dev/null || true
    sleep 10
fi

# Create environment file with localhost
echo "3. Creating environment file..."
cat > .env.prod << EOF
# Production Environment Variables
ENVIRONMENT=production
DEBUG=False

# Database Configuration
DB_HOST=localhost
DB_PORT=3306
DB_NAME=lawviksh_db
DB_USER=lawviksh_user
DB_PASSWORD=your_password

# CORS Configuration
CORS_ORIGINS=["https://www.lawvriksh.com","https://lawvriksh.com","https://app.lawvriksh.com","https://admin.lawvriksh.com"]

# Security
SECRET_KEY=your-secret-key-here-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Server Configuration
HOST=0.0.0.0
PORT=8000

# API Configuration
API_BASE_URL=https://www.lawvriksh.com/api
API_PREFIX=/api
EOF

# Start the application
echo "4. Starting application..."
docker-compose -f docker-compose.prod.external-mysql-linux.yml up -d

# Wait and check logs
echo "5. Waiting for application to start..."
sleep 15

echo "6. Checking logs..."
docker-compose -f docker-compose.prod.external-mysql-linux.yml logs --tail 10

echo ""
echo "=== Fix completed! ==="
echo "If you still see connection errors, try these alternatives:"
echo ""
echo "Alternative 1 - Use Docker bridge IP:"
echo "sed -i 's/DB_HOST=.*/DB_HOST=172.17.0.1/' .env.prod"
echo "docker-compose -f docker-compose.prod.external-mysql-linux.yml restart"
echo ""
echo "Alternative 2 - Use MySQL container IP:"
echo "MYSQL_IP=\$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mysql_lawviksh)"
echo "sed -i \"s/DB_HOST=.*/DB_HOST=\$MYSQL_IP/\" .env.prod"
echo "docker-compose -f docker-compose.prod.external-mysql-linux.yml restart"
echo ""
echo "Check logs with: docker-compose -f docker-compose.prod.external-mysql-linux.yml logs -f" 