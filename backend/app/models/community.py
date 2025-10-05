"""
FitTracker Backend - 社区相关数据模型
"""

from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, ForeignKey, JSON, Float
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class Post(Base):
    """社区动态表"""
    __tablename__ = "posts"

    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    deleted_at = Column(DateTime(timezone=True))
    
    # 用户关系
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    
    # 内容信息
    content = Column(Text, nullable=False)
    images = Column(JSON, default=list)  # 图片URL列表
    video_url = Column(String)  # 视频URL
    
    # 动态类型
    post_type = Column(String, default="general")  # general, workout, nutrition, education
    is_public = Column(Boolean, default=True)
    
    # 社区扩展
    tags = Column(JSON, default=list)  # 标签列表
    location = Column(String)  # 位置信息
    workout_data = Column(JSON)  # 训练数据
    
    # 状态管理
    is_featured = Column(Boolean, default=False)  # 是否精选
    is_pinned = Column(Boolean, default=False)  # 是否置顶
    
    # 统计信息
    view_count = Column(Integer, default=0)
    share_count = Column(Integer, default=0)
    likes_count = Column(Integer, default=0)
    comments_count = Column(Integer, default=0)
    
    # 约束
    __table_args__ = (
        {"extend_existing": True}
    )

class Comment(Base):
    """评论表"""
    __tablename__ = "comments"

    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    deleted_at = Column(DateTime(timezone=True))
    
    # 关系
    post_id = Column(Integer, ForeignKey("posts.id"), nullable=False)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    parent_id = Column(Integer, ForeignKey("comments.id"))  # 父评论ID，支持回复
    
    # 内容
    content = Column(Text, nullable=False)
    
    # 统计
    likes_count = Column(Integer, default=0)
    
    # 约束
    __table_args__ = (
        {"extend_existing": True}
    )

class Like(Base):
    """点赞表"""
    __tablename__ = "likes"

    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关系
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    post_id = Column(Integer, ForeignKey("posts.id"), nullable=True)
    comment_id = Column(Integer, ForeignKey("comments.id"), nullable=True)
    
    # 约束：只能点赞动态或评论中的一个
    __table_args__ = (
        {"extend_existing": True}
    )

class Follow(Base):
    """关注关系表"""
    __tablename__ = "follows"

    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关系
    follower_id = Column(String, ForeignKey("users.id"), nullable=False)  # 关注者
    following_id = Column(String, ForeignKey("users.id"), nullable=False)  # 被关注者
    
    # 约束
    __table_args__ = (
        {"extend_existing": True}
    )

class Topic(Base):
    """话题表"""
    __tablename__ = "topics"

    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # 基本信息
    name = Column(String, nullable=False, unique=True)
    description = Column(Text)
    icon = Column(String)  # 话题图标
    
    # 统计
    posts_count = Column(Integer, default=0)
    followers_count = Column(Integer, default=0)
    
    # 状态
    is_active = Column(Boolean, default=True)
    
    # 约束
    __table_args__ = (
        {"extend_existing": True}
    )

class PostTopic(Base):
    """动态话题关联表"""
    __tablename__ = "post_topics"

    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关系
    post_id = Column(Integer, ForeignKey("posts.id"), nullable=False)
    topic_id = Column(Integer, ForeignKey("topics.id"), nullable=False)
    
    # 约束
    __table_args__ = (
        {"extend_existing": True}
    )

class Report(Base):
    """举报表"""
    __tablename__ = "reports"

    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关系
    reporter_id = Column(String, ForeignKey("users.id"), nullable=False)  # 举报人
    post_id = Column(Integer, ForeignKey("posts.id"), nullable=True)
    comment_id = Column(Integer, ForeignKey("comments.id"), nullable=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=True)  # 被举报用户
    
    # 举报信息
    reason = Column(String, nullable=False)  # 举报原因
    description = Column(Text)  # 详细描述
    
    # 状态
    status = Column(String, default="pending")  # pending, processed, rejected
    processed_at = Column(DateTime(timezone=True))
    processed_by = Column(String, ForeignKey("users.id"))
    
    # 约束
    __table_args__ = (
        {"extend_existing": True}
    )
