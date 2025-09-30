#!/usr/bin/env python3
"""
简单的功能测试脚本
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.services.workout_service import WorkoutService
from app.services.bmi_service import BMIService
from app.services.ai_service import AIService

def test_workout_service():
    """测试健身服务"""
    print("🧪 测试健身服务...")
    
    # 创建模拟数据库会话
    class MockDBSession:
        def add(self, obj):
            pass
        def commit(self):
            pass
        def refresh(self, obj):
            pass
        def query(self, model):
            return MockQuery()
    
    class MockQuery:
        def filter(self, *args):
            return self
        def first(self):
            return None
        def all(self):
            return []
        def order_by(self, *args):
            return self
    
    mock_db = MockDBSession()
    workout_service = WorkoutService(mock_db)
    
    # 测试创建训练计划
    try:
        plan_data = {
            "name": "测试训练计划",
            "type": "减脂",
            "difficulty": "初级",
            "duration": 4,
            "description": "测试描述"
        }
        result = workout_service.create_workout_plan(plan_data, "test_user_id")
        print(f"✅ 创建训练计划成功: {result.name}")
    except Exception as e:
        print(f"❌ 创建训练计划失败: {e}")
    
    print("✅ 健身服务测试完成\n")

def test_bmi_service():
    """测试BMI服务"""
    print("🧪 测试BMI服务...")
    
    # 创建模拟数据库会话
    class MockDBSession:
        def add(self, obj):
            pass
        def commit(self):
            pass
        def refresh(self, obj):
            pass
        def query(self, model):
            return MockQuery()
    
    class MockQuery:
        def filter(self, *args):
            return self
        def first(self):
            return None
        def all(self):
            return []
        def order_by(self, *args):
            return self
    
    mock_db = MockDBSession()
    bmi_service = BMIService(mock_db)
    
    # 测试BMI计算
    try:
        result = bmi_service.calculate_bmi_and_advice(70.0, 175.0, "test_user_id")
        print(f"✅ BMI计算成功: {result['bmi']:.1f}, 状态: {result['status']}")
    except Exception as e:
        print(f"❌ BMI计算失败: {e}")
    
    print("✅ BMI服务测试完成\n")

def test_ai_service():
    """测试AI服务"""
    print("🧪 测试AI服务...")
    
    ai_service = AIService()
    
    # 测试AI训练计划生成
    try:
        result = ai_service.generate_personalized_workout_plan(
            goal="减脂",
            difficulty="中级",
            duration=4,
            user_id="test_user_id"
        )
        print(f"✅ AI训练计划生成成功: {result.name}")
        print(f"   包含 {len(result.exercises)} 个动作")
    except Exception as e:
        print(f"❌ AI训练计划生成失败: {e}")
    
    print("✅ AI服务测试完成\n")

def main():
    """主测试函数"""
    print("🚀 开始功能测试...\n")
    
    test_workout_service()
    test_bmi_service()
    test_ai_service()
    
    print("🎉 所有测试完成！")

if __name__ == "__main__":
    main()
