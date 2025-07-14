from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.responses import JSONResponse
from app.services.user_service import UserService
from app.services.feedback_service import FeedbackService
from app.services.auth_service import AuthService
from app.schemas.response_schemas import BaseResponse, DataDownloadResponse
from typing import List, Dict, Any
import json
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/data", tags=["Data Management"])
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

@router.post("/downloaddata", response_model=BaseResponse)
async def download_data(payload: dict = Depends(verify_admin_token)):
    """
    Download all data in JSON format (Admin only)
    """
    try:
        # Get all data
        users = UserService.get_all_users()
        creators = UserService.get_all_creators()
        not_interested = UserService.get_all_not_interested()
        feedback = FeedbackService.get_all_feedback()
        
        # Get analytics
        user_analytics = UserService.get_user_analytics()
        feedback_analytics = FeedbackService.get_feedback_analytics()
        
        # Prepare download data
        download_data = {
            "users": users,
            "creators": creators,
            "not_interested": not_interested,
            "feedback": feedback,
            "analytics": {
                "user_analytics": user_analytics,
                "feedback_analytics": feedback_analytics
            },
            "summary": {
                "total_users": len(users),
                "total_creators": len(creators),
                "total_not_interested": len(not_interested),
                "total_feedback": len(feedback)
            }
        }
        
        return BaseResponse(
            success=True,
            message="Data downloaded successfully",
            data=download_data
        )
    except Exception as e:
        logger.error(f"Error downloading data: {e}")
        return BaseResponse(
            success=False,
            message="Failed to download data"
        )

@router.get("/export/json", response_model=BaseResponse)
async def export_data_json(payload: dict = Depends(verify_admin_token)):
    """
    Export all data as JSON format (Admin only)
    """
    try:
        logger.info("Starting data export...")
        
        # Get all data with individual error handling
        try:
            users = UserService.get_all_users()
            logger.info(f"Retrieved {len(users)} users")
        except Exception as e:
            logger.error(f"Error getting users: {e}")
            users = []
        
        try:
            creators = UserService.get_all_creators()
            logger.info(f"Retrieved {len(creators)} creators")
        except Exception as e:
            logger.error(f"Error getting creators: {e}")
            creators = []
        
        try:
            not_interested = UserService.get_all_not_interested()
            logger.info(f"Retrieved {len(not_interested)} not interested users")
        except Exception as e:
            logger.error(f"Error getting not interested users: {e}")
            not_interested = []
        
        try:
            feedback = FeedbackService.get_all_feedback()
            logger.info(f"Retrieved {len(feedback)} feedback entries")
        except Exception as e:
            logger.error(f"Error getting feedback: {e}")
            feedback = []
        
        # Get analytics with error handling
        try:
            user_analytics = UserService.get_user_analytics()
            logger.info("Retrieved user analytics")
        except Exception as e:
            logger.error(f"Error getting user analytics: {e}")
            user_analytics = {}
        
        try:
            feedback_analytics = FeedbackService.get_feedback_analytics()
            logger.info("Retrieved feedback analytics")
        except Exception as e:
            logger.error(f"Error getting feedback analytics: {e}")
            feedback_analytics = {}
        
        # Prepare export data
        export_data = {
            "export_date": str(payload.get("exp", "")),
            "users": users,
            "creators": creators,
            "not_interested": not_interested,
            "feedback": feedback,
            "analytics": {
                "user_analytics": user_analytics,
                "feedback_analytics": feedback_analytics
            },
            "summary": {
                "total_users": len(users),
                "total_creators": len(creators),
                "total_not_interested": len(not_interested),
                "total_feedback": len(feedback)
            }
        }
        
        logger.info("Export data prepared successfully")
        
        return BaseResponse(
            success=True,
            message="Data exported successfully",
            data=export_data
        )
    except Exception as e:
        logger.error(f"Error exporting data: {e}")
        return BaseResponse(
            success=False,
            message="Failed to export data",
            data={"error": str(e)}
        )

@router.get("/export/userdata", response_model=BaseResponse)
async def export_user_data(payload: dict = Depends(verify_admin_token)):
    """
    Export user data only (Admin only)
    """
    try:
        logger.info("Starting user data export...")
        
        # Get user data
        try:
            users = UserService.get_all_users()
            logger.info(f"Retrieved {len(users)} users")
        except Exception as e:
            logger.error(f"Error getting users: {e}")
            users = []
        
        # Get user analytics
        try:
            user_analytics = UserService.get_user_analytics()
            logger.info("Retrieved user analytics")
        except Exception as e:
            logger.error(f"Error getting user analytics: {e}")
            user_analytics = {}
        
        # Prepare export data
        export_data = {
            "export_date": str(payload.get("exp", "")),
            "data_type": "user_data",
            "users": users,
            "analytics": user_analytics,
            "summary": {
                "total_users": len(users),
                "export_timestamp": str(payload.get("exp", ""))
            }
        }
        
        logger.info("User data export prepared successfully")
        
        return BaseResponse(
            success=True,
            message="User data exported successfully",
            data=export_data
        )
    except Exception as e:
        logger.error(f"Error exporting user data: {e}")
        return BaseResponse(
            success=False,
            message="Failed to export user data",
            data={"error": str(e)}
        )

@router.get("/export/creatordata", response_model=BaseResponse)
async def export_creator_data(payload: dict = Depends(verify_admin_token)):
    """
    Export creator data only (Admin only)
    """
    try:
        logger.info("Starting creator data export...")
        
        # Get creator data
        try:
            creators = UserService.get_all_creators()
            logger.info(f"Retrieved {len(creators)} creators")
        except Exception as e:
            logger.error(f"Error getting creators: {e}")
            creators = []
        
        # Prepare export data
        export_data = {
            "export_date": str(payload.get("exp", "")),
            "data_type": "creator_data",
            "creators": creators,
            "summary": {
                "total_creators": len(creators),
                "export_timestamp": str(payload.get("exp", ""))
            }
        }
        
        logger.info("Creator data export prepared successfully")
        
        return BaseResponse(
            success=True,
            message="Creator data exported successfully",
            data=export_data
        )
    except Exception as e:
        logger.error(f"Error exporting creator data: {e}")
        return BaseResponse(
            success=False,
            message="Failed to export creator data",
            data={"error": str(e)}
        )

@router.get("/export/feedbackdata", response_model=BaseResponse)
async def export_feedback_data(payload: dict = Depends(verify_admin_token)):
    """
    Export feedback data only (Admin only)
    """
    try:
        logger.info("Starting feedback data export...")
        
        # Get feedback data
        try:
            feedback = FeedbackService.get_all_feedback()
            logger.info(f"Retrieved {len(feedback)} feedback entries")
        except Exception as e:
            logger.error(f"Error getting feedback: {e}")
            feedback = []
        
        # Get feedback analytics
        try:
            feedback_analytics = FeedbackService.get_feedback_analytics()
            logger.info("Retrieved feedback analytics")
        except Exception as e:
            logger.error(f"Error getting feedback analytics: {e}")
            feedback_analytics = {}
        
        # Prepare export data
        export_data = {
            "export_date": str(payload.get("exp", "")),
            "data_type": "feedback_data",
            "feedback": feedback,
            "analytics": feedback_analytics,
            "summary": {
                "total_feedback": len(feedback),
                "export_timestamp": str(payload.get("exp", ""))
            }
        }
        
        logger.info("Feedback data export prepared successfully")
        
        return BaseResponse(
            success=True,
            message="Feedback data exported successfully",
            data=export_data
        )
    except Exception as e:
        logger.error(f"Error exporting feedback data: {e}")
        return BaseResponse(
            success=False,
            message="Failed to export feedback data",
            data={"error": str(e)}
        )

@router.get("/export/notintdata", response_model=BaseResponse)
async def export_not_interested_data(payload: dict = Depends(verify_admin_token)):
    """
    Export not interested data only (Admin only)
    """
    try:
        logger.info("Starting not interested data export...")
        # Get not interested data
        try:
            not_interested = UserService.get_all_not_interested()
            logger.info(f"Retrieved {len(not_interested)} not interested users")
        except Exception as e:
            logger.error(f"Error getting not interested users: {e}")
            not_interested = []
        # Prepare export data
        export_data = {
            "export_date": str(payload.get("exp", "")),
            "data_type": "not_interested_data",
            "not_interested": not_interested,
            "summary": {
                "total_not_interested": len(not_interested),
                "export_timestamp": str(payload.get("exp", ""))
            }
        }
        logger.info("Not interested data export prepared successfully")
        return BaseResponse(
            success=True,
            message="Not interested data exported successfully",
            data=export_data
        )
    except Exception as e:
        logger.error(f"Error exporting not interested data: {e}")
        return BaseResponse(
            success=False,
            message="Failed to export not interested data",
            data={"error": str(e)}
        )

@router.get("/stats", response_model=BaseResponse)
async def get_data_statistics(payload: dict = Depends(verify_admin_token)):
    """
    Get data statistics (Admin only)
    """
    try:
        # Get all data counts
        users = UserService.get_all_users()
        creators = UserService.get_all_creators()
        not_interested = UserService.get_all_not_interested()
        feedback = FeedbackService.get_all_feedback()
        
        # Get analytics
        user_analytics = UserService.get_user_analytics()
        feedback_analytics = FeedbackService.get_feedback_analytics()
        
        stats = {
            "total_users": len(users),
            "total_creators": len(creators),
            "total_not_interested": len(not_interested),
            "total_feedback": len(feedback),
            "user_analytics": user_analytics,
            "feedback_analytics": feedback_analytics
        }
        
        return BaseResponse(
            success=True,
            message="Statistics retrieved successfully",
            data=stats
        )
    except Exception as e:
        logger.error(f"Error fetching statistics: {e}")
        return BaseResponse(
            success=False,
            message="Failed to fetch statistics"
        ) 