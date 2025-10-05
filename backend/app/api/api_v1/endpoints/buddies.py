"""
FitTracker Backend - 健身搭子API路由
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime

from app.core.database import get_db
from app.models import User, WorkoutBuddy, BuddyRequest
from app.schemas.buddies import (
    BuddyRecommendationResponse,
    BuddyRequestCreate,
    BuddyRequestResponse,
    BuddyRequestUpdate,
    BuddyResponse,
    BuddyMatchResponse,
)
from app.services.buddy_service import BuddyService

router = APIRouter()

@router.get("/recommendations", response_model=List[BuddyRecommendationResponse])
async def get_buddy_recommendations(
    user_id: str,
    skip: int = 0,
    limit: int = 10,
    db: Session = Depends(get_db)
):
    """获取搭子推荐"""
    try:
        service = BuddyService(db)
        recommendations = service.get_buddy_recommendations(
            user_id=user_id,
            skip=skip,
            limit=limit
        )
        return recommendations
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取搭子推荐失败: {str(e)}"
        )

@router.get("/nearby", response_model=List[BuddyRecommendationResponse])
async def get_nearby_buddies(
    user_id: str,
    latitude: Optional[float] = None,
    longitude: Optional[float] = None,
    radius: float = 5.0,  # 公里
    skip: int = 0,
    limit: int = 10,
    db: Session = Depends(get_db)
):
    """获取附近搭子"""
    try:
        service = BuddyService(db)
        nearby_buddies = service.get_nearby_buddies(
            user_id=user_id,
            latitude=latitude,
            longitude=longitude,
            radius=radius,
            skip=skip,
            limit=limit
        )
        return nearby_buddies
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取附近搭子失败: {str(e)}"
        )

@router.get("/similar", response_model=List[BuddyRecommendationResponse])
async def get_similar_buddies(
    user_id: str,
    skip: int = 0,
    limit: int = 10,
    db: Session = Depends(get_db)
):
    """获取同好搭子"""
    try:
        service = BuddyService(db)
        similar_buddies = service.get_similar_buddies(
            user_id=user_id,
            skip=skip,
            limit=limit
        )
        return similar_buddies
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取同好搭子失败: {str(e)}"
        )

@router.post("/request", response_model=BuddyRequestResponse)
async def create_buddy_request(
    request_data: BuddyRequestCreate,
    user_id: str,
    db: Session = Depends(get_db)
):
    """创建搭子申请"""
    try:
        service = BuddyService(db)
        request = service.create_buddy_request(user_id, request_data)
        return request
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"创建搭子申请失败: {str(e)}"
        )

@router.get("/requests", response_model=List[BuddyRequestResponse])
async def get_buddy_requests(
    user_id: str,
    request_type: str = "received",  # received, sent
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """获取搭子申请列表"""
    try:
        service = BuddyService(db)
        requests = service.get_buddy_requests(
            user_id=user_id,
            request_type=request_type,
            skip=skip,
            limit=limit
        )
        return requests
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取搭子申请失败: {str(e)}"
        )

@router.put("/requests/{request_id}/accept", response_model=BuddyResponse)
async def accept_buddy_request(
    request_id: str,
    user_id: str,
    response_data: BuddyRequestUpdate,
    db: Session = Depends(get_db)
):
    """接受搭子申请"""
    try:
        service = BuddyService(db)
        buddy = service.accept_buddy_request(request_id, user_id, response_data)
        return buddy
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"接受搭子申请失败: {str(e)}"
        )

@router.put("/requests/{request_id}/reject")
async def reject_buddy_request(
    request_id: str,
    user_id: str,
    response_data: BuddyRequestUpdate,
    db: Session = Depends(get_db)
):
    """拒绝搭子申请"""
    try:
        service = BuddyService(db)
        success = service.reject_buddy_request(request_id, user_id, response_data)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="搭子申请不存在"
            )
        return {"message": "搭子申请已拒绝"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"拒绝搭子申请失败: {str(e)}"
        )

@router.get("/", response_model=List[BuddyResponse])
async def get_buddies(
    user_id: str,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """获取搭子列表"""
    try:
        service = BuddyService(db)
        buddies = service.get_user_buddies(
            user_id=user_id,
            skip=skip,
            limit=limit
        )
        return buddies
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取搭子列表失败: {str(e)}"
        )

@router.delete("/{buddy_id}")
async def remove_buddy(
    buddy_id: str,
    user_id: str,
    db: Session = Depends(get_db)
):
    """删除搭子关系"""
    try:
        service = BuddyService(db)
        success = service.remove_buddy(buddy_id, user_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="搭子关系不存在"
            )
        return {"message": "搭子关系已删除"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"删除搭子关系失败: {str(e)}"
        )

@router.get("/{buddy_id}/match", response_model=BuddyMatchResponse)
async def get_buddy_match_info(
    buddy_id: str,
    user_id: str,
    db: Session = Depends(get_db)
):
    """获取搭子匹配信息"""
    try:
        service = BuddyService(db)
        match_info = service.get_buddy_match_info(buddy_id, user_id)
        if not match_info:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="搭子不存在"
            )
        return match_info
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取搭子匹配信息失败: {str(e)}"
        )

@router.post("/search")
async def search_buddies(
    user_id: str,
    search_params: dict,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """搜索搭子"""
    try:
        service = BuddyService(db)
        results = service.search_buddies(
            user_id=user_id,
            search_params=search_params,
            skip=skip,
            limit=limit
        )
        return results
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"搜索搭子失败: {str(e)}"
        )

@router.get("/stats/{user_id}")
async def get_buddy_stats(
    user_id: str,
    db: Session = Depends(get_db)
):
    """获取搭子统计信息"""
    try:
        service = BuddyService(db)
        stats = service.get_buddy_stats(user_id)
        return stats
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取搭子统计失败: {str(e)}"
        )
