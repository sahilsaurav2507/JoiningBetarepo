# Import database
from database import db
from app.models.user_models import UserData, NotInterestedData
from typing import List, Optional
import logging

logger = logging.getLogger(__name__)

class UserRepository:
    
    @staticmethod
    def save_user(user_data: UserData) -> bool:
        """Save user or creator data to database (user_type from user_data)"""
        try:
            query = """
                INSERT INTO users (name, email, phone_number, gender, profession, interest_reason, user_type)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            params = (
                user_data.name,
                user_data.email,
                user_data.phone_number,
                user_data.gender,
                user_data.profession,
                user_data.interest_reason,
                user_data.user_type
            )
            
            result = db.execute_query(query, params)
            return result > 0
        except Exception as e:
            logger.error(f"Error saving user: {e}")
            return False
    
    @staticmethod
    def save_not_interested(not_interested_data: NotInterestedData) -> bool:
        """Save not interested user data to database"""
        try:
            query = """
                INSERT INTO not_interested_users (name, email, phone_number, gender, profession, not_interested_reason, improvement_suggestions, interest_reason)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """
            params = (
                not_interested_data.name,
                not_interested_data.email,
                not_interested_data.phone_number,
                not_interested_data.gender,
                not_interested_data.profession,
                not_interested_data.not_interested_reason,
                not_interested_data.improvement_suggestions,
                not_interested_data.interest_reason
            )
            
            result = db.execute_query(query, params)
            return result > 0
        except Exception as e:
            logger.error(f"Error saving not interested user: {e}")
            return False
    
    @staticmethod
    def get_all_users() -> List[dict]:
        """Get all registered users (user_type='user')"""
        try:
            query = "SELECT * FROM users WHERE user_type='user' ORDER BY created_at DESC"
            return db.execute_query(query)
        except Exception as e:
            logger.error(f"Error fetching users: {e}")
            return []
    
    @staticmethod
    def get_all_creators() -> List[dict]:
        """Get all registered creators (user_type='creator')"""
        try:
            query = "SELECT * FROM users WHERE user_type='creator' ORDER BY created_at DESC"
            return db.execute_query(query)
        except Exception as e:
            logger.error(f"Error fetching creators: {e}")
            return []
    
    @staticmethod
    def get_all_not_interested() -> List[dict]:
        """Get all not interested users"""
        try:
            query = "SELECT * FROM not_interested_users ORDER BY created_at DESC"
            return db.execute_query(query)
        except Exception as e:
            logger.error(f"Error fetching not interested users: {e}")
            return []
    
    @staticmethod
    def check_email_exists(email: str, table: str = "users") -> bool:
        """Check if email already exists in specified table"""
        try:
            query = f"SELECT COUNT(*) as count FROM {table} WHERE email = %s"
            result = db.execute_query(query, (email,))
            return result[0]['count'] > 0 if result else False
        except Exception as e:
            logger.error(f"Error checking email existence: {e}")
            return False 