#!/bin/bash

# Domain Setup Script for LawViksh Backend
# This script helps configure www.lawvriksh.com with SSL

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

echo -e "${GREEN}LawViksh Domain Setup for www.lawvriksh.com${NC}"
echo "================================================"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "Please run this script with sudo"
    exit 1
fi

# Update system
log "Updating system packages..."
apt update && apt upgrade -y

# Install required packages
log "Installing required packages..."
apt install -y certbot python3-certbot-nginx nginx

# Create SSL directory
log "Creating SSL directory..."
mkdir -p ssl

# Get SSL certificate
log "Obtaining SSL certificate for www.lawvriksh.com..."
certbot certonly --standalone -d lawvriksh.com -d www.lawvriksh.com --non-interactive --agree-tos --email admin@lawvriksh.com

# Copy certificates to SSL directory
log "Copying SSL certificates..."
cp /etc/letsencrypt/live/lawvriksh.com/fullchain.pem ssl/cert.pem
cp /etc/letsencrypt/live/lawvriksh.com/privkey.pem ssl/key.pem

# Set proper permissions
chmod 644 ssl/cert.pem
chmod 600 ssl/key.pem

# Create SSL renewal script
log "Creating SSL renewal script..."
cat > /etc/cron.daily/renew-ssl << 'EOF'
#!/bin/bash
certbot renew --quiet
cp /etc/letsencrypt/live/lawvriksh.com/fullchain.pem /path/to/your/app/ssl/cert.pem
cp /etc/letsencrypt/live/lawvriksh.com/privkey.pem /path/to/your/app/ssl/key.pem
docker-compose restart nginx
EOF

chmod +x /etc/cron.daily/renew-ssl

# Configure firewall
log "Configuring firewall..."
ufw allow 80
ufw allow 443
ufw allow 8000
ufw --force enable

success "Domain setup completed!"
echo ""
echo -e "${GREEN}✅ SSL certificate obtained for www.lawvriksh.com${NC}"
echo -e "${GREEN}✅ Certificates copied to ssl/ directory${NC}"
echo -e "${GREEN}✅ Auto-renewal configured${NC}"
echo -e "${GREEN}✅ Firewall configured${NC}"
echo ""
echo "Next steps:"
echo "1. Deploy your application: ./quick-deploy.sh"
echo "2. Your API will be available at: https://www.lawvriksh.com/api/"
echo "3. Health check: https://www.lawvriksh.com/health"
echo "4. API docs: https://www.lawvriksh.com/docs"
echo ""
echo "SSL certificate will auto-renew every 60 days." 