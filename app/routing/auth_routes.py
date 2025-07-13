from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.models.user_models import AdminLogin
from app.services.auth_service import AuthService
from app.schemas.response_schemas import BaseResponse, AdminTokenResponse
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/auth", tags=["Authentication"])
security = HTTPBearer()

def verify_admin_token(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    """Verify admin JWT token"""
    try:
        payload = AuthService.verify_token(credentials.credentials)
        if not payload or payload.get("role") != "admin":
            raise HTTPException(status_code=401, detail="Invalid or expired token")
        return payload
    except Exception as e:
        logger.error(f"Token verification error: {e}")
        raise HTTPException(status_code=401, detail="Invalid token")

@router.post("/adminlogin", response_model=BaseResponse)
async def admin_login(admin_credentials: AdminLogin):
    """
    Admin login endpoint
    
    - **username**: Admin username
    - **password**: Admin password
    """
    try:
        result = AuthService.login_admin(admin_credentials)
        
        if result["success"]:
            return BaseResponse(
                success=True,
                message="Login successful",
                data={
                    "access_token": result["access_token"],
                    "token_type": result["token_type"],
                    "expires_in": result["expires_in"]
                }
            )
        else:
            return BaseResponse(
                success=False,
                message=result["message"]
            )
    except Exception as e:
        logger.error(f"Admin login error: {e}")
        return BaseResponse(
            success=False,
            message="Login failed"
        )

@router.get("/verify", response_model=BaseResponse)
async def verify_token(payload: dict = Depends(verify_admin_token)):
    """
    Verify admin token endpoint
    """
    return BaseResponse(
        success=True,
        message="Token is valid",
        data={"user": payload.get("sub"), "role": payload.get("role")}
    ) 