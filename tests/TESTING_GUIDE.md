# LawViksh Backend API Testing Guide

This guide covers how to test the LawViksh Backend API comprehensively.

## 🚀 Quick Start

### Prerequisites
1. **Install testing dependencies**:
   ```bash
   pip install aiohttp psutil requests
   ```

2. **Start the server**:
   ```bash
   python appmain.py
   ```

3. **Run complete tests**:
   ```bash
   python test_complete_api.py
   ```

## 📋 Test Types

### 1. Complete API Test
Tests all endpoints and includes performance testing:
```bash
python test_complete_api.py
```

### 2. Test Runner (Recommended)
Use the test runner for different testing scenarios:
```bash
# Complete test suite (default)
python run_tests.py

# Basic API tests only
python run_tests.py --type basic

# Performance tests only
python run_tests.py --type performance

# Stress tests only
python run_tests.py --type stress
```

### 3. Export Endpoints Test
Test the new specific export endpoints:
```bash
python test_export_endpoints.py
```

## 🧪 Test Coverage

### API Endpoints Tested

#### Basic Endpoints
- `GET /` - Root endpoint
- `GET /health` - Health check

#### Authentication
- `POST /api/auth/adminlogin` - Admin login
- `GET /api/auth/verify` - Token verification

#### User Management
- `POST /api/users/userdata` - User registration
- `POST /api/users/creatordata` - Creator registration
- `POST /api/users/notinteresteddata` - Not interested feedback

#### Feedback System
- `POST /api/feedback/submit` - Feedback submission

#### Admin Endpoints (Requires Authentication)
- `GET /api/users/registereduserdata` - Get all users
- `GET /api/users/registeredcreatordata` - Get all creators
- `GET /api/users/analytics` - User analytics
- `GET /api/feedback/all` - Get all feedback
- `GET /api/feedback/analytics` - Feedback analytics
- `GET /api/feedback/summary` - Feedback summary
- `GET /api/data/export/json` - Export all data
- `GET /api/data/export/userdata` - Export user data only
- `GET /api/data/export/creatordata` - Export creator data only
- `GET /api/data/export/feedbackdata` - Export feedback data only
- `GET /api/data/stats` - Data statistics

### Performance Metrics

The tests measure:
- **Response Time**: Average, minimum, maximum, p95, p99
- **Throughput**: Requests per second
- **Success Rate**: Percentage of successful requests
- **Concurrent Performance**: How the API handles multiple simultaneous requests
- **System Resources**: CPU, memory, and disk usage during tests

## 📊 Understanding Test Results

### Test Summary
```
API TEST SUMMARY
============================================================
Total Tests: 15
Successful: 15
Failed: 0
Success Rate: 100.00%
Average Response Time: 0.045s
Timestamp: 2024-01-15T10:30:00
```

### Performance Metrics
```
PERFORMANCE METRICS
============================================================

Endpoint: /health
  Success Rate: 100.00%
  Requests/sec: 1250.50
  Avg Response Time: 0.080s
  P95 Response Time: 0.120s
```

### System Metrics
```
SYSTEM METRICS
============================================================
CPU Usage: 45.2%
Memory Usage: 62.5%
Disk Usage: 35.8%
```

## ⚙️ Configuration

### Test Configuration
Edit `test_config.py` to customize:
- Server URL and credentials
- Test data
- Performance test parameters
- Report settings

### Environment Variables
You can override default settings:
```bash
export LAWVIKSH_SERVER_URL="http://your-server:8000"
export LAWVIKSH_ADMIN_USERNAME="your_admin"
export LAWVIKSH_ADMIN_PASSWORD="your_password"
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Server Not Running
```
❌ Server is not running on http://localhost:8000
```
**Solution**: Start the server first with `python appmain.py`

#### 2. Database Connection Issues
```
Error: Failed to establish database connection
```
**Solution**: Check database configuration in `config.py`

#### 3. Authentication Failures
```
Admin login failed
```
**Solution**: Verify admin credentials in `config.py`

#### 4. Import Errors
```
ModuleNotFoundError: No module named 'aiohttp'
```
**Solution**: Install testing dependencies:
```bash
pip install aiohttp psutil requests
```

### Performance Issues

#### High Response Times
- Check database performance
- Monitor server resources
- Consider database indexing

#### Low Success Rates
- Check server logs for errors
- Verify database connectivity
- Monitor system resources

## 📈 Performance Benchmarks

### Expected Performance (Development Environment)
- **Health Check**: < 100ms average response time
- **User Registration**: < 500ms average response time
- **Admin Endpoints**: < 200ms average response time
- **Throughput**: > 100 requests/second for health endpoint

### Stress Test Results
- **1000 concurrent requests**: Should maintain > 95% success rate
- **Memory usage**: Should not exceed 80% during stress tests
- **CPU usage**: Should not exceed 90% during stress tests

## 📝 Test Reports

### Report Files
Tests generate detailed JSON reports:
- `api_test_report_YYYYMMDD_HHMMSS.json` - Complete test report
- Includes all test results, performance metrics, and system data

### Report Structure
```json
{
  "test_summary": {
    "total_tests": 15,
    "successful_tests": 15,
    "failed_tests": 0,
    "success_rate": 100.0,
    "avg_response_time": 0.045
  },
  "test_results": [...],
  "performance_metrics": [...],
  "system_metrics": {...}
}
```

## 🚀 Advanced Testing

### Custom Test Scenarios
1. **Edit test_config.py** to modify test parameters
2. **Create custom test data** for specific scenarios
3. **Modify performance test settings** for different load patterns

### Continuous Testing
```bash
# Run tests every 5 minutes
watch -n 300 python run_tests.py --type basic

# Run performance tests hourly
watch -n 3600 python run_tests.py --type performance
```

### Integration with CI/CD
Add to your CI/CD pipeline:
```yaml
- name: Run API Tests
  run: |
    python appmain.py &
    sleep 10
    python run_tests.py --type complete
```

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review server logs for errors
3. Verify database connectivity
4. Check system resources during tests

For additional help, refer to the main README.md file. 