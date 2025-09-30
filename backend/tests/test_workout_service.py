"""
FitTracker Backend - 健身中心单元测试
"""

import pytest
from unittest.mock import Mock, patch
from sqlalchemy.orm import Session
from datetime import datetime
import uuid

from app.services.workout_service import WorkoutService
from app.services.ai_service import AIService
from app.schemas.workout import (
    TrainingPlanCreate,
    TrainingPlanUpdate,
    PlanType,
    DifficultyLevel,
    WorkoutRecordCreate
)
from app.models import TrainingPlan, Exercise, WorkoutRecord

class TestWorkoutService:
    """健身中心服务测试"""
    
    @pytest.fixture
    def mock_db(self):
        """模拟数据库会话"""
        return Mock(spec=Session)
    
    @pytest.fixture
    def workout_service(self, mock_db):
        """创建健身中心服务实例"""
        return WorkoutService(mock_db)
    
    @pytest.fixture
    def sample_plan_data(self):
        """示例训练计划数据"""
        return TrainingPlanCreate(
            name="测试训练计划",
            plan_type=PlanType.FAT_LOSS,
            difficulty_level=DifficultyLevel.INTERMEDIATE,
            duration_weeks=4,
            description="测试描述",
            exercises=[
                {
                    "name": "深蹲",
                    "sets": 3,
                    "reps": 15,
                    "duration": 300
                }
            ]
        )
    
    def test_create_plan_success(self, workout_service, mock_db, sample_plan_data):
        """测试成功创建训练计划"""
        user_id = str(uuid.uuid4())
        
        # 模拟数据库操作
        mock_db.add = Mock()
        mock_db.commit = Mock()
        mock_db.refresh = Mock()
        
        # 执行创建
        result = workout_service.create_plan(user_id, sample_plan_data)
        
        # 验证结果
        assert result.name == sample_plan_data.name
        assert result.plan_type == sample_plan_data.plan_type.value
        assert result.difficulty_level == sample_plan_data.difficulty_level.value
        assert result.duration_weeks == sample_plan_data.duration_weeks
        assert result.user_id == user_id
        
        # 验证数据库操作
        mock_db.add.assert_called_once()
        mock_db.commit.assert_called_once()
        mock_db.refresh.assert_called_once()
    
    def test_get_user_plans(self, workout_service, mock_db):
        """测试获取用户训练计划列表"""
        user_id = str(uuid.uuid4())
        
        # 模拟查询结果
        mock_plans = [
            TrainingPlan(
                id=str(uuid.uuid4()),
                user_id=user_id,
                name="计划1",
                plan_type="减脂",
                difficulty_level="中级",
                duration_weeks=4,
                description="描述1",
                exercises=[],
                is_active=True,
                created_at=datetime.utcnow(),
                updated_at=datetime.utcnow()
            ),
            TrainingPlan(
                id=str(uuid.uuid4()),
                user_id=user_id,
                name="计划2",
                plan_type="增肌",
                difficulty_level="高级",
                duration_weeks=8,
                description="描述2",
                exercises=[],
                is_active=True,
                created_at=datetime.utcnow(),
                updated_at=datetime.utcnow()
            )
        ]
        
        # 模拟数据库查询
        mock_query = Mock()
        mock_query.filter.return_value = mock_query
        mock_query.offset.return_value = mock_query
        mock_query.limit.return_value = mock_query
        mock_query.all.return_value = mock_plans
        
        mock_db.query.return_value = mock_query
        
        # 执行查询
        result = workout_service.get_user_plans(user_id, skip=0, limit=20)
        
        # 验证结果
        assert len(result) == 2
        assert result[0].name == "计划1"
        assert result[1].name == "计划2"
        
        # 验证查询调用
        mock_db.query.assert_called_once_with(TrainingPlan)
    
    def test_get_plan_by_id_success(self, workout_service, mock_db):
        """测试根据ID获取训练计划成功"""
        user_id = str(uuid.uuid4())
        plan_id = str(uuid.uuid4())
        
        # 模拟查询结果
        mock_plan = TrainingPlan(
            id=plan_id,
            user_id=user_id,
            name="测试计划",
            plan_type="减脂",
            difficulty_level="中级",
            duration_weeks=4,
            description="测试描述",
            exercises=[],
            is_active=True,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
        # 模拟数据库查询
        mock_query = Mock()
        mock_query.filter.return_value = mock_query
        mock_query.first.return_value = mock_plan
        
        mock_db.query.return_value = mock_query
        
        # 执行查询
        result = workout_service.get_plan_by_id(plan_id, user_id)
        
        # 验证结果
        assert result is not None
        assert result.id == plan_id
        assert result.name == "测试计划"
    
    def test_get_plan_by_id_not_found(self, workout_service, mock_db):
        """测试根据ID获取训练计划不存在"""
        user_id = str(uuid.uuid4())
        plan_id = str(uuid.uuid4())
        
        # 模拟查询结果为空
        mock_query = Mock()
        mock_query.filter.return_value = mock_query
        mock_query.first.return_value = None
        
        mock_db.query.return_value = mock_query
        
        # 执行查询
        result = workout_service.get_plan_by_id(plan_id, user_id)
        
        # 验证结果
        assert result is None
    
    def test_update_plan_success(self, workout_service, mock_db):
        """测试更新训练计划成功"""
        user_id = str(uuid.uuid4())
        plan_id = str(uuid.uuid4())
        
        # 模拟现有计划
        mock_plan = TrainingPlan(
            id=plan_id,
            user_id=user_id,
            name="原计划",
            plan_type="减脂",
            difficulty_level="中级",
            duration_weeks=4,
            description="原描述",
            exercises=[],
            is_active=True,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
        # 模拟更新数据
        update_data = TrainingPlanUpdate(
            name="更新计划",
            description="更新描述"
        )
        
        # 模拟数据库查询
        mock_query = Mock()
        mock_query.filter.return_value = mock_query
        mock_query.first.return_value = mock_plan
        
        mock_db.query.return_value = mock_query
        mock_db.commit = Mock()
        mock_db.refresh = Mock()
        
        # 执行更新
        result = workout_service.update_plan(plan_id, user_id, update_data)
        
        # 验证结果
        assert result is not None
        assert result.name == "更新计划"
        assert result.description == "更新描述"
        
        # 验证数据库操作
        mock_db.commit.assert_called_once()
        mock_db.refresh.assert_called_once()
    
    def test_delete_plan_success(self, workout_service, mock_db):
        """测试删除训练计划成功"""
        user_id = str(uuid.uuid4())
        plan_id = str(uuid.uuid4())
        
        # 模拟现有计划
        mock_plan = TrainingPlan(
            id=plan_id,
            user_id=user_id,
            name="测试计划",
            plan_type="减脂",
            difficulty_level="中级",
            duration_weeks=4,
            description="测试描述",
            exercises=[],
            is_active=True,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
        # 模拟数据库查询
        mock_query = Mock()
        mock_query.filter.return_value = mock_query
        mock_query.first.return_value = mock_plan
        
        mock_db.query.return_value = mock_query
        mock_db.delete = Mock()
        mock_db.commit = Mock()
        
        # 执行删除
        result = workout_service.delete_plan(plan_id, user_id)
        
        # 验证结果
        assert result is True
        
        # 验证数据库操作
        mock_db.delete.assert_called_once_with(mock_plan)
        mock_db.commit.assert_called_once()
    
    def test_get_user_progress(self, workout_service, mock_db):
        """测试获取用户训练进度"""
        user_id = str(uuid.uuid4())
        
        # 模拟训练记录查询
        mock_query = Mock()
        mock_query.filter.return_value = mock_query
        mock_query.count.return_value = 10
        mock_query.with_entities.return_value = mock_query
        mock_query.scalar.return_value = 1200  # 总时长（秒）
        
        mock_db.query.return_value = mock_query
        
        # 执行查询
        result = workout_service.get_user_progress(user_id, "week")
        
        # 验证结果
        assert result.total_workouts == 10
        assert result.total_duration == 1200
        assert result.calories_burned == 120  # 1200 * 0.1
        assert result.period == "week"
        assert result.consistency_score >= 0.0
        assert result.consistency_score <= 1.0

class TestAIService:
    """AI服务测试"""
    
    @pytest.fixture
    def ai_service(self):
        """创建AI服务实例"""
        return AIService()
    
    @pytest.mark.asyncio
    async def test_generate_workout_plan_fat_loss(self, ai_service):
        """测试生成减脂训练计划"""
        result = await ai_service.generate_workout_plan(
            goal="减脂",
            difficulty="中级",
            duration=4,
            available_equipment=["无器械"],
            user_preferences=None
        )
        
        # 验证结果
        assert result["name"] == "AI 减脂 训练计划"
        assert result["type"] == "减脂"
        assert result["difficulty"] == "中级"
        assert result["duration"] == 4
        assert len(result["exercises"]) > 0
        assert len(result["suggestions"]) > 0
        assert 0.0 <= result["confidence_score"] <= 1.0
        
        # 验证动作信息
        for exercise in result["exercises"]:
            assert "name" in exercise
            assert "category" in exercise
            assert "muscle_groups" in exercise
            assert "equipment" in exercise
            assert "difficulty" in exercise
            assert "instructions" in exercise
    
    @pytest.mark.asyncio
    async def test_generate_workout_plan_muscle_gain(self, ai_service):
        """测试生成增肌训练计划"""
        result = await ai_service.generate_workout_plan(
            goal="增肌",
            difficulty="高级",
            duration=8,
            available_equipment=["杠铃", "哑铃"],
            user_preferences={"time_per_session": 60}
        )
        
        # 验证结果
        assert result["name"] == "AI 增肌 训练计划"
        assert result["type"] == "增肌"
        assert result["difficulty"] == "高级"
        assert result["duration"] == 8
        assert len(result["exercises"]) > 0
        assert len(result["suggestions"]) > 0
    
    @pytest.mark.asyncio
    async def test_analyze_exercise_feedback(self, ai_service):
        """测试分析动作反馈"""
        mock_exercise = Mock()
        mock_exercise.name = "深蹲"
        
        user_feedback = {
            "form_score": 8.5,
            "difficulty_rating": 3,
            "completion_percentage": 90.0
        }
        
        result = await ai_service.analyze_exercise_feedback(
            exercise=mock_exercise,
            user_feedback=user_feedback,
            user_id="test_user"
        )
        
        # 验证结果
        assert "feedback" in result
        assert "suggestions" in result
        assert "correctness_score" in result
        assert "improvement_tips" in result
        
        assert 0.0 <= result["correctness_score"] <= 1.0
        assert len(result["suggestions"]) >= 0
        assert len(result["improvement_tips"]) > 0
    
    def test_filter_by_difficulty(self, ai_service):
        """测试根据难度过滤动作"""
        exercises = [
            {"name": "深蹲", "difficulty": "初级"},
            {"name": "俯卧撑", "difficulty": "中级"},
            {"name": "卧推", "difficulty": "高级"}
        ]
        
        # 测试初级难度
        result = ai_service._filter_by_difficulty(exercises, "初级")
        assert len(result) == 1
        assert result[0]["name"] == "深蹲"
        
        # 测试中级难度
        result = ai_service._filter_by_difficulty(exercises, "中级")
        assert len(result) == 2
        assert any(ex["name"] == "深蹲" for ex in result)
        assert any(ex["name"] == "俯卧撑" for ex in result)
        
        # 测试高级难度
        result = ai_service._filter_by_difficulty(exercises, "高级")
        assert len(result) == 3
    
    def test_filter_by_equipment(self, ai_service):
        """测试根据器械过滤动作"""
        exercises = [
            {"name": "深蹲", "equipment": "无器械"},
            {"name": "卧推", "equipment": "杠铃"},
            {"name": "哑铃弯举", "equipment": "哑铃"}
        ]
        
        # 测试无器械过滤
        result = ai_service._filter_by_equipment(exercises, [])
        assert len(result) == 1
        assert result[0]["name"] == "深蹲"
        
        # 测试有器械过滤
        result = ai_service._filter_by_equipment(exercises, ["杠铃", "哑铃"])
        assert len(result) == 3
        
        # 测试部分器械过滤
        result = ai_service._filter_by_equipment(exercises, ["杠铃"])
        assert len(result) == 2
        assert any(ex["name"] == "深蹲" for ex in result)
        assert any(ex["name"] == "卧推" for ex in result)
    
    def test_calculate_confidence_score(self, ai_service):
        """测试计算置信度分数"""
        # 测试减脂初级
        score = ai_service._calculate_confidence_score("减脂", "初级", [])
        assert 0.0 <= score <= 1.0
        
        # 测试增肌高级
        score = ai_service._calculate_confidence_score("增肌", "高级", ["杠铃"])
        assert 0.0 <= score <= 1.0
        
        # 测试有器械的情况
        score_with_equipment = ai_service._calculate_confidence_score("减脂", "中级", ["哑铃"])
        score_without_equipment = ai_service._calculate_confidence_score("减脂", "中级", [])
        assert score_with_equipment <= score_without_equipment
