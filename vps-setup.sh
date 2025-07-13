#!/bin/bash

# LawViksh VPS Initial Setup Script
# Run this first on a fresh Ubuntu VPS

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

log "Starting VPS setup for LawViksh Backend..."

# Update system
log "Updating system packages..."
sudo apt update && sudo apt upgrade -y
success "System updated"

# Install essential packages
log "Installing essential packages..."
sudo apt install -y curl wget git nano htop ufw fail2ban

# Install Docker
log "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
rm get-docker.sh

# Install Docker Compose
log "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Configure firewall
log "Configuring firewall..."
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 8000
echo "y" | sudo ufw enable

# Create application directory
log "Setting up application directory..."
mkdir -p /home/$USER/lawviksh
cd /home/$USER/lawviksh

# Clone repository (if using git)
# git clone <your-repo-url> .

# Make deployment script executable
chmod +x deploy-vps.sh

success "VPS setup completed!"
echo ""
echo "Next steps:"
echo "1. Upload your application files to /home/$USER/lawviksh/"
echo "2. Run: ./deploy-vps.sh full"
echo "3. Edit .env file with your production values"
echo ""
echo "You may need to log out and back in for Docker group changes to take effect." 