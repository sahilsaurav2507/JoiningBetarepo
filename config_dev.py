import os
from pydantic_settings import BaseSettings
from typing import Optional, List

class DevSettings(BaseSettings):
    # Development Configuration (SQLite)
    db_type: str = "MYSQL"
    db_host: str = "localhost"
    db_port: int = 3306
    db_name: str = "lawviksh_db"
    db_user: str = "root"
    db_password: str = "Sahil@123"
    
    # Security Configuration
    secret_key: str = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    
    # Admin Credentials (change in production)
    admin_username: str = "admin"
    admin_password: str = "admin123"
    
    # Server Configuration
    host: str = "0.0.0.0"
    port: int = 8000
    debug: bool = True
    
    # CORS Configuration
    cors_origins: List[str] = [
        "http://localhost:3000",
        "http://localhost:3001", 
        "http://localhost:5173",
        "http://localhost:8080",
        "https://www.lawvriksh.com",
        "https://lawvriksh.com",
        "http://www.lawvriksh.com",
        "http://lawvriksh.com"
    ]
    
    class Config:
        env_file = ".env"
        case_sensitive = False

settings = DevSettings() 