#!/bin/bash

# LawViksh Backend VPS Deployment Script
# Optimized for Ubuntu VPS deployment from browser terminal

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Update system packages
update_system() {
    log "Updating system packages..."
    sudo apt-get update
    sudo apt-get upgrade -y
    success "System updated successfully"
}

# Install Docker
install_docker() {
    log "Installing Docker..."
    
    # Remove old versions
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Install prerequisites
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    
    # Start and enable Docker
    sudo systemctl start docker
    sudo systemctl enable docker
    
    success "Docker installed successfully"
    warning "You may need to log out and back in for group changes to take effect"
}

# Install Docker Compose (standalone)
install_docker_compose() {
    log "Installing Docker Compose..."
    
    # Download Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    
    # Make it executable
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Create symlink
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    success "Docker Compose installed successfully"
}

# Configure firewall
configure_firewall() {
    log "Configuring firewall..."
    
    # Install UFW if not present
    sudo apt-get install -y ufw
    
    # Allow SSH
    sudo ufw allow ssh
    
    # Allow HTTP and HTTPS
    sudo ufw allow 80
    sudo ufw allow 443
    
    # Allow application port
    sudo ufw allow 8000
    
    # Enable firewall
    echo "y" | sudo ufw enable
    
    success "Firewall configured successfully"
}

# Setup environment file
setup_environment() {
    log "Setting up environment configuration..."
    
    if [ ! -f .env ]; then
        if [ -f env.example ]; then
            cp env.example .env
            warning "Created .env file from template. Please edit it with your production values."
            echo "You can edit the .env file using: nano .env"
        else
            error "env.example file not found. Please create a .env file manually."
            exit 1
        fi
    else
        success "Environment file already exists"
    fi
}

# Generate secure secret key
generate_secret_key() {
    log "Generating secure secret key..."
    
    if [ -f generate_secret_key.py ]; then
        python3 generate_secret_key.py
        success "Secret key generated"
    else
        warning "generate_secret_key.py not found. Please generate a secure SECRET_KEY manually."
    fi
}

# Build and start services
deploy_services() {
    log "Building and starting services..."
    
    # Stop any existing services
    docker-compose down 2>/dev/null || true
    
    # Build images
    docker-compose build --no-cache
    
    # Start services
    docker-compose up -d
    
    success "Services deployed successfully"
}

# Check service health
check_health() {
    log "Checking service health..."
    
    # Wait for services to be ready
    sleep 15
    
    # Check if containers are running
    if ! docker-compose ps | grep -q "Up"; then
        error "Some services are not running properly"
        docker-compose logs
        exit 1
    fi
    
    # Check health endpoint
    if curl -f http://localhost:8000/health > /dev/null 2>&1; then
        success "Application is healthy and responding"
        echo "Your application is now running at: http://$(curl -s ifconfig.me):8000"
    else
        warning "Health check failed, but services are running"
        echo "Check logs with: docker-compose logs"
    fi
}

# Setup SSL with Let's Encrypt (optional)
setup_ssl() {
    log "Setting up SSL with Let's Encrypt..."
    
    # Install certbot
    sudo apt-get install -y certbot python3-certbot-nginx
    
    # Get domain from user
    read -p "Enter your domain name (e.g., lawvriksh.com): " DOMAIN
    
    if [ -n "$DOMAIN" ]; then
        # Get SSL certificate
        sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN
        
        success "SSL certificate obtained for $DOMAIN"
        
        # Update nginx configuration
        if [ -f nginx.conf ]; then
            sed -i "s/lawvriksh.com/$DOMAIN/g" nginx.conf
            sed -i "s/www.lawvriksh.com/www.$DOMAIN/g" nginx.conf
        fi
    else
        warning "No domain provided. SSL setup skipped."
    fi
}

# Create systemd service for auto-start
create_systemd_service() {
    log "Creating systemd service for auto-start..."
    
    sudo tee /etc/systemd/system/lawviksh.service > /dev/null <<EOF
[Unit]
Description=LawViksh Backend
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$(pwd)
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

    # Enable and start service
    sudo systemctl enable lawviksh.service
    sudo systemctl start lawviksh.service
    
    success "Systemd service created and enabled"
}

# Show deployment status
show_status() {
    log "Deployment Status:"
    echo "=================="
    
    # Docker status
    echo "Docker Status:"
    docker --version
    docker-compose --version
    echo ""
    
    # Service status
    echo "Service Status:"
    docker-compose ps
    echo ""
    
    # Port status
    echo "Port Status:"
    netstat -tlnp | grep -E ':(80|443|8000|3306)' || echo "No services listening on expected ports"
    echo ""
    
    # Application health
    echo "Application Health:"
    curl -s http://localhost:8000/health | jq . 2>/dev/null || curl -s http://localhost:8000/health
    echo ""
}

# Main deployment function
full_deployment() {
    log "Starting full VPS deployment..."
    
    # Update system
    update_system
    
    # Install Docker
    install_docker
    
    # Install Docker Compose
    install_docker_compose
    
    # Configure firewall
    configure_firewall
    
    # Setup environment
    setup_environment
    
    # Generate secret key
    generate_secret_key
    
    # Deploy services
    deploy_services
    
    # Check health
    check_health
    
    # Create systemd service
    create_systemd_service
    
    success "Full deployment completed successfully!"
    
    # Show final status
    show_status
    
    echo ""
    echo "Next steps:"
    echo "1. Edit .env file with your production values: nano .env"
    echo "2. Restart services: docker-compose restart"
    echo "3. View logs: docker-compose logs -f"
    echo "4. Setup SSL (optional): ./deploy-vps.sh ssl"
    echo "5. Access your application: http://$(curl -s ifconfig.me):8000"
}

# Main script logic
case "${1:-help}" in
    "full"|"deploy")
        full_deployment
        ;;
    "install-docker")
        install_docker
        ;;
    "install-compose")
        install_docker_compose
        ;;
    "setup-env")
        setup_environment
        ;;
    "deploy-app")
        deploy_services
        check_health
        ;;
    "ssl")
        setup_ssl
        ;;
    "status")
        show_status
        ;;
    "logs")
        docker-compose logs -f
        ;;
    "restart")
        docker-compose restart
        ;;
    "stop")
        docker-compose down
        ;;
    "update")
        git pull
        docker-compose down
        docker-compose up -d --build
        ;;
    "help"|*)
        echo "LawViksh Backend VPS Deployment Script"
        echo ""
        echo "Usage: $0 [COMMAND]"
        echo ""
        echo "Commands:"
        echo "  full, deploy     - Complete VPS deployment (recommended)"
        echo "  install-docker   - Install Docker only"
        echo "  install-compose  - Install Docker Compose only"
        echo "  setup-env        - Setup environment file"
        echo "  deploy-app       - Deploy application only"
        echo "  ssl              - Setup SSL with Let's Encrypt"
        echo "  status           - Show deployment status"
        echo "  logs             - Show service logs"
        echo "  restart          - Restart services"
        echo "  stop             - Stop services"
        echo "  update           - Update and redeploy"
        echo "  help             - Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 full          # Complete deployment"
        echo "  $0 status        # Check status"
        echo "  $0 logs          # View logs"
        ;;
esac 