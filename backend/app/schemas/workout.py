"""
FitTracker Backend - 健身中心Pydantic模式
"""

from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum

class PlanType(str, Enum):
    """训练计划类型"""
    FAT_LOSS = "减脂"
    MUSCLE_GAIN = "增肌"
    STRENGTH = "力量"
    ENDURANCE = "耐力"
    FLEXIBILITY = "柔韧性"
    GENERAL = "综合"

class DifficultyLevel(str, Enum):
    """难度等级"""
    BEGINNER = "初级"
    INTERMEDIATE = "中级"
    ADVANCED = "高级"

class ExerciseCategory(str, Enum):
    """运动类别"""
    STRENGTH = "力量"
    CARDIO = "有氧"
    FLEXIBILITY = "柔韧性"
    BALANCE = "平衡"
    FUNCTIONAL = "功能性"

class ExerciseCreate(BaseModel):
    """创建运动动作"""
    name: str = Field(..., min_length=1, max_length=100)
    category: ExerciseCategory
    muscle_groups: List[str] = Field(..., min_items=1)
    equipment: Optional[str] = Field(None, max_length=100)
    difficulty: DifficultyLevel
    instructions: str = Field(..., min_length=1)
    video_url: Optional[str] = Field(None, max_length=500)
    image_url: Optional[str] = Field(None, max_length=500)

class ExerciseResponse(BaseModel):
    """运动动作响应"""
    id: str
    name: str
    category: ExerciseCategory
    muscle_groups: List[str]
    equipment: Optional[str]
    difficulty: DifficultyLevel
    instructions: str
    video_url: Optional[str]
    image_url: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True

class TrainingPlanCreate(BaseModel):
    """创建训练计划"""
    name: str = Field(..., min_length=1, max_length=100)
    plan_type: PlanType
    difficulty_level: DifficultyLevel
    duration_weeks: int = Field(..., ge=1, le=52)
    description: Optional[str] = Field(None, max_length=500)
    exercises: List[Dict[str, Any]] = Field(..., min_items=1)

class TrainingPlanUpdate(BaseModel):
    """更新训练计划"""
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    plan_type: Optional[PlanType] = None
    difficulty_level: Optional[DifficultyLevel] = None
    duration_weeks: Optional[int] = Field(None, ge=1, le=52)
    description: Optional[str] = Field(None, max_length=500)
    exercises: Optional[List[Dict[str, Any]]] = None
    is_active: Optional[bool] = None

class TrainingPlanResponse(BaseModel):
    """训练计划响应"""
    id: str
    user_id: str
    name: str
    plan_type: PlanType
    difficulty_level: DifficultyLevel
    duration_weeks: int
    description: Optional[str]
    exercises: List[Dict[str, Any]]
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class WorkoutRecordCreate(BaseModel):
    """创建训练记录"""
    plan_id: str
    exercise_id: str
    sets: int = Field(..., ge=1)
    reps: int = Field(..., ge=1)
    weight: Optional[float] = Field(None, ge=0)
    duration: Optional[int] = Field(None, ge=0)  # 秒
    notes: Optional[str] = Field(None, max_length=500)

class WorkoutRecordResponse(BaseModel):
    """训练记录响应"""
    id: str
    user_id: str
    plan_id: str
    exercise_id: str
    sets: int
    reps: int
    weight: Optional[float]
    duration: Optional[int]
    notes: Optional[str]
    completed_at: datetime

    class Config:
        from_attributes = True

class AIPlanRequest(BaseModel):
    """AI训练计划请求"""
    goal: str = Field(..., min_length=1, max_length=100)
    difficulty: DifficultyLevel
    duration: int = Field(..., ge=1, le=12)  # 周数
    available_equipment: List[str] = Field(default_factory=list)
    user_preferences: Optional[Dict[str, Any]] = None
    fitness_level: Optional[str] = None
    target_muscle_groups: Optional[List[str]] = None
    time_per_session: Optional[int] = Field(None, ge=15, le=180)  # 分钟

class AIPlanResponse(BaseModel):
    """AI训练计划响应"""
    plan: TrainingPlanResponse
    ai_suggestions: List[str]
    confidence_score: float = Field(..., ge=0.0, le=1.0)

class ExerciseFeedback(BaseModel):
    """动作反馈"""
    exercise_id: str
    user_feedback: Dict[str, Any]
    form_score: Optional[float] = Field(None, ge=0.0, le=10.0)
    difficulty_rating: Optional[int] = Field(None, ge=1, le=5)
    completion_percentage: Optional[float] = Field(None, ge=0.0, le=100.0)

class AIFeedbackResponse(BaseModel):
    """AI反馈响应"""
    feedback: str
    suggestions: List[str]
    correctness_score: float = Field(..., ge=0.0, le=1.0)
    improvement_tips: List[str]

class WorkoutProgress(BaseModel):
    """训练进度"""
    period: str
    total_workouts: int
    total_duration: int  # 分钟
    calories_burned: int
    exercises_completed: int
    plans_completed: int
    average_session_duration: float
    consistency_score: float = Field(..., ge=0.0, le=1.0)
    improvement_areas: List[str]
    achievements: List[str]

class WorkoutStats(BaseModel):
    """训练统计"""
    total_workouts: int
    total_duration: int  # 分钟
    total_calories: int
    favorite_exercises: List[str]
    strongest_muscle_groups: List[str]
    weekly_average: float
    monthly_average: float
    longest_streak: int
    current_streak: int

class ExerciseRecommendation(BaseModel):
    """运动推荐"""
    exercise: ExerciseResponse
    reason: str
    difficulty_match: float = Field(..., ge=0.0, le=1.0)
    muscle_group_focus: List[str]
    estimated_duration: int  # 分钟
    equipment_needed: List[str]
