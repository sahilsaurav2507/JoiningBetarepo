from pydantic import BaseModel, EmailStr, validator
from typing import Optional
from enum import Enum

class FollowUpConsent(str, Enum):
    YES = "yes"
    NO = "no"

class RecognitionOption(str, Enum):
    YES = "yes"
    NO = "no"

class BloggingFrequency(str, Enum):
    NEVER = "never"
    RARELY = "rarely"
    SOMETIMES = "sometimes"
    OFTEN = "often"
    ALWAYS = "always"

class FeedbackData(BaseModel):
    user_email: Optional[EmailStr] = None
    
    # Digital Work Showcase Effectiveness (Rating 1-5)
    digital_work_showcase_effectiveness: Optional[int] = None
    
    # Legal Persons Online Recognition (Yes/No)
    legal_persons_online_recognition: Optional[RecognitionOption] = None
    
    # Digital Work Sharing Difficulty (Rating 1-5)
    digital_work_sharing_difficulty: Optional[int] = None
    
    # Regular Blogging (Yes/No)
    regular_blogging: Optional[RecognitionOption] = None
    
    # AI Tools Blogging Frequency (Never/Rarely/Sometimes/Often/Always)
    ai_tools_blogging_frequency: Optional[BloggingFrequency] = None
    
    # Blogging Tools Familiarity (Rating 1-5)
    blogging_tools_familiarity: Optional[int] = None
    
    # Core Platform Features (Text)
    core_platform_features: Optional[str] = None
    
    # AI Research Opinion (Text)
    ai_research_opinion: Optional[str] = None
    
    # Ideal Reading Features (Text)
    ideal_reading_features: Optional[str] = None
    
    # Portfolio Presentation Preference (Text)
    portfolio_presentation_preference: Optional[str] = None
    
    @validator('digital_work_showcase_effectiveness', 'digital_work_sharing_difficulty', 'blogging_tools_familiarity')
    def validate_rating(cls, v):
        if v is not None and (v < 1 or v > 5):
            raise ValueError('Rating must be between 1 and 5')
        return v
    
    @validator('core_platform_features', 'ai_research_opinion', 'ideal_reading_features', 'portfolio_presentation_preference')
    def validate_text_length(cls, v):
        if v is not None and len(v) > 1000:
            raise ValueError('Text field must be 1000 characters or less')
        return v 