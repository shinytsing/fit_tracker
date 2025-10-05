"""
FitTracker Backend - 用户服务
"""

from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime

from app.models import User
from app.schemas.auth import UserCreate, UserUpdate, UserResponse


class UserService:
    def __init__(self, db: Session):
        self.db = db

    def get_users(self, skip: int = 0, limit: int = 20) -> List[UserResponse]:
        """获取用户列表"""
        users = self.db.query(User).offset(skip).limit(limit).all()
        return [UserResponse.from_orm(user) for user in users]

    def get_user(self, user_id: str) -> Optional[UserResponse]:
        """获取特定用户信息"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if user:
            return UserResponse.from_orm(user)
        return None

    def get_user_by_email(self, email: str) -> Optional[User]:
        """根据邮箱获取用户"""
        return self.db.query(User).filter(User.email == email).first()

    def get_user_by_username(self, username: str) -> Optional[User]:
        """根据用户名获取用户"""
        return self.db.query(User).filter(User.username == username).first()

    def create_user(self, user_data: UserCreate) -> UserResponse:
        """创建用户"""
        user = User(
            id=str(uuid.uuid4()),
            username=user_data.username,
            email=user_data.email,
            password_hash=user_data.password_hash,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return UserResponse.from_orm(user)

    def update_user(self, user_id: str, user_data: UserUpdate) -> Optional[UserResponse]:
        """更新用户信息"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return None

        for field, value in user_data.dict(exclude_unset=True).items():
            setattr(user, field, value)
        
        user.updated_at = datetime.utcnow()
        self.db.commit()
        self.db.refresh(user)
        return UserResponse.from_orm(user)

    def delete_user(self, user_id: str) -> bool:
        """删除用户"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return False

        self.db.delete(user)
        self.db.commit()
        return True

    def update_last_login(self, user_id: str) -> None:
        """更新最后登录时间"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if user:
            user.last_login_at = datetime.utcnow()
            self.db.commit()
