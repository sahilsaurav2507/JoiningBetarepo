#!/bin/bash

# LawViksh Backend Deployment Script
# This script sets up the LawViksh backend on a VPS

set -e  # Exit on any error

echo "🚀 LawViksh Backend Deployment Script"
echo "======================================"

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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

# Update system
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
print_status "Installing required packages..."
sudo apt install -y python3 python3-pip python3-venv mysql-server nginx git curl

# Start and enable MySQL
print_status "Configuring MySQL..."
sudo systemctl start mysql
sudo systemctl enable mysql

# Secure MySQL installation
print_warning "You will be prompted to secure MySQL installation..."
sudo mysql_secure_installation

# Create database and user
print_status "Setting up database..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS lawviksh_joining_list;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'lawviksh_user'@'localhost' IDENTIFIED BY 'your_secure_password_here';"
sudo mysql -e "GRANT ALL PRIVILEGES ON lawviksh_joining_list.* TO 'lawviksh_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Import database schema
print_status "Importing database schema..."
mysql -u lawviksh_user -p lawviksh_joining_list < lawdata.sql

# Create virtual environment
print_status "Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
print_status "Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Create .env file
print_status "Creating environment configuration..."
cat > .env << EOF
# Database Configuration
DB_HOST=localhost
DB_PORT=3306
DB_NAME=lawviksh_joining_list
DB_USER=lawviksh_user
DB_PASSWORD=your_secure_password_here

# Security Configuration
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Admin Credentials (change these!)
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin123

# Server Configuration
HOST=0.0.0.0
PORT=8000
DEBUG=False
EOF

print_warning "Please edit the .env file and update the database password and admin credentials!"

# Create systemd service
print_status "Creating systemd service..."
sudo tee /etc/systemd/system/lawviksh.service > /dev/null << EOF
[Unit]
Description=LawViksh Backend
After=network.target mysql.service

[Service]
Type=exec
User=$USER
Group=$USER
WorkingDirectory=$(pwd)
Environment=PATH=$(pwd)/venv/bin
ExecStart=$(pwd)/venv/bin/gunicorn wsgi:application -w 4 -k uvicorn.workers.UvicornWorker --bind 127.0.0.1:8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable service
sudo systemctl daemon-reload
sudo systemctl enable lawviksh

# Configure Nginx
print_status "Configuring Nginx..."
sudo tee /etc/nginx/sites-available/lawviksh > /dev/null << EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /static/ {
        alias $(pwd)/static/;
    }
}
EOF

# Enable Nginx site
sudo ln -sf /etc/nginx/sites-available/lawviksh /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Start services
print_status "Starting services..."
sudo systemctl start lawviksh
sudo systemctl restart nginx

# Check service status
print_status "Checking service status..."
sudo systemctl status lawviksh --no-pager
sudo systemctl status nginx --no-pager

# Test the API
print_status "Testing API..."
sleep 5  # Wait for service to start

if curl -s http://localhost:8000/health > /dev/null; then
    print_status "✅ API is running successfully!"
else
    print_error "❌ API is not responding. Check the logs:"
    sudo journalctl -u lawviksh -n 20
fi

# Create firewall rules
print_status "Configuring firewall..."
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# Final instructions
echo ""
echo "🎉 Deployment completed!"
echo "========================"
echo ""
echo "Next steps:"
echo "1. Edit the .env file and update passwords:"
echo "   nano .env"
echo ""
echo "2. Restart the service:"
echo "   sudo systemctl restart lawviksh"
echo ""
echo "3. Test the API:"
echo "   python3 test_api.py"
echo ""
echo "4. Access the API documentation:"
echo "   http://your-server-ip/docs"
echo ""
echo "5. Monitor logs:"
echo "   sudo journalctl -u lawviksh -f"
echo ""
echo "Default admin credentials:"
echo "Username: admin"
echo "Password: admin123"
echo ""
print_warning "Please change the default admin password immediately!"
echo ""
echo "For support, check the README.md file." 