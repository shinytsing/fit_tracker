"""
FitTracker Backend - 社区动态API路由
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime

from app.core.database import get_db
from app.models import Post, User, Comment, Like
from app.schemas.community import (
    PostCreate,
    PostUpdate,
    PostResponse,
    CommentCreate,
    CommentResponse,
    LikeResponse,
    FeedResponse,
)
from app.services.community_service import CommunityService

router = APIRouter()

@router.get("/posts", response_model=List[PostResponse])
async def get_posts(
    user_id: str,
    feed_type: str = "recommend",  # recommend, following, trending
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """获取动态流"""
    try:
        service = CommunityService(db)
        posts = service.get_posts(
            user_id=user_id,
            feed_type=feed_type,
            skip=skip,
            limit=limit
        )
        return posts
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取动态失败: {str(e)}"
        )

@router.get("/trending", response_model=List[PostResponse])
async def get_trending_posts(
    user_id: str,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """获取热门动态流"""
    try:
        service = CommunityService(db)
        posts = service.get_trending_posts(
            user_id=user_id,
            skip=skip,
            limit=limit
        )
        return posts
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取热门动态失败: {str(e)}"
        )

@router.get("/coaches", response_model=List[dict])
async def get_recommended_coaches(
    user_id: str,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """获取推荐教练"""
    try:
        service = CommunityService(db)
        coaches = service.get_recommended_coaches(
            user_id=user_id,
            skip=skip,
            limit=limit
        )
        return coaches
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取推荐教练失败: {str(e)}"
        )

@router.get("/coaches/{coach_id}/posts", response_model=List[PostResponse])
async def get_coach_posts(
    coach_id: str,
    user_id: str,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """获取教练动态"""
    try:
        service = CommunityService(db)
        posts = service.get_coach_posts(
            coach_id=coach_id,
            user_id=user_id,
            skip=skip,
            limit=limit
        )
        return posts
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取教练动态失败: {str(e)}"
        )

@router.get("/training-shares", response_model=List[PostResponse])
async def get_training_shares(
    user_id: str,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """获取训练分享"""
    try:
        service = CommunityService(db)
        posts = service.get_training_shares(
            user_id=user_id,
            skip=skip,
            limit=limit
        )
        return posts
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取训练分享失败: {str(e)}"
        )

@router.get("/experience-articles", response_model=List[dict])
async def get_experience_articles(
    user_id: str,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """获取经验文章"""
    try:
        service = CommunityService(db)
        articles = service.get_experience_articles(
            user_id=user_id,
            skip=skip,
            limit=limit
        )
        return articles
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取经验文章失败: {str(e)}"
        )

@router.get("/online-courses", response_model=List[dict])
async def get_online_courses(
    user_id: str,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """获取在线课程"""
    try:
        service = CommunityService(db)
        courses = service.get_online_courses(
            user_id=user_id,
            skip=skip,
            limit=limit
        )
        return courses
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取在线课程失败: {str(e)}"
        )

@router.post("/posts", response_model=PostResponse)
async def create_post(
    post_data: PostCreate,
    user_id: str,
    db: Session = Depends(get_db)
):
    """创建动态"""
    try:
        service = CommunityService(db)
        post = service.create_post(user_id, post_data)
        return post
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"创建动态失败: {str(e)}"
        )

@router.get("/posts/{post_id}", response_model=PostResponse)
async def get_post(
    post_id: str,
    user_id: str,
    db: Session = Depends(get_db)
):
    """获取特定动态"""
    try:
        service = CommunityService(db)
        post = service.get_post_by_id(post_id, user_id)
        if not post:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="动态不存在"
            )
        return post
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取动态失败: {str(e)}"
        )

@router.post("/posts/{post_id}/like", response_model=LikeResponse)
async def toggle_like(
    post_id: str,
    user_id: str,
    db: Session = Depends(get_db)
):
    """点赞/取消点赞"""
    try:
        service = CommunityService(db)
        like = service.toggle_like(post_id, user_id)
        return like
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"点赞操作失败: {str(e)}"
        )

@router.post("/posts/{post_id}/comments", response_model=CommentResponse)
async def create_comment(
    post_id: str,
    comment_data: CommentCreate,
    user_id: str,
    db: Session = Depends(get_db)
):
    """创建评论"""
    try:
        service = CommunityService(db)
        comment = service.create_comment(post_id, user_id, comment_data)
        return comment
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"创建评论失败: {str(e)}"
        )

@router.get("/posts/{post_id}/comments", response_model=List[CommentResponse])
async def get_comments(
    post_id: str,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """获取评论列表"""
    try:
        service = CommunityService(db)
        comments = service.get_comments(post_id, skip=skip, limit=limit)
        return comments
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取评论失败: {str(e)}"
        )

@router.get("/feed", response_model=FeedResponse)
async def get_feed(
    user_id: str,
    feed_type: str = "recommend",
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """获取综合动态流（包含休息动态）"""
    try:
        service = CommunityService(db)
        feed = service.get_feed(user_id, feed_type, skip, limit)
        return feed
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取动态流失败: {str(e)}"
        )

@router.post("/posts/migrate-rest", response_model=dict)
async def migrate_rest_posts(
    user_id: str,
    db: Session = Depends(get_db)
):
    """迁移休息动态到社区动态"""
    try:
        service = CommunityService(db)
        result = service.migrate_rest_posts(user_id)
        return result
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"迁移休息动态失败: {str(e)}"
        )
