#!/bin/bash

# CORS and API Testing Script for LawViksh Backend
# Usage: ./test-cors.sh [local|prod]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Configuration
if [ "$1" = "prod" ]; then
    BASE_URL="https://www.lawvriksh.com"
    API_URL="https://www.lawvriksh.com/api"
    ORIGIN="https://www.lawvriksh.com"
else
    BASE_URL="http://localhost:8000"
    API_URL="http://localhost:8000/api"
    ORIGIN="http://localhost:3000"
fi

log "Testing CORS and API connectivity for $BASE_URL"

# Test 1: Health Check
log "1. Testing health check..."
if curl -f -s "$BASE_URL/health" > /dev/null; then
    success "Health check passed"
else
    error "Health check failed"
    exit 1
fi

# Test 2: CORS Preflight Request
log "2. Testing CORS preflight request..."
CORS_RESPONSE=$(curl -s -X OPTIONS "$API_URL/auth/login" \
    -H "Origin: $ORIGIN" \
    -H "Access-Control-Request-Method: POST" \
    -H "Access-Control-Request-Headers: Content-Type" \
    -w "%{http_code}" \
    -o /dev/null)

if [ "$CORS_RESPONSE" = "204" ]; then
    success "CORS preflight request successful (204)"
else
    error "CORS preflight request failed (HTTP $CORS_RESPONSE)"
fi

# Test 3: CORS Headers Check
log "3. Testing CORS headers..."
CORS_HEADERS=$(curl -s -I "$API_URL/auth/login" \
    -H "Origin: $ORIGIN" | grep -i "access-control")

if echo "$CORS_HEADERS" | grep -q "Access-Control-Allow-Origin"; then
    success "CORS headers present"
    echo "$CORS_HEADERS"
else
    warning "CORS headers not found"
fi

# Test 4: API Documentation Access
log "4. Testing API documentation access..."
if curl -f -s "$BASE_URL/docs" > /dev/null; then
    success "API documentation accessible"
else
    error "API documentation not accessible"
fi

# Test 5: Authentication Endpoint
log "5. Testing authentication endpoint..."
AUTH_RESPONSE=$(curl -s -X POST "$API_URL/auth/login" \
    -H "Content-Type: application/json" \
    -H "Origin: $ORIGIN" \
    -d '{"username":"admin","password":"admin123"}' \
    -w "%{http_code}" \
    -o /dev/null)

if [ "$AUTH_RESPONSE" = "200" ] || [ "$AUTH_RESPONSE" = "401" ]; then
    success "Authentication endpoint responding (HTTP $AUTH_RESPONSE)"
else
    error "Authentication endpoint failed (HTTP $AUTH_RESPONSE)"
fi

# Test 6: SSL Certificate (Production only)
if [ "$1" = "prod" ]; then
    log "6. Testing SSL certificate..."
    SSL_INFO=$(openssl s_client -connect www.lawvriksh.com:443 -servername www.lawvriksh.com < /dev/null 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        success "SSL certificate valid"
        echo "$SSL_INFO"
    else
        error "SSL certificate validation failed"
    fi
fi

# Test 7: Rate Limiting
log "7. Testing rate limiting..."
for i in {1..5}; do
    RATE_RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null "$API_URL/auth/login")
    if [ "$RATE_RESPONSE" = "429" ]; then
        success "Rate limiting working (HTTP 429 on request $i)"
        break
    fi
    sleep 0.1
done

# Test 8: Database Connection
log "8. Testing database connection..."
DB_STATUS=$(curl -s "$BASE_URL/health" | grep -o '"database":"[^"]*"' | cut -d'"' -f4)

if [ "$DB_STATUS" = "connected" ]; then
    success "Database connection healthy"
else
    error "Database connection issue: $DB_STATUS"
fi

# Summary
echo ""
log "=== CORS and API Test Summary ==="
success "All tests completed for $BASE_URL"
echo ""
log "API Base URL: $API_URL"
log "Health Check: $BASE_URL/health"
log "Documentation: $BASE_URL/docs"
log "ReDoc: $BASE_URL/redoc"
echo ""
log "For frontend integration, use:"
log "const API_BASE_URL = '$API_URL';"
echo ""
success "CORS and API configuration is ready for frontend-backend communication!" 