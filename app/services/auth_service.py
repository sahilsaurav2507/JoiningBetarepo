from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
# Import configuration (production or development)
try:
    from config import settings
except ImportError:
    from config_dev import settings
from app.models.user_models import AdminLogin
import logging

logger = logging.getLogger(__name__)

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class AuthService:
    
    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        """Verify a password against its hash"""
        return pwd_context.verify(plain_password, hashed_password)
    
    @staticmethod
    def get_password_hash(password: str) -> str:
        """Hash a password"""
        return pwd_context.hash(password)
    
    @staticmethod
    def authenticate_admin(admin_credentials: AdminLogin) -> bool:
        """Authenticate admin credentials"""
        try:
            # Check against configured admin credentials
            if (admin_credentials.username == settings.admin_username and 
                admin_credentials.password == settings.admin_password):
                return True
            return False
        except Exception as e:
            logger.error(f"Error authenticating admin: {e}")
            return False
    
    @staticmethod
    def create_access_token(data: dict, expires_delta: timedelta = None) -> str:
        """Create JWT access token"""
        try:
            to_encode = data.copy()
            if expires_delta:
                expire = datetime.utcnow() + expires_delta
            else:
                expire = datetime.utcnow() + timedelta(minutes=settings.access_token_expire_minutes)
            
            to_encode.update({"exp": expire})
            encoded_jwt = jwt.encode(to_encode, settings.secret_key, algorithm=settings.algorithm)
            return encoded_jwt
        except Exception as e:
            logger.error(f"Error creating access token: {e}")
            return None
    
    @staticmethod
    def verify_token(token: str) -> dict:
        """Verify and decode JWT token"""
        try:
            payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
            return payload
        except JWTError as e:
            logger.error(f"Error verifying token: {e}")
            return None
    
    @staticmethod
    def login_admin(admin_credentials: AdminLogin) -> dict:
        """Login admin and return token"""
        try:
            if AuthService.authenticate_admin(admin_credentials):
                access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
                access_token = AuthService.create_access_token(
                    data={"sub": admin_credentials.username, "role": "admin"},
                    expires_delta=access_token_expires
                )
                
                if access_token:
                    return {
                        "success": True,
                        "access_token": access_token,
                        "token_type": "bearer",
                        "expires_in": settings.access_token_expire_minutes * 60
                    }
            
            return {
                "success": False,
                "message": "Invalid credentials"
            }
        except Exception as e:
            logger.error(f"Error in admin login: {e}")
            return {
                "success": False,
                "message": "Login failed"
            } 