"""
FitTracker Backend - 消息相关模式
"""

from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
import uuid


class MessageCreate(BaseModel):
    """创建消息请求"""
    content: str = Field(..., min_length=1, max_length=1000)
    message_type: Optional[str] = "text"


class MessageResponse(BaseModel):
    """消息响应"""
    id: str
    chat_id: str
    sender_id: str
    content: str
    message_type: str
    is_read: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


class ChatResponse(BaseModel):
    """聊天响应"""
    id: str
    user1_id: str
    user2_id: str
    created_at: datetime
    updated_at: datetime
    last_message: Optional[MessageResponse] = None
    unread_count: int = 0
    
    class Config:
        from_attributes = True


class ChatCreate(BaseModel):
    """创建聊天请求"""
    user2_id: str = Field(..., description="对方用户ID")


class GroupResponse(BaseModel):
    """群组响应"""
    id: str
    name: str
    description: Optional[str] = None
    avatar_url: Optional[str] = None
    creator_id: str
    member_count: int
    is_active: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class GroupCreate(BaseModel):
    """创建群组请求"""
    name: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    avatar_url: Optional[str] = None


class NotificationResponse(BaseModel):
    """通知响应"""
    id: str
    user_id: str
    type: str
    title: str
    content: str
    data: Optional[dict] = None
    is_read: bool
    created_at: datetime
    
    class Config:
        from_attributes = True
