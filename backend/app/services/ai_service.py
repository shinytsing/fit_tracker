"""
FitTracker Backend - AI服务
集成多LLM API支持
"""

import json
import random
from typing import List, Dict, Any, Optional
from datetime import datetime

from app.schemas.workout import (
    AIPlanRequest,
    TrainingPlanCreate,
    PlanType,
    DifficultyLevel,
    ExerciseCategory
)

# 导入新的AI服务
try:
    from .llm_manager import call_llm
    from .ai_coach_service import ai_coach_service
    from .ai_nutritionist_service import ai_nutritionist_service
    LLM_AVAILABLE = True
except ImportError:
    LLM_AVAILABLE = False
    import logging
    logging.warning("LLM服务未配置，使用模拟AI响应")

class AIService:
    """AI服务类，用于生成训练计划和动作分析"""
    
    def __init__(self):
        self.exercise_database = self._load_exercise_database()
    
    def _load_exercise_database(self) -> Dict[str, List[Dict[str, Any]]]:
        """加载运动动作数据库"""
        return {
            "减脂": [
                {
                    "name": "深蹲",
                    "category": "力量",
                    "muscle_groups": ["腿部", "臀部"],
                    "equipment": "无器械",
                    "difficulty": "初级",
                    "instructions": "双脚与肩同宽，下蹲至大腿与地面平行，然后站起",
                    "sets": 3,
                    "reps": 15,
                    "duration": 300
                },
                {
                    "name": "俯卧撑",
                    "category": "力量",
                    "muscle_groups": ["胸部", "手臂"],
                    "equipment": "无器械",
                    "difficulty": "中级",
                    "instructions": "保持身体挺直，下压至胸部接近地面，然后推起",
                    "sets": 3,
                    "reps": 12,
                    "duration": 240
                },
                {
                    "name": "开合跳",
                    "category": "有氧",
                    "muscle_groups": ["全身"],
                    "equipment": "无器械",
                    "difficulty": "初级",
                    "instructions": "双脚并拢站立，跳起时双脚分开，手臂上举",
                    "sets": 4,
                    "reps": 30,
                    "duration": 180
                }
            ],
            "增肌": [
                {
                    "name": "卧推",
                    "category": "力量",
                    "muscle_groups": ["胸部", "手臂"],
                    "equipment": "杠铃",
                    "difficulty": "高级",
                    "instructions": "平躺在卧推凳上，推举杠铃至胸部上方",
                    "sets": 4,
                    "reps": 8,
                    "duration": 480
                },
                {
                    "name": "硬拉",
                    "category": "力量",
                    "muscle_groups": ["背部", "腿部"],
                    "equipment": "杠铃",
                    "difficulty": "高级",
                    "instructions": "从地面拉起杠铃至站立位置，保持背部挺直",
                    "sets": 4,
                    "reps": 6,
                    "duration": 600
                },
                {
                    "name": "引体向上",
                    "category": "力量",
                    "muscle_groups": ["背部", "手臂"],
                    "equipment": "单杠",
                    "difficulty": "中级",
                    "instructions": "悬挂在单杠上，拉起身体至下巴超过横杆",
                    "sets": 3,
                    "reps": 10,
                    "duration": 360
                }
            ],
            "力量": [
                {
                    "name": "深蹲",
                    "category": "力量",
                    "muscle_groups": ["腿部", "臀部"],
                    "equipment": "无器械",
                    "difficulty": "初级",
                    "instructions": "双脚与肩同宽，下蹲至大腿与地面平行",
                    "sets": 4,
                    "reps": 12,
                    "duration": 360
                },
                {
                    "name": "平板支撑",
                    "category": "力量",
                    "muscle_groups": ["核心", "全身"],
                    "equipment": "无器械",
                    "difficulty": "中级",
                    "instructions": "保持身体挺直，支撑在肘部和脚尖上",
                    "sets": 3,
                    "reps": 1,
                    "duration": 300
                }
            ]
        }
    
    async def generate_workout_plan(self, goal: str, difficulty: str, duration: int,
                                  available_equipment: List[str],
                                  user_preferences: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """生成AI训练计划（使用LLM增强）"""
        
        # 如果LLM可用，使用AI教练服务生成计划
        if LLM_AVAILABLE:
            try:
                user_profile = {
                    "goals": goal,
                    "fitness_level": difficulty,
                    "available_time": duration,
                    "equipment": available_equipment or ["基础器械"],
                    "preferences": user_preferences or {}
                }
                
                ai_result = await ai_coach_service.generate_workout_plan(user_profile)
                
                if ai_result.get("success"):
                    plan_data = ai_result.get("workout_plan", {})
                    
                    # 将LLM生成的计划与本地动作库结合
                    base_exercises = self.exercise_database.get(goal, self.exercise_database["减脂"])
                    plan_exercises = self._enhance_with_local_exercises(plan_data, base_exercises)
                    
                    return {
                        "name": plan_data.get("plan_name", f"AI {goal} 训练计划"),
                        "type": goal,
                        "difficulty": difficulty,
                        "duration": duration,
                        "description": plan_data.get("ai_response", f"AI生成的{goal}训练计划"),
                        "exercises": plan_exercises,
                        "suggestions": plan_data.get("nutrition_tips", "保持均衡饮食"),
                        "confidence_score": 0.95,
                        "ai_powered": True,
                        "ai_provider": ai_result.get("ai_provider")
                    }
            except Exception as e:
                import logging
                logging.warning(f"LLM生成计划失败，使用备用方案: {str(e)}")
        
        # 备用方案：使用原有的本地生成逻辑
        base_exercises = self.exercise_database.get(goal, self.exercise_database["减脂"])
        filtered_exercises = self._filter_by_difficulty(base_exercises, difficulty)
        
        if available_equipment:
            filtered_exercises = self._filter_by_equipment(filtered_exercises, available_equipment)
        
        plan_exercises = self._generate_exercise_plan(filtered_exercises, duration)
        plan_name = f"AI {goal} 训练计划"
        description = self._generate_plan_description(goal, difficulty, duration, len(plan_exercises))
        suggestions = self._generate_ai_suggestions(goal, difficulty, plan_exercises)
        confidence_score = self._calculate_confidence_score(goal, difficulty, available_equipment)
        
        return {
            "name": plan_name,
            "type": goal,
            "difficulty": difficulty,
            "duration": duration,
            "description": description,
            "exercises": plan_exercises,
            "suggestions": suggestions,
            "confidence_score": confidence_score,
            "ai_powered": False
        }
    
    def _enhance_with_local_exercises(self, ai_plan: Dict[str, Any], local_exercises: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """使用本地动作库增强AI生成的计划"""
        # 简单实现：返回本地动作的子集
        return random.sample(local_exercises, min(3, len(local_exercises)))
    
    def _filter_by_difficulty(self, exercises: List[Dict[str, Any]], difficulty: str) -> List[Dict[str, Any]]:
        """根据难度过滤动作"""
        difficulty_map = {
            "初级": ["初级"],
            "中级": ["初级", "中级"],
            "高级": ["初级", "中级", "高级"]
        }
        
        allowed_difficulties = difficulty_map.get(difficulty, ["初级"])
        return [ex for ex in exercises if ex["difficulty"] in allowed_difficulties]
    
    def _filter_by_equipment(self, exercises: List[Dict[str, Any]], available_equipment: List[str]) -> List[Dict[str, Any]]:
        """根据可用器械过滤动作"""
        filtered = []
        for ex in exercises:
            equipment = ex.get("equipment", "无器械")
            if equipment == "无器械" or equipment in available_equipment:
                filtered.append(ex)
        return filtered
    
    def _generate_exercise_plan(self, exercises: List[Dict[str, Any]], duration: int) -> List[Dict[str, Any]]:
        """生成训练计划中的动作安排"""
        # 根据训练周数选择动作数量
        exercise_count = min(len(exercises), max(3, duration * 2))
        
        # 随机选择动作
        selected_exercises = random.sample(exercises, min(exercise_count, len(exercises)))
        
        # 为每个动作生成训练参数
        plan_exercises = []
        for i, exercise in enumerate(selected_exercises):
            plan_exercise = {
                "exercise_id": f"ai_exercise_{i+1}",
                "name": exercise["name"],
                "category": exercise["category"],
                "muscle_groups": exercise["muscle_groups"],
                "equipment": exercise["equipment"],
                "difficulty": exercise["difficulty"],
                "instructions": exercise["instructions"],
                "sets": exercise["sets"],
                "reps": exercise["reps"],
                "duration": exercise["duration"],
                "rest_time": 60,  # 休息时间（秒）
                "order": i + 1
            }
            plan_exercises.append(plan_exercise)
        
        return plan_exercises
    
    def _generate_plan_description(self, goal: str, difficulty: str, duration: int, exercise_count: int) -> str:
        """生成计划描述"""
        descriptions = {
            "减脂": f"这是一个为期{duration}周的减脂训练计划，包含{exercise_count}个精选动作，适合{difficulty}水平的用户。计划注重有氧运动和力量训练的结合，帮助您有效燃烧脂肪，塑造理想身材。",
            "增肌": f"这是一个为期{duration}周的增肌训练计划，包含{exercise_count}个专业动作，适合{difficulty}水平的用户。计划注重力量训练和肌肉刺激，帮助您增加肌肉质量和力量。",
            "力量": f"这是一个为期{duration}周的力量训练计划，包含{exercise_count}个核心动作，适合{difficulty}水平的用户。计划注重基础力量训练，帮助您提升整体力量水平。"
        }
        
        return descriptions.get(goal, f"这是一个为期{duration}周的综合训练计划，包含{exercise_count}个动作，适合{difficulty}水平的用户。")
    
    def _generate_ai_suggestions(self, goal: str, difficulty: str, exercises: List[Dict[str, Any]]) -> List[str]:
        """生成AI建议"""
        suggestions = [
            "💡 建议在训练前进行5-10分钟的热身运动",
            "💡 训练过程中保持正确的动作姿势，避免受伤",
            "💡 根据个人情况适当调整训练强度和次数",
            "💡 训练后进行拉伸放松，促进肌肉恢复",
            "💡 保持规律的训练频率，建议每周3-4次"
        ]
        
        if goal == "减脂":
            suggestions.extend([
                "🔥 减脂期间建议配合有氧运动，如跑步、游泳等",
                "🥗 注意饮食控制，保持热量赤字",
                "💧 多喝水，保持身体水分平衡"
            ])
        elif goal == "增肌":
            suggestions.extend([
                "🍖 增肌期间需要充足的蛋白质摄入",
                "😴 保证充足的睡眠，促进肌肉恢复",
                "📈 逐渐增加训练重量，持续挑战肌肉"
            ])
        
        return suggestions
    
    def _calculate_confidence_score(self, goal: str, difficulty: str, equipment: List[str]) -> float:
        """计算AI计划的置信度分数"""
        base_score = 0.8
        
        # 根据目标调整分数
        goal_scores = {"减脂": 0.9, "增肌": 0.85, "力量": 0.8}
        base_score *= goal_scores.get(goal, 0.8)
        
        # 根据难度调整分数
        difficulty_scores = {"初级": 0.9, "中级": 0.85, "高级": 0.8}
        base_score *= difficulty_scores.get(difficulty, 0.8)
        
        # 根据器械可用性调整分数
        if equipment:
            base_score *= 0.95
        
        return min(base_score, 1.0)
    
    async def analyze_exercise_feedback(self, exercise: Any, user_feedback: Dict[str, Any], 
                                      user_id: str) -> Dict[str, Any]:
        """分析动作反馈"""
        
        # 模拟AI分析
        form_score = user_feedback.get("form_score", 7.5)
        difficulty_rating = user_feedback.get("difficulty_rating", 3)
        completion_percentage = user_feedback.get("completion_percentage", 85.0)
        
        # 生成反馈
        if form_score >= 8.0:
            feedback = "动作完成得很好！继续保持正确的姿势。"
        elif form_score >= 6.0:
            feedback = "动作基本正确，但还有改进空间。注意保持身体稳定。"
        else:
            feedback = "动作需要改进，建议降低难度或寻求专业指导。"
        
        # 生成建议
        suggestions = []
        if completion_percentage < 80:
            suggestions.append("建议降低训练强度，确保动作质量")
        if difficulty_rating > 4:
            suggestions.append("动作难度较高，建议先掌握基础动作")
        if form_score < 7:
            suggestions.append("注意动作标准性，避免受伤")
        
        # 生成改进建议
        improvement_tips = [
            "保持核心稳定，避免身体晃动",
            "控制动作速度，避免快速完成",
            "注意呼吸节奏，用力时呼气",
            "如果感到疼痛，立即停止训练"
        ]
        
        # 计算正确性分数
        correctness_score = (form_score / 10.0) * 0.6 + (completion_percentage / 100.0) * 0.4
        
        return {
            "feedback": feedback,
            "suggestions": suggestions,
            "correctness_score": correctness_score,
            "improvement_tips": improvement_tips
        }
