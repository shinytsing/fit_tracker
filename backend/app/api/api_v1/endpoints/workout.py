"""
FitTracker Backend - 健身中心API路由
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime

from app.core.database import get_db
from app.models import TrainingPlan, Exercise, WorkoutRecord
from app.schemas.workout import (
    TrainingPlanCreate,
    TrainingPlanUpdate,
    TrainingPlanResponse,
    ExerciseResponse,
    WorkoutRecordCreate,
    WorkoutRecordResponse,
    AIPlanRequest,
    AIPlanResponse,
)
from app.services.workout_service import WorkoutService
from app.services.ai_service import AIService

router = APIRouter()

@router.get("/plans", response_model=List[TrainingPlanResponse])
async def get_workout_plans(
    user_id: str,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """获取用户的训练计划列表"""
    try:
        service = WorkoutService(db)
        plans = service.get_user_plans(user_id, skip=skip, limit=limit)
        return plans
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取训练计划失败: {str(e)}"
        )

@router.post("/plans", response_model=TrainingPlanResponse)
async def create_workout_plan(
    plan_data: TrainingPlanCreate,
    user_id: str,
    db: Session = Depends(get_db)
):
    """创建新的训练计划"""
    try:
        service = WorkoutService(db)
        plan = service.create_plan(user_id, plan_data)
        return plan
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"创建训练计划失败: {str(e)}"
        )

@router.get("/plans/{plan_id}", response_model=TrainingPlanResponse)
async def get_workout_plan(
    plan_id: str,
    user_id: str,
    db: Session = Depends(get_db)
):
    """获取特定训练计划详情"""
    try:
        service = WorkoutService(db)
        plan = service.get_plan_by_id(plan_id, user_id)
        if not plan:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="训练计划不存在"
            )
        return plan
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取训练计划失败: {str(e)}"
        )

@router.put("/plans/{plan_id}", response_model=TrainingPlanResponse)
async def update_workout_plan(
    plan_id: str,
    plan_data: TrainingPlanUpdate,
    user_id: str,
    db: Session = Depends(get_db)
):
    """更新训练计划"""
    try:
        service = WorkoutService(db)
        plan = service.update_plan(plan_id, user_id, plan_data)
        if not plan:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="训练计划不存在"
            )
        return plan
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"更新训练计划失败: {str(e)}"
        )

@router.delete("/plans/{plan_id}")
async def delete_workout_plan(
    plan_id: str,
    user_id: str,
    db: Session = Depends(get_db)
):
    """删除训练计划"""
    try:
        service = WorkoutService(db)
        success = service.delete_plan(plan_id, user_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="训练计划不存在"
            )
        return {"message": "训练计划删除成功"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"删除训练计划失败: {str(e)}"
        )

@router.get("/exercises", response_model=List[ExerciseResponse])
async def get_exercises(
    category: Optional[str] = None,
    difficulty: Optional[str] = None,
    equipment: Optional[str] = None,
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db)
):
    """获取运动动作列表"""
    try:
        service = WorkoutService(db)
        exercises = service.get_exercises(
            category=category,
            difficulty=difficulty,
            equipment=equipment,
            skip=skip,
            limit=limit
        )
        return exercises
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取运动动作失败: {str(e)}"
        )

@router.get("/exercises/{exercise_id}", response_model=ExerciseResponse)
async def get_exercise(
    exercise_id: str,
    db: Session = Depends(get_db)
):
    """获取特定运动动作详情"""
    try:
        service = WorkoutService(db)
        exercise = service.get_exercise_by_id(exercise_id)
        if not exercise:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="运动动作不存在"
            )
        return exercise
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取运动动作失败: {str(e)}"
        )

@router.post("/records", response_model=WorkoutRecordResponse)
async def create_workout_record(
    record_data: WorkoutRecordCreate,
    user_id: str,
    db: Session = Depends(get_db)
):
    """创建训练记录"""
    try:
        service = WorkoutService(db)
        record = service.create_record(user_id, record_data)
        return record
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"创建训练记录失败: {str(e)}"
        )

@router.get("/records", response_model=List[WorkoutRecordResponse])
async def get_workout_records(
    user_id: str,
    plan_id: Optional[str] = None,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db)
):
    """获取训练记录列表"""
    try:
        service = WorkoutService(db)
        records = service.get_user_records(
            user_id,
            plan_id=plan_id,
            start_date=start_date,
            end_date=end_date,
            skip=skip,
            limit=limit
        )
        return records
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取训练记录失败: {str(e)}"
        )

@router.post("/ai/generate-plan", response_model=AIPlanResponse)
async def generate_ai_plan(
    request: AIPlanRequest,
    user_id: str,
    db: Session = Depends(get_db)
):
    """生成AI训练计划"""
    try:
        ai_service = AIService()
        workout_service = WorkoutService(db)
        
        # 调用AI服务生成计划
        ai_plan = await ai_service.generate_workout_plan(
            goal=request.goal,
            difficulty=request.difficulty,
            duration=request.duration,
            available_equipment=request.available_equipment,
            user_preferences=request.user_preferences
        )
        
        # 保存到数据库
        plan_data = TrainingPlanCreate(
            name=ai_plan.name,
            plan_type=ai_plan.type,
            difficulty_level=ai_plan.difficulty,
            duration_weeks=ai_plan.duration,
            description=ai_plan.description,
            exercises=ai_plan.exercises
        )
        
        plan = workout_service.create_plan(user_id, plan_data)
        
        return AIPlanResponse(
            plan=plan,
            ai_suggestions=ai_plan.suggestions,
            confidence_score=ai_plan.confidence_score
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"AI计划生成失败: {str(e)}"
        )

@router.get("/progress/{user_id}")
async def get_workout_progress(
    user_id: str,
    period: str = "week",  # week, month, year
    db: Session = Depends(get_db)
):
    """获取用户训练进度统计"""
    try:
        service = WorkoutService(db)
        progress = service.get_user_progress(user_id, period)
        return progress
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取训练进度失败: {str(e)}"
        )

@router.post("/exercises/{exercise_id}/feedback")
async def submit_exercise_feedback(
    exercise_id: str,
    feedback_data: dict,
    user_id: str,
    db: Session = Depends(get_db)
):
    """提交动作反馈（用于AI实时纠正）"""
    try:
        ai_service = AIService()
        workout_service = WorkoutService(db)
        
        # 获取动作信息
        exercise = workout_service.get_exercise_by_id(exercise_id)
        if not exercise:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="运动动作不存在"
            )
        
        # 调用AI分析反馈
        ai_feedback = await ai_service.analyze_exercise_feedback(
            exercise=exercise,
            user_feedback=feedback_data,
            user_id=user_id
        )
        
        return {
            "feedback": ai_feedback.feedback,
            "suggestions": ai_feedback.suggestions,
            "correctness_score": ai_feedback.correctness_score,
            "improvement_tips": ai_feedback.improvement_tips
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"动作反馈分析失败: {str(e)}"
        )
