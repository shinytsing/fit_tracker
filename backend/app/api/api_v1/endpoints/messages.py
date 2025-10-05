"""
FitTracker Backend - 消息API路由
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime

from app.core.database import get_db
from app.models import Message, Chat, Group, Notification
from app.schemas.messages import (
    MessageCreate,
    MessageResponse,
    ChatResponse,
    GroupResponse,
    NotificationResponse,
)
from app.services.message_service import MessageService

router = APIRouter()

@router.get("/chats", response_model=List[ChatResponse])
async def get_chats(
    user_id: str,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """获取聊天列表"""
    try:
        service = MessageService(db)
        chats = service.get_user_chats(user_id, skip=skip, limit=limit)
        return chats
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取聊天列表失败: {str(e)}"
        )

@router.get("/chats/{chat_id}/messages", response_model=List[MessageResponse])
async def get_chat_messages(
    chat_id: str,
    user_id: str,
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db)
):
    """获取聊天消息"""
    try:
        service = MessageService(db)
        messages = service.get_chat_messages(chat_id, user_id, skip=skip, limit=limit)
        return messages
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取消息失败: {str(e)}"
        )

@router.post("/chats/{chat_id}/messages", response_model=MessageResponse)
async def send_message(
    chat_id: str,
    message_data: MessageCreate,
    user_id: str,
    db: Session = Depends(get_db)
):
    """发送消息"""
    try:
        service = MessageService(db)
        message = service.send_message(chat_id, user_id, message_data)
        return message
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"发送消息失败: {str(e)}"
        )

@router.post("/chats", response_model=ChatResponse)
async def create_chat(
    user_id: str,
    target_user_id: str,
    db: Session = Depends(get_db)
):
    """创建聊天"""
    try:
        service = MessageService(db)
        chat = service.create_chat(user_id, target_user_id)
        return chat
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"创建聊天失败: {str(e)}"
        )

@router.get("/notifications", response_model=List[NotificationResponse])
async def get_notifications(
    user_id: str,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """获取系统通知"""
    try:
        service = MessageService(db)
        notifications = service.get_user_notifications(user_id, skip=skip, limit=limit)
        return notifications
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取通知失败: {str(e)}"
        )

@router.put("/notifications/{notification_id}/read")
async def mark_notification_read(
    notification_id: str,
    user_id: str,
    db: Session = Depends(get_db)
):
    """标记通知为已读"""
    try:
        service = MessageService(db)
        service.mark_notification_read(notification_id, user_id)
        return {"message": "通知已标记为已读"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"标记通知失败: {str(e)}"
        )

@router.get("/groups", response_model=List[GroupResponse])
async def get_groups(
    user_id: str,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """获取群聊列表"""
    try:
        service = MessageService(db)
        groups = service.get_user_groups(user_id, skip=skip, limit=limit)
        return groups
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取群聊列表失败: {str(e)}"
        )

@router.post("/groups", response_model=GroupResponse)
async def create_group(
    user_id: str,
    group_name: str,
    member_ids: List[str],
    db: Session = Depends(get_db)
):
    """创建群聊"""
    try:
        service = MessageService(db)
        group = service.create_group(user_id, group_name, member_ids)
        return group
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"创建群聊失败: {str(e)}"
        )
