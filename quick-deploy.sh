#!/bin/bash

# Quick Deploy Script for LawViksh Backend
# Use this for immediate deployment on Ubuntu VPS

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}LawViksh Backend Quick Deploy for www.lawvriksh.com${NC}"
echo "========================================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker not found. Installing Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo -e "${YELLOW}Please log out and back in, then run this script again.${NC}"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}Installing Docker Compose...${NC}"
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Setup environment file
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file...${NC}"
    if [ -f env.example ]; then
        cp env.example .env
        echo -e "${YELLOW}Please edit .env file with your production values: nano .env${NC}"
        echo -e "${YELLOW}Make sure to update CORS_ORIGINS and other domain settings.${NC}"
    fi
fi

# Check for SSL certificates
if [ ! -f ssl/cert.pem ] || [ ! -f ssl/key.pem ]; then
    echo -e "${YELLOW}SSL certificates not found.${NC}"
    echo -e "${YELLOW}For production with www.lawvriksh.com, run: sudo ./setup-domain.sh${NC}"
    echo -e "${YELLOW}Or create self-signed certificates for testing:${NC}"
    echo -e "${YELLOW}  mkdir -p ssl${NC}"
    echo -e "${YELLOW}  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ssl/key.pem -out ssl/cert.pem${NC}"
fi

# Stop existing containers
echo -e "${YELLOW}Stopping existing containers...${NC}"
docker-compose down 2>/dev/null || true

# Build and start
echo -e "${YELLOW}Building and starting services...${NC}"
docker-compose build --no-cache
docker-compose up -d

# Wait for services
echo -e "${YELLOW}Waiting for services to start...${NC}"
sleep 20

# Check status
echo -e "${YELLOW}Checking service status...${NC}"
docker-compose ps

# Health check
if curl -f http://localhost:8000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Application is running successfully!${NC}"
    echo ""
    echo -e "${GREEN}🌐 Access URLs:${NC}"
    echo -e "${GREEN}   Main App: https://www.lawvriksh.com${NC}"
    echo -e "${GREEN}   API Base: https://www.lawvriksh.com/api/${NC}"
    echo -e "${GREEN}   Health Check: https://www.lawvriksh.com/health${NC}"
    echo -e "${GREEN}   API Documentation: https://www.lawvriksh.com/docs${NC}"
    echo -e "${GREEN}   ReDoc: https://www.lawvriksh.com/redoc${NC}"
    echo ""
    echo -e "${GREEN}📊 API Endpoints:${NC}"
    echo -e "${GREEN}   Authentication: https://www.lawvriksh.com/api/auth/login${NC}"
    echo -e "${GREEN}   User Management: https://www.lawvriksh.com/api/users${NC}"
    echo -e "${GREEN}   Feedback: https://www.lawvriksh.com/api/feedback${NC}"
    echo -e "${GREEN}   Data: https://www.lawvriksh.com/api/data${NC}"
    echo ""
    echo -e "${GREEN}🔧 Frontend Integration:${NC}"
    echo -e "${GREEN}   Set your frontend API base URL to: https://www.lawvriksh.com/api${NC}"
    echo -e "${GREEN}   CORS is configured for: https://www.lawvriksh.com${NC}"
else
    echo -e "${RED}❌ Health check failed. Check logs with: docker-compose logs${NC}"
fi

echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo "  docker-compose logs -f    # View logs"
echo "  docker-compose restart    # Restart services"
echo "  docker-compose down       # Stop services"
echo "  docker-compose up -d      # Start services"
echo "  sudo ./setup-domain.sh    # Setup SSL certificates"
echo ""
echo -e "${YELLOW}For frontend integration:${NC}"
echo "  Update your frontend API calls to use: https://www.lawvriksh.com/api/"
echo "  Example: fetch('https://www.lawvriksh.com/api/auth/login', {...})" 