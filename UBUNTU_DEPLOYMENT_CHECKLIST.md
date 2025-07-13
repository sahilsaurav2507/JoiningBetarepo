# Ubuntu Production Deployment Checklist

## 🚀 Quick Deployment Steps

### Phase 1: Server Setup (One-time)
```bash
# 1. Connect to Ubuntu server
ssh user@your-server-ip

# 2. Clone repository
git clone <your-repo-url>
cd JoiningBetarepo

# 3. Run automated setup
chmod +x ubuntu-deploy.sh
./ubuntu-deploy.sh setup

# 4. Log out and back in
exit
ssh user@your-server-ip
```

### Phase 2: Application Deployment
```bash
# 1. Configure environment
cp env.example .env
nano .env  # Edit with production values

# 2. Deploy application
./ubuntu-deploy.sh deploy

# 3. Verify deployment
./ubuntu-deploy.sh status
```

## 📋 Pre-deployment Checklist

### Server Requirements
- [ ] Ubuntu 20.04 LTS or later
- [ ] Minimum 2GB RAM
- [ ] Minimum 20GB storage
- [ ] Domain pointing to server IP
- [ ] SSH access configured
- [ ] Sudo privileges granted

### Domain Configuration
- [ ] Domain DNS A record pointing to server IP
- [ ] www subdomain configured
- [ ] Domain propagation completed (can take 24-48 hours)

## 🔧 Server Setup Checklist

### System Updates
- [ ] System packages updated (`sudo apt update && sudo apt upgrade -y`)
- [ ] Essential packages installed (curl, git, nano, htop, ufw, fail2ban)
- [ ] Docker installed and configured
- [ ] Docker Compose installed
- [ ] User added to docker group

### Security Configuration
- [ ] Firewall (UFW) enabled
- [ ] SSH port (22) allowed
- [ ] HTTP port (80) allowed
- [ ] HTTPS port (443) allowed
- [ ] Application port (8000) allowed
- [ ] Fail2ban installed and configured

### SSL Certificate Setup
- [ ] Certbot installed
- [ ] Domain accessible from server
- [ ] Let's Encrypt certificates obtained
- [ ] Certificates copied to ssl/ directory
- [ ] Auto-renewal cron job configured

## 📦 Application Deployment Checklist

### Environment Configuration
- [ ] `.env` file created from `env.example`
- [ ] Database credentials configured
- [ ] Security keys updated
- [ ] API base URL set to `https://www.lawvriksh.com/api`
- [ ] CORS origins configured for production
- [ ] Debug mode disabled

### Docker Deployment
- [ ] SSL certificates in place (`ssl/cert.pem`, `ssl/key.pem`)
- [ ] Docker containers built successfully
- [ ] All services started (`docker-compose -f docker-compose.prod.yml up -d`)
- [ ] No container errors in logs
- [ ] Health check endpoint responding

### Service Verification
- [ ] MySQL database container running
- [ ] FastAPI application container running
- [ ] Nginx reverse proxy container running
- [ ] All containers healthy
- [ ] No port conflicts

## 🌐 Endpoint Verification Checklist

### Health and Status
- [ ] `https://www.lawvriksh.com/health` - Returns healthy status
- [ ] `https://www.lawvriksh.com/` - Root endpoint accessible
- [ ] `https://www.lawvriksh.com/docs` - API documentation accessible
- [ ] `https://www.lawvriksh.com/redoc` - ReDoc accessible

### API Endpoints
- [ ] `https://www.lawvriksh.com/api/auth/login` - Authentication endpoint
- [ ] `https://www.lawvriksh.com/api/users` - User management
- [ ] `https://www.lawvriksh.com/api/feedback` - Feedback endpoints
- [ ] `https://www.lawvriksh.com/api/data` - Data endpoints

### SSL and Security
- [ ] SSL certificate valid and not expired
- [ ] HTTPS redirect working (HTTP → HTTPS)
- [ ] Security headers present (HSTS, X-Frame-Options, etc.)
- [ ] CORS preflight requests working
- [ ] Rate limiting functional

## 🔒 Security Verification Checklist

### SSL/TLS Security
- [ ] SSL certificate from Let's Encrypt
- [ ] Certificate auto-renewal working
- [ ] TLS 1.2 and 1.3 enabled
- [ ] Secure cipher suites configured
- [ ] HSTS headers present

### Network Security
- [ ] Firewall blocking unnecessary ports
- [ ] Fail2ban protecting against brute force
- [ ] SSH key-based authentication (recommended)
- [ ] Root login disabled
- [ ] Only necessary services running

### Application Security
- [ ] Environment variables not exposed
- [ ] Database credentials secure
- [ ] JWT tokens properly configured
- [ ] CORS origins restricted to production domains
- [ ] Rate limiting on API endpoints

## 📊 Monitoring and Maintenance Checklist

### Health Monitoring
- [ ] Health check endpoint responding
- [ ] Database connection healthy
- [ ] Container resource usage acceptable
- [ ] System resource usage normal
- [ ] Log files being generated

### Backup Strategy
- [ ] Database backup script working
- [ ] Configuration backup created
- [ ] Backup files stored securely
- [ ] Backup restoration tested
- [ ] Automated backup schedule configured

### Log Management
- [ ] Application logs accessible
- [ ] Error logs being captured
- [ ] Log rotation configured
- [ ] Log file sizes manageable
- [ ] Important events logged

## 🚨 Troubleshooting Checklist

### Common Issues
- [ ] Port conflicts resolved
- [ ] Docker permission issues fixed
- [ ] SSL certificate issues resolved
- [ ] Database connection issues fixed
- [ ] CORS issues resolved

### Performance Issues
- [ ] Resource limits appropriate
- [ ] Nginx configuration optimized
- [ ] Database queries optimized
- [ ] Caching configured (if needed)
- [ ] CDN configured (if needed)

## 🔄 Update and Maintenance Checklist

### Regular Maintenance
- [ ] System updates scheduled
- [ ] Docker images updated
- [ ] SSL certificates renewed
- [ ] Logs rotated and cleaned
- [ ] Backups verified

### Application Updates
- [ ] Git repository updated
- [ ] New features tested
- [ ] Database migrations applied
- [ ] Rollback plan prepared
- [ ] Update process documented

## 📞 Support and Documentation

### Documentation
- [ ] Deployment guide completed
- [ ] Troubleshooting guide available
- [ ] API documentation accessible
- [ ] Environment variables documented
- [ ] Contact information available

### Monitoring Tools
- [ ] Health check monitoring
- [ ] Error alerting configured
- [ ] Performance monitoring
- [ ] Uptime monitoring
- [ ] SSL certificate monitoring

## ✅ Final Verification

### Production Readiness
- [ ] All services running stable
- [ ] No critical errors in logs
- [ ] Performance acceptable
- [ ] Security measures in place
- [ ] Backup and recovery tested

### Frontend Integration
- [ ] API base URL configured in frontend
- [ ] CORS working for frontend requests
- [ ] Authentication flow working
- [ ] All API endpoints accessible
- [ ] Error handling implemented

## 🎯 Success Criteria

Your deployment is successful when:

1. ✅ **Health Check**: `https://www.lawvriksh.com/health` returns healthy
2. ✅ **API Access**: All endpoints accessible at `https://www.lawvriksh.com/api/`
3. ✅ **SSL Working**: Valid SSL certificate with auto-renewal
4. ✅ **CORS Working**: Frontend can communicate with backend
5. ✅ **Security**: All security measures implemented
6. ✅ **Monitoring**: Health monitoring and logging working
7. ✅ **Backup**: Backup and recovery procedures tested

## 🚀 Quick Commands Reference

```bash
# Status check
./ubuntu-deploy.sh status

# View logs
./ubuntu-deploy.sh logs

# Update application
./ubuntu-deploy.sh update

# Create backup
./ubuntu-deploy.sh backup

# Restart services
docker-compose -f docker-compose.prod.yml restart

# Health check
curl https://www.lawvriksh.com/health

# Test API
curl https://www.lawvriksh.com/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"admin123"}'
```

## 📞 Emergency Contacts

- **Server Provider**: [Your VPS provider support]
- **Domain Registrar**: [Your domain registrar support]
- **SSL Provider**: Let's Encrypt Community Support
- **Application Support**: [Your team contact]

---

**Deployment completed successfully!** 🎉

Your LawViksh Backend is now running in production at `https://www.lawvriksh.com/api/` with full security, monitoring, and maintenance capabilities. 