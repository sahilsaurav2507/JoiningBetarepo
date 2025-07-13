from pydantic import BaseModel
from typing import Optional, List, Any
from datetime import datetime

class BaseResponse(BaseModel):
    success: bool
    message: str
    data: Optional[Any] = None

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    phone_number: str
    gender: Optional[str] = None
    profession: Optional[str] = None
    interest_reason: Optional[str] = None
    created_at: datetime

class NotInterestedResponse(BaseModel):
    id: int
    name: str
    email: str
    not_interested_reason: Optional[str] = None
    improvement_suggestions: Optional[str] = None
    created_at: datetime

class FeedbackResponse(BaseModel):
    id: int
    user_email: Optional[str] = None
    created_at: datetime

class AdminTokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

class DataDownloadResponse(BaseModel):
    users: List[UserResponse]
    creators: List[UserResponse]
    not_interested: List[NotInterestedResponse]
    feedback: List[FeedbackResponse]
    total_users: int
    total_creators: int
    total_not_interested: int
    total_feedback: int 