from fastapi import APIRouter, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.models.user_models import NotInterestedData
from app.services.user_service import UserService
from app.schemas.response_schemas import BaseResponse
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/users", tags=["Not Interested Management"])

@router.post("/notinteresteddata", response_model=BaseResponse)
async def save_not_interested_data(not_interested_data: NotInterestedData):
    """
    Save not interested user data
    - **name**: User's full name (required)
    - **email**: User's email address (required)
    - **phone_number**: User's phone number (required)
    - **gender**: User's gender (optional)
    - **profession**: User's profession (optional)
    - **not_interested_reason**: Reason for not being interested (optional)
    - **improvement_suggestions**: Suggestions for improvement (optional)
    - **interest_reason**: Reason for interest (optional)
    """
    try:
        result = UserService.save_not_interested_data(not_interested_data)
        return result
    except Exception as e:
        logger.error(f"Error saving not interested data: {e}")
        return BaseResponse(
            success=False,
            message="Failed to save feedback"
        )

# Add admin token verification
from app.services.auth_service import AuthService
security = HTTPBearer()

def verify_admin_token(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    try:
        payload = AuthService.verify_token(credentials.credentials)
        if not payload or payload.get("role") != "admin":
            raise Exception("Invalid or expired token")
        return payload
    except Exception as e:
        logger.error(f"Token verification error: {e}")
        raise Exception("Invalid token")

@router.get("/notintdata", response_model=BaseResponse)
async def get_all_not_interested_data(payload: dict = Depends(verify_admin_token)):
    """
    Get all not interested user data (Admin only)
    """
    try:
        data = UserService.get_all_not_interested()
        return BaseResponse(
            success=True,
            message="Not interested data retrieved successfully",
            data=data
        )
    except Exception as e:
        logger.error(f"Error fetching not interested data: {e}")
        return BaseResponse(
            success=False,
            message="Failed to fetch not interested data"
        ) 