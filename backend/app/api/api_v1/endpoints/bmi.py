"""
FitTracker Backend - BMI计算器API路由
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime

from app.core.database import get_db
from app.models import BMIRecord, User
from app.schemas.bmi import (
    BMIRecordCreate,
    BMIRecordUpdate,
    BMIRecordResponse,
    BMICalculationRequest,
    BMICalculationResponse,
    BMIStatsResponse,
)
from app.services.bmi_service import BMIService

router = APIRouter()

@router.post("/calculate", response_model=BMICalculationResponse)
async def calculate_bmi(
    request: BMICalculationRequest,
    user_id: str,
    db: Session = Depends(get_db)
):
    """计算BMI"""
    try:
        service = BMIService(db)
        result = service.calculate_bmi(
            user_id=user_id,
            height=request.height,
            weight=request.weight,
            age=request.age,
            gender=request.gender
        )
        return result
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"BMI计算失败: {str(e)}"
        )

@router.post("/records", response_model=BMIRecordResponse)
async def create_bmi_record(
    record_data: BMIRecordCreate,
    user_id: str,
    db: Session = Depends(get_db)
):
    """创建BMI记录"""
    try:
        service = BMIService(db)
        record = service.create_record(user_id, record_data)
        return record
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"创建BMI记录失败: {str(e)}"
        )

@router.get("/records", response_model=List[BMIRecordResponse])
async def get_bmi_records(
    user_id: str,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """获取用户BMI记录列表"""
    try:
        service = BMIService(db)
        records = service.get_user_records(user_id, skip=skip, limit=limit)
        return records
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取BMI记录失败: {str(e)}"
        )

@router.get("/records/{record_id}", response_model=BMIRecordResponse)
async def get_bmi_record(
    record_id: str,
    user_id: str,
    db: Session = Depends(get_db)
):
    """获取特定BMI记录"""
    try:
        service = BMIService(db)
        record = service.get_record_by_id(record_id, user_id)
        if not record:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="BMI记录不存在"
            )
        return record
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取BMI记录失败: {str(e)}"
        )

@router.put("/records/{record_id}", response_model=BMIRecordResponse)
async def update_bmi_record(
    record_id: str,
    record_data: BMIRecordUpdate,
    user_id: str,
    db: Session = Depends(get_db)
):
    """更新BMI记录"""
    try:
        service = BMIService(db)
        record = service.update_record(record_id, user_id, record_data)
        if not record:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="BMI记录不存在"
            )
        return record
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"更新BMI记录失败: {str(e)}"
        )

@router.delete("/records/{record_id}")
async def delete_bmi_record(
    record_id: str,
    user_id: str,
    db: Session = Depends(get_db)
):
    """删除BMI记录"""
    try:
        service = BMIService(db)
        success = service.delete_record(record_id, user_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="BMI记录不存在"
            )
        return {"message": "BMI记录删除成功"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"删除BMI记录失败: {str(e)}"
        )

@router.get("/stats/{user_id}", response_model=BMIStatsResponse)
async def get_bmi_stats(
    user_id: str,
    period: str = "month",  # week, month, year
    db: Session = Depends(get_db)
):
    """获取用户BMI统计信息"""
    try:
        service = BMIService(db)
        stats = service.get_user_stats(user_id, period)
        return stats
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取BMI统计失败: {str(e)}"
        )

@router.get("/trend/{user_id}")
async def get_bmi_trend(
    user_id: str,
    days: int = 30,
    db: Session = Depends(get_db)
):
    """获取用户BMI趋势"""
    try:
        service = BMIService(db)
        trend = service.get_bmi_trend(user_id, days)
        return trend
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取BMI趋势失败: {str(e)}"
        )

@router.get("/advice/{user_id}")
async def get_health_advice(
    user_id: str,
    bmi: float,
    db: Session = Depends(get_db)
):
    """获取健康建议"""
    try:
        service = BMIService(db)
        advice = service.get_health_advice(user_id, bmi)
        return advice
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取健康建议失败: {str(e)}"
        )

@router.post("/goals/{user_id}")
async def set_health_goal(
    user_id: str,
    goal_data: dict,
    db: Session = Depends(get_db)
):
    """设定健康目标"""
    try:
        service = BMIService(db)
        goal = service.set_health_goal(user_id, goal_data)
        return goal
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"设定健康目标失败: {str(e)}"
        )

@router.get("/goals/{user_id}")
async def get_health_goals(
    user_id: str,
    db: Session = Depends(get_db)
):
    """获取健康目标"""
    try:
        service = BMIService(db)
        goals = service.get_health_goals(user_id)
        return goals
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取健康目标失败: {str(e)}"
        )
