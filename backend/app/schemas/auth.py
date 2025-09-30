"""
FitTracker Backend - 认证Pydantic模式
"""

from pydantic import BaseModel, Field, EmailStr
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    """用户基础信息"""
    username: str = Field(..., min_length=3, max_length=50)
    email: EmailStr
    phone: Optional[str] = Field(None, max_length=20)
    bio: Optional[str] = Field(None, max_length=500)
    fitness_goal: Optional[str] = Field(None, max_length=100)
    height: Optional[float] = Field(None, ge=50, le=300)  # cm
    weight: Optional[float] = Field(None, ge=20, le=500)  # kg
    age: Optional[int] = Field(None, ge=1, le=150)
    gender: Optional[str] = Field(None, max_length=10)

class UserCreate(UserBase):
    """创建用户"""
    password: str = Field(..., min_length=6, max_length=100)

class UserLogin(BaseModel):
    """用户登录"""
    username: str
    password: str

class UserUpdate(BaseModel):
    """更新用户信息"""
    username: Optional[str] = Field(None, min_length=3, max_length=50)
    email: Optional[EmailStr] = None
    phone: Optional[str] = Field(None, max_length=20)
    bio: Optional[str] = Field(None, max_length=500)
    fitness_goal: Optional[str] = Field(None, max_length=100)
    height: Optional[float] = Field(None, ge=50, le=300)
    weight: Optional[float] = Field(None, ge=20, le=500)
    age: Optional[int] = Field(None, ge=1, le=150)
    gender: Optional[str] = Field(None, max_length=10)

class UserResponse(UserBase):
    """用户响应"""
    id: str
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class Token(BaseModel):
    """访问令牌"""
    access_token: str
    token_type: str = "bearer"
    expires_in: int

class TokenData(BaseModel):
    """令牌数据"""
    username: Optional[str] = None
