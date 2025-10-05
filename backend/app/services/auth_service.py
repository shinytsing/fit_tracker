"""
FitTracker Backend - 认证服务
"""

from sqlalchemy.orm import Session
from sqlalchemy import or_
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
from typing import Optional
import uuid

from app.core.config import settings
from app.models import User
from app.schemas.auth import UserCreate, Token, UserResponse

# 密码加密上下文
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class AuthService:
    """认证服务类"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def create_user(self, user_data: UserCreate) -> UserResponse:
        """创建用户"""
        # 检查用户名是否已存在
        existing_user = self.db.query(User).filter(
            or_(User.username == user_data.username, User.email == user_data.email)
        ).first()
        
        if existing_user:
            if existing_user.username == user_data.username:
                raise ValueError("用户名已存在")
            else:
                raise ValueError("邮箱已存在")
        
        # 创建新用户
        hashed_password = pwd_context.hash(user_data.password)
        
        user = User(
            id=str(uuid.uuid4()),
            username=user_data.username,
            email=user_data.email,
            phone=user_data.phone,
            bio=user_data.bio,
            fitness_goal=user_data.fitness_goal,
            height=user_data.height,
            weight=user_data.weight,
            age=user_data.age,
            gender=user_data.gender,
            password_hash=hashed_password,
            is_active=True,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        
        return UserResponse.from_orm(user)
    
    def authenticate_user(self, username: str, password: str) -> Token:
        """验证用户并返回访问令牌"""
        # 查找用户
        user = self.db.query(User).filter(
            or_(User.username == username, User.email == username)
        ).first()
        
        if not user:
            raise ValueError("用户名或密码错误")
        
        if not user.is_active:
            raise ValueError("用户账户已被禁用")
        
        # 验证密码
        if not pwd_context.verify(password, user.password_hash):
            raise ValueError("用户名或密码错误")
        
        # 生成访问令牌
        access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = self._create_access_token(
            data={"sub": user.id}, expires_delta=access_token_expires
        )
        
        # 更新最后登录时间
        user.last_login_at = datetime.utcnow()
        self.db.commit()
        
        return Token(
            access_token=access_token,
            token_type="bearer",
            user=UserResponse.from_orm(user)
        )
    
    def get_current_user(self, token: str) -> UserResponse:
        """根据令牌获取当前用户"""
        try:
            payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
            user_id: str = payload.get("sub")
            if user_id is None:
                raise ValueError("无效的令牌")
        except JWTError:
            raise ValueError("无效的令牌")
        
        user = self.db.query(User).filter(User.id == user_id).first()
        if user is None:
            raise ValueError("用户不存在")
        
        if not user.is_active:
            raise ValueError("用户账户已被禁用")
        
        return UserResponse.from_orm(user)
    
    def _create_access_token(self, data: dict, expires_delta: Optional[timedelta] = None):
        """创建访问令牌"""
        to_encode = data.copy()
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(minutes=15)
        to_encode.update({"exp": expire})
        encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
        return encoded_jwt
