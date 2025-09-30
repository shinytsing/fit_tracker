"""
FitTracker Backend - BMI计算器Pydantic模式
"""

from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum

class Gender(str, Enum):
    """性别"""
    MALE = "男"
    FEMALE = "女"

class BMICategory(str, Enum):
    """BMI分类"""
    UNDERWEIGHT = "偏瘦"
    NORMAL = "正常"
    OVERWEIGHT = "偏胖"
    OBESE = "肥胖"

class BMICalculationRequest(BaseModel):
    """BMI计算请求"""
    height: float = Field(..., ge=50, le=300, description="身高(cm)")
    weight: float = Field(..., ge=20, le=500, description="体重(kg)")
    age: int = Field(..., ge=1, le=150, description="年龄")
    gender: Gender = Field(..., description="性别")

class BMICalculationResponse(BaseModel):
    """BMI计算响应"""
    bmi: float = Field(..., description="BMI值")
    category: BMICategory = Field(..., description="BMI分类")
    health_status: str = Field(..., description="健康状态")
    advice: List[str] = Field(..., description="健康建议")
    risk_factors: List[str] = Field(default_factory=list, description="风险因素")
    recommendations: List[str] = Field(default_factory=list, description="推荐行动")

class BMIRecordCreate(BaseModel):
    """创建BMI记录"""
    height: float = Field(..., ge=50, le=300)
    weight: float = Field(..., ge=20, le=500)
    bmi: float = Field(..., ge=10, le=100)
    category: BMICategory
    age: int = Field(..., ge=1, le=150)
    gender: Gender
    notes: Optional[str] = Field(None, max_length=500)

class BMIRecordUpdate(BaseModel):
    """更新BMI记录"""
    height: Optional[float] = Field(None, ge=50, le=300)
    weight: Optional[float] = Field(None, ge=20, le=500)
    bmi: Optional[float] = Field(None, ge=10, le=100)
    category: Optional[BMICategory] = None
    age: Optional[int] = Field(None, ge=1, le=150)
    gender: Optional[Gender] = None
    notes: Optional[str] = Field(None, max_length=500)

class BMIRecordResponse(BaseModel):
    """BMI记录响应"""
    id: str
    user_id: str
    height: float
    weight: float
    bmi: float
    category: BMICategory
    age: int
    gender: Gender
    notes: Optional[str]
    recorded_at: datetime

    class Config:
        from_attributes = True

class BMIStatsResponse(BaseModel):
    """BMI统计响应"""
    period: str
    total_records: int
    average_bmi: float
    current_bmi: float
    bmi_change: float
    category_distribution: Dict[str, int]
    trend_direction: str  # "up", "down", "stable"
    health_score: float = Field(..., ge=0.0, le=100.0)
    recommendations: List[str]

class BMITrendPoint(BaseModel):
    """BMI趋势点"""
    date: datetime
    bmi: float
    weight: float
    category: BMICategory

class BMITrendResponse(BaseModel):
    """BMI趋势响应"""
    user_id: str
    period_days: int
    trend_points: List[BMITrendPoint]
    trend_direction: str
    average_change_per_week: float
    prediction: Optional[Dict[str, Any]] = None

class HealthAdviceResponse(BaseModel):
    """健康建议响应"""
    bmi: float
    category: BMICategory
    general_advice: str
    specific_recommendations: List[str]
    dietary_suggestions: List[str]
    exercise_recommendations: List[str]
    lifestyle_tips: List[str]
    warning_signs: List[str]
    follow_up_schedule: str

class HealthGoalCreate(BaseModel):
    """创建健康目标"""
    goal_type: str = Field(..., description="目标类型: weight_loss, weight_gain, maintain")
    target_bmi: Optional[float] = Field(None, ge=15, le=50)
    target_weight: Optional[float] = Field(None, ge=30, le=200)
    target_date: Optional[datetime] = None
    description: Optional[str] = Field(None, max_length=500)

class HealthGoalResponse(BaseModel):
    """健康目标响应"""
    id: str
    user_id: str
    goal_type: str
    target_bmi: Optional[float]
    target_weight: Optional[float]
    current_bmi: float
    current_weight: float
    progress_percentage: float
    target_date: Optional[datetime]
    description: Optional[str]
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class BMIAnalysisResponse(BaseModel):
    """BMI分析响应"""
    bmi: float
    category: BMICategory
    health_risk: str  # "low", "moderate", "high"
    body_fat_estimate: float
    ideal_weight_range: Dict[str, float]
    weight_to_lose_gain: Optional[float]
    time_to_goal: Optional[str]
    personalized_plan: Dict[str, Any]
