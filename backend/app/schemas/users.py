"""
FitTracker Backend - 用户相关模式
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class UserResponse(BaseModel):
    """用户响应"""
    id: str
    username: str
    email: str
    phone: Optional[str] = None
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    fitness_goal: Optional[str] = None
    is_active: bool
    last_login_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    height: Optional[float] = None
    weight: Optional[float] = None
    age: Optional[int] = None
    gender: Optional[str] = None
    
    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    """更新用户请求"""
    username: Optional[str] = Field(None, min_length=3, max_length=50)
    email: Optional[str] = Field(None, regex=r'^[^@]+@[^@]+\.[^@]+$')
    phone: Optional[str] = Field(None, min_length=11, max_length=20)
    avatar_url: Optional[str] = None
    bio: Optional[str] = Field(None, max_length=500)
    fitness_goal: Optional[str] = Field(None, max_length=100)
    height: Optional[float] = Field(None, ge=50, le=300)
    weight: Optional[float] = Field(None, ge=20, le=500)
    age: Optional[int] = Field(None, ge=1, le=150)
    gender: Optional[str] = Field(None, regex=r'^(male|female|other)$')
