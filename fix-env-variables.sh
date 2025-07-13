#!/bin/bash

echo "=== Fix Environment Variables ==="
echo "The issue is that the config.py expects lowercase environment variable names"
echo ""

# Stop the application
echo "1. Stopping application..."
docker-compose -f docker-compose.prod.external-mysql-linux.yml down

# Create correct environment file with lowercase variable names
echo "2. Creating correct environment file..."
cat > .env.prod << EOF
# Production Environment Variables
environment=production
debug=false

# Database Configuration (lowercase as expected by config.py)
db_host=localhost
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

echo "3. Environment file created with correct variable names"
echo ""

# Check if MySQL container exists and is running
echo "4. Checking MySQL container..."
if ! docker ps | grep -q mysql; then
    echo "MySQL container not running. Creating one..."
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
    echo "MySQL container is running"
fi

# Start the application
echo "5. Starting application..."
docker-compose -f docker-compose.prod.external-mysql-linux.yml up -d

# Wait and check logs
echo "6. Waiting for application to start..."
sleep 15

echo "7. Checking logs..."
docker-compose -f docker-compose.prod.external-mysql-linux.yml logs --tail 15

echo ""
echo "=== Fix completed! ==="
echo ""
echo "If you still see connection errors, try these alternatives:"
echo ""
echo "Alternative 1 - Use Docker bridge IP:"
echo "sed -i 's/db_host=.*/db_host=172.17.0.1/' .env.prod"
echo "docker-compose -f docker-compose.prod.external-mysql-linux.yml restart"
echo ""
echo "Alternative 2 - Use MySQL container IP:"
echo "MYSQL_IP=\$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mysql_lawviksh)"
echo "sed -i \"s/db_host=.*/db_host=\$MYSQL_IP/\" .env.prod"
echo "docker-compose -f docker-compose.prod.external-mysql-linux.yml restart"
echo ""
echo "Check logs with: docker-compose -f docker-compose.prod.external-mysql-linux.yml logs -f" 