# MySQL Container Troubleshooting Guide

This guide helps you resolve the "container lawviksh_mysql_prod is unhealthy" error that occurs during deployment.

## 🚨 Quick Fix Commands

### Option 1: Use the Fix Script
```bash
# Make scripts executable
chmod +x debug-mysql.sh fix-mysql-issue.sh

# Debug the issue
./debug-mysql.sh

# Fix the issue
./fix-mysql-issue.sh
```

### Option 2: Manual Fix
```bash
# Stop all containers
docker-compose -f docker-compose.prod.yml down

# Remove MySQL volume (WARNING: This deletes all data)
docker volume rm joiningbetarepo_mysql_data_prod

# Start MySQL only first
docker-compose -f docker-compose.prod.yml up -d mysql

# Wait for MySQL to be healthy
sleep 60

# Start other services
docker-compose -f docker-compose.prod.yml up -d
```

### Option 3: Use Lightweight Version
```bash
# Use MySQL 5.7 for lower resource usage
docker-compose -f docker-compose.prod.light.yml up -d
```

## 🔍 Common Causes and Solutions

### 1. Insufficient System Resources

**Symptoms:**
- MySQL container fails to start
- System runs out of memory
- High CPU usage

**Solutions:**
```bash
# Check system resources
free -h
df -h

# Increase swap space
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make swap permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 2. MySQL Health Check Timeout

**Symptoms:**
- Health check fails before MySQL is ready
- Container marked as unhealthy

**Solutions:**
```bash
# Use the updated docker-compose.prod.yml with longer timeouts
# Or manually increase timeouts in your compose file:

healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${DB_ROOT_PASSWORD:-Sahil@123}"]
  timeout: 120s
  retries: 30
  start_period: 120s
```

### 3. Port Conflicts

**Symptoms:**
- Port 3306 already in use
- MySQL can't bind to port

**Solutions:**
```bash
# Check what's using port 3306
sudo lsof -i :3306

# Stop conflicting services
sudo systemctl stop mysql  # if system MySQL is running
sudo systemctl stop mariadb  # if MariaDB is running

# Or change MySQL port in docker-compose
ports:
  - "3307:3306"  # Use different external port
```

### 4. Permission Issues

**Symptoms:**
- Docker permission denied errors
- Volume mount issues

**Solutions:**
```bash
# Fix Docker permissions
sudo usermod -aG docker $USER
sudo chown -R $USER:$USER /var/lib/docker

# Log out and back in
exit
ssh user@your-server-ip
```

### 5. MySQL Configuration Issues

**Symptoms:**
- MySQL fails to initialize
- Configuration errors in logs

**Solutions:**
```bash
# Check MySQL logs
docker-compose -f docker-compose.prod.yml logs mysql

# Access MySQL container
docker-compose -f docker-compose.prod.yml exec mysql bash

# Check MySQL status inside container
mysql -u root -p -e "SELECT VERSION();"
```

## 🛠️ Step-by-Step Troubleshooting

### Step 1: Check System Resources
```bash
# Memory usage
free -h

# Disk usage
df -h

# CPU usage
top

# Docker resources
docker system df
```

### Step 2: Check Container Status
```bash
# List all containers
docker ps -a

# Check MySQL container specifically
docker inspect lawviksh_mysql_prod

# Check container logs
docker-compose -f docker-compose.prod.yml logs mysql
```

### Step 3: Check Docker Daemon
```bash
# Check Docker service status
sudo systemctl status docker

# Check Docker logs
sudo journalctl -u docker --no-pager -l

# Restart Docker if needed
sudo systemctl restart docker
```

### Step 4: Verify Environment Variables
```bash
# Check if .env file exists
ls -la .env

# Check database environment variables
grep -E "DB_|MYSQL_" .env
```

## 🔧 Alternative Solutions

### Solution 1: Use MySQL 5.7 (Lower Resource Usage)
```bash
# Use the lightweight compose file
docker-compose -f docker-compose.prod.light.yml up -d
```

### Solution 2: Increase System Resources
```bash
# Add more swap space
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Reduce MySQL memory limits
# Edit docker-compose.prod.yml:
deploy:
  resources:
    limits:
      memory: 256M  # Reduce from 512M
      cpus: '0.25'  # Reduce from 0.5
```

### Solution 3: Use External MySQL
```bash
# If you have an external MySQL server, update .env:
DB_HOST=your-external-mysql-host
DB_PORT=3306
DB_NAME=lawviksh_db
DB_USER=your_user
DB_PASSWORD=your_password

# Remove MySQL service from docker-compose
# Comment out the mysql service in docker-compose.prod.yml
```

### Solution 4: Use SQLite Instead
```bash
# For very low-resource systems, consider using SQLite
# This requires modifying the application code
```

## 📊 Resource Requirements

### Minimum Requirements for MySQL 8.0
- **RAM**: 2GB total system RAM
- **Storage**: 20GB available space
- **CPU**: 1 vCPU

### Minimum Requirements for MySQL 5.7
- **RAM**: 1GB total system RAM
- **Storage**: 15GB available space
- **CPU**: 0.5 vCPU

### Recommended Requirements
- **RAM**: 4GB total system RAM
- **Storage**: 50GB available space
- **CPU**: 2 vCPU

## 🚨 Emergency Recovery

### If All Else Fails
```bash
# Complete reset
docker-compose -f docker-compose.prod.yml down -v
docker system prune -f
docker volume prune -f

# Start fresh
docker-compose -f docker-compose.prod.yml up -d
```

### Backup Before Troubleshooting
```bash
# Create backup before making changes
docker-compose -f docker-compose.prod.yml exec mysql mysqldump -u root -p lawviksh_db > backup_$(date +%Y%m%d_%H%M%S).sql
```

## 📞 Getting Help

### Debug Information to Collect
```bash
# Run the debug script
./debug-mysql.sh

# Collect system information
uname -a
docker --version
docker-compose --version
free -h
df -h
```

### Common Error Messages and Solutions

| Error Message | Solution |
|---------------|----------|
| `container is unhealthy` | Increase health check timeouts |
| `port already in use` | Stop conflicting services or change port |
| `permission denied` | Fix Docker permissions |
| `out of memory` | Increase swap space or reduce memory limits |
| `connection refused` | Check if MySQL is actually running |

## ✅ Success Verification

After fixing the issue, verify with:
```bash
# Check all services are running
docker-compose -f docker-compose.prod.yml ps

# Check MySQL health
docker-compose -f docker-compose.prod.yml exec mysql mysqladmin ping -h localhost -u root -p

# Check application health
curl https://www.lawvriksh.com/health

# Test database connection
docker-compose -f docker-compose.prod.yml exec mysql mysql -u root -p -e "USE lawviksh_db; SHOW TABLES;"
```

## 🎯 Prevention Tips

1. **Monitor Resources**: Regularly check system resources
2. **Use Resource Limits**: Set appropriate limits in docker-compose
3. **Regular Backups**: Backup database regularly
4. **Health Checks**: Use proper health check configurations
5. **Log Monitoring**: Monitor logs for early warning signs

---

**Remember**: The most common cause is insufficient system resources. If you're on a low-resource VPS, consider using the lightweight version with MySQL 5.7. 