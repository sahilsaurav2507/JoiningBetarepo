# LawViksh API Deployment Guide

This guide provides step-by-step instructions for deploying the LawViksh Backend API at `https://www.lawvriksh.com/api/` with proper CORS management for frontend-backend communication.

## 🎯 Deployment Target

- **API Base URL**: `https://www.lawvriksh.com/api/`
- **Documentation**: `https://www.lawvriksh.com/docs`
- **Health Check**: `https://www.lawvriksh.com/health`
- **ReDoc**: `https://www.lawvriksh.com/redoc`

## 📋 Prerequisites

- VPS/Server with Ubuntu 20.04+
- Domain: `www.lawvriksh.com` pointing to your server
- Docker and Docker Compose installed
- SSL certificates for HTTPS

## 🚀 Quick Deployment

### 1. Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Log out and back in for Docker group changes
```

### 2. Clone and Configure

```bash
# Clone repository
git clone <your-repo-url>
cd JoiningBetarepo

# Create environment file
cp env.example .env

# Edit configuration
nano .env
```

### 3. Environment Configuration

Update your `.env` file with production values:

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

### 4. SSL Certificate Setup

```bash
# Install certbot
sudo apt install certbot

# Get SSL certificates
sudo certbot certonly --standalone -d lawvriksh.com -d www.lawvriksh.com

# Create SSL directory and copy certificates
mkdir -p ssl
sudo cp /etc/letsencrypt/live/lawvriksh.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/lawvriksh.com/privkey.pem ssl/key.pem
sudo chmod 644 ssl/cert.pem
sudo chmod 600 ssl/key.pem
```

### 5. Deploy Application

```bash
# Make deployment script executable
chmod +x deploy.sh

# Deploy production environment
./deploy.sh prod
```

## 🔧 CORS Configuration

### Frontend Integration

Your frontend should be configured to use the API base URL:

```javascript
// Frontend configuration
const API_BASE_URL = 'https://www.lawvriksh.com/api';

// Example API calls
const response = await fetch(`${API_BASE_URL}/auth/login`, {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
    },
    credentials: 'include', // For cookies
    body: JSON.stringify({
        username: 'user@example.com',
        password: 'password'
    })
});
```

### CORS Origins Configuration

The API is configured to accept requests from:

- `https://www.lawvriksh.com` (Main domain)
- `https://lawvriksh.com` (Domain without www)
- `https://app.lawvriksh.com` (App subdomain)
- `https://admin.lawvriksh.com` (Admin subdomain)

For development, you can add localhost origins:

```env
CORS_ORIGINS=["http://localhost:3000","http://localhost:3001","https://www.lawvriksh.com","https://lawvriksh.com"]
```

## 🌐 API Endpoints

After deployment, your API will be available at:

### Authentication
- `POST https://www.lawvriksh.com/api/auth/login`
- `POST https://www.lawvriksh.com/api/auth/logout`
- `POST https://www.lawvriksh.com/api/auth/refresh`

### User Management
- `GET https://www.lawvriksh.com/api/users`
- `POST https://www.lawvriksh.com/api/users`
- `PUT https://www.lawvriksh.com/api/users/{id}`
- `DELETE https://www.lawvriksh.com/api/users/{id}`

### Feedback
- `GET https://www.lawvriksh.com/api/feedback`
- `POST https://www.lawvriksh.com/api/feedback`
- `PUT https://www.lawvriksh.com/api/feedback/{id}`

### Data
- `GET https://www.lawvriksh.com/api/data`
- `POST https://www.lawvriksh.com/api/data`

### Health & Documentation
- `GET https://www.lawvriksh.com/health`
- `GET https://www.lawvriksh.com/docs`
- `GET https://www.lawvriksh.com/redoc`

## 🔒 Security Features

### CORS Security
- Strict origin validation
- Credential support for authentication
- Preflight request handling
- Rate limiting on API endpoints

### SSL/TLS
- HTTPS enforcement
- HSTS headers
- Secure cipher configuration
- SSL certificate auto-renewal

### API Security
- JWT token authentication
- Rate limiting (10 requests/second)
- Input validation
- SQL injection protection

## 📊 Monitoring

### Health Checks

```bash
# Check API health
curl https://www.lawvriksh.com/health

# Expected response
{
    "status": "healthy",
    "database": "connected",
    "timestamp": 1234567890
}
```

### Logs

```bash
# View application logs
./deploy.sh logs prod

# View specific service logs
docker-compose -f docker-compose.prod.yml logs -f app
docker-compose -f docker-compose.prod.yml logs -f nginx
```

### Status

```bash
# Check service status
./deploy.sh status
```

## 🔄 SSL Certificate Renewal

Set up automatic SSL certificate renewal:

```bash
# Test renewal
sudo certbot renew --dry-run

# Add to crontab for automatic renewal
sudo crontab -e

# Add this line
0 12 * * * /usr/bin/certbot renew --quiet && docker-compose -f /path/to/your/project/docker-compose.prod.yml restart nginx
```

## 🛠️ Troubleshooting

### CORS Issues

If you encounter CORS errors:

1. **Check Origin**: Ensure your frontend domain is in `CORS_ORIGINS`
2. **Check Protocol**: Use HTTPS for production
3. **Check Headers**: Ensure proper headers are sent

```bash
# Test CORS preflight
curl -X OPTIONS https://www.lawvriksh.com/api/auth/login \
  -H "Origin: https://www.lawvriksh.com" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v
```

### SSL Issues

```bash
# Check certificate validity
openssl x509 -in ssl/cert.pem -text -noout

# Test SSL connection
openssl s_client -connect www.lawvriksh.com:443 -servername www.lawvriksh.com
```

### Database Issues

```bash
# Check database connection
docker-compose -f docker-compose.prod.yml exec mysql mysql -u root -p

# Check database logs
docker-compose -f docker-compose.prod.yml logs mysql
```

## 📈 Performance Optimization

### Nginx Configuration
- Gzip compression enabled
- HTTP/2 support
- Connection pooling
- Rate limiting

### Application Optimization
- Resource limits configured
- Health checks enabled
- Proper logging
- Error handling

## 🔄 Backup Strategy

### Database Backup

```bash
# Create backup
docker-compose -f docker-compose.prod.yml exec mysql mysqldump -u root -p lawviksh_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore backup
docker-compose -f docker-compose.prod.yml exec -T mysql mysql -u root -p lawviksh_db < backup_file.sql
```

### Configuration Backup

```bash
# Backup configuration
tar -czf config_backup_$(date +%Y%m%d_%H%M%S).tar.gz .env ssl/ nginx.prod.conf
```

## 🎯 Production Checklist

- [ ] Domain DNS configured
- [ ] SSL certificates installed
- [ ] Environment variables set
- [ ] Database initialized
- [ ] CORS origins configured
- [ ] Health checks passing
- [ ] Logs being collected
- [ ] Backup strategy in place
- [ ] Monitoring configured
- [ ] Frontend updated with API URL

## 📞 Support

### Useful Commands

```bash
# Quick deployment
./deploy.sh prod

# View logs
./deploy.sh logs prod

# Restart services
./deploy.sh restart prod

# Check status
./deploy.sh status

# Complete cleanup and redeploy
./deploy.sh clean
./deploy.sh prod
```

### API Testing

```bash
# Test API endpoints
curl -X GET https://www.lawvriksh.com/api/users \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"

# Test authentication
curl -X POST https://www.lawvriksh.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

Your API is now ready to serve requests at `https://www.lawvriksh.com/api/` with proper CORS management for secure frontend-backend communication! 