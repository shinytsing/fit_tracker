"""
FitTracker Backend - 健身中心服务层
"""

from sqlalchemy.orm import Session
from sqlalchemy import and_, desc, func
from typing import List, Optional, Dict, Any
import uuid
from datetime import datetime, timedelta

from app.models import TrainingPlan, Exercise, Workout, User
from app.schemas.workout import (
    TrainingPlanCreate,
    TrainingPlanUpdate,
    TrainingPlanResponse,
    ExerciseResponse,
    WorkoutRecordCreate,
    WorkoutRecordResponse,
    WorkoutProgress,
    WorkoutStats,
)

class WorkoutService:
    """健身中心服务类"""
    
    def __init__(self, db: Session):
        self.db = db

    def get_user_plans(self, user_id: str, skip: int = 0, limit: int = 20) -> List[TrainingPlanResponse]:
        """获取用户的训练计划列表"""
        plans = self.db.query(TrainingPlan).filter(
            and_(
                TrainingPlan.user_id == user_id,
                TrainingPlan.is_active == True
            )
        ).offset(skip).limit(limit).all()
        
        return [self._plan_to_response(plan) for plan in plans]

    def create_plan(self, user_id: str, plan_data: TrainingPlanCreate) -> TrainingPlanResponse:
        """创建训练计划"""
        plan = TrainingPlan(
            id=str(uuid.uuid4()),
            user_id=user_id,
            name=plan_data.name,
            plan_type=plan_data.plan_type.value,
            difficulty_level=plan_data.difficulty_level.value,
            duration_weeks=plan_data.duration_weeks,
            description=plan_data.description,
            exercises=plan_data.exercises,
            is_active=True,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
        self.db.add(plan)
        self.db.commit()
        self.db.refresh(plan)
        
        return self._plan_to_response(plan)

    def get_plan_by_id(self, plan_id: str, user_id: str) -> Optional[TrainingPlanResponse]:
        """根据ID获取训练计划"""
        plan = self.db.query(TrainingPlan).filter(
            and_(
                TrainingPlan.id == plan_id,
                TrainingPlan.user_id == user_id
            )
        ).first()
        
        return self._plan_to_response(plan) if plan else None

    def update_plan(self, plan_id: str, user_id: str, plan_data: TrainingPlanUpdate) -> Optional[TrainingPlanResponse]:
        """更新训练计划"""
        plan = self.db.query(TrainingPlan).filter(
            and_(
                TrainingPlan.id == plan_id,
                TrainingPlan.user_id == user_id
            )
        ).first()
        
        if not plan:
            return None
        
        # 更新字段
        if plan_data.name is not None:
            plan.name = plan_data.name
        if plan_data.plan_type is not None:
            plan.plan_type = plan_data.plan_type.value
        if plan_data.difficulty_level is not None:
            plan.difficulty_level = plan_data.difficulty_level.value
        if plan_data.duration_weeks is not None:
            plan.duration_weeks = plan_data.duration_weeks
        if plan_data.description is not None:
            plan.description = plan_data.description
        if plan_data.exercises is not None:
            plan.exercises = plan_data.exercises
        if plan_data.is_active is not None:
            plan.is_active = plan_data.is_active
        
        plan.updated_at = datetime.utcnow()
        
        self.db.commit()
        self.db.refresh(plan)
        
        return self._plan_to_response(plan)

    def delete_plan(self, plan_id: str, user_id: str) -> bool:
        """删除训练计划"""
        plan = self.db.query(TrainingPlan).filter(
            and_(
                TrainingPlan.id == plan_id,
                TrainingPlan.user_id == user_id
            )
        ).first()
        
        if not plan:
            return False
        
        self.db.delete(plan)
        self.db.commit()
        
        return True

    def get_exercises(self, category: Optional[str] = None, difficulty: Optional[str] = None, 
                     equipment: Optional[str] = None, skip: int = 0, limit: int = 50) -> List[ExerciseResponse]:
        """获取运动动作列表"""
        query = self.db.query(Exercise)
        
        if category:
            query = query.filter(Exercise.category == category)
        if difficulty:
            query = query.filter(Exercise.difficulty == difficulty)
        if equipment:
            query = query.filter(Exercise.equipment.contains(equipment))
        
        exercises = query.offset(skip).limit(limit).all()
        
        return [self._exercise_to_response(exercise) for exercise in exercises]

    def get_exercise_by_id(self, exercise_id: str) -> Optional[ExerciseResponse]:
        """根据ID获取运动动作"""
        exercise = self.db.query(Exercise).filter(Exercise.id == exercise_id).first()
        
        return self._exercise_to_response(exercise) if exercise else None

    def create_record(self, user_id: str, record_data: WorkoutRecordCreate) -> WorkoutRecordResponse:
        """创建训练记录"""
        record = WorkoutRecord(
            id=str(uuid.uuid4()),
            user_id=user_id,
            plan_id=record_data.plan_id,
            exercise_id=record_data.exercise_id,
            sets=record_data.sets,
            reps=record_data.reps,
            weight=record_data.weight,
            duration=record_data.duration,
            notes=record_data.notes,
            completed_at=datetime.utcnow()
        )
        
        self.db.add(record)
        self.db.commit()
        self.db.refresh(record)
        
        return self._record_to_response(record)

    def get_user_records(self, user_id: str, plan_id: Optional[str] = None,
                        start_date: Optional[str] = None, end_date: Optional[str] = None,
                        skip: int = 0, limit: int = 50) -> List[WorkoutRecordResponse]:
        """获取用户训练记录"""
        query = self.db.query(WorkoutRecord).filter(WorkoutRecord.user_id == user_id)
        
        if plan_id:
            query = query.filter(WorkoutRecord.plan_id == plan_id)
        if start_date:
            start_dt = datetime.fromisoformat(start_date)
            query = query.filter(WorkoutRecord.completed_at >= start_dt)
        if end_date:
            end_dt = datetime.fromisoformat(end_date)
            query = query.filter(WorkoutRecord.completed_at <= end_dt)
        
        records = query.order_by(desc(WorkoutRecord.completed_at)).offset(skip).limit(limit).all()
        
        return [self._record_to_response(record) for record in records]

    def get_user_progress(self, user_id: str, period: str = "week") -> WorkoutProgress:
        """获取用户训练进度"""
        now = datetime.utcnow()
        
        if period == "week":
            start_date = now - timedelta(days=7)
        elif period == "month":
            start_date = now - timedelta(days=30)
        elif period == "year":
            start_date = now - timedelta(days=365)
        else:
            start_date = now - timedelta(days=7)
        
        # 获取训练记录统计
        records_query = self.db.query(WorkoutRecord).filter(
            and_(
                WorkoutRecord.user_id == user_id,
                WorkoutRecord.completed_at >= start_date
            )
        )
        
        total_workouts = records_query.count()
        total_duration = records_query.with_entities(
            func.sum(WorkoutRecord.duration)
        ).scalar() or 0
        
        # 计算卡路里消耗（简单估算）
        calories_burned = int(total_duration * 0.1)  # 每分钟0.1卡路里
        
        # 获取完成的动作数量
        exercises_completed = records_query.with_entities(
            func.count(func.distinct(WorkoutRecord.exercise_id))
        ).scalar() or 0
        
        # 获取完成的计划数量
        plans_completed = records_query.with_entities(
            func.count(func.distinct(WorkoutRecord.plan_id))
        ).scalar() or 0
        
        # 计算平均训练时长
        average_session_duration = total_duration / max(total_workouts, 1)
        
        # 计算一致性分数（基于训练频率）
        expected_workouts = 7 if period == "week" else 30 if period == "month" else 365
        consistency_score = min(total_workouts / expected_workouts, 1.0)
        
        return WorkoutProgress(
            period=period,
            total_workouts=total_workouts,
            total_duration=total_duration,
            calories_burned=calories_burned,
            exercises_completed=exercises_completed,
            plans_completed=plans_completed,
            average_session_duration=average_session_duration,
            consistency_score=consistency_score,
            improvement_areas=["力量训练", "有氧运动"],
            achievements=["连续训练7天", "完成第一个训练计划"]
        )

    def get_user_stats(self, user_id: str) -> WorkoutStats:
        """获取用户训练统计"""
        # 总训练次数
        total_workouts = self.db.query(WorkoutRecord).filter(
            WorkoutRecord.user_id == user_id
        ).count()
        
        # 总训练时长
        total_duration = self.db.query(WorkoutRecord).filter(
            WorkoutRecord.user_id == user_id
        ).with_entities(func.sum(WorkoutRecord.duration)).scalar() or 0
        
        # 总卡路里消耗
        total_calories = int(total_duration * 0.1)
        
        # 最喜欢的运动（基于训练次数）
        favorite_exercises = self.db.query(
            Exercise.name,
            func.count(WorkoutRecord.id).label('count')
        ).join(WorkoutRecord).filter(
            WorkoutRecord.user_id == user_id
        ).group_by(Exercise.name).order_by(desc('count')).limit(5).all()
        
        favorite_exercise_names = [ex.name for ex in favorite_exercises]
        
        # 最强肌群（基于训练次数）
        strongest_muscle_groups = ["胸部", "腿部", "背部"]  # 简化实现
        
        # 周平均和月平均
        weekly_average = total_workouts / max((datetime.utcnow() - datetime(2024, 1, 1)).days / 7, 1)
        monthly_average = total_workouts / max((datetime.utcnow() - datetime(2024, 1, 1)).days / 30, 1)
        
        # 连续训练天数（简化实现）
        longest_streak = 15
        current_streak = 7
        
        return WorkoutStats(
            total_workouts=total_workouts,
            total_duration=total_duration,
            total_calories=total_calories,
            favorite_exercises=favorite_exercise_names,
            strongest_muscle_groups=strongest_muscle_groups,
            weekly_average=weekly_average,
            monthly_average=monthly_average,
            longest_streak=longest_streak,
            current_streak=current_streak
        )

    def _plan_to_response(self, plan: TrainingPlan) -> TrainingPlanResponse:
        """将训练计划模型转换为响应模型"""
        return TrainingPlanResponse(
            id=plan.id,
            user_id=plan.user_id,
            name=plan.name,
            plan_type=plan.plan_type,
            difficulty_level=plan.difficulty_level,
            duration_weeks=plan.duration_weeks,
            description=plan.description,
            exercises=plan.exercises,
            is_active=plan.is_active,
            created_at=plan.created_at,
            updated_at=plan.updated_at
        )

    def _exercise_to_response(self, exercise: Exercise) -> ExerciseResponse:
        """将运动动作模型转换为响应模型"""
        return ExerciseResponse(
            id=exercise.id,
            name=exercise.name,
            category=exercise.category,
            muscle_groups=exercise.muscle_groups,
            equipment=exercise.equipment,
            difficulty=exercise.difficulty,
            instructions=exercise.instructions,
            video_url=exercise.video_url,
            image_url=exercise.image_url,
            created_at=exercise.created_at
        )

    def _record_to_response(self, record: Workout) -> WorkoutRecordResponse:
        """将训练记录模型转换为响应模型"""
        return WorkoutRecordResponse(
            id=record.id,
            user_id=record.user_id,
            plan_id=record.plan_id,
            exercise_id=record.exercise_id,
            sets=record.sets,
            reps=record.reps,
            weight=record.weight,
            duration=record.duration,
            notes=record.notes,
            completed_at=record.completed_at
        )
