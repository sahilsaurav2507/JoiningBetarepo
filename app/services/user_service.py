from app.repository.user_repository import UserRepository
from app.models.user_models import UserData, NotInterestedData
from app.schemas.response_schemas import BaseResponse
from typing import List, Dict, Any
import logging

logger = logging.getLogger(__name__)

class UserService:
    
    @staticmethod
    def save_user_data(user_data: UserData) -> BaseResponse:
        """Save user or creator registration data (user_type from user_data)"""
        try:
            # Check if email already exists
            if UserRepository.check_email_exists(user_data.email, "users"):
                return BaseResponse(
                    success=False,
                    message="Email already registered"
                )
            
            # Save user or creator data
            if UserRepository.save_user(user_data):
                return BaseResponse(
                    success=True,
                    message="User registered successfully" if user_data.user_type == 'user' else "Creator registered successfully"
                )
            else:
                return BaseResponse(
                    success=False,
                    message="Failed to register user" if user_data.user_type == 'user' else "Failed to register creator"
                )
        except Exception as e:
            logger.error(f"Error in save_user_data: {e}")
            return BaseResponse(
                success=False,
                message="Internal server error"
            )
    
    @staticmethod
    def save_not_interested_data(not_interested_data: NotInterestedData) -> BaseResponse:
        """Save not interested user data"""
        try:
            # Check if email already exists
            if UserRepository.check_email_exists(not_interested_data.email, "not_interested_users"):
                return BaseResponse(
                    success=False,
                    message="Email already submitted"
                )
            
            # Save not interested data
            if UserRepository.save_not_interested(not_interested_data):
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
            logger.error(f"Error in save_not_interested_data: {e}")
            return BaseResponse(
                success=False,
                message="Internal server error"
            )
    
    @staticmethod
    def get_all_users() -> List[Dict[str, Any]]:
        """Get all registered users"""
        try:
            return UserRepository.get_all_users()
        except Exception as e:
            logger.error(f"Error in get_all_users: {e}")
            return []
    
    @staticmethod
    def get_all_creators() -> List[Dict[str, Any]]:
        """Get all registered creators"""
        try:
            return UserRepository.get_all_creators()
        except Exception as e:
            logger.error(f"Error in get_all_creators: {e}")
            return []
    
    @staticmethod
    def get_all_not_interested() -> List[Dict[str, Any]]:
        """Get all not interested users"""
        try:
            return UserRepository.get_all_not_interested()
        except Exception as e:
            logger.error(f"Error in get_all_not_interested: {e}")
            return []
    
    @staticmethod
    def get_user_analytics() -> Dict[str, Any]:
        """Get user analytics and statistics"""
        try:
            users = UserRepository.get_all_users()
            not_interested = UserRepository.get_all_not_interested()
            
            # Calculate statistics
            total_users = len(users)
            total_not_interested = len(not_interested)
            
            # Gender distribution
            gender_stats = {}
            for user in users:
                gender = user.get('gender', 'Not specified')
                gender_stats[gender] = gender_stats.get(gender, 0) + 1
            
            # Profession distribution
            profession_stats = {}
            for user in users:
                profession = user.get('profession', 'Not specified')
                profession_stats[profession] = profession_stats.get(profession, 0) + 1
            
            # Not interested reasons
            reason_stats = {}
            for ni_user in not_interested:
                reason = ni_user.get('not_interested_reason', 'Not specified')
                reason_stats[reason] = reason_stats.get(reason, 0) + 1
            
            return {
                'total_users': total_users,
                'total_not_interested': total_not_interested,
                'gender_distribution': gender_stats,
                'profession_distribution': profession_stats,
                'not_interested_reasons': reason_stats
            }
        except Exception as e:
            logger.error(f"Error in get_user_analytics: {e}")
            return {} 