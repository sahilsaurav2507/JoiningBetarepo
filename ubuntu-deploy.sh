#!/bin/bash

# LawViksh Backend Ubuntu Production Deployment Script
# Usage: ./ubuntu-deploy.sh [setup|deploy|update|status|logs|backup|restore]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging functions
log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
info() { echo -e "${CYAN}[INFO]${NC} $1"; }

# Configuration
APP_NAME="lawviksh"
DOMAIN="www.lawvriksh.com"
EMAIL="admin@lawvriksh.com"
APP_DIR="/opt/lawviksh"
BACKUP_DIR="/opt/backups"
LOG_DIR="/var/log/lawviksh"

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root. Please run as a regular user with sudo privileges."
        exit 1
    fi
}

# Check if running on Ubuntu
check_ubuntu() {
    if ! grep -q "Ubuntu" /etc/os-release; then
        error "This script is designed for Ubuntu systems only."
        exit 1
    fi
}

# Initial server setup
setup_server() {
    log "Starting Ubuntu server setup for LawViksh Backend..."
    
    # Update system
    log "Updating system packages..."
    sudo apt update && sudo apt upgrade -y
    success "System updated"
    
    # Install essential packages
    log "Installing essential packages..."
    sudo apt install -y \
        curl \
        wget \
        git \
        nano \
        htop \
        ufw \
        fail2ban \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release
    success "Essential packages installed"
    
    # Install Docker
    log "Installing Docker..."
    if ! command -v docker &> /dev/null; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        success "Docker installed"
    else
        info "Docker already installed"
    fi
    
    # Install Docker Compose
    log "Installing Docker Compose..."
    if ! command -v docker-compose &> /dev/null; then
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        success "Docker Compose installed"
    else
        info "Docker Compose already installed"
    fi
    
    # Configure firewall
    log "Configuring firewall..."
    sudo ufw allow ssh
    sudo ufw allow 80
    sudo ufw allow 443
    sudo ufw allow 8000
    echo "y" | sudo ufw enable
    success "Firewall configured"
    
    # Install certbot for SSL
    log "Installing certbot for SSL certificates..."
    sudo apt install -y certbot python3-certbot-nginx
    success "Certbot installed"
    
    # Create application directories
    log "Creating application directories..."
    sudo mkdir -p $APP_DIR
    sudo mkdir -p $BACKUP_DIR
    sudo mkdir -p $LOG_DIR
    sudo mkdir -p $APP_DIR/ssl
    sudo chown -R $USER:$USER $APP_DIR
    sudo chown -R $USER:$USER $BACKUP_DIR
    sudo chown -R $USER:$USER $LOG_DIR
    success "Directories created"
    
    # Configure fail2ban
    log "Configuring fail2ban..."
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban
    success "Fail2ban configured"
    
    # Set up log rotation
    log "Setting up log rotation..."
    sudo tee /etc/logrotate.d/lawviksh > /dev/null <<EOF
$LOG_DIR/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 $USER $USER
}
EOF
    success "Log rotation configured"
    
    success "Server setup completed!"
    warning "Please log out and back in for Docker group changes to take effect."
}

# Deploy application
deploy_app() {
    log "Starting LawViksh Backend deployment..."
    
    # Check if in correct directory
    if [ ! -f "docker-compose.prod.yml" ]; then
        error "Please run this script from the project root directory"
        exit 1
    fi
    
    # Check if .env file exists
    if [ ! -f ".env" ]; then
        warning "No .env file found. Creating from template..."
        if [ -f "env.example" ]; then
            cp env.example .env
            warning "Please edit .env file with your production values before continuing."
            warning "Run: nano .env"
            read -p "Press Enter after editing .env file..."
        else
            error "No env.example file found. Please create .env file manually."
            exit 1
        fi
    fi
    
    # Setup SSL certificates
    setup_ssl
    
    # Stop existing containers
    log "Stopping existing containers..."
    docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
    
    # Build and start services
    log "Building and starting services..."
    docker-compose -f docker-compose.prod.yml build --no-cache
    docker-compose -f docker-compose.prod.yml up -d
    
    # Wait for services to start
    log "Waiting for services to start..."
    sleep 30
    
    # Check service status
    log "Checking service status..."
    docker-compose -f docker-compose.prod.yml ps
    
    # Health check
    log "Performing health check..."
    if curl -f -s https://$DOMAIN/health > /dev/null; then
        success "✅ Application deployed successfully!"
        show_deployment_info
    else
        error "❌ Health check failed. Check logs with: ./ubuntu-deploy.sh logs"
        exit 1
    fi
}

# Setup SSL certificates
setup_ssl() {
    log "Setting up SSL certificates..."
    
    # Check if certificates already exist
    if [ -f "ssl/cert.pem" ] && [ -f "ssl/key.pem" ]; then
        info "SSL certificates already exist"
        return
    fi
    
    # Check if domain is accessible
    if ! nslookup $DOMAIN > /dev/null 2>&1; then
        warning "Domain $DOMAIN not accessible. Creating self-signed certificates for testing..."
        mkdir -p ssl
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout ssl/key.pem -out ssl/cert.pem \
            -subj "/C=IN/ST=State/L=City/O=LawViksh/CN=$DOMAIN"
        success "Self-signed certificates created"
        return
    fi
    
    # Get Let's Encrypt certificates
    log "Obtaining Let's Encrypt certificates..."
    sudo certbot certonly --standalone -d $DOMAIN -d ${DOMAIN#www.} --email $EMAIL --agree-tos --non-interactive
    
    # Copy certificates
    sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem ssl/cert.pem
    sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem ssl/key.pem
    sudo chmod 644 ssl/cert.pem
    sudo chmod 600 ssl/key.pem
    sudo chown $USER:$USER ssl/cert.pem ssl/key.pem
    
    success "SSL certificates configured"
    
    # Setup auto-renewal
    log "Setting up SSL certificate auto-renewal..."
    sudo tee /etc/cron.d/lawviksh-ssl-renewal > /dev/null <<EOF
0 12 * * * root /usr/bin/certbot renew --quiet && cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem $APP_DIR/ssl/cert.pem && cp /etc/letsencrypt/live/$DOMAIN/privkey.pem $APP_DIR/ssl/key.pem && chmod 644 $APP_DIR/ssl/cert.pem && chmod 600 $APP_DIR/ssl/key.pem && chown $USER:$USER $APP_DIR/ssl/cert.pem $APP_DIR/ssl/key.pem && docker-compose -f $APP_DIR/docker-compose.prod.yml restart nginx
EOF
    success "SSL auto-renewal configured"
}

# Update application
update_app() {
    log "Updating LawViksh Backend..."
    
    # Backup current deployment
    backup_app
    
    # Pull latest changes
    log "Pulling latest changes..."
    git pull origin main
    
    # Rebuild and restart
    log "Rebuilding and restarting services..."
    docker-compose -f docker-compose.prod.yml down
    docker-compose -f docker-compose.prod.yml build --no-cache
    docker-compose -f docker-compose.prod.yml up -d
    
    # Health check
    sleep 30
    if curl -f -s https://$DOMAIN/health > /dev/null; then
        success "✅ Application updated successfully!"
    else
        error "❌ Update failed. Rolling back..."
        restore_app
    fi
}

# Show deployment status
show_status() {
    log "LawViksh Backend Status"
    echo "======================"
    
    echo ""
    echo "Container Status:"
    docker-compose -f docker-compose.prod.yml ps
    
    echo ""
    echo "Resource Usage:"
    docker stats --no-stream
    
    echo ""
    echo "Health Check:"
    if curl -f -s https://$DOMAIN/health > /dev/null; then
        success "✅ Application is healthy"
    else
        error "❌ Application health check failed"
    fi
    
    echo ""
    echo "SSL Certificate:"
    if [ -f "ssl/cert.pem" ]; then
        openssl x509 -in ssl/cert.pem -text -noout | grep -E "(Subject:|Not After)"
    else
        warning "SSL certificate not found"
    fi
    
    echo ""
    echo "Disk Usage:"
    df -h | grep -E "(Filesystem|/dev/)"
    
    echo ""
    echo "Memory Usage:"
    free -h
}

# Show logs
show_logs() {
    log "Showing application logs..."
    docker-compose -f docker-compose.prod.yml logs -f
}

# Backup application
backup_app() {
    log "Creating backup..."
    
    BACKUP_FILE="$BACKUP_DIR/lawviksh_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    # Backup database
    log "Backing up database..."
    docker-compose -f docker-compose.prod.yml exec -T mysql mysqldump -u root -p lawviksh_db > $BACKUP_DIR/db_backup_$(date +%Y%m%d_%H%M%S).sql
    
    # Backup configuration
    log "Backing up configuration..."
    tar -czf $BACKUP_FILE \
        --exclude='.git' \
        --exclude='__pycache__' \
        --exclude='*.pyc' \
        --exclude='node_modules' \
        --exclude='.env' \
        .
    
    success "Backup created: $BACKUP_FILE"
}

# Restore application
restore_app() {
    log "Restoring from backup..."
    
    # List available backups
    echo "Available backups:"
    ls -la $BACKUP_DIR/*.tar.gz 2>/dev/null || echo "No backups found"
    
    read -p "Enter backup file path: " BACKUP_FILE
    
    if [ ! -f "$BACKUP_FILE" ]; then
        error "Backup file not found"
        exit 1
    fi
    
    # Stop services
    docker-compose -f docker-compose.prod.yml down
    
    # Extract backup
    tar -xzf $BACKUP_FILE -C .
    
    # Restart services
    docker-compose -f docker-compose.prod.yml up -d
    
    success "Application restored from backup"
}

# Show deployment information
show_deployment_info() {
    echo ""
    info "=== LawViksh Backend Deployment Complete ==="
    echo ""
    success "🌐 Access URLs:"
    echo "   Main App: https://$DOMAIN"
    echo "   API Base: https://$DOMAIN/api/"
    echo "   Health Check: https://$DOMAIN/health"
    echo "   API Documentation: https://$DOMAIN/docs"
    echo "   ReDoc: https://$DOMAIN/redoc"
    echo ""
    success "📊 API Endpoints:"
    echo "   Authentication: https://$DOMAIN/api/auth/login"
    echo "   User Management: https://$DOMAIN/api/users"
    echo "   Feedback: https://$DOMAIN/api/feedback"
    echo "   Data: https://$DOMAIN/api/data"
    echo ""
    success "🔧 Management Commands:"
    echo "   Status: ./ubuntu-deploy.sh status"
    echo "   Logs: ./ubuntu-deploy.sh logs"
    echo "   Update: ./ubuntu-deploy.sh update"
    echo "   Backup: ./ubuntu-deploy.sh backup"
    echo ""
    success "🔒 Frontend Integration:"
    echo "   Set your frontend API base URL to: https://$DOMAIN/api"
    echo "   CORS is configured for: https://$DOMAIN"
    echo ""
    success "📈 Monitoring:"
    echo "   Health Check: curl https://$DOMAIN/health"
    echo "   SSL Status: openssl s_client -connect $DOMAIN:443"
    echo ""
}

# Main script logic
main() {
    check_root
    check_ubuntu
    
    case "$1" in
        "setup")
            setup_server
            ;;
        "deploy")
            deploy_app
            ;;
        "update")
            update_app
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs
            ;;
        "backup")
            backup_app
            ;;
        "restore")
            restore_app
            ;;
        *)
            echo "Usage: $0 {setup|deploy|update|status|logs|backup|restore}"
            echo ""
            echo "Commands:"
            echo "  setup   - Initial server setup (run once)"
            echo "  deploy  - Deploy application"
            echo "  update  - Update application"
            echo "  status  - Show deployment status"
            echo "  logs    - Show application logs"
            echo "  backup  - Create backup"
            echo "  restore - Restore from backup"
            echo ""
            echo "Deployment Steps:"
            echo "1. ./ubuntu-deploy.sh setup    # Initial server setup"
            echo "2. ./ubuntu-deploy.sh deploy   # Deploy application"
            echo "3. ./ubuntu-deploy.sh status   # Check status"
            exit 1
            ;;
    esac
}

# Run main function
main "$@" 