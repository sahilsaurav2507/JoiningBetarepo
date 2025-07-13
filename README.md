# LawViksh Backend API

A FastAPI-based backend server for the LawViksh joining list and feedback system.

## 🚀 Features

- **User Registration**: Join as user or creator
- **Not Interested Form**: Collect feedback from non-interested users
- **Feedback System**: Comprehensive feedback collection with ratings
- **Admin Panel**: Secure admin access with JWT authentication
- **Data Analytics**: User and feedback analytics
- **Data Export**: Download data in JSON format
- **MySQL Integration**: Robust database management

## 📋 Prerequisites

- Python 3.8+
- MySQL 8.0+
- pip (Python package manager)

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd betajoin
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Set up MySQL database**
   ```bash
   # Import the database schema
   mysql -u root -p < lawdata.sql
   ```

4. **Configure environment variables**
   ```bash
   # Copy and edit the config.py file
   # Update database credentials and other settings
   ```

## ⚙️ Configuration

Edit `config.py` to configure your settings:

```python
# Database Configuration
db_host: str = "localhost"
db_port: int = 3306
db_name: str = "lawviksh_joining_list"
db_user: str = "your_username"
db_password: str = "your_password"

# Security Configuration
secret_key: str = "your_super_secret_key_here"
admin_username: str = "admin"
admin_password: str = "admin123"
```

## 🚀 Running the Application

### Development Mode
```bash
python appmain.py
```

### Production Mode
```bash
python wsgi.py
```

### Using Uvicorn
```bash
uvicorn appmain:app --host 0.0.0.0 --port 8000
```

### Using Gunicorn (Production)
```bash
gunicorn wsgi:application -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

## 📚 API Documentation

Once the server is running, visit:
- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`
- **Health Check**: `http://localhost:8000/health`

## 🔐 API Endpoints

### Authentication
- `POST /api/auth/adminlogin` - Admin login
- `GET /api/auth/verify` - Verify admin token

### User Management
- `POST /api/users/userdata` - Register user
- `POST /api/users/creatordata` - Register creator
- `POST /api/users/notinteresteddata` - Submit not interested feedback
- `GET /api/users/registereduserdata` - Get all users (Admin)
- `GET /api/users/registeredcreatordata` - Get all creators (Admin)
- `GET /api/users/analytics` - Get user analytics (Admin)

### Feedback
- `POST /api/feedback/submit` - Submit feedback for legal blogging platform
- `GET /api/feedback/all` - Get all feedback (Admin)
- `GET /api/feedback/analytics` - Get feedback analytics (Admin)
- `GET /api/feedback/summary` - Get feedback summary (Admin)

**New Feedback Fields:**
- Digital work showcase effectiveness (1-5 rating)
- Legal persons online recognition (yes/no)
- Digital work sharing difficulty (1-5 rating)
- Regular blogging (yes/no)
- AI tools blogging frequency (never/rarely/sometimes/often/always)
- Blogging tools familiarity (1-5 rating)
- Core platform features (text)
- AI research opinion (text)
- Ideal reading features (text)
- Portfolio presentation preference (text)

### Data Management
- `POST /api/data/downloaddata` - Download all data (Admin)
- `GET /api/data/export/json` - Export all data as JSON (Admin)
- `GET /api/data/export/userdata` - Export user data only (Admin)
- `GET /api/data/export/creatordata` - Export creator data only (Admin)
- `GET /api/data/export/feedbackdata` - Export feedback data only (Admin)
- `GET /api/data/stats` - Get data statistics (Admin)

## 🔒 Security

- JWT-based authentication for admin endpoints
- Password hashing with bcrypt
- CORS middleware for cross-origin requests
- Input validation with Pydantic models
- SQL injection protection with parameterized queries

## 🌐 CORS Configuration

The application is configured to allow requests from the following origins:

### Development Origins
- `http://localhost:3000` (React default)
- `http://localhost:3001` (React alternative)
- `http://localhost:5173` (Vite default)
- `http://localhost:8080` (Vue.js default)

### Production Origins
- `https://www.lawvriksh.com`
- `https://lawvriksh.com`
- `http://www.lawvriksh.com`
- `http://lawvriksh.com`

### Testing CORS
You can test CORS configuration using your browser's developer tools or tools like Postman by making requests from the allowed origins.

## 🧪 API Testing

The project includes a comprehensive unified testing suite located in the `tests/` directory that covers all API endpoints and performance testing in a single file.

### Running Tests

#### Simple Test Runner (Recommended)
```bash
# Run all tests (API + Performance + Stress)
cd tests
python run_unified_tests.py

# Run specific test types
python run_unified_tests.py api
python run_unified_tests.py performance
python run_unified_tests.py stress

# Test against different server URL
python run_unified_tests.py all http://your-server:8000
```

#### Advanced Test Runner
```bash
# Run all tests (API + Performance + Stress)
cd tests
python test_unified.py

# Run API tests only
python test_unified.py --api-only

# Run performance tests only
python test_unified.py --performance-only

# Run stress tests only
python test_unified.py --stress-only

# Test against different server URL
python test_unified.py --url http://your-server:8000

# Skip server availability check
python test_unified.py --no-check
```

### Test Coverage
The unified test suite covers:

#### 🔍 **API Testing**
- **Health Check**: Server status and database connectivity
- **Authentication**: Admin login and token verification
- **User Registration**: User and creator registration
- **Not Interested**: Feedback collection from non-interested users
- **Feedback System**: Complete feedback submission with all fields
- **Admin Endpoints**: All admin-only data access endpoints
- **Data Export**: JSON file export functionality

#### ⚡ **Performance Testing**
- Response time analysis (avg, min, max, median)
- Requests per second measurement
- Concurrent request handling
- Endpoint-specific performance metrics

#### 🔥 **Stress Testing**
- High-load testing with 1000+ concurrent requests
- Connection limit testing (50 concurrent max)
- System stability under load
- Performance degradation analysis

### Test Documentation
- `TESTING_GUIDE.md` - Comprehensive testing documentation
- `EXPORT_ENDPOINTS_SUMMARY.md` - Export endpoints documentation

### Test Reports
The test suite automatically generates detailed JSON reports with:
- API test results and success rates
- Performance metrics and benchmarks
- Stress test results and system limits
- Timestamped reports for tracking improvements

### Test Reports
Tests generate detailed reports including:
- Success/failure rates for each endpoint
- Response time statistics (avg, min, max, p95, p99)
- Throughput metrics (requests per second)
- System resource usage during tests
- JSON report files for further analysis

## 🧹 Code Maintenance

### Cleanup Script
Use the cleanup script to remove unnecessary files and maintain a clean codebase:
```bash
python cleanup.py
```

This script will:
- Remove all `__pycache__` directories
- Clean up temporary and generated files
- Remove empty directories
- Clean up performance monitoring files

### Manual Cleanup
You can also manually clean up:
- `__pycache__` directories
- Temporary files (`*.tmp`, `*.temp`, `*.log`)
- Generated performance files (`system_metrics_*.json`, `system_performance_*.png`)
- Migration files after they've been applied

# System monitoring with performance graphs
python monitor_system.py
```

### Test Results
The performance tests generate:
- **Console output** with real-time statistics
- **JSON files** with detailed metrics (`system_metrics_*.json`)
- **Performance graphs** (`system_performance_*.png`)
- **CSV files** with request/response data (`load_test_results_*.csv`)

### Performance Metrics Monitored
- **Response Times**: Min, max, mean, median, 95th/99th percentiles
- **Success Rates**: Overall and per-endpoint success rates
- **System Resources**: CPU, memory, disk, network usage
- **Database Performance**: Connections, queries, slow queries
- **Error Analysis**: Status codes, error patterns, failure rates

## 📊 Database Schema

The application uses the following main tables:
- `users` - User and creator registrations
- `not_interested_users` - Not interested feedback
- `feedback_forms` - Main feedback records
- `digital_work_feedback` - Digital work and blogging feedback
- `platform_features_opinions` - Platform features and opinions

- `form_submissions_log` - Audit trail

## 🏗️ Project Structure

```
betajoin/
├── app/
│   ├── models/          # Pydantic models
│   ├── schemas/         # Response schemas
│   ├── repository/      # Database operations
│   ├── services/        # Business logic
│   └── routing/         # API routes
├── config.py           # Configuration settings
├── database.py         # Database connection
├── appmain.py          # Main application
├── wsgi.py            # WSGI application
├── requirements.txt    # Dependencies
├── lawdata.sql        # Database schema
└── README.md          # This file
```

## 🔄 Database Migration

### Update Feedback Schema
If you have an existing database with the old feedback structure, run the migration script:

```bash
# Run the migration script
mysql -u root -p < migrate_feedback_schema.sql
```

This will:
- Backup existing feedback data
- Drop old feedback tables (ui_ratings, ux_ratings, suggestions_and_needs)
- Create new tables (digital_work_feedback, platform_features_opinions)
- Update the feedback analytics view
- Insert sample data for testing

### Fresh Installation
For new installations, use the updated schema:

```bash
# Import the complete database schema
mysql -u root -p < lawdata.sql
```

## 🚀 Deployment

1. **Install system dependencies**
   ```bash
   sudo apt update
   sudo apt install python3 python3-pip mysql-server nginx
   ```

2. **Set up MySQL**
   ```bash
   sudo mysql_secure_installation
   mysql -u root -p < lawdata.sql
   ```

3. **Install Python dependencies**
   ```bash
   pip3 install -r requirements.txt
   ```

4. **Configure Nginx**
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;
       
       location / {
           proxy_pass http://127.0.0.1:8000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

5. **Run with systemd**
   ```bash
   # Create service file
   sudo nano /etc/systemd/system/lawviksh.service
   
   [Unit]
   Description=LawViksh Backend
   After=network.target
   
   [Service]
   User=www-data
   WorkingDirectory=/path/to/betajoin
   Environment="PATH=/path/to/betajoin/venv/bin"
   ExecStart=/path/to/betajoin/venv/bin/gunicorn wsgi:application -w 4 -k uvicorn.workers.UvicornWorker --bind 127.0.0.1:8000
   
   [Install]
   WantedBy=multi-user.target
   ```

6. **Start the service**
   ```bash
   sudo systemctl enable lawviksh
   sudo systemctl start lawviksh
   ```

## 🔧 Environment Variables

Create a `.env` file for production:

```env
DB_HOST=localhost
DB_PORT=3306
DB_NAME=lawviksh_joining_list
DB_USER=your_db_user
DB_PASSWORD=your_db_password
SECRET_KEY=your_super_secret_key
ADMIN_USERNAME=admin
ADMIN_PASSWORD=secure_password
HOST=0.0.0.0
PORT=8000
DEBUG=False
```

## 📝 Usage Examples

### Register a User
```bash
curl -X POST "http://localhost:8000/api/users/userdata" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "phone_number": "+1234567890",
    "gender": "Male",
    "profession": "Student",
    "interest_reason": "Interested in legal resources"
  }'
```

### Admin Login
```bash
curl -X POST "http://localhost:8000/api/auth/adminlogin" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }'
```

### Submit Feedback
```bash
curl -X POST "http://localhost:8000/api/feedback/submit" \
  -H "Content-Type: application/json" \
  -d '{
    "user_email": "user@example.com",
    "visual_design_rating": 4,
    "ease_of_navigation_rating": 5,
    "overall_satisfaction_rating": 4,
    "liked_features": "Clean interface",
    "improvement_suggestions": "Add more features"
  }'
```

## 🐛 Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Check MySQL service is running
   - Verify database credentials in config.py
   - Ensure database exists

2. **Import Errors**
   - Install all dependencies: `pip install -r requirements.txt`
   - Check Python version (3.8+ required)

3. **Permission Errors**
   - Ensure proper file permissions
   - Check database user permissions

### Logs

Check application logs:
```bash
# If using systemd
sudo journalctl -u lawviksh -f

# If running directly
python appmain.py
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team

---

**LawViksh Backend API** - Built with FastAPI and MySQL 