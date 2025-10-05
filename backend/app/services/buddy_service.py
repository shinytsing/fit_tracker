"""
FitTracker Backend - 搭子服务
"""

from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, desc
from typing import List, Optional, Dict, Any
import uuid
from datetime import datetime, timedelta
import math

from app.models.buddies import WorkoutBuddy, BuddyRequest, BuddyMatch
from app.models import User
from app.schemas.buddies import (
    BuddyRecommendationResponse,
    BuddyRequestCreate,
    BuddyRequestResponse,
    BuddyRequestUpdate,
    BuddyResponse,
    BuddyMatchResponse,
    BuddySearchParams,
    BuddyStatsResponse,
)

class BuddyService:
    def __init__(self, db: Session):
        self.db = db

    def get_buddy_recommendations(
        self, 
        user_id: str, 
        skip: int = 0, 
        limit: int = 10
    ) -> List[BuddyRecommendationResponse]:
        """获取搭子推荐"""
        # 获取用户信息
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return []

        # 获取已申请或已建立关系的用户ID
        excluded_ids = self._get_excluded_user_ids(user_id)

        # 基于用户偏好进行推荐
        recommendations = []
        
        # 1. 基于健身目标匹配
        goal_matches = self._get_goal_based_recommendations(user, excluded_ids, limit)
        recommendations.extend(goal_matches)

        # 2. 基于兴趣标签匹配
        interest_matches = self._get_interest_based_recommendations(user, excluded_ids, limit)
        recommendations.extend(interest_matches)

        # 3. 基于地理位置匹配
        location_matches = self._get_location_based_recommendations(user, excluded_ids, limit)
        recommendations.extend(location_matches)

        # 去重并按匹配度排序
        unique_recommendations = self._deduplicate_and_rank_recommendations(recommendations)
        
        return unique_recommendations[skip:skip + limit]

    def get_nearby_buddies(
        self,
        user_id: str,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        radius: float = 5.0,
        skip: int = 0,
        limit: int = 10
    ) -> List[BuddyRecommendationResponse]:
        """获取附近搭子"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return []

        excluded_ids = self._get_excluded_user_ids(user_id)
        
        # 如果没有提供坐标，使用用户默认位置
        if latitude is None or longitude is None:
            # 这里应该从用户配置中获取默认位置
            latitude, longitude = 39.9042, 116.4074  # 北京坐标作为默认值

        # 查询附近用户
        nearby_users = self.db.query(User).filter(
            and_(
                User.id != user_id,
                User.id.notin_(excluded_ids),
                User.location.isnot(None)
            )
        ).all()

        recommendations = []
        for nearby_user in nearby_users:
            # 计算距离（这里简化处理，实际应该使用地理位置计算）
            distance = self._calculate_distance(latitude, longitude, 39.9042, 116.4074)
            
            if distance <= radius:
                match_score = self._calculate_match_score(user, nearby_user)
                recommendations.append(BuddyRecommendationResponse(
                    user=self._format_user_info(nearby_user),
                    match_score=match_score,
                    match_reasons=self._get_match_reasons(user, nearby_user),
                    workout_preferences=self._get_workout_preferences(nearby_user),
                    distance=distance
                ))

        # 按距离和匹配度排序
        recommendations.sort(key=lambda x: (x.distance or 0, -x.match_score))
        
        return recommendations[skip:skip + limit]

    def get_similar_buddies(
        self,
        user_id: str,
        skip: int = 0,
        limit: int = 10
    ) -> List[BuddyRecommendationResponse]:
        """获取同好搭子"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return []

        excluded_ids = self._get_excluded_user_ids(user_id)

        # 基于兴趣标签和健身水平匹配
        similar_users = self.db.query(User).filter(
            and_(
                User.id != user_id,
                User.id.notin_(excluded_ids),
                User.fitness_tags.isnot(None)
            )
        ).all()

        recommendations = []
        for similar_user in similar_users:
            match_score = self._calculate_similarity_score(user, similar_user)
            if match_score >= 60:  # 只推荐相似度60%以上的用户
                recommendations.append(BuddyRecommendationResponse(
                    user=self._format_user_info(similar_user),
                    match_score=match_score,
                    match_reasons=self._get_similarity_reasons(user, similar_user),
                    workout_preferences=self._get_workout_preferences(similar_user)
                ))

        # 按相似度排序
        recommendations.sort(key=lambda x: -x.match_score)
        
        return recommendations[skip:skip + limit]

    def create_buddy_request(
        self,
        user_id: str,
        request_data: BuddyRequestCreate
    ) -> BuddyRequestResponse:
        """创建搭子申请"""
        # 检查是否已经存在申请
        existing_request = self.db.query(BuddyRequest).filter(
            and_(
                BuddyRequest.requester_id == user_id,
                BuddyRequest.target_id == request_data.target_id,
                BuddyRequest.status == "pending"
            )
        ).first()

        if existing_request:
            raise ValueError("已经向该用户发送过申请")

        # 检查是否已经是搭子
        existing_buddy = self.db.query(WorkoutBuddy).filter(
            and_(
                or_(
                    and_(WorkoutBuddy.user_id == user_id, WorkoutBuddy.buddy_id == request_data.target_id),
                    and_(WorkoutBuddy.user_id == request_data.target_id, WorkoutBuddy.buddy_id == user_id)
                ),
                WorkoutBuddy.status == "active"
            )
        ).first()

        if existing_buddy:
            raise ValueError("已经是搭子关系")

        # 创建申请
        buddy_request = BuddyRequest(
            requester_id=user_id,
            target_id=request_data.target_id,
            request_message=request_data.request_message,
            workout_preferences=request_data.workout_preferences,
            preferred_time=request_data.preferred_time,
            preferred_location=request_data.preferred_location,
            expires_at=datetime.utcnow() + timedelta(days=7)  # 7天过期
        )

        self.db.add(buddy_request)
        self.db.commit()
        self.db.refresh(buddy_request)

        return self._format_buddy_request_response(buddy_request)

    def get_buddy_requests(
        self,
        user_id: str,
        request_type: str = "received",
        skip: int = 0,
        limit: int = 20
    ) -> List[BuddyRequestResponse]:
        """获取搭子申请列表"""
        query = self.db.query(BuddyRequest)
        
        if request_type == "received":
            query = query.filter(BuddyRequest.target_id == user_id)
        elif request_type == "sent":
            query = query.filter(BuddyRequest.requester_id == user_id)
        else:
            query = query.filter(
                or_(
                    BuddyRequest.target_id == user_id,
                    BuddyRequest.requester_id == user_id
                )
            )

        requests = query.order_by(desc(BuddyRequest.created_at)).offset(skip).limit(limit).all()
        
        return [self._format_buddy_request_response(req) for req in requests]

    def accept_buddy_request(
        self,
        request_id: str,
        user_id: str,
        response_data: BuddyRequestUpdate
    ) -> BuddyResponse:
        """接受搭子申请"""
        request = self.db.query(BuddyRequest).filter(
            and_(
                BuddyRequest.id == request_id,
                BuddyRequest.target_id == user_id,
                BuddyRequest.status == "pending"
            )
        ).first()

        if not request:
            raise ValueError("申请不存在或已处理")

        # 更新申请状态
        request.status = "accepted"
        request.response_message = response_data.response_message
        request.responded_at = datetime.utcnow()

        # 创建搭子关系
        buddy_relation = WorkoutBuddy(
            user_id=request.requester_id,
            buddy_id=request.target_id,
            status="active",
            workout_preferences=request.workout_preferences,
            match_score=self._calculate_initial_match_score(request.requester_id, request.target_id)
        )

        self.db.add(buddy_relation)
        self.db.commit()
        self.db.refresh(buddy_relation)

        return self._format_buddy_response(buddy_relation)

    def reject_buddy_request(
        self,
        request_id: str,
        user_id: str,
        response_data: BuddyRequestUpdate
    ) -> bool:
        """拒绝搭子申请"""
        request = self.db.query(BuddyRequest).filter(
            and_(
                BuddyRequest.id == request_id,
                BuddyRequest.target_id == user_id,
                BuddyRequest.status == "pending"
            )
        ).first()

        if not request:
            return False

        request.status = "rejected"
        request.response_message = response_data.response_message or response_data.reason
        request.responded_at = datetime.utcnow()

        self.db.commit()
        return True

    def get_user_buddies(
        self,
        user_id: str,
        skip: int = 0,
        limit: int = 20
    ) -> List[BuddyResponse]:
        """获取用户搭子列表"""
        buddies = self.db.query(WorkoutBuddy).filter(
            and_(
                or_(
                    WorkoutBuddy.user_id == user_id,
                    WorkoutBuddy.buddy_id == user_id
                ),
                WorkoutBuddy.status == "active"
            )
        ).offset(skip).limit(limit).all()

        return [self._format_buddy_response(buddy) for buddy in buddies]

    def remove_buddy(
        self,
        buddy_id: str,
        user_id: str
    ) -> bool:
        """删除搭子关系"""
        buddy = self.db.query(WorkoutBuddy).filter(
            and_(
                or_(
                    and_(WorkoutBuddy.user_id == user_id, WorkoutBuddy.buddy_id == buddy_id),
                    and_(WorkoutBuddy.user_id == buddy_id, WorkoutBuddy.buddy_id == user_id)
                ),
                WorkoutBuddy.status == "active"
            )
        ).first()

        if not buddy:
            return False

        buddy.status = "ended"
        self.db.commit()
        return True

    def get_buddy_match_info(
        self,
        buddy_id: str,
        user_id: str
    ) -> Optional[BuddyMatchResponse]:
        """获取搭子匹配信息"""
        buddy = self.db.query(User).filter(User.id == buddy_id).first()
        user = self.db.query(User).filter(User.id == user_id).first()
        
        if not buddy or not user:
            return None

        match_score = self._calculate_match_score(user, buddy)
        match_reasons = self._get_match_reasons(user, buddy)
        
        return BuddyMatchResponse(
            user=self._format_user_info(buddy),
            match_score=match_score,
            match_reasons=match_reasons,
            workout_preferences=self._get_workout_preferences(buddy),
            compatibility=self._analyze_compatibility(user, buddy),
            suggested_activities=self._suggest_activities(user, buddy)
        )

    def search_buddies(
        self,
        user_id: str,
        search_params: Dict[str, Any],
        skip: int = 0,
        limit: int = 20
    ) -> List[BuddyRecommendationResponse]:
        """搜索搭子"""
        excluded_ids = self._get_excluded_user_ids(user_id)
        
        query = self.db.query(User).filter(
            and_(
                User.id != user_id,
                User.id.notin_(excluded_ids)
            )
        )

        # 应用搜索条件
        if search_params.get("age_range"):
            min_age, max_age = search_params["age_range"]
            query = query.filter(User.age >= min_age, User.age <= max_age)

        if search_params.get("fitness_level"):
            query = query.filter(User.fitness_level.in_(search_params["fitness_level"]))

        if search_params.get("interests"):
            # 这里需要根据具体的数据库实现来调整
            pass

        users = query.offset(skip).limit(limit).all()
        
        recommendations = []
        for user in users:
            match_score = self._calculate_match_score(
                self.db.query(User).filter(User.id == user_id).first(),
                user
            )
            recommendations.append(BuddyRecommendationResponse(
                user=self._format_user_info(user),
                match_score=match_score,
                match_reasons=[],
                workout_preferences=self._get_workout_preferences(user)
            ))

        return recommendations

    def get_buddy_stats(self, user_id: str) -> BuddyStatsResponse:
        """获取搭子统计信息"""
        # 总搭子数
        total_buddies = self.db.query(WorkoutBuddy).filter(
            or_(
                WorkoutBuddy.user_id == user_id,
                WorkoutBuddy.buddy_id == user_id
            )
        ).count()

        # 活跃搭子数
        active_buddies = self.db.query(WorkoutBuddy).filter(
            and_(
                or_(
                    WorkoutBuddy.user_id == user_id,
                    WorkoutBuddy.buddy_id == user_id
                ),
                WorkoutBuddy.status == "active"
            )
        ).count()

        # 申请统计
        sent_requests = self.db.query(BuddyRequest).filter(
            BuddyRequest.requester_id == user_id
        ).count()

        received_requests = self.db.query(BuddyRequest).filter(
            BuddyRequest.target_id == user_id
        ).count()

        accepted_requests = self.db.query(BuddyRequest).filter(
            and_(
                BuddyRequest.target_id == user_id,
                BuddyRequest.status == "accepted"
            )
        ).count()

        rejected_requests = self.db.query(BuddyRequest).filter(
            and_(
                BuddyRequest.target_id == user_id,
                BuddyRequest.status == "rejected"
            )
        ).count()

        # 训练统计
        total_workouts = self.db.query(func.sum(WorkoutBuddy.total_workouts)).filter(
            or_(
                WorkoutBuddy.user_id == user_id,
                WorkoutBuddy.buddy_id == user_id
            )
        ).scalar() or 0

        # 平均评分
        avg_rating = self.db.query(func.avg(WorkoutBuddy.rating)).filter(
            or_(
                WorkoutBuddy.user_id == user_id,
                WorkoutBuddy.buddy_id == user_id
            )
        ).scalar() or 0.0

        # 匹配成功率
        success_rate = (accepted_requests / max(received_requests, 1)) * 100

        return BuddyStatsResponse(
            total_buddies=total_buddies,
            active_buddies=active_buddies,
            total_requests_sent=sent_requests,
            total_requests_received=received_requests,
            accepted_requests=accepted_requests,
            rejected_requests=rejected_requests,
            total_workouts=total_workouts,
            average_rating=round(avg_rating, 2),
            match_success_rate=round(success_rate, 2)
        )

    # 私有辅助方法
    def _get_excluded_user_ids(self, user_id: str) -> List[str]:
        """获取需要排除的用户ID列表"""
        # 已建立搭子关系的用户
        buddy_ids = self.db.query(WorkoutBuddy.buddy_id).filter(
            WorkoutBuddy.user_id == user_id
        ).all()
        buddy_ids.extend(
            self.db.query(WorkoutBuddy.user_id).filter(
                WorkoutBuddy.buddy_id == user_id
            ).all()
        )

        # 已发送申请的用户
        request_ids = self.db.query(BuddyRequest.target_id).filter(
            BuddyRequest.requester_id == user_id
        ).all()

        # 已收到申请的用户
        received_ids = self.db.query(BuddyRequest.requester_id).filter(
            BuddyRequest.target_id == user_id
        ).all()

        excluded_ids = set()
        excluded_ids.update([id[0] for id in buddy_ids])
        excluded_ids.update([id[0] for id in request_ids])
        excluded_ids.update([id[0] for id in received_ids])
        excluded_ids.add(user_id)  # 排除自己

        return list(excluded_ids)

    def _calculate_match_score(self, user1: User, user2: User) -> int:
        """计算匹配度分数"""
        score = 0
        
        # 年龄匹配 (20分)
        if user1.age and user2.age:
            age_diff = abs(user1.age - user2.age)
            if age_diff <= 2:
                score += 20
            elif age_diff <= 5:
                score += 15
            elif age_diff <= 10:
                score += 10

        # 健身水平匹配 (30分)
        if user1.fitness_level and user2.fitness_level:
            if user1.fitness_level == user2.fitness_level:
                score += 30
            elif abs(self._get_fitness_level_score(user1.fitness_level) - 
                    self._get_fitness_level_score(user2.fitness_level)) <= 1:
                score += 20

        # 兴趣标签匹配 (30分)
        if user1.fitness_tags and user2.fitness_tags:
            common_tags = set(user1.fitness_tags) & set(user2.fitness_tags)
            if common_tags:
                score += min(30, len(common_tags) * 10)

        # 健身目标匹配 (20分)
        if user1.fitness_goal and user2.fitness_goal:
            if user1.fitness_goal == user2.fitness_goal:
                score += 20

        return min(100, score)

    def _get_fitness_level_score(self, level: str) -> int:
        """获取健身水平分数"""
        level_scores = {
            "初级": 1,
            "中级": 2,
            "高级": 3,
            "专业": 4
        }
        return level_scores.get(level, 1)

    def _get_match_reasons(self, user1: User, user2: User) -> List[str]:
        """获取匹配原因"""
        reasons = []
        
        if user1.age and user2.age:
            age_diff = abs(user1.age - user2.age)
            if age_diff <= 2:
                reasons.append("年龄相近")
            elif age_diff <= 5:
                reasons.append("年龄相仿")

        if user1.fitness_level and user2.fitness_level:
            if user1.fitness_level == user2.fitness_level:
                reasons.append("健身水平相同")

        if user1.fitness_tags and user2.fitness_tags:
            common_tags = set(user1.fitness_tags) & set(user2.fitness_tags)
            if common_tags:
                reasons.append(f"共同兴趣: {', '.join(common_tags)}")

        if user1.fitness_goal and user2.fitness_goal:
            if user1.fitness_goal == user2.fitness_goal:
                reasons.append("健身目标相同")

        return reasons

    def _get_similarity_reasons(self, user1: User, user2: User) -> List[str]:
        """获取相似性原因"""
        reasons = []
        
        if user1.fitness_tags and user2.fitness_tags:
            common_tags = set(user1.fitness_tags) & set(user2.fitness_tags)
            if common_tags:
                reasons.append(f"共同兴趣: {', '.join(common_tags)}")

        if user1.fitness_level and user2.fitness_level:
            if user1.fitness_level == user2.fitness_level:
                reasons.append("健身水平相同")

        return reasons

    def _calculate_similarity_score(self, user1: User, user2: User) -> int:
        """计算相似度分数"""
        score = 0
        
        # 兴趣标签相似度 (60分)
        if user1.fitness_tags and user2.fitness_tags:
            common_tags = set(user1.fitness_tags) & set(user2.fitness_tags)
            total_tags = set(user1.fitness_tags) | set(user2.fitness_tags)
            if total_tags:
                similarity = len(common_tags) / len(total_tags)
                score += int(similarity * 60)

        # 健身水平相似度 (40分)
        if user1.fitness_level and user2.fitness_level:
            if user1.fitness_level == user2.fitness_level:
                score += 40
            elif abs(self._get_fitness_level_score(user1.fitness_level) - 
                    self._get_fitness_level_score(user2.fitness_level)) <= 1:
                score += 25

        return min(100, score)

    def _calculate_distance(self, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """计算两点间距离（公里）"""
        # 使用Haversine公式计算距离
        R = 6371  # 地球半径（公里）
        
        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        
        a = (math.sin(dlat/2) * math.sin(dlat/2) +
             math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
             math.sin(dlon/2) * math.sin(dlon/2))
        
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
        distance = R * c
        
        return distance

    def _format_user_info(self, user: User) -> Dict[str, Any]:
        """格式化用户信息"""
        return {
            "id": user.id,
            "nickname": user.nickname,
            "avatar": user.avatar,
            "age": user.age,
            "fitness_level": user.fitness_level,
            "fitness_tags": user.fitness_tags or [],
            "fitness_goal": user.fitness_goal,
            "location": user.location,
            "is_verified": user.is_verified,
            "bio": user.bio
        }

    def _format_buddy_request_response(self, request: BuddyRequest) -> BuddyRequestResponse:
        """格式化搭子申请响应"""
        requester = self.db.query(User).filter(User.id == request.requester_id).first()
        target = self.db.query(User).filter(User.id == request.target_id).first()
        
        return BuddyRequestResponse(
            id=request.id,
            requester=self._format_user_info(requester),
            target=self._format_user_info(target),
            status=request.status,
            request_message=request.request_message,
            response_message=request.response_message,
            workout_preferences=request.workout_preferences or {},
            preferred_time=request.preferred_time,
            preferred_location=request.preferred_location,
            requested_at=request.requested_at,
            responded_at=request.responded_at
        )

    def _format_buddy_response(self, buddy: WorkoutBuddy) -> BuddyResponse:
        """格式化搭子响应"""
        buddy_user = self.db.query(User).filter(User.id == buddy.buddy_id).first()
        
        return BuddyResponse(
            id=buddy.id,
            buddy=self._format_user_info(buddy_user),
            status=buddy.status,
            match_score=buddy.match_score,
            match_reasons=buddy.match_reasons or [],
            workout_preferences=buddy.workout_preferences or {},
            total_workouts=buddy.total_workouts,
            rating=buddy.rating,
            last_interaction=buddy.last_interaction,
            created_at=buddy.created_at
        )

    def _get_workout_preferences(self, user: User) -> Dict[str, Any]:
        """获取训练偏好"""
        return {
            "interests": user.fitness_tags or [],
            "goal": user.fitness_goal,
            "level": user.fitness_level
        }

    def _analyze_compatibility(self, user1: User, user2: User) -> Dict[str, Any]:
        """分析兼容性"""
        return {
            "age_compatibility": abs(user1.age - user2.age) <= 5 if user1.age and user2.age else False,
            "level_compatibility": user1.fitness_level == user2.fitness_level,
            "goal_compatibility": user1.fitness_goal == user2.fitness_goal,
            "interest_overlap": len(set(user1.fitness_tags or []) & set(user2.fitness_tags or []))
        }

    def _suggest_activities(self, user1: User, user2: User) -> List[str]:
        """建议活动"""
        suggestions = []
        
        if user1.fitness_tags and user2.fitness_tags:
            common_tags = set(user1.fitness_tags) & set(user2.fitness_tags)
            if "力量训练" in common_tags:
                suggestions.append("一起进行力量训练")
            if "有氧运动" in common_tags:
                suggestions.append("一起进行有氧运动")
            if "瑜伽" in common_tags:
                suggestions.append("一起练习瑜伽")
            if "跑步" in common_tags:
                suggestions.append("一起跑步")
        
        if not suggestions:
            suggestions.append("尝试新的运动项目")
            
        return suggestions

    def _calculate_initial_match_score(self, user_id1: str, user_id2: str) -> int:
        """计算初始匹配分数"""
        user1 = self.db.query(User).filter(User.id == user_id1).first()
        user2 = self.db.query(User).filter(User.id == user_id2).first()
        
        if user1 and user2:
            return self._calculate_match_score(user1, user2)
        
        return 50  # 默认分数

    def _get_goal_based_recommendations(self, user: User, excluded_ids: List[str], limit: int) -> List[BuddyRecommendationResponse]:
        """基于健身目标的推荐"""
        if not user.fitness_goal:
            return []
            
        similar_users = self.db.query(User).filter(
            and_(
                User.id.notin_(excluded_ids),
                User.fitness_goal == user.fitness_goal
            )
        ).limit(limit).all()
        
        recommendations = []
        for similar_user in similar_users:
            match_score = self._calculate_match_score(user, similar_user)
            recommendations.append(BuddyRecommendationResponse(
                user=self._format_user_info(similar_user),
                match_score=match_score,
                match_reasons=self._get_match_reasons(user, similar_user),
                workout_preferences=self._get_workout_preferences(similar_user)
            ))
        
        return recommendations

    def _get_interest_based_recommendations(self, user: User, excluded_ids: List[str], limit: int) -> List[BuddyRecommendationResponse]:
        """基于兴趣标签的推荐"""
        if not user.fitness_tags:
            return []
            
        recommendations = []
        for tag in user.fitness_tags:
            tag_users = self.db.query(User).filter(
                and_(
                    User.id.notin_(excluded_ids),
                    User.fitness_tags.contains([tag])
                )
            ).limit(limit // len(user.fitness_tags)).all()
            
            for tag_user in tag_users:
                match_score = self._calculate_match_score(user, tag_user)
                recommendations.append(BuddyRecommendationResponse(
                    user=self._format_user_info(tag_user),
                    match_score=match_score,
                    match_reasons=self._get_match_reasons(user, tag_user),
                    workout_preferences=self._get_workout_preferences(tag_user)
                ))
        
        return recommendations

    def _get_location_based_recommendations(self, user: User, excluded_ids: List[str], limit: int) -> List[BuddyRecommendationResponse]:
        """基于地理位置的推荐"""
        if not user.location:
            return []
            
        # 这里应该根据用户位置进行地理搜索
        # 简化处理，返回随机用户
        nearby_users = self.db.query(User).filter(
            and_(
                User.id.notin_(excluded_ids),
                User.location.isnot(None)
            )
        ).limit(limit).all()
        
        recommendations = []
        for nearby_user in nearby_users:
            match_score = self._calculate_match_score(user, nearby_user)
            recommendations.append(BuddyRecommendationResponse(
                user=self._format_user_info(nearby_user),
                match_score=match_score,
                match_reasons=self._get_match_reasons(user, nearby_user),
                workout_preferences=self._get_workout_preferences(nearby_user)
            ))
        
        return recommendations

    def _deduplicate_and_rank_recommendations(self, recommendations: List[BuddyRecommendationResponse]) -> List[BuddyRecommendationResponse]:
        """去重并排序推荐"""
        # 去重
        unique_recommendations = {}
        for rec in recommendations:
            user_id = rec.user["id"]
            if user_id not in unique_recommendations or rec.match_score > unique_recommendations[user_id].match_score:
                unique_recommendations[user_id] = rec
        
        # 按匹配度排序
        sorted_recommendations = sorted(
            unique_recommendations.values(),
            key=lambda x: -x.match_score
        )
        
        return sorted_recommendations
