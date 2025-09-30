"""
AI教练服务 - 提供个性化训练建议和指导
使用多LLM API支持
"""
from typing import Dict, List, Optional, Any
from datetime import datetime
import json
import logging
from .llm_manager import call_llm

logger = logging.getLogger(__name__)

class AICoachService:
    """AI教练服务类"""
    
    def __init__(self):
        self.coach_name = "FitCoach AI"
    
    async def generate_workout_plan(self, user_profile: Dict[str, Any]) -> Dict[str, Any]:
        """
        生成个性化训练计划
        
        Args:
            user_profile: 用户信息
                - age: 年龄
                - gender: 性别
                - height: 身高(cm)
                - weight: 体重(kg)
                - fitness_level: 健身水平 (beginner/intermediate/advanced)
                - goals: 健身目标 (weight_loss/muscle_gain/endurance/general_fitness)
                - available_time: 每周可用时间(小时)
                - equipment: 可用器械
                - injuries: 伤病情况
                - preferences: 运动偏好
        
        Returns:
            个性化训练计划
        """
        try:
            prompt = self._build_workout_plan_prompt(user_profile)
            
            messages = [
                {"role": "user", "content": prompt}
            ]
            
            response = await call_llm(messages)
            
            # 解析AI响应并格式化为结构化数据
            workout_plan = self._parse_workout_plan_response(response['content'], user_profile)
            
            return {
                "success": True,
                "workout_plan": workout_plan,
                "generated_at": datetime.now().isoformat(),
                "ai_provider": response.get('provider', 'Unknown'),
                "ai_model": response.get('model', 'Unknown')
            }
            
        except Exception as e:
            logger.error(f"生成训练计划失败: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "generated_at": datetime.now().isoformat()
            }
    
    async def get_exercise_guidance(self, exercise_name: str, user_level: str) -> Dict[str, Any]:
        """
        获取特定动作的指导建议
        
        Args:
            exercise_name: 动作名称
            user_level: 用户水平 (beginner/intermediate/advanced)
        
        Returns:
            动作指导信息
        """
        try:
            level_map = {
                'beginner': '初学者',
                'intermediate': '中级',
                'advanced': '高级'
            }
            level_name = level_map.get(user_level, '初学者')
            
            prompt = f"""
            请为{level_name}水平的用户提供"{exercise_name}"动作的详细指导，包括：
            
            1. 动作要领和技巧
            2. 常见错误和纠正方法
            3. 呼吸方法
            4. 适合的重量/强度建议
            5. 安全注意事项
            6. 替代动作（如果有）
            
            请用专业但易懂的语言，提供实用的建议。用中文回答。
            """
            
            messages = [
                {"role": "user", "content": prompt}
            ]
            
            response = await call_llm(messages)
            
            return {
                "success": True,
                "exercise_name": exercise_name,
                "user_level": user_level,
                "guidance": response['content'],
                "generated_at": datetime.now().isoformat(),
                "ai_provider": response.get('provider', 'Unknown')
            }
            
        except Exception as e:
            logger.error(f"获取动作指导失败: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "generated_at": datetime.now().isoformat()
            }
    
    async def analyze_workout_progress(self, workout_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        分析训练进度并提供建议
        
        Args:
            workout_data: 训练数据
                - recent_workouts: 最近训练记录
                - performance_metrics: 表现指标
                - goals: 目标设定
                - time_period: 分析时间段
        
        Returns:
            进度分析报告
        """
        try:
            prompt = self._build_progress_analysis_prompt(workout_data)
            
            messages = [
                {"role": "user", "content": prompt}
            ]
            
            response = await call_llm(messages)
            
            return {
                "success": True,
                "analysis": response['content'],
                "analyzed_at": datetime.now().isoformat(),
                "data_period": workout_data.get('time_period', 'recent'),
                "ai_provider": response.get('provider', 'Unknown')
            }
            
        except Exception as e:
            logger.error(f"分析训练进度失败: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "analyzed_at": datetime.now().isoformat()
            }
    
    async def chat_with_coach(self, message: str, context: Dict[str, Any]) -> Dict[str, Any]:
        """
        与AI教练对话
        
        Args:
            message: 用户消息
            context: 对话上下文（用户信息、历史对话等）
        
        Returns:
            AI教练回复
        """
        try:
            system_prompt = self._build_coach_system_prompt(context)
            
            messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": message}
            ]
            
            response = await call_llm(messages)
            
            return {
                "success": True,
                "message": response['content'],
                "timestamp": datetime.now().isoformat(),
                "context_used": bool(context),
                "ai_provider": response.get('provider', 'Unknown')
            }
            
        except Exception as e:
            logger.error(f"AI教练对话失败: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
    
    def _build_workout_plan_prompt(self, user_profile: Dict[str, Any]) -> str:
        """构建训练计划生成提示词"""
        return f"""
        你是一位专业的健身教练，请为以下用户制定个性化的训练计划：

        用户信息：
        - 年龄：{user_profile.get('age', '未知')}岁
        - 性别：{user_profile.get('gender', '未知')}
        - 身高：{user_profile.get('height', '未知')}cm
        - 体重：{user_profile.get('weight', '未知')}kg
        - 健身水平：{user_profile.get('fitness_level', '初学者')}
        - 健身目标：{user_profile.get('goals', '一般健身')}
        - 每周可用时间：{user_profile.get('available_time', '未知')}小时
        - 可用器械：{user_profile.get('equipment', '基础器械')}
        - 伤病情况：{user_profile.get('injuries', '无')}
        - 运动偏好：{user_profile.get('preferences', '无特殊偏好')}

        请制定一个详细的训练计划，包括：
        1. 训练频率和时长安排
        2. 具体的训练动作和组数
        3. 强度建议
        4. 休息时间安排
        5. 进度调整建议
        6. 营养配合建议
        7. 安全注意事项

        请用JSON格式返回，包含plan_name, duration_weeks, weekly_schedule, exercises, nutrition_tips, safety_notes等字段。
        """
    
    def _build_progress_analysis_prompt(self, workout_data: Dict[str, Any]) -> str:
        """构建进度分析提示词"""
        return f"""
        你是一位专业的健身教练，请分析以下训练数据并提供专业建议：

        训练数据：
        {json.dumps(workout_data, ensure_ascii=False, indent=2)}

        请分析：
        1. 训练强度和频率是否合适
        2. 进步趋势分析
        3. 需要改进的地方
        4. 下一步训练建议
        5. 目标达成情况评估

        请提供具体、可操作的建议。用中文回答。
        """
    
    def _build_coach_system_prompt(self, context: Dict[str, Any]) -> str:
        """构建AI教练系统提示词"""
        user_info = context.get('user_info', {})
        
        return f"""
        你是一位专业、热情、耐心的AI健身教练。你的名字是"{self.coach_name}"。

        用户基本信息：
        - 年龄：{user_info.get('age', '未知')}岁
        - 性别：{user_info.get('gender', '未知')}
        - 健身水平：{user_info.get('fitness_level', '初学者')}
        - 健身目标：{user_info.get('goals', '一般健身')}

        你的特点：
        1. 专业：提供科学、准确的健身建议
        2. 热情：用积极正面的语言鼓励用户
        3. 耐心：详细解释每个建议的原因
        4. 个性化：根据用户情况调整建议
        5. 安全第一：始终优先考虑用户安全

        回答要求：
        - 用中文回答
        - 语言友好、专业
        - 提供具体、可操作的建议
        - 适当使用emoji增加亲和力
        - 如果涉及专业医学问题，建议咨询医生
        """
    
    def _parse_workout_plan_response(self, response: str, user_profile: Dict[str, Any]) -> Dict[str, Any]:
        """解析AI响应为结构化训练计划"""
        try:
            # 尝试解析JSON响应
            if response.strip().startswith('{'):
                return json.loads(response)
        except json.JSONDecodeError:
            pass
        
        # 如果不是JSON格式，创建默认结构
        return {
            "plan_name": f"{user_profile.get('goals', '健身')}训练计划",
            "duration_weeks": 8,
            "weekly_schedule": {
                "monday": "胸部和三头肌训练",
                "tuesday": "休息",
                "wednesday": "背部和二头肌训练", 
                "thursday": "休息",
                "friday": "腿部和肩部训练",
                "saturday": "有氧运动",
                "sunday": "休息"
            },
            "exercises": [],
            "nutrition_tips": "保持均衡饮食，适量蛋白质摄入",
            "safety_notes": "训练前充分热身，注意动作标准",
            "ai_response": response
        }

# 全局AI教练服务实例
ai_coach_service = AICoachService()
