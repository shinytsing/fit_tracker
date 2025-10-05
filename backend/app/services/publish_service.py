"""
FitTracker Backend - 发布服务
"""

from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime

from app.models import Post, Draft, User
from app.schemas.publish import PostCreate, PostUpdate, PostResponse, DraftCreate, DraftResponse, QuickCheckinRequest, QuickCheckinResponse


class PublishService:
    def __init__(self, db: Session):
        self.db = db

    def create_post(self, user_id: str, post_data: PostCreate) -> PostResponse:
        """创建动态"""
        post = Post(
            id=str(uuid.uuid4()),
            user_id=user_id,
            content=post_data.content,
            images=post_data.images,
            tags=post_data.tags,
            post_type=getattr(post_data, 'post_type', 'dynamic'),
            mood_type=getattr(post_data, 'mood_type', None),
            nutrition_data=getattr(post_data, 'nutrition_data', None),
            training_data=getattr(post_data, 'training_data', None),
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        self.db.add(post)
        self.db.commit()
        self.db.refresh(post)
        return PostResponse.from_orm(post)

    def update_post(self, post_id: str, user_id: str, post_data: PostUpdate) -> Optional[PostResponse]:
        """更新动态"""
        post = self.db.query(Post).filter(
            Post.id == post_id,
            Post.user_id == user_id
        ).first()
        if not post:
            return None

        for field, value in post_data.dict(exclude_unset=True).items():
            setattr(post, field, value)
        
        post.updated_at = datetime.utcnow()
        self.db.commit()
        self.db.refresh(post)
        return PostResponse.from_orm(post)

    def delete_post(self, post_id: str, user_id: str) -> bool:
        """删除动态"""
        post = self.db.query(Post).filter(
            Post.id == post_id,
            Post.user_id == user_id
        ).first()
        if not post:
            return False

        self.db.delete(post)
        self.db.commit()
        return True

    def quick_checkin(self, user_id: str, checkin_data: QuickCheckinRequest) -> QuickCheckinResponse:
        """快速打卡"""
        # 创建打卡动态
        post_data = PostCreate(
            content=checkin_data.content or "今日训练完成！",
            images=checkin_data.images,
            tags=checkin_data.tags,
            post_type="checkin",
            training_data=checkin_data.training_data
        )
        
        post = self.create_post(user_id, post_data)
        
        return QuickCheckinResponse(
            success=True,
            message="打卡成功！",
            post_id=post.id,
            checkin_time=datetime.utcnow()
        )

    def create_draft(self, user_id: str, draft_data: DraftCreate) -> DraftResponse:
        """创建草稿"""
        draft = Draft(
            id=str(uuid.uuid4()),
            user_id=user_id,
            content=draft_data.content,
            images=draft_data.images,
            tags=draft_data.tags,
            post_type=getattr(draft_data, 'post_type', 'dynamic'),
            mood_type=getattr(draft_data, 'mood_type', None),
            nutrition_data=getattr(draft_data, 'nutrition_data', None),
            training_data=getattr(draft_data, 'training_data', None),
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        self.db.add(draft)
        self.db.commit()
        self.db.refresh(draft)
        return DraftResponse.from_orm(draft)

    def get_drafts(self, user_id: str, skip: int = 0, limit: int = 20) -> List[DraftResponse]:
        """获取草稿列表"""
        drafts = self.db.query(Draft).filter(
            Draft.user_id == user_id
        ).order_by(Draft.updated_at.desc()).offset(skip).limit(limit).all()
        return [DraftResponse.from_orm(draft) for draft in drafts]

    def get_draft(self, draft_id: str, user_id: str) -> Optional[DraftResponse]:
        """获取特定草稿"""
        draft = self.db.query(Draft).filter(
            Draft.id == draft_id,
            Draft.user_id == user_id
        ).first()
        if draft:
            return DraftResponse.from_orm(draft)
        return None

    def update_draft(self, draft_id: str, user_id: str, draft_data: DraftCreate) -> Optional[DraftResponse]:
        """更新草稿"""
        draft = self.db.query(Draft).filter(
            Draft.id == draft_id,
            Draft.user_id == user_id
        ).first()
        if not draft:
            return None

        for field, value in draft_data.dict(exclude_unset=True).items():
            setattr(draft, field, value)
        
        draft.updated_at = datetime.utcnow()
        self.db.commit()
        self.db.refresh(draft)
        return DraftResponse.from_orm(draft)

    def delete_draft(self, draft_id: str, user_id: str) -> bool:
        """删除草稿"""
        draft = self.db.query(Draft).filter(
            Draft.id == draft_id,
            Draft.user_id == user_id
        ).first()
        if not draft:
            return False

        self.db.delete(draft)
        self.db.commit()
        return True

    def publish_draft(self, draft_id: str, user_id: str) -> PostResponse:
        """发布草稿"""
        draft = self.db.query(Draft).filter(
            Draft.id == draft_id,
            Draft.user_id == user_id
        ).first()
        if not draft:
            raise ValueError("草稿不存在")

        # 创建动态
        post_data = PostCreate(
            content=draft.content,
            images=draft.images,
            tags=draft.tags,
            post_type=draft.post_type,
            mood_type=draft.mood_type,
            nutrition_data=draft.nutrition_data,
            training_data=draft.training_data
        )
        
        post = self.create_post(user_id, post_data)
        
        # 删除草稿
        self.db.delete(draft)
        self.db.commit()
        
        return post
