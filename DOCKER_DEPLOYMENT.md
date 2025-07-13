# LawViksh Backend Docker Deployment Guide

This guide provides comprehensive instructions for deploying the LawViksh Backend API using Docker and Docker Compose.

## 📋 Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Git
- OpenSSL (for SSL certificates)

## 🚀 Quick Start

### 1. Clone and Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd JoiningBetarepo

# Make deployment script executable (Linux/Mac)
chmod +x deploy.sh
```

### 2. Environment Configuration

Create a `.env` file with your configuration:

```bash
# Copy example environment file
cp env.example .env

# Edit the configuration
nano .env
```

Example `.env` configuration:

```env
# Database Configuration
DB_HOST=mysql
DB_PORT=3306
DB_NAME=lawviksh_db
DB_USER=root
DB_PASSWORD=Sahil@123

# Security Configuration
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Admin Credentials
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin123

# Server Configuration
HOST=0.0.0.0
PORT=8000
DEBUG=False

# CORS Configuration
CORS_ORIGINS=["http://localhost:3000","https://www.lawvriksh.com","https://lawvriksh.com"]
```

### 3. Deploy Application

#### Development Environment
```bash
# Using deployment script
./deploy.sh dev

# Or using docker-compose directly
docker-compose up -d
```

#### Production Environment
```bash
# Using deployment script
./deploy.sh prod

# Or using docker-compose directly
docker-compose -f docker-compose.prod.yml up -d
```

## 🐳 Docker Configuration

### Multi-stage Dockerfile

The `Dockerfile` uses a multi-stage build approach:

1. **Builder Stage**: Installs dependencies and creates virtual environment
2. **Production Stage**: Creates optimized production image

Key features:
- Python 3.11 slim base image
- Multi-stage build for smaller final image
- Non-root user for security
- Health checks
- Optimized layer caching

### Docker Compose Services

#### Development (`docker-compose.yml`)
- **MySQL 8.0**: Database with persistent storage
- **FastAPI App**: Application with hot-reload
- **Nginx**: Optional reverse proxy (production profile)

#### Production (`docker-compose.prod.yml`)
- **MySQL 8.0**: Database with resource limits
- **FastAPI App**: Optimized production build
- **Nginx**: Reverse proxy with SSL support

## 🔧 Deployment Scripts

### Linux/Mac (`deploy.sh`)

```bash
# Development deployment
./deploy.sh dev

# Production deployment
./deploy.sh prod

# Stop all containers
./deploy.sh stop

# View logs
./deploy.sh logs
./deploy.sh logs prod

# Restart services
./deploy.sh restart
./deploy.sh restart prod

# Clean up resources
./deploy.sh clean

# Check status
./deploy.sh status
```

### Windows (`docker-deploy.bat`)

```cmd
# Development deployment
docker-deploy.bat dev

# Production deployment
docker-deploy.bat prod

# Stop all containers
docker-deploy.bat stop

# View logs
docker-deploy.bat logs
docker-deploy.bat logs prod

# Restart services
docker-deploy.bat restart
docker-deploy.bat restart prod

# Clean up resources
docker-deploy.bat clean

# Check status
docker-deploy.bat status
```

## 🌐 SSL/HTTPS Setup

### Automatic SSL Setup

The deployment scripts automatically create self-signed certificates for testing:

```bash
# Certificates are created automatically during production deployment
./deploy.sh prod
```

### Manual SSL Setup

For production with Let's Encrypt certificates:

```bash
# Install certbot
sudo apt install certbot

# Get SSL certificate
sudo certbot certonly --standalone -d lawvriksh.com -d www.lawvriksh.com

# Copy certificates
sudo cp /etc/letsencrypt/live/lawvriksh.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/lawvriksh.com/privkey.pem ssl/key.pem
sudo chmod 644 ssl/cert.pem
sudo chmod 600 ssl/key.pem
```

## 📊 Monitoring and Management

### Health Checks

The application includes health check endpoints:

```bash
# Application health
curl http://localhost:8000/health

# Docker health checks
docker-compose ps
```

### Logs

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f app
docker-compose logs -f mysql

# Production logs
docker-compose -f docker-compose.prod.yml logs -f
```

### Resource Monitoring

```bash
# Container resource usage
docker stats

# System resource usage
htop
```

## 🔄 Backup and Recovery

### Database Backup

```bash
# Create backup
docker-compose exec mysql mysqldump -u root -p lawviksh_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore backup
docker-compose exec -T mysql mysql -u root -p lawviksh_db < backup_file.sql
```

### Volume Backup

```bash
# Backup volumes
docker run --rm -v lawviksh_mysql_data:/data -v $(pwd):/backup alpine tar czf /backup/mysql_backup.tar.gz -C /data .

# Restore volumes
docker run --rm -v lawviksh_mysql_data:/data -v $(pwd):/backup alpine tar xzf /backup/mysql_backup.tar.gz -C /data
```

## 🛠️ Troubleshooting

### Common Issues

#### 1. Port Already in Use
```bash
# Check what's using the port
sudo lsof -i :8000

# Stop conflicting services
sudo systemctl stop apache2  # if Apache is running
```

#### 2. Database Connection Issues
```bash
# Check MySQL container status
docker-compose ps mysql

# Check MySQL logs
docker-compose logs mysql

# Access MySQL directly
docker-compose exec mysql mysql -u root -p
```

#### 3. Permission Issues
```bash
# Fix file permissions
sudo chown -R $USER:$USER .

# Fix Docker permissions
sudo usermod -aG docker $USER
# Log out and back in
```

#### 4. SSL Certificate Issues
```bash
# Check certificate validity
openssl x509 -in ssl/cert.pem -text -noout

# Regenerate certificates
rm -rf ssl/
./deploy.sh prod
```

### Debug Commands

```bash
# Access container shell
docker-compose exec app bash
docker-compose exec mysql mysql -u root -p

# Check network connectivity
docker network ls
docker network inspect lawviksh_lawviksh_network

# Check container details
docker inspect lawviksh_app
```

## 📈 Performance Optimization

### Resource Limits

The production compose file includes resource limits:

- **App**: 1GB RAM, 1 CPU
- **MySQL**: 512MB RAM, 0.5 CPU
- **Nginx**: 128MB RAM, 0.25 CPU

### Optimization Tips

1. **Use Production Build**: Always use `docker-compose.prod.yml` for production
2. **Enable Caching**: Use Docker layer caching for faster builds
3. **Monitor Resources**: Use `docker stats` to monitor resource usage
4. **Regular Updates**: Keep base images updated for security patches

## 🔒 Security Best Practices

1. **Use Strong Passwords**: Change default passwords in `.env`
2. **Limit Network Access**: Use Docker networks for service communication
3. **Regular Updates**: Keep images and dependencies updated
4. **SSL/TLS**: Use proper SSL certificates in production
5. **Non-root User**: Application runs as non-root user
6. **Resource Limits**: Prevent resource exhaustion attacks

## 📞 Support

### Useful Commands

```bash
# Quick status check
./deploy.sh status

# View all logs
./deploy.sh logs

# Restart everything
./deploy.sh restart

# Complete cleanup and redeploy
./deploy.sh clean
./deploy.sh prod
```

### Access URLs

After successful deployment:

- **API Base**: http://localhost:8000/api/ (dev) / https://www.lawvriksh.com/api/ (prod)
- **Documentation**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health
- **ReDoc**: http://localhost:8000/redoc

### Environment Variables

Key environment variables for customization:

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_HOST` | Database host | `mysql` |
| `DB_PASSWORD` | Database password | `Sahil@123` |
| `SECRET_KEY` | JWT secret key | Auto-generated |
| `DEBUG` | Debug mode | `False` (prod) |
| `CORS_ORIGINS` | Allowed origins | Domain-specific |

## 🎯 Production Checklist

- [ ] Environment variables configured
- [ ] SSL certificates installed
- [ ] Database initialized with data
- [ ] Health checks passing
- [ ] Resource limits configured
- [ ] Logs being collected
- [ ] Backup strategy in place
- [ ] Monitoring configured
- [ ] Security measures implemented
- [ ] Performance optimized 