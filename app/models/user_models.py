from pydantic import BaseModel, EmailStr, validator
from typing import Optional
from enum import Enum

class Gender(str, Enum):
    MALE = "Male"
    FEMALE = "Female"
    OTHER = "Other"
    PREFER_NOT_TO_SAY = "Prefer not to say"

class Profession(str, Enum):
    STUDENT = "Student"
    LAWYER = "Lawyer"
    OTHER = "Other"

class NotInterestedReason(str, Enum):
    TOO_COMPLEX = "Too complex"
    NOT_RELEVANT = "Not relevant"
    OTHER = "Other"

class UserData(BaseModel):
    name: str
    email: EmailStr
    phone_number: str
    gender: Optional[Gender] = None
    profession: Optional[Profession] = None
    interest_reason: Optional[str] = None
    user_type: str = 'user'  # 'user' or 'creator'
    
    @validator('name')
    def validate_name(cls, v):
        if not v.strip():
            raise ValueError('Name cannot be empty')
        return v.strip()
    
    @validator('phone_number')
    def validate_phone(cls, v):
        if not v.strip():
            raise ValueError('Phone number cannot be empty')
        return v.strip()

class NotInterestedData(BaseModel):
    name: str
    email: EmailStr
    phone_number: str
    gender: Optional[Gender] = None
    profession: Optional[Profession] = None
    not_interested_reason: Optional[NotInterestedReason] = None
    improvement_suggestions: Optional[str] = None
    interest_reason: Optional[str] = None

    @validator('name')
    def validate_name(cls, v):
        if not v.strip():
            raise ValueError('Name cannot be empty')
        return v.strip()

    @validator('phone_number')
    def validate_phone(cls, v):
        if not v.strip():
            raise ValueError('Phone number cannot be empty')
        return v.strip()

class AdminLogin(BaseModel):
    username: str
    password: str 