"""
FitTracker Backend - 消息服务
"""

from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime

from app.models import Chat, Message, User


class MessageService:
    def __init__(self, db: Session):
        self.db = db

    def get_chats(self, user_id: str, skip: int = 0, limit: int = 20) -> List[Chat]:
        """获取聊天列表"""
        chats = self.db.query(Chat).filter(
            (Chat.user1_id == user_id) | (Chat.user2_id == user_id)
        ).order_by(Chat.updated_at.desc()).offset(skip).limit(limit).all()
        return chats

    def get_chat_messages(self, chat_id: str, user_id: str, skip: int = 0, limit: int = 50) -> List[Message]:
        """获取聊天消息"""
        # 验证用户是否有权限访问该聊天
        chat = self.db.query(Chat).filter(
            Chat.id == chat_id,
            (Chat.user1_id == user_id) | (Chat.user2_id == user_id)
        ).first()
        
        if not chat:
            return []

        messages = self.db.query(Message).filter(
            Message.chat_id == chat_id
        ).order_by(Message.created_at.desc()).offset(skip).limit(limit).all()
        return messages

    def create_chat(self, user1_id: str, user2_id: str) -> Chat:
        """创建聊天"""
        # 检查是否已存在聊天
        existing_chat = self.db.query(Chat).filter(
            ((Chat.user1_id == user1_id) & (Chat.user2_id == user2_id)) |
            ((Chat.user1_id == user2_id) & (Chat.user2_id == user1_id))
        ).first()
        
        if existing_chat:
            return existing_chat

        chat = Chat(
            id=str(uuid.uuid4()),
            user1_id=user1_id,
            user2_id=user2_id,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        self.db.add(chat)
        self.db.commit()
        self.db.refresh(chat)
        return chat

    def send_message(self, chat_id: str, sender_id: str, content: str, message_type: str = "text") -> Message:
        """发送消息"""
        # 验证用户是否有权限发送消息到该聊天
        chat = self.db.query(Chat).filter(
            Chat.id == chat_id,
            (Chat.user1_id == sender_id) | (Chat.user2_id == sender_id)
        ).first()
        
        if not chat:
            raise ValueError("无权访问该聊天")

        message = Message(
            id=str(uuid.uuid4()),
            chat_id=chat_id,
            sender_id=sender_id,
            content=content,
            message_type=message_type,
            created_at=datetime.utcnow()
        )
        self.db.add(message)
        
        # 更新聊天最后消息时间
        chat.updated_at = datetime.utcnow()
        
        self.db.commit()
        self.db.refresh(message)
        return message

    def mark_messages_read(self, chat_id: str, user_id: str) -> bool:
        """标记消息为已读"""
        # 验证用户权限
        chat = self.db.query(Chat).filter(
            Chat.id == chat_id,
            (Chat.user1_id == user_id) | (Chat.user2_id == user_id)
        ).first()
        
        if not chat:
            return False

        # 标记所有未读消息为已读
        self.db.query(Message).filter(
            Message.chat_id == chat_id,
            Message.sender_id != user_id,
            Message.is_read == False
        ).update({"is_read": True})
        
        self.db.commit()
        return True

    def get_unread_count(self, user_id: str) -> int:
        """获取未读消息数量"""
        count = self.db.query(Message).join(Chat).filter(
            (Chat.user1_id == user_id) | (Chat.user2_id == user_id),
            Message.sender_id != user_id,
            Message.is_read == False
        ).count()
        return count

    def delete_chat(self, chat_id: str, user_id: str) -> bool:
        """删除聊天"""
        chat = self.db.query(Chat).filter(
            Chat.id == chat_id,
            (Chat.user1_id == user_id) | (Chat.user2_id == user_id)
        ).first()
        
        if not chat:
            return False

        # 删除聊天中的所有消息
        self.db.query(Message).filter(Message.chat_id == chat_id).delete()
        
        # 删除聊天
        self.db.delete(chat)
        self.db.commit()
        return True
