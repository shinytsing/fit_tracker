"""
FitTracker Backend - BMI计算器单元测试
"""

import pytest
from unittest.mock import Mock, patch
from sqlalchemy.orm import Session
from datetime import datetime
import uuid

from app.services.bmi_service import BMIService
from app.schemas.bmi import (
    BMIRecordCreate,
    BMIRecordUpdate,
    BMICategory,
    Gender,
    BMICalculationRequest
)
from app.models import BMIRecord

class TestBMIService:
    """BMI计算器服务测试"""
    
    @pytest.fixture
    def mock_db(self):
        """模拟数据库会话"""
        return Mock(spec=Session)
    
    @pytest.fixture
    def bmi_service(self, mock_db):
        """创建BMI服务实例"""
        return BMIService(mock_db)
    
    @pytest.fixture
    def sample_record_data(self):
        """示例BMI记录数据"""
        return BMIRecordCreate(
            height=175.0,
            weight=70.0,
            bmi=22.9,
            category=BMICategory.NORMAL,
            age=25,
            gender=Gender.MALE,
            notes="测试记录"
        )
    
    def test_calculate_bmi_normal(self, bmi_service):
        """测试正常BMI计算"""
        result = bmi_service.calculate_bmi(
            user_id="test_user",
            height=175.0,
            weight=70.0,
            age=25,
            gender=Gender.MALE
        )
        
        # 验证BMI计算
        expected_bmi = 70.0 / (1.75 * 1.75)  # 22.86
        assert abs(result.bmi - expected_bmi) < 0.1
        assert result.category == BMICategory.NORMAL
        assert result.health_status == "健康"
        assert len(result.advice) > 0
        assert len(result.recommendations) > 0
    
    def test_calculate_bmi_underweight(self, bmi_service):
        """测试偏瘦BMI计算"""
        result = bmi_service.calculate_bmi(
            user_id="test_user",
            height=175.0,
            weight=50.0,
            age=25,
            gender=Gender.MALE
        )
        
        assert result.category == BMICategory.UNDERWEIGHT
        assert "偏瘦" in result.health_status
        assert "增加营养摄入" in result.advice[0]
    
    def test_calculate_bmi_overweight(self, bmi_service):
        """测试偏胖BMI计算"""
        result = bmi_service.calculate_bmi(
            user_id="test_user",
            height=175.0,
            weight=85.0,
            age=25,
            gender=Gender.MALE
        )
        
        assert result.category == BMICategory.OVERWEIGHT
        assert "偏胖" in result.health_status
        assert "控制饮食" in result.advice[0]
    
    def test_calculate_bmi_obese(self, bmi_service):
        """测试肥胖BMI计算"""
        result = bmi_service.calculate_bmi(
            user_id="test_user",
            height=175.0,
            weight=100.0,
            age=25,
            gender=Gender.MALE
        )
        
        assert result.category == BMICategory.OBESE
        assert "肥胖" in result.health_status
        assert "咨询专业医生" in result.advice[0]
    
    def test_create_record_success(self, bmi_service, mock_db, sample_record_data):
        """测试成功创建BMI记录"""
        user_id = str(uuid.uuid4())
        
        # 模拟数据库操作
        mock_db.add = Mock()
        mock_db.commit = Mock()
        mock_db.refresh = Mock()
        
        # 执行创建
        result = bmi_service.create_record(user_id, sample_record_data)
        
        # 验证结果
        assert result.height == sample_record_data.height
        assert result.weight == sample_record_data.weight
        assert result.bmi == sample_record_data.bmi
        assert result.category == sample_record_data.category
        assert result.user_id == user_id
        
        # 验证数据库操作
        mock_db.add.assert_called_once()
        mock_db.commit.assert_called_once()
        mock_db.refresh.assert_called_once()
    
    def test_get_user_records(self, bmi_service, mock_db):
        """测试获取用户BMI记录列表"""
        user_id = str(uuid.uuid4())
        
        # 模拟查询结果
        mock_records = [
            BMIRecord(
                id=str(uuid.uuid4()),
                user_id=user_id,
                height=175.0,
                weight=70.0,
                bmi=22.9,
                category="正常",
                age=25,
                gender="男",
                notes="记录1",
                recorded_at=datetime.utcnow()
            ),
            BMIRecord(
                id=str(uuid.uuid4()),
                user_id=user_id,
                height=175.0,
                weight=72.0,
                bmi=23.5,
                category="正常",
                age=25,
                gender="男",
                notes="记录2",
                recorded_at=datetime.utcnow()
            )
        ]
        
        # 模拟数据库查询
        mock_query = Mock()
        mock_query.filter.return_value = mock_query
        mock_query.order_by.return_value = mock_query
        mock_query.offset.return_value = mock_query
        mock_query.limit.return_value = mock_query
        mock_query.all.return_value = mock_records
        
        mock_db.query.return_value = mock_query
        
        # 执行查询
        result = bmi_service.get_user_records(user_id, skip=0, limit=20)
        
        # 验证结果
        assert len(result) == 2
        assert result[0].bmi == 22.9
        assert result[1].bmi == 23.5
        
        # 验证查询调用
        mock_db.query.assert_called_once_with(BMIRecord)
    
    def test_get_record_by_id_success(self, bmi_service, mock_db):
        """测试根据ID获取BMI记录成功"""
        user_id = str(uuid.uuid4())
        record_id = str(uuid.uuid4())
        
        # 模拟查询结果
        mock_record = BMIRecord(
            id=record_id,
            user_id=user_id,
            height=175.0,
            weight=70.0,
            bmi=22.9,
            category="正常",
            age=25,
            gender="男",
            notes="测试记录",
            recorded_at=datetime.utcnow()
        )
        
        # 模拟数据库查询
        mock_query = Mock()
        mock_query.filter.return_value = mock_query
        mock_query.first.return_value = mock_record
        
        mock_db.query.return_value = mock_query
        
        # 执行查询
        result = bmi_service.get_record_by_id(record_id, user_id)
        
        # 验证结果
        assert result is not None
        assert result.id == record_id
        assert result.bmi == 22.9
    
    def test_get_record_by_id_not_found(self, bmi_service, mock_db):
        """测试根据ID获取BMI记录不存在"""
        user_id = str(uuid.uuid4())
        record_id = str(uuid.uuid4())
        
        # 模拟查询结果为空
        mock_query = Mock()
        mock_query.filter.return_value = mock_query
        mock_query.first.return_value = None
        
        mock_db.query.return_value = mock_query
        
        # 执行查询
        result = bmi_service.get_record_by_id(record_id, user_id)
        
        # 验证结果
        assert result is None
    
    def test_update_record_success(self, bmi_service, mock_db):
        """测试更新BMI记录成功"""
        user_id = str(uuid.uuid4())
        record_id = str(uuid.uuid4())
        
        # 模拟现有记录
        mock_record = BMIRecord(
            id=record_id,
            user_id=user_id,
            height=175.0,
            weight=70.0,
            bmi=22.9,
            category="正常",
            age=25,
            gender="男",
            notes="原记录",
            recorded_at=datetime.utcnow()
        )
        
        # 模拟更新数据
        update_data = BMIRecordUpdate(
            weight=72.0,
            bmi=23.5,
            notes="更新记录"
        )
        
        # 模拟数据库查询
        mock_query = Mock()
        mock_query.filter.return_value = mock_query
        mock_query.first.return_value = mock_record
        
        mock_db.query.return_value = mock_query
        mock_db.commit = Mock()
        mock_db.refresh = Mock()
        
        # 执行更新
        result = bmi_service.update_record(record_id, user_id, update_data)
        
        # 验证结果
        assert result is not None
        assert result.weight == 72.0
        assert result.bmi == 23.5
        assert result.notes == "更新记录"
        
        # 验证数据库操作
        mock_db.commit.assert_called_once()
        mock_db.refresh.assert_called_once()
    
    def test_delete_record_success(self, bmi_service, mock_db):
        """测试删除BMI记录成功"""
        user_id = str(uuid.uuid4())
        record_id = str(uuid.uuid4())
        
        # 模拟现有记录
        mock_record = BMIRecord(
            id=record_id,
            user_id=user_id,
            height=175.0,
            weight=70.0,
            bmi=22.9,
            category="正常",
            age=25,
            gender="男",
            notes="测试记录",
            recorded_at=datetime.utcnow()
        )
        
        # 模拟数据库查询
        mock_query = Mock()
        mock_query.filter.return_value = mock_query
        mock_query.first.return_value = mock_record
        
        mock_db.query.return_value = mock_query
        mock_db.delete = Mock()
        mock_db.commit = Mock()
        
        # 执行删除
        result = bmi_service.delete_record(record_id, user_id)
        
        # 验证结果
        assert result is True
        
        # 验证数据库操作
        mock_db.delete.assert_called_once_with(mock_record)
        mock_db.commit.assert_called_once()
    
    def test_get_user_stats(self, bmi_service, mock_db):
        """测试获取用户BMI统计"""
        user_id = str(uuid.uuid4())
        
        # 模拟BMI记录查询
        mock_query = Mock()
        mock_query.filter.return_value = mock_query
        mock_query.order_by.return_value = mock_query
        mock_query.first.return_value = Mock(bmi=22.9)
        mock_query.count.return_value = 5
        mock_query.with_entities.return_value = mock_query
        mock_query.scalar.return_value = 22.9
        
        mock_db.query.return_value = mock_query
        
        # 执行查询
        result = bmi_service.get_user_stats(user_id, "month")
        
        # 验证结果
        assert result.total_records == 5
        assert result.average_bmi == 22.9
        assert result.current_bmi == 22.9
        assert result.period == "month"
        assert result.health_score >= 0.0
        assert result.health_score <= 100.0
    
    def test_get_bmi_trend(self, bmi_service, mock_db):
        """测试获取BMI趋势"""
        user_id = str(uuid.uuid4())
        
        # 模拟趋势记录
        mock_records = [
            BMIRecord(
                id="1",
                user_id=user_id,
                height=175.0,
                weight=70.0,
                bmi=22.9,
                category="正常",
                age=25,
                gender="男",
                notes="",
                recorded_at=datetime.utcnow()
            ),
            BMIRecord(
                id="2",
                user_id=user_id,
                height=175.0,
                weight=72.0,
                bmi=23.5,
                category="正常",
                age=25,
                gender="男",
                notes="",
                recorded_at=datetime.utcnow()
            )
        ]
        
        # 模拟数据库查询
        mock_query = Mock()
        mock_query.filter.return_value = mock_query
        mock_query.order_by.return_value = mock_query
        mock_query.all.return_value = mock_records
        
        mock_db.query.return_value = mock_query
        
        # 执行查询
        result = bmi_service.get_bmi_trend(user_id, 30)
        
        # 验证结果
        assert result.user_id == user_id
        assert result.period_days == 30
        assert len(result.trend_points) == 2
        assert result.trend_points[0].bmi == 22.9
        assert result.trend_points[1].bmi == 23.5
        assert result.trend_direction in ["up", "down", "stable"]
    
    def test_get_health_advice(self, bmi_service, mock_db):
        """测试获取健康建议"""
        user_id = str(uuid.uuid4())
        
        result = bmi_service.get_health_advice(user_id, 22.9)
        
        # 验证结果
        assert result.bmi == 22.9
        assert result.category == BMICategory.NORMAL
        assert len(result.general_advice) > 0
        assert len(result.specific_recommendations) > 0
        assert len(result.dietary_suggestions) > 0
        assert len(result.exercise_recommendations) > 0
        assert len(result.lifestyle_tips) > 0
        assert len(result.warning_signs) > 0
        assert len(result.follow_up_schedule) > 0
    
    def test_bmi_category_classification(self, bmi_service):
        """测试BMI分类"""
        # 测试各种BMI值的分类
        assert bmi_service._get_bmi_category(17.0) == BMICategory.UNDERWEIGHT
        assert bmi_service._get_bmi_category(22.0) == BMICategory.NORMAL
        assert bmi_service._get_bmi_category(25.0) == BMICategory.OVERWEIGHT
        assert bmi_service._get_bmi_category(30.0) == BMICategory.OBESE
    
    def test_health_score_calculation(self, bmi_service):
        """测试健康分数计算"""
        # 测试正常BMI的健康分数
        score = bmi_service._calculate_health_score(22.0, 0.0, 10)
        assert 0.0 <= score <= 100.0
        
        # 测试偏胖BMI的健康分数
        score = bmi_service._calculate_health_score(26.0, 1.0, 5)
        assert 0.0 <= score <= 100.0
        
        # 测试肥胖BMI的健康分数
        score = bmi_service._calculate_health_score(32.0, 2.0, 2)
        assert 0.0 <= score <= 100.0
