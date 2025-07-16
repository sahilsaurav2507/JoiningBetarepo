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
    api_base_url: str = "https://beta.lawvriksh.com/api"
    api_prefix: str = "/api"
    
    # CORS Configuration - Production ready
    cors_origins: List[str] = [
        "https://beta.lawvriksh.com"
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