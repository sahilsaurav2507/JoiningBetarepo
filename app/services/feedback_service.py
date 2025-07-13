from app.repository.feedback_repository import FeedbackRepository
from app.models.feedback_models import FeedbackData
from app.schemas.response_schemas import BaseResponse
from typing import List, Dict, Any
import logging

logger = logging.getLogger(__name__)

class FeedbackService:
    
    @staticmethod
    def save_feedback(feedback_data: FeedbackData) -> BaseResponse:
        """Save feedback data"""
        try:
            if FeedbackRepository.save_feedback(feedback_data):
                return BaseResponse(
                    success=True,
                    message="Feedback submitted successfully"
                )
            else:
                return BaseResponse(
                    success=False,
                    message="Failed to submit feedback"
                )
        except Exception as e:
            logger.error(f"Error in save_feedback: {e}")
            return BaseResponse(
                success=False,
                message="Internal server error"
            )
    
    @staticmethod
    def get_all_feedback() -> List[Dict[str, Any]]:
        """Get all feedback data"""
        try:
            return FeedbackRepository.get_all_feedback()
        except Exception as e:
            logger.error(f"Error in get_all_feedback: {e}")
            return []
    
    @staticmethod
    def get_feedback_analytics() -> Dict[str, Any]:
        """Get feedback analytics and statistics"""
        try:
            return FeedbackRepository.get_feedback_analytics()
        except Exception as e:
            logger.error(f"Error in get_feedback_analytics: {e}")
            return {}
    
    @staticmethod
    def get_feedback_summary() -> Dict[str, Any]:
        """Get a summary of feedback data"""
        try:
            feedback_list = FeedbackRepository.get_all_feedback()
            analytics = FeedbackRepository.get_feedback_analytics()
            
            # Calculate summary statistics
            total_feedback = len(feedback_list)
            
            # Rating summaries
            rating_summaries = {}
            if analytics.get('average_ratings'):
                avg_ratings = analytics['average_ratings']
                rating_summaries = {
                    'digital_work_showcase_effectiveness': round(avg_ratings.get('avg_showcase_effectiveness', 0), 2),
                    'digital_work_sharing_difficulty': round(avg_ratings.get('avg_sharing_difficulty', 0), 2),
                    'blogging_tools_familiarity': round(avg_ratings.get('avg_blogging_familiarity', 0), 2)
                }
            
            # Recognition summary
            recognition_summary = {}
            if analytics.get('recognition_stats'):
                for stat in analytics['recognition_stats']:
                    recognition_summary[stat['legal_persons_online_recognition']] = stat['count']
            
            # Blogging summary
            blogging_summary = {}
            if analytics.get('blogging_stats'):
                for stat in analytics['blogging_stats']:
                    blogging_summary[stat['regular_blogging']] = stat['count']
            
            # AI tools usage summary
            ai_tools_summary = {}
            if analytics.get('ai_tools_stats'):
                for stat in analytics['ai_tools_stats']:
                    ai_tools_summary[stat['ai_tools_blogging_frequency']] = stat['count']
            
            # Recent feedback (last 10)
            recent_feedback = feedback_list[:10] if feedback_list else []
            
            return {
                'total_feedback': total_feedback,
                'average_ratings': rating_summaries,
                'recognition_summary': recognition_summary,
                'blogging_summary': blogging_summary,
                'ai_tools_summary': ai_tools_summary,
                'recent_feedback': recent_feedback
            }
        except Exception as e:
            logger.error(f"Error in get_feedback_summary: {e}")
            return {} 