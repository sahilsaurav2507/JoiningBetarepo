from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.models.user_models import UserData, NotInterestedData
from app.services.user_service import UserService
from app.services.auth_service import AuthService
from app.schemas.response_schemas import BaseResponse
from typing import List, Dict, Any
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/users", tags=["User Management"])
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

@router.post("/userdata", response_model=BaseResponse)
async def save_user_data(user_data: UserData):
    user_data.user_type = 'user'
    return UserService.save_user_data(user_data)

@router.post("/creatordata", response_model=BaseResponse)
async def save_creator_data(user_data: UserData):
    user_data.user_type = 'creator'
    return UserService.save_user_data(user_data)

@router.get("/registereduserdata", response_model=BaseResponse)
async def get_registered_users(payload: dict = Depends(verify_admin_token)):
    """
    Get all registered users (Admin only)
    """
    try:
        users = UserService.get_all_users()
        return BaseResponse(
            success=True,
            message="Users retrieved successfully",
            data=users
        )
    except Exception as e:
        logger.error(f"Error fetching users: {e}")
        return BaseResponse(
            success=False,
            message="Failed to fetch users"
        )

@router.get("/registeredcreatordata", response_model=BaseResponse)
async def get_registered_creators(payload: dict = Depends(verify_admin_token)):
    """
    Get all registered creators (Admin only)
    """
    try:
        creators = UserService.get_all_creators()
        return BaseResponse(
            success=True,
            message="Creators retrieved successfully",
            data=creators
        )
    except Exception as e:
        logger.error(f"Error fetching creators: {e}")
        return BaseResponse(
            success=False,
            message="Failed to fetch creators"
        )

@router.get("/analytics", response_model=BaseResponse)
async def get_user_analytics(payload: dict = Depends(verify_admin_token)):
    """
    Get user analytics and statistics (Admin only)
    """
    try:
        analytics = UserService.get_user_analytics()
        return BaseResponse(
            success=True,
            message="Analytics retrieved successfully",
            data=analytics
        )
    except Exception as e:
        logger.error(f"Error fetching analytics: {e}")
        return BaseResponse(
            success=False,
            message="Failed to fetch analytics"
        ) 