# Ubuntu Production Deployment Guide for LawViksh Backend

This guide provides a complete step-by-step strategy for deploying the LawViksh Backend API on Ubuntu servers in production.

## 🎯 Deployment Target

- **Server**: Ubuntu 20.04 LTS or later
- **API Base URL**: `https://www.lawvriksh.com/api/`
- **Domain**: `www.lawvriksh.com`
- **SSL**: Let's Encrypt certificates
- **Containerization**: Docker + Docker Compose

## 📋 Prerequisites

- Ubuntu VPS/Server (minimum 2GB RAM, 20GB storage)
- Domain name pointing to your server
- SSH access to the server
- Sudo privileges

## 🚀 Quick Deployment Strategy

### Phase 1: Server Preparation (One-time setup)

```bash
# 1. Connect to your Ubuntu server
ssh user@your-server-ip

# 2. Clone the repository
git clone <your-repo-url>
cd JoiningBetarepo

# 3. Make deployment script executable
chmod +x ubuntu-deploy.sh

# 4. Run initial server setup
./ubuntu-deploy.sh setup

# 5. Log out and back in for Docker group changes
exit
ssh user@your-server-ip
```

### Phase 2: Application Deployment

```bash
# 1. Navigate to project directory
cd JoiningBetarepo

# 2. Configure environment
cp env.example .env
nano .env

# 3. Deploy application
./ubuntu-deploy.sh deploy

# 4. Check status
./ubuntu-deploy.sh status
```

## 🔧 Detailed Step-by-Step Guide

### Step 1: Server Initialization

#### 1.1 Update System
```bash
sudo apt update && sudo apt upgrade -y
```

#### 1.2 Install Essential Packages
```bash
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
```

#### 1.3 Install Docker
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
rm get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### 1.4 Configure Firewall
```bash
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 8000
echo "y" | sudo ufw enable
```

#### 1.5 Install SSL Tools
```bash
sudo apt install -y certbot python3-certbot-nginx
```

### Step 2: Application Setup

#### 2.1 Clone Repository
```bash
git clone <your-repo-url>
cd JoiningBetarepo
```

#### 2.2 Configure Environment
```bash
# Copy environment template
cp env.example .env

# Edit configuration
nano .env
```

**Production Environment Configuration:**
```env
# Database Configuration
DB_HOST=mysql
DB_PORT=3306
DB_NAME=lawviksh_db
DB_USER=root
DB_PASSWORD=your_secure_password_here

# Security Configuration
SECRET_KEY=your_secure_secret_key_here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Admin Credentials
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your_secure_admin_password

# Server Configuration
HOST=0.0.0.0
PORT=8000
DEBUG=False

# API Configuration
API_BASE_URL=https://www.lawvriksh.com/api
API_PREFIX=/api

# CORS Configuration - Production
CORS_ORIGINS=["https://www.lawvriksh.com","https://lawvriksh.com","https://app.lawvriksh.com","https://admin.lawvriksh.com"]
CORS_ALLOW_CREDENTIALS=true
CORS_ALLOW_METHODS=["GET","POST","PUT","DELETE","OPTIONS","PATCH"]
CORS_ALLOW_HEADERS=["*"]
CORS_EXPOSE_HEADERS=["Content-Length","Content-Type","Authorization"]
CORS_MAX_AGE=86400
```

### Step 3: SSL Certificate Setup

#### 3.1 Domain Verification
```bash
# Check if domain resolves to your server
nslookup www.lawvriksh.com
```

#### 3.2 Obtain SSL Certificates
```bash
# Get Let's Encrypt certificates
sudo certbot certonly --standalone \
    -d www.lawvriksh.com \
    -d lawvriksh.com \
    --email admin@lawvriksh.com \
    --agree-tos \
    --non-interactive
```

#### 3.3 Copy Certificates
```bash
# Create SSL directory
mkdir -p ssl

# Copy certificates
sudo cp /etc/letsencrypt/live/www.lawvriksh.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/www.lawvriksh.com/privkey.pem ssl/key.pem

# Set permissions
sudo chmod 644 ssl/cert.pem
sudo chmod 600 ssl/key.pem
sudo chown $USER:$USER ssl/cert.pem ssl/key.pem
```

#### 3.4 Setup Auto-renewal
```bash
# Test renewal
sudo certbot renew --dry-run

# Add to crontab
sudo crontab -e

# Add this line
0 12 * * * /usr/bin/certbot renew --quiet && cp /etc/letsencrypt/live/www.lawvriksh.com/fullchain.pem /path/to/project/ssl/cert.pem && cp /etc/letsencrypt/live/www.lawvriksh.com/privkey.pem /path/to/project/ssl/key.pem && chmod 644 /path/to/project/ssl/cert.pem && chmod 600 /path/to/project/ssl/key.pem && chown user:user /path/to/project/ssl/cert.pem /path/to/project/ssl/key.pem && docker-compose -f /path/to/project/docker-compose.prod.yml restart nginx
```

### Step 4: Application Deployment

#### 4.1 Deploy with Docker Compose
```bash
# Build and start services
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d

# Check status
docker-compose -f docker-compose.prod.yml ps
```

#### 4.2 Verify Deployment
```bash
# Health check
curl https://www.lawvriksh.com/health

# Test API endpoint
curl https://www.lawvriksh.com/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"admin123"}'
```

## 🔧 Automated Deployment Script

### Using the Ubuntu Deployment Script

```bash
# 1. Initial server setup (run once)
./ubuntu-deploy.sh setup

# 2. Deploy application
./ubuntu-deploy.sh deploy

# 3. Check status
./ubuntu-deploy.sh status

# 4. View logs
./ubuntu-deploy.sh logs

# 5. Update application
./ubuntu-deploy.sh update

# 6. Create backup
./ubuntu-deploy.sh backup

# 7. Restore from backup
./ubuntu-deploy.sh restore
```

## 📊 Monitoring and Maintenance

### Health Monitoring
```bash
# Check application health
curl https://www.lawvriksh.com/health

# Check container status
docker-compose -f docker-compose.prod.yml ps

# Check resource usage
docker stats --no-stream

# Check system resources
htop
df -h
free -h
```

### Log Management
```bash
# View application logs
docker-compose -f docker-compose.prod.yml logs -f

# View specific service logs
docker-compose -f docker-compose.prod.yml logs -f app
docker-compose -f docker-compose.prod.yml logs -f nginx
docker-compose -f docker-compose.prod.yml logs -f mysql

# Check system logs
sudo journalctl -u docker
sudo journalctl -u fail2ban
```

### Backup Strategy
```bash
# Create backup
./ubuntu-deploy.sh backup

# Manual database backup
docker-compose -f docker-compose.prod.yml exec mysql mysqldump -u root -p lawviksh_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore database
docker-compose -f docker-compose.prod.yml exec -T mysql mysql -u root -p lawviksh_db < backup_file.sql
```

## 🔒 Security Configuration

### Firewall Rules
```bash
# Check firewall status
sudo ufw status

# Allow specific ports
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 8000

# Enable firewall
sudo ufw enable
```

### Fail2ban Configuration
```bash
# Check fail2ban status
sudo systemctl status fail2ban

# View banned IPs
sudo fail2ban-client status sshd
sudo fail2ban-client status nginx-http-auth
```

### SSL Security
```bash
# Check SSL certificate
openssl x509 -in ssl/cert.pem -text -noout

# Test SSL connection
openssl s_client -connect www.lawvriksh.com:443 -servername www.lawvriksh.com

# Check SSL grade
curl -s https://www.ssllabs.com/ssltest/analyze.html?d=www.lawvriksh.com
```

## 🚨 Troubleshooting

### Common Issues and Solutions

#### 1. Port Already in Use
```bash
# Check what's using the port
sudo lsof -i :8000
sudo lsof -i :80
sudo lsof -i :443

# Stop conflicting services
sudo systemctl stop apache2  # if Apache is running
sudo systemctl stop nginx    # if nginx is running
```

#### 2. Docker Permission Issues
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in
exit
ssh user@your-server-ip
```

#### 3. SSL Certificate Issues
```bash
# Check certificate validity
openssl x509 -in ssl/cert.pem -text -noout

# Renew certificates manually
sudo certbot renew

# Test renewal
sudo certbot renew --dry-run
```

#### 4. Database Connection Issues
```bash
# Check MySQL container
docker-compose -f docker-compose.prod.yml ps mysql

# Check MySQL logs
docker-compose -f docker-compose.prod.yml logs mysql

# Access MySQL directly
docker-compose -f docker-compose.prod.yml exec mysql mysql -u root -p
```

#### 5. CORS Issues
```bash
# Test CORS preflight
curl -X OPTIONS https://www.lawvriksh.com/api/auth/login \
    -H "Origin: https://www.lawvriksh.com" \
    -H "Access-Control-Request-Method: POST" \
    -H "Access-Control-Request-Headers: Content-Type" \
    -v
```

## 📈 Performance Optimization

### System Optimization
```bash
# Update system limits
sudo tee -a /etc/security/limits.conf <<EOF
* soft nofile 65536
* hard nofile 65536
EOF

# Optimize Docker daemon
sudo tee /etc/docker/daemon.json <<EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    }
}
EOF

sudo systemctl restart docker
```

### Application Optimization
```bash
# Monitor resource usage
docker stats

# Check container resource limits
docker inspect lawviksh_app_prod | grep -A 10 "HostConfig"

# Optimize nginx configuration
# Edit nginx.prod.conf for your specific needs
```

## 🔄 Update Strategy

### Application Updates
```bash
# Pull latest changes
git pull origin main

# Backup current deployment
./ubuntu-deploy.sh backup

# Update application
./ubuntu-deploy.sh update

# Verify update
./ubuntu-deploy.sh status
```

### System Updates
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Update Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# Update Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## 📋 Production Checklist

### Pre-deployment
- [ ] Ubuntu 20.04+ installed
- [ ] Domain DNS configured
- [ ] SSH access configured
- [ ] Sudo privileges granted
- [ ] Repository cloned

### Server Setup
- [ ] System packages updated
- [ ] Docker installed
- [ ] Docker Compose installed
- [ ] Firewall configured
- [ ] Fail2ban configured
- [ ] SSL certificates obtained
- [ ] Auto-renewal configured

### Application Deployment
- [ ] Environment variables configured
- [ ] SSL certificates in place
- [ ] Docker containers built
- [ ] Services started
- [ ] Health checks passing
- [ ] API endpoints accessible
- [ ] CORS working correctly

### Post-deployment
- [ ] Monitoring configured
- [ ] Backup strategy in place
- [ ] Log rotation configured
- [ ] Security measures implemented
- [ ] Performance optimized
- [ ] Documentation updated

## 📞 Support Commands

### Quick Status Check
```bash
./ubuntu-deploy.sh status
```

### View All Logs
```bash
./ubuntu-deploy.sh logs
```

### Restart Everything
```bash
docker-compose -f docker-compose.prod.yml restart
```

### Complete Redeploy
```bash
./ubuntu-deploy.sh backup
./ubuntu-deploy.sh deploy
```

## 🎯 Final Verification

After deployment, verify these endpoints:

- ✅ **Health Check**: `https://www.lawvriksh.com/health`
- ✅ **API Base**: `https://www.lawvriksh.com/api/`
- ✅ **Documentation**: `https://www.lawvriksh.com/docs`
- ✅ **Authentication**: `https://www.lawvriksh.com/api/auth/login`
- ✅ **SSL Certificate**: Valid and auto-renewing
- ✅ **CORS**: Working for frontend integration

Your LawViksh Backend is now successfully deployed on Ubuntu with production-grade security, monitoring, and maintenance capabilities! 