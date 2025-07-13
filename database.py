import mysql.connector
from mysql.connector import Error
from config import settings
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DatabaseConnection:
    def __init__(self):
        self.connection = None
        self.cursor = None
    
    def connect(self):
        """Establish database connection"""
        try:
            self.connection = mysql.connector.connect(
                host=settings.db_host,
                port=settings.db_port,
                database=settings.db_name,
                user=settings.db_user,
                password=settings.db_password,
                autocommit=True
            )
            self.cursor = self.connection.cursor(dictionary=True)
            logger.info("Database connection established successfully")
            return True
        except Error as e:
            logger.error(f"Error connecting to MySQL: {e}")
            return False
    
    def disconnect(self):
        """Close database connection"""
        if self.cursor:
            self.cursor.close()
        if self.connection:
            self.connection.close()
            logger.info("Database connection closed")
    
    def execute_query(self, query, params=None):
        """Execute a query and return results"""
        try:
            if not self.connection or not self.connection.is_connected():
                self.connect()
            
            self.cursor.execute(query, params or ())
            
            if query.strip().upper().startswith('SELECT'):
                return self.cursor.fetchall()
            else:
                return self.cursor.rowcount
        except Error as e:
            logger.error(f"Error executing query: {e}")
            raise e
    
    def execute_many(self, query, params_list):
        """Execute multiple queries with different parameters"""
        try:
            if not self.connection or not self.connection.is_connected():
                self.connect()
            
            self.cursor.executemany(query, params_list)
            return self.cursor.rowcount
        except Error as e:
            logger.error(f"Error executing multiple queries: {e}")
            raise e

# Global database instance
db = DatabaseConnection() 