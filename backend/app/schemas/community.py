"""
FitTracker Backend - 社区相关模式
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


class CommentCreate(BaseModel):
    """创建评论请求"""
    content: str = Field(..., min_length=1, max_length=500)
    parent_id: Optional[str] = None


class CommentResponse(BaseModel):
    """评论响应"""
    id: str
    user_id: str
    post_id: str
    content: str
    parent_id: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class LikeResponse(BaseModel):
    """点赞响应"""
    id: str
    user_id: str
    post_id: str
    created_at: datetime
    
    class Config:
        from_attributes = True


class FeedResponse(BaseModel):
    """动态流响应"""
    posts: List[PostResponse]
    total: int
    has_more: bool
