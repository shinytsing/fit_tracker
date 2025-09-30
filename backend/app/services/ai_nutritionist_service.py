"""
AI营养师服务 - 提供个性化营养建议和饮食计划
使用多LLM API支持
"""
from typing import Dict, List, Optional, Any
from datetime import datetime
import json
import logging
from .llm_manager import call_llm

logger = logging.getLogger(__name__)

class AINutritionistService:
    """AI营养师服务类"""
    
    def __init__(self):
        self.nutritionist_name = "NutriCoach AI"
    
    async def generate_meal_plan(self, user_profile: Dict[str, Any]) -> Dict[str, Any]:
        """
        生成个性化饮食计划
        
        Args:
            user_profile: 用户信息
                - age: 年龄
                - gender: 性别
                - height: 身高(cm)
                - weight: 体重(kg)
                - target_weight: 目标体重(kg)
                - activity_level: 活动水平
                - dietary_restrictions: 饮食限制
                - health_goals: 健康目标
                - allergies: 过敏信息
                - preferences: 饮食偏好
        
        Returns:
            个性化饮食计划
        """
        try:
            prompt = self._build_meal_plan_prompt(user_profile)
            
            messages = [
                {"role": "user", "content": prompt}
            ]
            
            response = await call_llm(messages, max_tokens=3000)
            
            # 解析AI响应并格式化为结构化数据
            meal_plan = self._parse_meal_plan_response(response['content'], user_profile)
            
            return {
                "success": True,
                "meal_plan": meal_plan,
                "generated_at": datetime.now().isoformat(),
                "ai_provider": response.get('provider', 'Unknown'),
                "ai_model": response.get('model', 'Unknown')
            }
            
        except Exception as e:
            logger.error(f"生成饮食计划失败: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "generated_at": datetime.now().isoformat()
            }
    
    async def analyze_nutrition(self, food_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        分析食物营养成分
        
        Args:
            food_data: 食物数据
                - food_name: 食物名称
                - portion_size: 份量
                - ingredients: 成分（可选）
        
        Returns:
            营养分析报告
        """
        try:
            prompt = f"""
            请分析以下食物的营养成分：

            食物名称：{food_data.get('food_name', '未知')}
            份量：{food_data.get('portion_size', '100g')}
            {f"成分：{food_data.get('ingredients', '')}" if food_data.get('ingredients') else ''}

            请提供详细的营养分析，包括：
            1. 卡路里含量
            2. 三大营养素（蛋白质、碳水化合物、脂肪）
            3. 维生素和矿物质
            4. 健康评估
            5. 适合的人群
            6. 食用建议

            请用JSON格式返回，包含calories, protein, carbs, fat, vitamins, minerals, health_score, recommendations等字段。
            用中文回答。
            """
            
            messages = [
                {"role": "user", "content": prompt}
            ]
            
            response = await call_llm(messages)
            
            nutrition_analysis = self._parse_nutrition_analysis(response['content'])
            
            return {
                "success": True,
                "food_name": food_data.get('food_name'),
                "nutrition_analysis": nutrition_analysis,
                "generated_at": datetime.now().isoformat(),
                "ai_provider": response.get('provider', 'Unknown')
            }
            
        except Exception as e:
            logger.error(f"分析营养成分失败: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "generated_at": datetime.now().isoformat()
            }
    
    async def get_dietary_advice(self, health_condition: str, user_profile: Dict[str, Any]) -> Dict[str, Any]:
        """
        获取针对特定健康状况的饮食建议
        
        Args:
            health_condition: 健康状况（如：高血压、糖尿病、减重等）
            user_profile: 用户信息
        
        Returns:
            饮食建议
        """
        try:
            prompt = f"""
            请为有{health_condition}的用户提供专业的饮食建议：

            用户信息：
            - 年龄：{user_profile.get('age', '未知')}岁
            - 性别：{user_profile.get('gender', '未知')}
            - 当前体重：{user_profile.get('weight', '未知')}kg
            - 活动水平：{user_profile.get('activity_level', '中等')}

            请提供：
            1. 饮食原则和注意事项
            2. 推荐的食物类型
            3. 应避免的食物
            4. 营养素比例建议
            5. 餐食时间安排
            6. 补充剂建议（如需要）

            请用专业但易懂的语言，提供实用的建议。用中文回答。
            """
            
            messages = [
                {"role": "user", "content": prompt}
            ]
            
            response = await call_llm(messages)
            
            return {
                "success": True,
                "health_condition": health_condition,
                "dietary_advice": response['content'],
                "generated_at": datetime.now().isoformat(),
                "ai_provider": response.get('provider', 'Unknown')
            }
            
        except Exception as e:
            logger.error(f"获取饮食建议失败: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "generated_at": datetime.now().isoformat()
            }
    
    async def calculate_macros(self, user_profile: Dict[str, Any]) -> Dict[str, Any]:
        """
        计算用户的宏量营养素需求
        
        Args:
            user_profile: 用户信息
        
        Returns:
            宏量营养素计算结果
        """
        try:
            # 使用AI计算并提供建议
            prompt = f"""
            请为以下用户计算每日宏量营养素需求：

            用户信息：
            - 年龄：{user_profile.get('age', '未知')}岁
            - 性别：{user_profile.get('gender', '未知')}
            - 身高：{user_profile.get('height', '未知')}cm
            - 体重：{user_profile.get('weight', '未知')}kg
            - 目标体重：{user_profile.get('target_weight', user_profile.get('weight', '未知'))}kg
            - 活动水平：{user_profile.get('activity_level', '中等')}
            - 健康目标：{user_profile.get('health_goals', '维持健康')}

            请使用科学的计算方法（如Mifflin-St Jeor公式），提供：
            1. 基础代谢率（BMR）
            2. 总能量消耗（TDEE）
            3. 建议的每日卡路里摄入
            4. 蛋白质需求（克）
            5. 碳水化合物需求（克）
            6. 脂肪需求（克）
            7. 详细说明和建议

            请用JSON格式返回，包含bmr, tdee, calories, protein, carbs, fat, explanation等字段。
            用中文回答。
            """
            
            messages = [
                {"role": "user", "content": prompt}
            ]
            
            response = await call_llm(messages)
            
            macros = self._parse_macros_response(response['content'])
            
            return {
                "success": True,
                "macros": macros,
                "generated_at": datetime.now().isoformat(),
                "ai_provider": response.get('provider', 'Unknown')
            }
            
        except Exception as e:
            logger.error(f"计算宏量营养素失败: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "generated_at": datetime.now().isoformat()
            }
    
    async def chat_with_nutritionist(self, message: str, context: Dict[str, Any]) -> Dict[str, Any]:
        """
        与AI营养师对话
        
        Args:
            message: 用户消息
            context: 对话上下文
        
        Returns:
            AI营养师回复
        """
        try:
            system_prompt = self._build_nutritionist_system_prompt(context)
            
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
            logger.error(f"AI营养师对话失败: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
    
    def _build_meal_plan_prompt(self, user_profile: Dict[str, Any]) -> str:
        """构建饮食计划生成提示词"""
        return f"""
        你是一位专业的营养师，请为以下用户制定个性化的饮食计划：

        用户信息：
        - 年龄：{user_profile.get('age', '未知')}岁
        - 性别：{user_profile.get('gender', '未知')}
        - 身高：{user_profile.get('height', '未知')}cm
        - 当前体重：{user_profile.get('weight', '未知')}kg
        - 目标体重：{user_profile.get('target_weight', user_profile.get('weight', '未知'))}kg
        - 活动水平：{user_profile.get('activity_level', '中等')}
        - 饮食限制：{user_profile.get('dietary_restrictions', '无')}
        - 健康目标：{user_profile.get('health_goals', '维持健康')}
        - 过敏信息：{user_profile.get('allergies', '无')}
        - 饮食偏好：{user_profile.get('preferences', '无特殊偏好')}

        请制定一个详细的一周饮食计划，包括：
        1. 每日三餐和加餐的具体食物
        2. 份量建议
        3. 烹饪方法
        4. 营养素分配
        5. 购物清单
        6. 食谱推荐
        7. 注意事项

        请用JSON格式返回，包含daily_meals, shopping_list, recipes, nutrition_summary, tips等字段。
        用中文回答。
        """
    
    def _build_nutritionist_system_prompt(self, context: Dict[str, Any]) -> str:
        """构建AI营养师系统提示词"""
        user_info = context.get('user_info', {})
        
        return f"""
        你是一位专业、细心、负责的AI营养师。你的名字是"{self.nutritionist_name}"。

        用户基本信息：
        - 年龄：{user_info.get('age', '未知')}岁
        - 性别：{user_info.get('gender', '未知')}
        - 健康目标：{user_info.get('health_goals', '维持健康')}
        - 饮食限制：{user_info.get('dietary_restrictions', '无')}

        你的特点：
        1. 专业：提供科学、准确的营养建议
        2. 细心：考虑用户的具体情况和需求
        3. 负责：提供安全、可行的饮食方案
        4. 个性化：根据用户情况调整建议
        5. 健康第一：优先考虑用户健康

        回答要求：
        - 用中文回答
        - 语言友好、专业
        - 提供具体、可操作的建议
        - 适当使用emoji增加亲和力
        - 涉及严重健康问题时建议咨询医生
        - 不推荐极端或不健康的饮食方法
        """
    
    def _parse_meal_plan_response(self, response: str, user_profile: Dict[str, Any]) -> Dict[str, Any]:
        """解析AI响应为结构化饮食计划"""
        try:
            if response.strip().startswith('{'):
                return json.loads(response)
        except json.JSONDecodeError:
            pass
        
        # 创建默认结构
        return {
            "plan_name": f"{user_profile.get('health_goals', '健康')}饮食计划",
            "duration_days": 7,
            "daily_meals": {},
            "shopping_list": [],
            "nutrition_summary": {
                "daily_calories": 2000,
                "protein": 100,
                "carbs": 250,
                "fat": 70
            },
            "tips": "保持均衡饮食，多喝水",
            "ai_response": response
        }
    
    def _parse_nutrition_analysis(self, response: str) -> Dict[str, Any]:
        """解析营养分析响应"""
        try:
            if response.strip().startswith('{'):
                return json.loads(response)
        except json.JSONDecodeError:
            pass
        
        return {
            "calories": 0,
            "protein": 0,
            "carbs": 0,
            "fat": 0,
            "vitamins": {},
            "minerals": {},
            "health_score": 0,
            "recommendations": response
        }
    
    def _parse_macros_response(self, response: str) -> Dict[str, Any]:
        """解析宏量营养素响应"""
        try:
            if response.strip().startswith('{'):
                return json.loads(response)
        except json.JSONDecodeError:
            pass
        
        return {
            "bmr": 0,
            "tdee": 0,
            "calories": 2000,
            "protein": 100,
            "carbs": 250,
            "fat": 70,
            "explanation": response
        }

# 全局AI营养师服务实例
ai_nutritionist_service = AINutritionistService()
