"""
FitTracker Backend - 发布API路由
"""

from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime

from app.core.database import get_db
from app.models import Post, User, Draft
from app.schemas.publish import (
    PostCreate,
    PostUpdate,
    PostResponse,
    DraftCreate,
    DraftResponse,
    QuickCheckinRequest,
    QuickCheckinResponse,
)
from app.services.publish_service import PublishService

router = APIRouter()

@router.post("/posts", response_model=PostResponse)
async def create_post(
    post_data: PostCreate,
    user_id: str,
    db: Session = Depends(get_db)
):
    """发布动态"""
    try:
        service = PublishService(db)
        post = service.create_post(user_id, post_data)
        return post
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"发布动态失败: {str(e)}"
        )

@router.post("/posts/upload-image")
async def upload_post_image(
    file: UploadFile = File(...),
    user_id: str = None,
    db: Session = Depends(get_db)
):
    """上传动态图片"""
    try:
        service = PublishService(db)
        image_url = service.upload_image(file, user_id)
        return {"image_url": image_url}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"上传图片失败: {str(e)}"
        )

@router.post("/posts/upload-video")
async def upload_post_video(
    file: UploadFile = File(...),
    user_id: str = None,
    db: Session = Depends(get_db)
):
    """上传动态视频"""
    try:
        service = PublishService(db)
        video_url = service.upload_video(file, user_id)
        return {"video_url": video_url}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"上传视频失败: {str(e)}"
        )

@router.post("/quick-checkin", response_model=QuickCheckinResponse)
async def quick_checkin(
    checkin_data: QuickCheckinRequest,
    user_id: str,
    db: Session = Depends(get_db)
):
    """快速打卡"""
    try:
        service = PublishService(db)
        result = service.quick_checkin(user_id, checkin_data)
        return result
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"快速打卡失败: {str(e)}"
        )

@router.get("/drafts", response_model=List[DraftResponse])
async def get_drafts(
    user_id: str,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """获取草稿列表"""
    try:
        service = PublishService(db)
        drafts = service.get_user_drafts(user_id, skip=skip, limit=limit)
        return drafts
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取草稿失败: {str(e)}"
        )

@router.post("/drafts", response_model=DraftResponse)
async def save_draft(
    draft_data: DraftCreate,
    user_id: str,
    db: Session = Depends(get_db)
):
    """保存草稿"""
    try:
        service = PublishService(db)
        draft = service.save_draft(user_id, draft_data)
        return draft
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"保存草稿失败: {str(e)}"
        )

@router.put("/drafts/{draft_id}", response_model=DraftResponse)
async def update_draft(
    draft_id: str,
    draft_data: DraftCreate,
    user_id: str,
    db: Session = Depends(get_db)
):
    """更新草稿"""
    try:
        service = PublishService(db)
        draft = service.update_draft(draft_id, user_id, draft_data)
        return draft
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"更新草稿失败: {str(e)}"
        )

@router.delete("/drafts/{draft_id}")
async def delete_draft(
    draft_id: str,
    user_id: str,
    db: Session = Depends(get_db)
):
    """删除草稿"""
    try:
        service = PublishService(db)
        service.delete_draft(draft_id, user_id)
        return {"message": "草稿已删除"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"删除草稿失败: {str(e)}"
        )

@router.post("/drafts/{draft_id}/publish", response_model=PostResponse)
async def publish_draft(
    draft_id: str,
    user_id: str,
    db: Session = Depends(get_db)
):
    """发布草稿"""
    try:
        service = PublishService(db)
        post = service.publish_draft(draft_id, user_id)
        return post
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"发布草稿失败: {str(e)}"
        )

@router.post("/mood-share", response_model=PostResponse)
async def share_mood(
    mood_data: PostCreate,
    user_id: str,
    db: Session = Depends(get_db)
):
    """分享心情"""
    try:
        service = PublishService(db)
        # 设置心情分享类型
        mood_data.type = "mood"
        post = service.create_post(user_id, mood_data)
        return post
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"分享心情失败: {str(e)}"
        )

@router.post("/nutrition-record", response_model=PostResponse)
async def record_nutrition(
    nutrition_data: PostCreate,
    user_id: str,
    db: Session = Depends(get_db)
):
    """记录饮食"""
    try:
        service = PublishService(db)
        # 设置饮食记录类型
        nutrition_data.type = "nutrition"
        post = service.create_post(user_id, nutrition_data)
        return post
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"记录饮食失败: {str(e)}"
        )

@router.post("/training-data-share", response_model=PostResponse)
async def share_training_data(
    training_data: PostCreate,
    user_id: str,
    db: Session = Depends(get_db)
):
    """分享训练数据"""
    try:
        service = PublishService(db)
        # 设置训练数据分享类型
        training_data.type = "training_data"
        post = service.create_post(user_id, training_data)
        return post
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"分享训练数据失败: {str(e)}"
        )

@router.get("/publish-stats")
async def get_publish_stats(
    user_id: str,
    db: Session = Depends(get_db)
):
    """获取发布统计"""
    try:
        service = PublishService(db)
        stats = service.get_publish_stats(user_id)
        return stats
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取发布统计失败: {str(e)}"
        )
