# LawViksh Backend Docker Deployment Guide

This guide provides comprehensive instructions for deploying the LawViksh Backend API using Docker containers.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Docker Desktop** (for Windows/Mac) or **Docker Engine** (for Linux)
- **Docker Compose** (usually included with Docker Desktop)
- **Git** (for cloning the repository)

## 🚀 Quick Start

### 1. Clone and Navigate to Project
```bash
git clone <your-repository-url>
cd JoiningBetarepo
```

### 2. Set Up Environment Variables
```bash
# Copy the example environment file
cp env.example .env

# Edit the .env file with your production values
# Use a secure text editor to modify the values
```

### 3. Deploy Using Scripts

#### For Windows:
```cmd
# Development deployment
docker-deploy.bat start

# Production deployment
docker-deploy.bat production

# View logs
docker-deploy.bat logs

# Stop services
docker-deploy.bat stop
```

#### For Linux/Mac:
```bash
# Make script executable (first time only)
chmod +x docker-deploy.sh

# Development deployment
./docker-deploy.sh start

# Production deployment
./docker-deploy.sh production

# View logs
./docker-deploy.sh logs

# Stop services
./docker-deploy.sh stop
```

## 📁 Docker Files Overview

### Core Files
- **`Dockerfile`** - Multi-stage Docker image for the FastAPI application
- **`docker-compose.yml`** - Development environment with MySQL and optional Nginx
- **`docker-compose.prod.yml`** - Production environment with enhanced security
- **`.dockerignore`** - Excludes unnecessary files from Docker build context

### Configuration Files
- **`nginx.conf`** - Nginx configuration for development
- **`nginx.prod.conf`** - Production Nginx configuration with security headers
- **`env.example`** - Template for environment variables

### Deployment Scripts
- **`docker-deploy.sh`** - Linux/Mac deployment script
- **`docker-deploy.bat`** - Windows deployment script

## 🔧 Manual Deployment

### Development Environment

1. **Build and start services:**
```bash
docker-compose up -d --build
```

2. **Check service status:**
```bash
docker-compose ps
```

3. **View logs:**
```bash
docker-compose logs -f
```

4. **Stop services:**
```bash
docker-compose down
```

### Production Environment

1. **Set up environment variables:**
```bash
cp env.example .env
# Edit .env with production values
```

2. **Build and start production services:**
```bash
docker-compose -f docker-compose.prod.yml up -d --build
```

3. **Check production status:**
```bash
docker-compose -f docker-compose.prod.yml ps
```

## 🔐 Environment Variables

Create a `.env` file with the following variables:

```env
# Database Configuration
MYSQL_ROOT_PASSWORD=your_secure_root_password
MYSQL_DATABASE=lawviksh_db
MYSQL_USER=lawviksh_user
MYSQL_PASSWORD=your_secure_user_password

# Security Configuration
SECRET_KEY=your_secure_secret_key_here_make_it_long_and_random
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Admin Credentials
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your_secure_admin_password

# Server Configuration
HOST=0.0.0.0
PORT=8000
DEBUG=false

# CORS Configuration (comma-separated)
CORS_ORIGINS=https://www.lawvriksh.com,https://lawvriksh.com,http://localhost:3000
```

## 🌐 SSL/HTTPS Setup

For production deployment with HTTPS:

1. **Create SSL directory:**
```bash
mkdir ssl
```

2. **Add your SSL certificates:**
```bash
# Copy your SSL certificates to the ssl directory
cp your-cert.pem ssl/cert.pem
cp your-key.pem ssl/key.pem
```

3. **Deploy with Nginx:**
```bash
# The production compose file includes Nginx with SSL
docker-compose -f docker-compose.prod.yml up -d
```

## 📊 Monitoring and Health Checks

### Health Check Endpoint
The application includes a health check endpoint:
```bash
curl http://localhost:8000/health
```

### Docker Health Checks
All services include Docker health checks:
```bash
# Check container health
docker-compose ps

# View health check logs
docker inspect <container_name>
```

## 🔍 Troubleshooting

### Common Issues

1. **Port already in use:**
```bash
# Check what's using the port
netstat -tulpn | grep :8000

# Stop conflicting services or change ports in docker-compose.yml
```

2. **Database connection issues:**
```bash
# Check MySQL container logs
docker-compose logs mysql

# Ensure database is ready before starting app
docker-compose up mysql -d
# Wait a few seconds, then start app
docker-compose up app -d
```

3. **Permission issues (Linux/Mac):**
```bash
# Fix file permissions
sudo chown -R $USER:$USER .
chmod +x docker-deploy.sh
```

4. **Build failures:**
```bash
# Clean Docker cache
docker system prune -a

# Rebuild without cache
docker-compose build --no-cache
```

### Logs and Debugging

```bash
# View all service logs
docker-compose logs

# View specific service logs
docker-compose logs app
docker-compose logs mysql

# Follow logs in real-time
docker-compose logs -f

# Access container shell
docker-compose exec app bash
docker-compose exec mysql mysql -u root -p
```

## 🔄 Updates and Maintenance

### Updating the Application

1. **Pull latest changes:**
```bash
git pull origin main
```

2. **Rebuild and restart:**
```bash
# Development
docker-compose down
docker-compose up -d --build

# Production
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d --build
```

### Database Backups

```bash
# Create backup
docker-compose exec mysql mysqldump -u root -p lawviksh_db > backup.sql

# Restore backup
docker-compose exec -T mysql mysql -u root -p lawviksh_db < backup.sql
```

### Cleanup

```bash
# Remove unused containers, networks, and images
docker system prune -a

# Remove specific volumes (WARNING: This will delete data)
docker volume rm joiningbetarepo_mysql_data
```

## 🛡️ Security Considerations

### Production Security Checklist

- [ ] Use strong, unique passwords for all services
- [ ] Generate a secure SECRET_KEY (use `generate_secret_key.py`)
- [ ] Enable HTTPS with valid SSL certificates
- [ ] Configure firewall rules
- [ ] Regularly update Docker images and dependencies
- [ ] Monitor logs for suspicious activity
- [ ] Use production Nginx configuration
- [ ] Enable rate limiting
- [ ] Set up automated backups

### Security Features Included

- **Non-root user** in Docker containers
- **Read-only filesystems** where possible
- **Security headers** in Nginx
- **Rate limiting** for API endpoints
- **CORS protection**
- **Input validation** and sanitization
- **SQL injection protection** via parameterized queries

## 📈 Performance Optimization

### Docker Optimizations

- **Multi-stage builds** for smaller images
- **Layer caching** for faster builds
- **Health checks** for better orchestration
- **Resource limits** in production

### Application Optimizations

- **Connection pooling** for database
- **Gzip compression** via Nginx
- **Static file caching**
- **Load balancing** ready

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review Docker and application logs
3. Ensure all prerequisites are met
4. Verify environment variables are correctly set
5. Check network connectivity between containers

## 📝 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Nginx Documentation](https://nginx.org/en/docs/) 