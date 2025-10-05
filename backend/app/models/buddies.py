"""
FitTracker Backend - 搭子相关数据模型
"""

from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, ForeignKey, JSON, Float
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class WorkoutBuddy(Base):
    """健身搭子关系表"""
    __tablename__ = "workout_buddies"

    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # 用户关系
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    buddy_id = Column(String, ForeignKey("users.id"), nullable=False)
    
    # 关系状态
    status = Column(String, default="active")  # active, paused, ended
    
    # 匹配信息
    match_score = Column(Integer, default=0)  # 匹配度分数 0-100
    match_reasons = Column(JSON, default=list)  # 匹配原因列表
    
    # 训练偏好
    workout_preferences = Column(JSON, default=dict)  # 训练偏好
    location_match = Column(Boolean, default=False)  # 地理位置匹配
    schedule_match = Column(Boolean, default=False)  # 时间安排匹配
    goal_match = Column(Boolean, default=False)  # 健身目标匹配
    
    # 关系管理
    last_interaction = Column(DateTime(timezone=True))
    total_workouts = Column(Integer, default=0)  # 一起训练次数
    rating = Column(Float, default=0.0)  # 搭子评分
    
    # 约束
    __table_args__ = (
        {"extend_existing": True}
    )

class BuddyRequest(Base):
    """搭子申请表"""
    __tablename__ = "buddy_requests"

    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # 申请关系
    requester_id = Column(String, ForeignKey("users.id"), nullable=False)
    target_id = Column(String, ForeignKey("users.id"), nullable=False)
    
    # 申请状态
    status = Column(String, default="pending")  # pending, accepted, rejected, expired
    
    # 申请信息
    request_message = Column(Text)
    response_message = Column(Text)
    
    # 训练偏好
    workout_preferences = Column(JSON, default=dict)
    preferred_time = Column(String)  # 偏好训练时间
    preferred_location = Column(String)  # 偏好训练地点
    
    # 时间管理
    requested_at = Column(DateTime(timezone=True), server_default=func.now())
    responded_at = Column(DateTime(timezone=True))
    expires_at = Column(DateTime(timezone=True))  # 申请过期时间
    
    # 约束
    __table_args__ = (
        {"extend_existing": True}
    )

class BuddyMatch(Base):
    """搭子匹配记录表"""
    __tablename__ = "buddy_matches"

    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 匹配关系
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    matched_user_id = Column(String, ForeignKey("users.id"), nullable=False)
    
    # 匹配信息
    match_score = Column(Integer, nullable=False)  # 匹配分数
    match_reasons = Column(JSON, default=list)  # 匹配原因
    match_type = Column(String)  # 匹配类型: recommendation, nearby, similar
    
    # 匹配状态
    is_viewed = Column(Boolean, default=False)  # 是否已查看
    is_interested = Column(Boolean, default=False)  # 是否感兴趣
    
    # 约束
    __table_args__ = (
        {"extend_existing": True}
    )
