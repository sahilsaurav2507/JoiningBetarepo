from fastapi import APIRouter
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