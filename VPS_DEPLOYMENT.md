# LawViksh Backend VPS Deployment Guide

Complete guide for deploying LawViksh Backend on Ubuntu VPS for www.lawvriksh.com domain.

## 🚀 Quick Start (Recommended)

### Step 1: Upload Files to VPS
Upload all your project files to your Ubuntu VPS in a directory (e.g., `/home/username/lawviksh/`)

### Step 2: Setup Domain and SSL
```bash
cd /home/username/lawviksh/
chmod +x setup-domain.sh
sudo ./setup-domain.sh
```

### Step 3: Deploy Application
```bash
chmod +x quick-deploy.sh
./quick-deploy.sh
```

Your API will be available at `https://www.lawvriksh.com/api/`

## 🌐 Domain Configuration

### API Endpoints Structure
Your backend API will be accessible at:
- **Base URL**: `https://www.lawvriksh.com/api/`
- **Authentication**: `https://www.lawvriksh.com/api/auth/login`
- **Users**: `https://www.lawvriksh.com/api/users`
- **Feedback**: `https://www.lawvriksh.com/api/feedback`
- **Data**: `https://www.lawvriksh.com/api/data`
- **Health Check**: `https://www.lawvriksh.com/health`
- **API Docs**: `https://www.lawvriksh.com/docs`

### Frontend Integration
Update your frontend to use the new API base URL:
```javascript
// Old API calls
fetch('http://localhost:8000/auth/login', {...})

// New API calls
fetch('https://www.lawvriksh.com/api/auth/login', {...})
```

## 📋 Detailed Deployment Steps

### 1. Initial VPS Setup (Fresh Ubuntu Server)

If you have a fresh Ubuntu VPS, run the initial setup:

```bash
# Upload vps-setup.sh to your VPS
chmod +x vps-setup.sh
./vps-setup.sh
```

This will:
- Update system packages
- Install Docker and Docker Compose
- Configure firewall
- Create application directory

### 2. Upload Application Files

Upload all your project files to the VPS:
- All Python files
- Docker files
- Configuration files
- SQL files

### 3. Configure Environment

```bash
# Copy environment template
cp env.example .env

# Edit with your production values
nano .env
```

**Important**: Update these values in your `.env` file:
```env
# CORS Configuration
CORS_ORIGINS=https://www.lawvriksh.com,https://lawvriksh.com

# Domain Configuration
DOMAIN=www.lawvriksh.com
API_BASE_URL=https://www.lawvriksh.com/api
```

### 4. Setup SSL Certificates

```bash
# Setup SSL for www.lawvriksh.com
sudo ./setup-domain.sh
```

This will:
- Install certbot
- Obtain SSL certificates from Let's Encrypt
- Configure auto-renewal
- Set up firewall rules

### 5. Deploy Application

#### Option A: Quick Deploy (Recommended)
```bash
./quick-deploy.sh
```

#### Option B: Full Deployment
```bash
chmod +x deploy-vps.sh
./deploy-vps.sh full
```

## 🔧 Manual Deployment Commands

### Install Docker (if not installed)
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
# Log out and back in
```

### Install Docker Compose
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Deploy Application
```bash
# Build and start
docker-compose build --no-cache
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

## 🌐 SSL/HTTPS Setup

### Automatic SSL Setup (Recommended)
```bash
sudo ./setup-domain.sh
```

### Manual SSL Setup
```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot certonly --standalone -d lawvriksh.com -d www.lawvriksh.com

# Copy certificates
sudo cp /etc/letsencrypt/live/lawvriksh.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/lawvriksh.com/privkey.pem ssl/key.pem
sudo chmod 644 ssl/cert.pem
sudo chmod 600 ssl/key.pem
```

## 📊 Monitoring and Management

### Check Application Status
```bash
# Service status
docker-compose ps

# Health check
curl https://www.lawvriksh.com/health

# Application logs
docker-compose logs -f app

# Database logs
docker-compose logs -f mysql

# Nginx logs
docker-compose logs -f nginx
```

### Useful Commands
```bash
# Restart services
docker-compose restart

# Stop all services
docker-compose down

# Start services
docker-compose up -d

# Update application
git pull
docker-compose down
docker-compose up -d --build

# View resource usage
docker stats

# Clean up unused resources
docker system prune -a
```

## 🔐 Security Configuration

### Firewall Setup
```bash
# Allow necessary ports
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 8000

# Enable firewall
sudo ufw enable
```

### Environment Variables Security
Make sure your `.env` file has secure values:
```env
# Generate a secure secret key
SECRET_KEY=your_very_long_and_secure_secret_key_here

# Use strong passwords
MYSQL_ROOT_PASSWORD=very_strong_password_here
MYSQL_PASSWORD=another_strong_password_here
ADMIN_PASSWORD=secure_admin_password_here

# Domain configuration
CORS_ORIGINS=https://www.lawvriksh.com,https://lawvriksh.com
```

## 🚨 Troubleshooting

### Common Issues

1. **SSL Certificate Issues**
```bash
# Check certificate status
sudo certbot certificates

# Renew certificates
sudo certbot renew

# Check nginx SSL configuration
docker-compose logs nginx
```

2. **Domain Not Resolving**
```bash
# Check DNS settings
nslookup www.lawvriksh.com

# Check if domain points to your VPS IP
dig www.lawvriksh.com
```

3. **API Not Accessible**
```bash
# Check if nginx is running
docker-compose ps nginx

# Check nginx configuration
docker-compose exec nginx nginx -t

# Check application logs
docker-compose logs app
```

4. **CORS Issues**
```bash
# Verify CORS configuration in .env
cat .env | grep CORS

# Check browser console for CORS errors
# Ensure frontend is using https://www.lawvriksh.com/api/
```

### Debug Commands
```bash
# Check Docker status
sudo systemctl status docker

# Check container details
docker inspect lawviksh_app
docker inspect lawviksh_nginx

# Access container shell
docker-compose exec app bash
docker-compose exec nginx sh
docker-compose exec mysql mysql -u root -p

# Check network connectivity
docker network ls
docker network inspect lawviksh_lawviksh_network
```

## 📈 Performance Optimization

### Resource Limits
The docker-compose.yml includes resource limits:
- App: 1GB RAM, 1 CPU
- MySQL: 512MB RAM
- Nginx: 128MB RAM

### Monitoring
```bash
# Monitor resource usage
htop
docker stats

# Check disk usage
df -h
docker system df
```

## 🔄 Backup and Recovery

### Database Backup
```bash
# Create backup
docker-compose exec mysql mysqldump -u root -p lawviksh_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore backup
docker-compose exec -T mysql mysql -u root -p lawviksh_db < backup_file.sql
```

### Full Application Backup
```bash
# Backup entire application
tar -czf lawviksh_backup_$(date +%Y%m%d_%H%M%S).tar.gz . --exclude='.git' --exclude='__pycache__'
```

## 📞 Support Commands

### Quick Status Check
```bash
./deploy-vps.sh status
```

### View All Logs
```bash
./deploy-vps.sh logs
```

### Restart Everything
```bash
./deploy-vps.sh restart
```

## 🎯 Final Checklist

- [ ] VPS is running Ubuntu 20.04 or later
- [ ] All files uploaded to VPS
- [ ] Environment file configured with production values
- [ ] Docker and Docker Compose installed
- [ ] Firewall configured
- [ ] SSL certificates obtained for www.lawvriksh.com
- [ ] Application deployed and running
- [ ] Health check passing
- [ ] Domain www.lawvriksh.com points to VPS
- [ ] API accessible at https://www.lawvriksh.com/api/
- [ ] Frontend updated to use new API base URL
- [ ] CORS configured correctly
- [ ] Backups configured
- [ ] Monitoring set up

## 🌐 Access URLs

After successful deployment:
- **Main App**: `https://www.lawvriksh.com`
- **API Base**: `https://www.lawvriksh.com/api/`
- **Health Check**: `https://www.lawvriksh.com/health`
- **API Documentation**: `https://www.lawvriksh.com/docs`
- **ReDoc**: `https://www.lawvriksh.com/redoc`

## 🔧 Frontend Integration Guide

### Update API Base URL
In your frontend application, update all API calls:

```javascript
// Configuration
const API_BASE_URL = 'https://www.lawvriksh.com/api';

// Example API calls
const login = async (credentials) => {
  const response = await fetch(`${API_BASE_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(credentials)
  });
  return response.json();
};

const getUsers = async () => {
  const response = await fetch(`${API_BASE_URL}/users`);
  return response.json();
};
```

### CORS Configuration
The backend is configured to accept requests from:
- `https://www.lawvriksh.com`
- `https://lawvriksh.com`

Make sure your frontend is served from one of these domains. 