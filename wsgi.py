"""
WSGI application for LawViksh Backend
For production deployment with Gunicorn, uWSGI, etc.
"""

from appmain import app

# WSGI application
application = app

if __name__ == "__main__":
    import uvicorn
    from config import settings
    
    uvicorn.run(
        "wsgi:application",
        host=settings.host,
        port=settings.port,
        reload=False,  # Disable reload in production
        log_level="info"
    ) 