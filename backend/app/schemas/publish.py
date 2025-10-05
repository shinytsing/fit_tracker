"""
FitTracker Backend - 发布相关模式
"""

from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
import uuid


class PostCreate(BaseModel):
    """创建动态请求"""
    content: str = Field(..., min_length=1, max_length=2000)
    images: Optional[List[str]] = None
    tags: Optional[List[str]] = None
    post_type: Optional[str] = "dynamic"
    mood_type: Optional[str] = None
    nutrition_data: Optional[Dict[str, Any]] = None
    training_data: Optional[Dict[str, Any]] = None


class PostUpdate(BaseModel):
    """更新动态请求"""
    content: Optional[str] = Field(None, min_length=1, max_length=2000)
    images: Optional[List[str]] = None
    tags: Optional[List[str]] = None
    mood_type: Optional[str] = None
    nutrition_data: Optional[Dict[str, Any]] = None
    training_data: Optional[Dict[str, Any]] = None


class PostResponse(BaseModel):
    """动态响应"""
    id: str
    user_id: str
    content: str
    images: Optional[List[str]] = None
    tags: Optional[List[str]] = None
    post_type: str
    mood_type: Optional[str] = None
    nutrition_data: Optional[Dict[str, Any]] = None
    training_data: Optional[Dict[str, Any]] = None
    like_count: int
    comment_count: int
    share_count: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class DraftCreate(BaseModel):
    """创建草稿请求"""
    content: str = Field(..., min_length=1, max_length=2000)
    images: Optional[List[str]] = None
    tags: Optional[List[str]] = None
    post_type: Optional[str] = "dynamic"
    mood_type: Optional[str] = None
    nutrition_data: Optional[Dict[str, Any]] = None
    training_data: Optional[Dict[str, Any]] = None


class DraftResponse(BaseModel):
    """草稿响应"""
    id: str
    user_id: str
    content: str
    images: Optional[List[str]] = None
    tags: Optional[List[str]] = None
    post_type: str
    mood_type: Optional[str] = None
    nutrition_data: Optional[Dict[str, Any]] = None
    training_data: Optional[Dict[str, Any]] = None
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class QuickCheckinRequest(BaseModel):
    """快速打卡请求"""
    content: Optional[str] = None
    images: Optional[List[str]] = None
    tags: Optional[List[str]] = None
    training_data: Optional[Dict[str, Any]] = None


class QuickCheckinResponse(BaseModel):
    """快速打卡响应"""
    success: bool
    message: str
    post_id: str
    checkin_time: datetime
