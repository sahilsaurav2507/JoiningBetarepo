# Import database
from database import db
from app.models.feedback_models import FeedbackData
from typing import List, Optional
import logging

logger = logging.getLogger(__name__)

class FeedbackRepository:
    
    @staticmethod
    def save_feedback(feedback_data: FeedbackData) -> bool:
        """Save feedback data to database"""
        try:
            # Start transaction (SQLite doesn't need explicit start)
            if hasattr(db.connection, 'start_transaction'):
                db.connection.start_transaction()
            
            # Insert into feedback_forms
            feedback_query = "INSERT INTO feedback_forms (user_email) VALUES (%s)"
            feedback_result = db.execute_query(feedback_query, (feedback_data.user_email,))
            
            if feedback_result <= 0:
                if hasattr(db.connection, 'rollback'):
                    db.connection.rollback()
                return False
            
            feedback_form_id = db.cursor.lastrowid
            
            # Insert digital work feedback if provided
            if any([
                feedback_data.digital_work_showcase_effectiveness,
                feedback_data.legal_persons_online_recognition,
                feedback_data.digital_work_sharing_difficulty,
                feedback_data.regular_blogging,
                feedback_data.ai_tools_blogging_frequency,
                feedback_data.blogging_tools_familiarity
            ]):
                digital_work_query = """
                    INSERT INTO digital_work_feedback (
                        feedback_form_id, digital_work_showcase_effectiveness,
                        legal_persons_online_recognition, digital_work_sharing_difficulty,
                        regular_blogging, ai_tools_blogging_frequency, blogging_tools_familiarity
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s)
                """
                digital_work_params = (
                    feedback_form_id,
                    feedback_data.digital_work_showcase_effectiveness,
                    feedback_data.legal_persons_online_recognition,
                    feedback_data.digital_work_sharing_difficulty,
                    feedback_data.regular_blogging,
                    feedback_data.ai_tools_blogging_frequency,
                    feedback_data.blogging_tools_familiarity
                )
                db.execute_query(digital_work_query, digital_work_params)
            
            # Insert platform features and opinions if provided
            if any([
                feedback_data.core_platform_features,
                feedback_data.ai_research_opinion,
                feedback_data.ideal_reading_features,
                feedback_data.portfolio_presentation_preference
            ]):
                platform_query = """
                    INSERT INTO platform_features_opinions (
                        feedback_form_id, core_platform_features, ai_research_opinion,
                        ideal_reading_features, portfolio_presentation_preference
                    ) VALUES (%s, %s, %s, %s, %s)
                """
                platform_params = (
                    feedback_form_id,
                    feedback_data.core_platform_features,
                    feedback_data.ai_research_opinion,
                    feedback_data.ideal_reading_features,
                    feedback_data.portfolio_presentation_preference
                )
                db.execute_query(platform_query, platform_params)
            
            # Commit transaction
            if hasattr(db.connection, 'commit'):
                db.connection.commit()
            return True
            
        except Exception as e:
            logger.error(f"Error saving feedback: {e}")
            if hasattr(db.connection, 'rollback'):
                db.connection.rollback()
            return False
    
    @staticmethod
    def get_all_feedback() -> List[dict]:
        """Get all feedback data with related information"""
        try:
            query = """
                SELECT 
                    f.id, f.user_email, f.created_at,
                    dwf.digital_work_showcase_effectiveness,
                    dwf.legal_persons_online_recognition,
                    dwf.digital_work_sharing_difficulty,
                    dwf.regular_blogging,
                    dwf.ai_tools_blogging_frequency,
                    dwf.blogging_tools_familiarity,
                    pfo.core_platform_features,
                    pfo.ai_research_opinion,
                    pfo.ideal_reading_features,
                    pfo.portfolio_presentation_preference
                FROM feedback_forms f
                LEFT JOIN digital_work_feedback dwf ON f.id = dwf.feedback_form_id
                LEFT JOIN platform_features_opinions pfo ON f.id = pfo.feedback_form_id
                ORDER BY f.created_at DESC
            """
            return db.execute_query(query)
        except Exception as e:
            logger.error(f"Error fetching feedback: {e}")
            return []
    
    @staticmethod
    def get_feedback_analytics() -> dict:
        """Get feedback analytics and statistics"""
        try:
            # Get average ratings
            avg_ratings_query = """
                SELECT 
                    AVG(dwf.digital_work_showcase_effectiveness) as avg_showcase_effectiveness,
                    AVG(dwf.digital_work_sharing_difficulty) as avg_sharing_difficulty,
                    AVG(dwf.blogging_tools_familiarity) as avg_blogging_familiarity
                FROM feedback_forms f
                LEFT JOIN digital_work_feedback dwf ON f.id = dwf.feedback_form_id
            """
            avg_ratings = db.execute_query(avg_ratings_query)
            
            # Get total feedback count
            count_query = "SELECT COUNT(*) as total_feedback FROM feedback_forms"
            total_count = db.execute_query(count_query)
            
            # Get recognition statistics
            recognition_query = """
                SELECT 
                    legal_persons_online_recognition,
                    COUNT(*) as count
                FROM digital_work_feedback 
                WHERE legal_persons_online_recognition IS NOT NULL
                GROUP BY legal_persons_online_recognition
            """
            recognition_stats = db.execute_query(recognition_query)
            
            # Get blogging statistics
            blogging_query = """
                SELECT 
                    regular_blogging,
                    COUNT(*) as count
                FROM digital_work_feedback 
                WHERE regular_blogging IS NOT NULL
                GROUP BY regular_blogging
            """
            blogging_stats = db.execute_query(blogging_query)
            
            # Get AI tools usage statistics
            ai_tools_query = """
                SELECT 
                    ai_tools_blogging_frequency,
                    COUNT(*) as count
                FROM digital_work_feedback 
                WHERE ai_tools_blogging_frequency IS NOT NULL
                GROUP BY ai_tools_blogging_frequency
            """
            ai_tools_stats = db.execute_query(ai_tools_query)
            
            return {
                'average_ratings': avg_ratings[0] if avg_ratings else {},
                'total_feedback': total_count[0]['total_feedback'] if total_count else 0,
                'recognition_stats': recognition_stats,
                'blogging_stats': blogging_stats,
                'ai_tools_stats': ai_tools_stats
            }
        except Exception as e:
            logger.error(f"Error fetching feedback analytics: {e}")
            return {} 