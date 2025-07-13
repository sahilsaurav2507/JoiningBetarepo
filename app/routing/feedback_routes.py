from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.models.feedback_models import FeedbackData
from app.services.feedback_service import FeedbackService
from app.services.auth_service import AuthService
from app.schemas.response_schemas import BaseResponse
from typing import List, Dict, Any
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/feedback", tags=["Feedback"])
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

@router.post("/submit", response_model=BaseResponse)
async def submit_feedback(feedback_data: FeedbackData):
    """
    Submit feedback data for legal blogging platform
    
    - **user_email**: User's email (optional)
    - **digital_work_showcase_effectiveness**: Rating for digital work showcase effectiveness (1-5, optional)
    - **legal_persons_online_recognition**: Whether legal persons get enough recognition online (yes/no, optional)
    - **digital_work_sharing_difficulty**: Rating for difficulty in sharing work digitally (1-5, optional)
    - **regular_blogging**: Whether user blogs regularly (yes/no, optional)
    - **ai_tools_blogging_frequency**: Frequency of using AI tools for blogging (never/rarely/sometimes/often/always, optional)
    - **blogging_tools_familiarity**: Rating for familiarity with blogging tools (1-5, optional)
    - **core_platform_features**: Expected core features from legal blogging platform (text, optional)
    - **ai_research_opinion**: Opinion on AI-assisted legal research (text, optional)
    - **ideal_reading_features**: Ideal reading features for legal content (text, optional)
    - **portfolio_presentation_preference**: Preferred way to present legal portfolio online (text, optional)
    """
    try:
        result = FeedbackService.save_feedback(feedback_data)
        return result
    except Exception as e:
        logger.error(f"Error submitting feedback: {e}")
        return BaseResponse(
            success=False,
            message="Failed to submit feedback"
        )

@router.get("/all", response_model=BaseResponse)
async def get_all_feedback(payload: dict = Depends(verify_admin_token)):
    """
    Get all feedback data (Admin only)
    """
    try:
        feedback = FeedbackService.get_all_feedback()
        return BaseResponse(
            success=True,
            message="Feedback retrieved successfully",
            data=feedback
        )
    except Exception as e:
        logger.error(f"Error fetching feedback: {e}")
        return BaseResponse(
            success=False,
            message="Failed to fetch feedback"
        )

@router.get("/userfeedbackdata", response_model=BaseResponse)
async def get_user_feedback_data(payload: dict = Depends(verify_admin_token)):
    """
    Get all feedback data (Admin only, alternate endpoint)
    """
    try:
        feedback = FeedbackService.get_all_feedback()
        return BaseResponse(
            success=True,
            message="Feedback retrieved successfully",
            data=feedback
        )
    except Exception as e:
        logger.error(f"Error fetching feedback: {e}")
        return BaseResponse(
            success=False,
            message="Failed to fetch feedback"
        )

@router.get("/analytics", response_model=BaseResponse)
async def get_feedback_analytics(payload: dict = Depends(verify_admin_token)):
    """
    Get feedback analytics and statistics (Admin only)
    """
    try:
        analytics = FeedbackService.get_feedback_analytics()
        return BaseResponse(
            success=True,
            message="Analytics retrieved successfully",
            data=analytics
        )
    except Exception as e:
        logger.error(f"Error fetching feedback analytics: {e}")
        return BaseResponse(
            success=False,
            message="Failed to fetch analytics"
        )

@router.get("/summary", response_model=BaseResponse)
async def get_feedback_summary(payload: dict = Depends(verify_admin_token)):
    """
    Get feedback summary (Admin only)
    """
    try:
        summary = FeedbackService.get_feedback_summary()
        return BaseResponse(
            success=True,
            message="Summary retrieved successfully",
            data=summary
        )
    except Exception as e:
        logger.error(f"Error fetching feedback summary: {e}")
        return BaseResponse(
            success=False,
            message="Failed to fetch summary"
        ) 