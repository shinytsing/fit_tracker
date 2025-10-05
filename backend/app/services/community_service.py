"""
FitTracker Backend - 社区服务
"""

from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime

from app.models import Post, User, Comment, Like
from app.schemas.community import PostCreate, PostUpdate, PostResponse


class CommunityService:
    def __init__(self, db: Session):
        self.db = db

    def get_posts(self, user_id: str, feed_type: str = "recommend", skip: int = 0, limit: int = 20) -> List[PostResponse]:
        """获取动态流"""
        query = self.db.query(Post)
        
        if feed_type == "following":
            # 获取关注用户的动态
            # TODO: 实现关注逻辑
            pass
        elif feed_type == "trending":
            # 获取热门动态
            query = query.order_by(Post.like_count.desc(), Post.created_at.desc())
        else:
            # 推荐动态
            query = query.order_by(Post.created_at.desc())
        
        posts = query.offset(skip).limit(limit).all()
        return [PostResponse.from_orm(post) for post in posts]

    def get_trending_posts(self, user_id: str, skip: int = 0, limit: int = 20) -> List[PostResponse]:
        """获取热门动态"""
        posts = self.db.query(Post).order_by(
            Post.like_count.desc(),
            Post.comment_count.desc(),
            Post.created_at.desc()
        ).offset(skip).limit(limit).all()
        return [PostResponse.from_orm(post) for post in posts]

    def get_post(self, post_id: str) -> Optional[PostResponse]:
        """获取特定动态"""
        post = self.db.query(Post).filter(Post.id == post_id).first()
        if post:
            return PostResponse.from_orm(post)
        return None

    def create_post(self, user_id: str, post_data: PostCreate) -> PostResponse:
        """创建动态"""
        post = Post(
            id=str(uuid.uuid4()),
            user_id=user_id,
            content=post_data.content,
            images=post_data.images,
            tags=post_data.tags,
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

    def like_post(self, post_id: str, user_id: str) -> bool:
        """点赞动态"""
        # 检查是否已经点赞
        existing_like = self.db.query(Like).filter(
            Like.post_id == post_id,
            Like.user_id == user_id
        ).first()
        
        if existing_like:
            # 取消点赞
            self.db.delete(existing_like)
            # 更新动态点赞数
            post = self.db.query(Post).filter(Post.id == post_id).first()
            if post:
                post.like_count = max(0, post.like_count - 1)
        else:
            # 添加点赞
            like = Like(
                id=str(uuid.uuid4()),
                post_id=post_id,
                user_id=user_id,
                created_at=datetime.utcnow()
            )
            self.db.add(like)
            # 更新动态点赞数
            post = self.db.query(Post).filter(Post.id == post_id).first()
            if post:
                post.like_count += 1
        
        self.db.commit()
        return True

    def comment_post(self, post_id: str, user_id: str, content: str) -> Optional[Comment]:
        """评论动态"""
        comment = Comment(
            id=str(uuid.uuid4()),
            post_id=post_id,
            user_id=user_id,
            content=content,
            created_at=datetime.utcnow()
        )
        self.db.add(comment)
        
        # 更新动态评论数
        post = self.db.query(Post).filter(Post.id == post_id).first()
        if post:
            post.comment_count += 1
        
        self.db.commit()
        self.db.refresh(comment)
        return comment

    def get_post_comments(self, post_id: str, skip: int = 0, limit: int = 20) -> List[Comment]:
        """获取动态评论"""
        comments = self.db.query(Comment).filter(
            Comment.post_id == post_id
        ).order_by(Comment.created_at.desc()).offset(skip).limit(limit).all()
        return comments

    def follow_user(self, follower_id: str, following_id: str) -> bool:
        """关注用户"""
        # TODO: 实现关注逻辑
        pass

    def unfollow_user(self, follower_id: str, following_id: str) -> bool:
        """取消关注用户"""
        # TODO: 实现取消关注逻辑
        pass
