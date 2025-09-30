"""
FitTracker Backend - 数据库模型
"""

from sqlalchemy import Column, String, Text, Integer, Boolean, DateTime, ForeignKey, JSON, Float, Date
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
from app.core.database import Base

class User(Base):
    """用户模型"""
    __tablename__ = "users"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    username = Column(String(50), unique=True, nullable=False, index=True)
    email = Column(String(100), unique=True, nullable=False, index=True)
    phone = Column(String(20), unique=True, nullable=True)
    password_hash = Column(String(255), nullable=False)
    avatar_url = Column(String(500), nullable=True)
    bio = Column(Text, nullable=True)
    fitness_goal = Column(String(100), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # 身体指标
    height = Column(Float, nullable=True)  # 身高(cm)
    weight = Column(Float, nullable=True)  # 体重(kg)
    age = Column(Integer, nullable=True)    # 年龄
    gender = Column(String(10), nullable=True)  # 性别
    
    # 关系
    checkins = relationship("Checkin", back_populates="user", cascade="all, delete-orphan")
    followers = relationship("Follow", foreign_keys="Follow.following_id", back_populates="following")
    following = relationship("Follow", foreign_keys="Follow.follower_id", back_populates="follower")
    likes = relationship("Like", back_populates="user", cascade="all, delete-orphan")
    comments = relationship("Comment", back_populates="user", cascade="all, delete-orphan")
    workouts = relationship("Workout", back_populates="user", cascade="all, delete-orphan")
    nutrition_logs = relationship("NutritionLog", back_populates="user", cascade="all, delete-orphan")
    health_records = relationship("HealthRecord", back_populates="user", cascade="all, delete-orphan")
    training_plans = relationship("TrainingPlan", back_populates="user", cascade="all, delete-orphan")

class Checkin(Base):
    """健身打卡模型"""
    __tablename__ = "checkins"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    content = Column(Text, nullable=False)
    images = Column(JSON, nullable=True)  # 存储图片URL数组
    tags = Column(JSON, nullable=True)    # 存储标签数组
    workout_type = Column(String(50), nullable=True, index=True)
    duration_minutes = Column(Integer, nullable=True)
    calories_burned = Column(Integer, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # 关系
    user = relationship("User", back_populates="checkins")
    likes = relationship("Like", back_populates="checkin", cascade="all, delete-orphan")
    comments = relationship("Comment", back_populates="checkin", cascade="all, delete-orphan")

class Workout(Base):
    """运动记录模型"""
    __tablename__ = "workouts"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    workout_type = Column(String(50), nullable=False, index=True)  # 跑步、骑行、游泳等
    duration_minutes = Column(Integer, nullable=False)
    distance_km = Column(Float, nullable=True)
    calories_burned = Column(Integer, nullable=True)
    avg_heart_rate = Column(Integer, nullable=True)
    max_heart_rate = Column(Integer, nullable=True)
    notes = Column(Text, nullable=True)
    workout_date = Column(Date, nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关系
    user = relationship("User", back_populates="workouts")

class NutritionLog(Base):
    """营养记录模型"""
    __tablename__ = "nutrition_logs"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    food_name = Column(String(100), nullable=False)
    quantity = Column(Float, nullable=False)  # 数量
    unit = Column(String(20), nullable=False)  # 单位(g, ml, 个等)
    calories = Column(Float, nullable=False)
    protein = Column(Float, nullable=True)
    carbs = Column(Float, nullable=True)
    fat = Column(Float, nullable=True)
    fiber = Column(Float, nullable=True)
    meal_type = Column(String(20), nullable=False)  # 早餐、午餐、晚餐、加餐
    log_date = Column(Date, nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关系
    user = relationship("User", back_populates="nutrition_logs")

class HealthRecord(Base):
    """健康记录模型"""
    __tablename__ = "health_records"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    record_type = Column(String(50), nullable=False, index=True)  # 心率、血压、睡眠、体重等
    value = Column(Float, nullable=False)
    unit = Column(String(20), nullable=True)
    notes = Column(Text, nullable=True)
    record_date = Column(Date, nullable=False, index=True)
    record_time = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关系
    user = relationship("User", back_populates="health_records")

class TrainingPlan(Base):
    """训练计划模型"""
    __tablename__ = "training_plans"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    plan_name = Column(String(100), nullable=False)
    plan_type = Column(String(50), nullable=False)  # 减脂、增肌、塑形、耐力
    difficulty_level = Column(String(20), nullable=False)  # 初级、中级、高级
    duration_weeks = Column(Integer, nullable=False)
    description = Column(Text, nullable=True)
    exercises = Column(JSON, nullable=False)  # 存储训练动作和组数
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # 关系
    user = relationship("User", back_populates="training_plans")

class Exercise(Base):
    """运动动作模型"""
    __tablename__ = "exercises"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(100), nullable=False, index=True)
    category = Column(String(50), nullable=False, index=True)  # 力量、有氧、柔韧性
    muscle_groups = Column(JSON, nullable=True)  # 目标肌群
    equipment = Column(String(100), nullable=True)  # 所需器械
    difficulty = Column(String(20), nullable=False)  # 初级、中级、高级
    instructions = Column(Text, nullable=True)  # 动作说明
    video_url = Column(String(500), nullable=True)  # 视频链接
    image_url = Column(String(500), nullable=True)  # 图片链接
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
class Challenge(Base):
    """挑战赛模型"""
    __tablename__ = "challenges"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    challenge_type = Column(String(50), nullable=False)  # 减脂、增肌、耐力、习惯养成
    duration_days = Column(Integer, nullable=False)
    target_value = Column(Float, nullable=True)  # 目标值
    target_unit = Column(String(20), nullable=True)  # 目标单位
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class ChallengeParticipant(Base):
    """挑战参与者模型"""
    __tablename__ = "challenge_participants"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    challenge_id = Column(UUID(as_uuid=True), ForeignKey("challenges.id"), nullable=False, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    current_progress = Column(Float, default=0)
    is_completed = Column(Boolean, default=False)
    joined_at = Column(DateTime(timezone=True), server_default=func.now())
    completed_at = Column(DateTime(timezone=True), nullable=True)

class Follow(Base):
    """关注关系模型"""
    __tablename__ = "follows"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    follower_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    following_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关系
    follower = relationship("User", foreign_keys=[follower_id], back_populates="following")
    following = relationship("User", foreign_keys=[following_id], back_populates="followers")

class Like(Base):
    """点赞模型"""
    __tablename__ = "likes"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    checkin_id = Column(UUID(as_uuid=True), ForeignKey("checkins.id"), nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关系
    user = relationship("User", back_populates="likes")
    checkin = relationship("Checkin", back_populates="likes")

class Comment(Base):
    """评论模型"""
    __tablename__ = "comments"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    checkin_id = Column(UUID(as_uuid=True), ForeignKey("checkins.id"), nullable=False, index=True)
    content = Column(Text, nullable=False)
    parent_id = Column(UUID(as_uuid=True), ForeignKey("comments.id"), nullable=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # 关系
    user = relationship("User", back_populates="comments")
    checkin = relationship("Checkin", back_populates="comments")
    parent = relationship("Comment", remote_side=[id], backref="replies")
