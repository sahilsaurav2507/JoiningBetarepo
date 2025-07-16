import os
from pydantic_settings import BaseSettings
from typing import Optional, List

class Settings(BaseSettings):
    # Database Configuration
    db_host: str = "localhost"
    db_port: int = 3306
    db_name: str = "lawviksh_db"
    db_user: str = "root"
    db_password: str = "Sahil@123"
    
    # Security Configuration
    secret_key: str = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    
    # Admin Credentials
    admin_username: str = "admin"
    admin_password: str = "admin123"
    
    # Server Configuration
    host: str = "0.0.0.0"
    port: int = 8000
    debug: bool = True
    
    # API Configuration
    api_base_url: str = "https://www.lawvriksh.com/api"
    api_prefix: str = "/api"
    
    # CORS Configuration - Production ready
    cors_origins: List[str] = [
        # Development origins
        "http://localhost:3000",
        "http://localhost:3001", 
        "http://localhost:5173",
        "http://localhost:8080",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:3001",
        "http://127.0.0.1:5173",
        "http://127.0.0.1:8080",
        # Production origins
        "https://www.lawvriksh.com",
        "https://lawvriksh.com",
        "http://www.lawvriksh.com",
        "http://lawvriksh.com",
        "https://www.beta.lawvriksh.com",
        "https://beta.lawvriksh.com",
        "http://www.beta.lawvriksh.com",
        "http://beta.lawvriksh.com",
        # Frontend subdomains (if any)
        "https://app.lawvriksh.com",
        "https://admin.lawvriksh.com"
    ]
    
    # CORS additional settings
    cors_allow_credentials: bool = True
    cors_allow_methods: List[str] = ["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"]
    cors_allow_headers: List[str] = ["*"]
    cors_expose_headers: List[str] = ["Content-Length", "Content-Type", "Authorization"]
    cors_max_age: int = 86400  # 24 hours
    
    class Config:
        env_file = ".env"
        case_sensitive = False

settings = Settings() 
