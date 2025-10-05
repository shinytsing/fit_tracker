"""
FitTracker Backend - 搭子相关Schema
"""

from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime

class BuddyRecommendationResponse(BaseModel):
    """搭子推荐响应"""
    user: Dict[str, Any] = Field(..., description="用户信息")
    match_score: int = Field(..., description="匹配度分数", ge=0, le=100)
    match_reasons: List[str] = Field(default=[], description="匹配原因")
    workout_preferences: Dict[str, Any] = Field(default={}, description="训练偏好")
    distance: Optional[float] = Field(None, description="距离(公里)")
    
    class Config:
        from_attributes = True

class BuddyRequestCreate(BaseModel):
    """创建搭子申请"""
    target_id: str = Field(..., description="目标用户ID")
    request_message: str = Field(..., description="申请消息")
    workout_preferences: Dict[str, Any] = Field(default={}, description="训练偏好")
    preferred_time: Optional[str] = Field(None, description="偏好训练时间")
    preferred_location: Optional[str] = Field(None, description="偏好训练地点")

class BuddyRequestUpdate(BaseModel):
    """更新搭子申请"""
    response_message: Optional[str] = Field(None, description="回复消息")
    reason: Optional[str] = Field(None, description="拒绝原因")

class BuddyRequestResponse(BaseModel):
    """搭子申请响应"""
    id: int = Field(..., description="申请ID")
    requester: Dict[str, Any] = Field(..., description="申请者信息")
    target: Dict[str, Any] = Field(..., description="目标用户信息")
    status: str = Field(..., description="申请状态")
    request_message: Optional[str] = Field(None, description="申请消息")
    response_message: Optional[str] = Field(None, description="回复消息")
    workout_preferences: Dict[str, Any] = Field(default={}, description="训练偏好")
    preferred_time: Optional[str] = Field(None, description="偏好训练时间")
    preferred_location: Optional[str] = Field(None, description="偏好训练地点")
    requested_at: datetime = Field(..., description="申请时间")
    responded_at: Optional[datetime] = Field(None, description="回复时间")
    
    class Config:
        from_attributes = True

class BuddyResponse(BaseModel):
    """搭子关系响应"""
    id: int = Field(..., description="关系ID")
    buddy: Dict[str, Any] = Field(..., description="搭子信息")
    status: str = Field(..., description="关系状态")
    match_score: int = Field(..., description="匹配度分数")
    match_reasons: List[str] = Field(default=[], description="匹配原因")
    workout_preferences: Dict[str, Any] = Field(default={}, description="训练偏好")
    total_workouts: int = Field(default=0, description="一起训练次数")
    rating: float = Field(default=0.0, description="搭子评分")
    last_interaction: Optional[datetime] = Field(None, description="最后互动时间")
    created_at: datetime = Field(..., description="建立关系时间")
    
    class Config:
        from_attributes = True

class BuddyMatchResponse(BaseModel):
    """搭子匹配信息响应"""
    user: Dict[str, Any] = Field(..., description="用户信息")
    match_score: int = Field(..., description="匹配度分数")
    match_reasons: List[str] = Field(default=[], description="匹配原因")
    workout_preferences: Dict[str, Any] = Field(default={}, description="训练偏好")
    compatibility: Dict[str, Any] = Field(default={}, description="兼容性分析")
    suggested_activities: List[str] = Field(default=[], description="建议活动")
    
    class Config:
        from_attributes = True

class BuddySearchParams(BaseModel):
    """搭子搜索参数"""
    age_range: Optional[List[int]] = Field(None, description="年龄范围")
    fitness_level: Optional[List[str]] = Field(None, description="健身水平")
    interests: Optional[List[str]] = Field(None, description="兴趣标签")
    location: Optional[Dict[str, float]] = Field(None, description="位置信息")
    radius: Optional[float] = Field(5.0, description="搜索半径(公里)")
    preferred_time: Optional[str] = Field(None, description="偏好时间")
    preferred_location: Optional[str] = Field(None, description="偏好地点")

class BuddyStatsResponse(BaseModel):
    """搭子统计响应"""
    total_buddies: int = Field(..., description="总搭子数")
    active_buddies: int = Field(..., description="活跃搭子数")
    total_requests_sent: int = Field(..., description="发送申请总数")
    total_requests_received: int = Field(..., description="收到申请总数")
    accepted_requests: int = Field(..., description="接受申请数")
    rejected_requests: int = Field(..., description="拒绝申请数")
    total_workouts: int = Field(..., description="总训练次数")
    average_rating: float = Field(..., description="平均评分")
    match_success_rate: float = Field(..., description="匹配成功率")
    
    class Config:
        from_attributes = True
