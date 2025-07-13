from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
import logging
import time

# Import settings
try:
    from config import settings
    print("Using production configuration")
except ImportError:
    from config_dev import settings
    print("Using development configuration")

# Import routes
from app.routing.auth_routes import router as auth_router
from app.routing.user_routes import router as user_router
from app.routing.feedback_routes import router as feedback_router
from app.routing.data_routes import router as data_router
from app.routing.notint_routes import router as notint_router

# Import database
from database import db
print("Using MySQL database")

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager"""
    # Startup
    logger.info("Starting LawViksh Backend Server...")
    
    # Initialize database connection
    if db.connect():
        logger.info("Database connection established")
    else:
        logger.error("Failed to establish database connection")
    
    yield
    
    # Shutdown
    logger.info("Shutting down LawViksh Backend Server...")
    db.disconnect()
    logger.info("Database connection closed")

# Create FastAPI app
app = FastAPI(
    title="LawViksh Backend API",
    description="Backend API for LawViksh joining list and feedback system",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,  # Use configured origins
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
    allow_headers=["*"],
)

# Add trusted host middleware
app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=["localhost", "127.0.0.1", "www.lawvriksh.com", "lawvriksh.com"]  # Configured hosts
)

# Request logging middleware
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    
    # Log request
    logger.info(f"Request: {request.method} {request.url}")
    
    response = await call_next(request)
    
    # Log response
    process_time = time.time() - start_time
    logger.info(f"Response: {response.status_code} - {process_time:.4f}s")
    
    return response

# Global exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Global exception: {exc}")
    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "message": "Internal server error",
            "error": str(exc) if app.debug else "Something went wrong"
        }
    )

# Include routers
app.include_router(auth_router, prefix="/api")
app.include_router(user_router, prefix="/api")
app.include_router(feedback_router, prefix="/api")
app.include_router(data_router, prefix="/api")
app.include_router(notint_router, prefix="/api")

# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint"""
    try:
        # Check database connection
        db_status = "connected" if db.connection and db.connection.is_connected() else "disconnected"
        
        return {
            "status": "healthy",
            "database": db_status,
            "timestamp": time.time()
        }
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return {
            "status": "unhealthy",
            "error": str(e),
            "timestamp": time.time()
        }

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Welcome to LawViksh Backend API",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health"
    }

if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "appmain:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
        log_level="info"
    ) 