#!/usr/bin/env python3
"""
FitTracker API 简化测试服务器
用于API测试，不依赖数据库
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import uuid
import datetime
import json

# 创建 FastAPI 应用
app = FastAPI(
    title="FitTracker API Test Server",
    version="1.0.0",
    description="FitTracker - 健身打卡社交应用后端API测试服务器",
)

# 配置 CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 内存数据存储
users_db = {}
bmi_records_db = {}
workout_plans_db = {}
workout_records_db = {}
exercises_db = {}

# Pydantic 模型
class UserCreate(BaseModel):
    username: str
    email: str
    password: str
    phone: Optional[str] = None
    bio: Optional[str] = None
    fitness_goal: Optional[str] = None
    height: Optional[float] = None
    weight: Optional[float] = None
    age: Optional[int] = None
    gender: Optional[str] = None

class UserResponse(BaseModel):
    id: str
    username: str
    email: str
    phone: Optional[str]
    bio: Optional[str]
    fitness_goal: Optional[str]
    height: Optional[float]
    weight: Optional[float]
    age: Optional[int]
    gender: Optional[str]
    is_active: bool = True
    created_at: str
    updated_at: str

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int = 1800

class BMICalculationRequest(BaseModel):
    height: float
    weight: float
    age: int
    gender: str

class BMICalculationResponse(BaseModel):
    bmi: float
    category: str
    recommendation: str

class BMIRecordCreate(BaseModel):
    height: float
    weight: float
    bmi: float
    category: str
    notes: Optional[str] = None

class BMIRecordResponse(BaseModel):
    id: str
    user_id: str
    height: float
    weight: float
    bmi: float
    category: str
    notes: Optional[str]
    created_at: str

class TrainingPlanCreate(BaseModel):
    name: str
    plan_type: str
    difficulty_level: str
    duration_weeks: int
    description: Optional[str] = None
    exercises: List[Dict[str, Any]]

class TrainingPlanResponse(BaseModel):
    id: str
    user_id: str
    name: str
    plan_type: str
    difficulty_level: str
    duration_weeks: int
    description: Optional[str]
    exercises: List[Dict[str, Any]]
    is_active: bool = True
    created_at: str
    updated_at: str

class WorkoutRecordCreate(BaseModel):
    plan_id: str
    exercise_id: str
    sets: int
    reps: int
    weight: Optional[float] = None
    duration: Optional[int] = None
    notes: Optional[str] = None

class WorkoutRecordResponse(BaseModel):
    id: str
    user_id: str
    plan_id: str
    exercise_id: str
    sets: int
    reps: int
    weight: Optional[float]
    duration: Optional[int]
    notes: Optional[str]
    completed_at: str

class AIPlanRequest(BaseModel):
    goal: str
    difficulty: str
    duration: int
    available_equipment: List[str] = []
    user_preferences: Optional[Dict[str, Any]] = None
    fitness_level: Optional[str] = None
    target_muscle_groups: Optional[List[str]] = None
    time_per_session: Optional[int] = None

class AIPlanResponse(BaseModel):
    plan: TrainingPlanResponse
    ai_suggestions: List[str]
    confidence_score: float

# 工具函数
def calculate_bmi(height: float, weight: float) -> tuple:
    """计算BMI值和分类"""
    bmi = weight / ((height / 100) ** 2)
    
    if bmi < 18.5:
        category = "偏瘦"
        recommendation = "建议增加营养摄入，适当增重"
    elif bmi < 24:
        category = "正常"
        recommendation = "保持当前体重，维持健康生活方式"
    elif bmi < 28:
        category = "偏胖"
        recommendation = "建议控制饮食，增加运动量"
    else:
        category = "肥胖"
        recommendation = "建议制定减重计划，咨询专业医生"
    
    return round(bmi, 2), category, recommendation

def generate_token() -> str:
    """生成简单的访问令牌"""
    return f"test_token_{uuid.uuid4().hex[:16]}"

# API 端点

@app.get("/")
async def root():
    """根路径健康检查"""
    return {
        "message": "FitTracker API Test Server",
        "version": "1.0.0",
        "status": "healthy"
    }

@app.get("/health")
async def health_check():
    """健康检查端点"""
    return {
        "status": "healthy",
        "timestamp": datetime.datetime.now().isoformat()
    }

# 认证相关端点
@app.post("/api/v1/auth/register", response_model=UserResponse)
async def register(user_data: UserCreate):
    """用户注册"""
    user_id = str(uuid.uuid4())
    now = datetime.datetime.now().isoformat()
    
    # 检查用户名是否已存在
    for user in users_db.values():
        if user["username"] == user_data.username:
            raise HTTPException(status_code=400, detail="用户名已存在")
    
    # 检查邮箱是否已存在
    for user in users_db.values():
        if user["email"] == user_data.email:
            raise HTTPException(status_code=400, detail="邮箱已存在")
    
    user = {
        "id": user_id,
        "username": user_data.username,
        "email": user_data.email,
        "phone": user_data.phone,
        "bio": user_data.bio,
        "fitness_goal": user_data.fitness_goal,
        "height": user_data.height,
        "weight": user_data.weight,
        "age": user_data.age,
        "gender": user_data.gender,
        "password": user_data.password,  # 实际应用中应该加密
        "is_active": True,
        "created_at": now,
        "updated_at": now
    }
    
    users_db[user_id] = user
    return UserResponse(**user)

class LoginRequest(BaseModel):
    username: str
    password: str

@app.post("/api/v1/auth/login", response_model=Token)
async def login(request: LoginRequest):
    """用户登录"""
    # 查找用户
    user = None
    for u in users_db.values():
        if u["username"] == request.username and u["password"] == request.password:
            user = u
            break
    
    if not user:
        raise HTTPException(status_code=401, detail="用户名或密码错误")
    
    token = generate_token()
    return Token(access_token=token, expires_in=1800)

@app.get("/api/v1/auth/me", response_model=UserResponse)
async def get_current_user(token: str):
    """获取当前用户信息"""
    if not token.startswith("test_token_"):
        raise HTTPException(status_code=401, detail="无效的访问令牌")
    
    # 简化实现：返回第一个用户
    if users_db:
        user_id = list(users_db.keys())[0]
        user = users_db[user_id]
        return UserResponse(**user)
    else:
        raise HTTPException(status_code=404, detail="用户不存在")

# BMI相关端点
@app.post("/api/v1/bmi/calculate", response_model=BMICalculationResponse)
async def calculate_bmi_endpoint(request: BMICalculationRequest, user_id: str):
    """计算BMI"""
    bmi, category, recommendation = calculate_bmi(request.height, request.weight)
    return BMICalculationResponse(
        bmi=bmi,
        category=category,
        recommendation=recommendation
    )

@app.post("/api/v1/bmi/records", response_model=BMIRecordResponse)
async def create_bmi_record(record_data: BMIRecordCreate, user_id: str):
    """创建BMI记录"""
    record_id = str(uuid.uuid4())
    now = datetime.datetime.now().isoformat()
    
    record = {
        "id": record_id,
        "user_id": user_id,
        "height": record_data.height,
        "weight": record_data.weight,
        "bmi": record_data.bmi,
        "category": record_data.category,
        "notes": record_data.notes,
        "created_at": now
    }
    
    bmi_records_db[record_id] = record
    return BMIRecordResponse(**record)

@app.get("/api/v1/bmi/records")
async def get_bmi_records(user_id: str):
    """获取BMI记录列表"""
    user_records = [record for record in bmi_records_db.values() if record["user_id"] == user_id]
    return user_records

@app.get("/api/v1/bmi/stats")
async def get_bmi_stats(user_id: str, period: str = "month"):
    """获取BMI统计"""
    user_records = [record for record in bmi_records_db.values() if record["user_id"] == user_id]
    
    if not user_records:
        return {"message": "暂无BMI记录"}
    
    avg_bmi = sum(record["bmi"] for record in user_records) / len(user_records)
    latest_record = max(user_records, key=lambda x: x["created_at"])
    
    return {
        "average_bmi": round(avg_bmi, 2),
        "latest_bmi": latest_record["bmi"],
        "latest_category": latest_record["category"],
        "total_records": len(user_records),
        "period": period
    }

@app.get("/api/v1/bmi/trend")
async def get_bmi_trend(user_id: str, days: int = 30):
    """获取BMI趋势"""
    user_records = [record for record in bmi_records_db.values() if record["user_id"] == user_id]
    
    return {
        "trend_data": user_records,
        "period": f"{days}天",
        "total_records": len(user_records)
    }

@app.get("/api/v1/bmi/advice")
async def get_health_advice(user_id: str, bmi: float):
    """获取健康建议"""
    _, category, recommendation = calculate_bmi(175, bmi * ((175/100) ** 2))  # 反向计算体重
    
    return {
        "bmi": bmi,
        "category": category,
        "advice": recommendation,
        "tips": [
            "保持规律作息",
            "均衡饮食",
            "适量运动",
            "定期体检"
        ]
    }

# 健身训练相关端点
@app.get("/api/v1/workout/plans")
async def get_workout_plans(user_id: str, skip: int = 0, limit: int = 20):
    """获取训练计划列表"""
    user_plans = [plan for plan in workout_plans_db.values() if plan["user_id"] == user_id]
    return user_plans[skip:skip+limit]

@app.post("/api/v1/workout/plans", response_model=TrainingPlanResponse)
async def create_workout_plan(plan_data: TrainingPlanCreate, user_id: str):
    """创建训练计划"""
    plan_id = str(uuid.uuid4())
    now = datetime.datetime.now().isoformat()
    
    plan = {
        "id": plan_id,
        "user_id": user_id,
        "name": plan_data.name,
        "plan_type": plan_data.plan_type,
        "difficulty_level": plan_data.difficulty_level,
        "duration_weeks": plan_data.duration_weeks,
        "description": plan_data.description,
        "exercises": plan_data.exercises,
        "is_active": True,
        "created_at": now,
        "updated_at": now
    }
    
    workout_plans_db[plan_id] = plan
    return TrainingPlanResponse(**plan)

@app.get("/api/v1/workout/exercises")
async def get_exercises(category: Optional[str] = None, difficulty: Optional[str] = None, equipment: Optional[str] = None):
    """获取运动动作列表"""
    # 预定义一些运动动作
    exercises = [
        {
            "id": "1",
            "name": "俯卧撑",
            "category": "力量",
            "muscle_groups": ["胸肌", "三头肌", "肩部"],
            "equipment": "无",
            "difficulty": "初级",
            "instructions": "双手撑地，身体保持直线，做俯卧撑动作",
            "video_url": None,
            "image_url": None,
            "created_at": datetime.datetime.now().isoformat()
        },
        {
            "id": "2",
            "name": "深蹲",
            "category": "力量",
            "muscle_groups": ["腿部", "臀部"],
            "equipment": "无",
            "difficulty": "初级",
            "instructions": "双脚与肩同宽，下蹲至大腿与地面平行",
            "video_url": None,
            "image_url": None,
            "created_at": datetime.datetime.now().isoformat()
        },
        {
            "id": "3",
            "name": "哑铃弯举",
            "category": "力量",
            "muscle_groups": ["二头肌"],
            "equipment": "哑铃",
            "difficulty": "初级",
            "instructions": "手持哑铃，做弯举动作",
            "video_url": None,
            "image_url": None,
            "created_at": datetime.datetime.now().isoformat()
        }
    ]
    
    # 根据条件过滤
    if category:
        exercises = [e for e in exercises if e["category"] == category]
    if difficulty:
        exercises = [e for e in exercises if e["difficulty"] == difficulty]
    if equipment:
        exercises = [e for e in exercises if equipment.lower() in e["equipment"].lower()]
    
    return exercises

@app.get("/api/v1/workout/records")
async def get_workout_records(user_id: str, plan_id: Optional[str] = None, skip: int = 0, limit: int = 50):
    """获取训练记录"""
    user_records = [record for record in workout_records_db.values() if record["user_id"] == user_id]
    
    if plan_id:
        user_records = [record for record in user_records if record["plan_id"] == plan_id]
    
    return user_records[skip:skip+limit]

@app.post("/api/v1/workout/records", response_model=WorkoutRecordResponse)
async def create_workout_record(record_data: WorkoutRecordCreate, user_id: str):
    """创建训练记录"""
    record_id = str(uuid.uuid4())
    now = datetime.datetime.now().isoformat()
    
    record = {
        "id": record_id,
        "user_id": user_id,
        "plan_id": record_data.plan_id,
        "exercise_id": record_data.exercise_id,
        "sets": record_data.sets,
        "reps": record_data.reps,
        "weight": record_data.weight,
        "duration": record_data.duration,
        "notes": record_data.notes,
        "completed_at": now
    }
    
    workout_records_db[record_id] = record
    return WorkoutRecordResponse(**record)

@app.get("/api/v1/workout/progress/{user_id}")
async def get_workout_progress(user_id: str, period: str = "week"):
    """获取训练进度"""
    user_records = [record for record in workout_records_db.values() if record["user_id"] == user_id]
    
    total_workouts = len(user_records)
    total_duration = sum(record.get("duration", 0) for record in user_records)
    calories_burned = total_duration * 5  # 简单计算：每分钟5卡路里
    
    return {
        "period": period,
        "total_workouts": total_workouts,
        "total_duration": total_duration,
        "calories_burned": calories_burned,
        "exercises_completed": len(set(record["exercise_id"] for record in user_records)),
        "plans_completed": len(set(record["plan_id"] for record in user_records)),
        "average_session_duration": total_duration / max(total_workouts, 1),
        "consistency_score": min(total_workouts / 7, 1.0),  # 假设一周7次为满分
        "improvement_areas": ["力量", "耐力"],
        "achievements": ["连续训练3天", "完成第一个训练计划"]
    }

@app.post("/api/v1/workout/ai/generate-plan", response_model=AIPlanResponse)
async def generate_ai_plan(request: AIPlanRequest, user_id: str):
    """生成AI训练计划"""
    plan_id = str(uuid.uuid4())
    now = datetime.datetime.now().isoformat()
    
    # 根据请求生成训练计划
    exercises = []
    if "胸肌" in request.target_muscle_groups:
        exercises.append({"name": "俯卧撑", "sets": 3, "reps": 10, "duration": 30})
    if "腿部" in request.target_muscle_groups:
        exercises.append({"name": "深蹲", "sets": 3, "reps": 15, "duration": 45})
    
    plan = {
        "id": plan_id,
        "user_id": user_id,
        "name": f"AI生成的{request.goal}训练计划",
        "plan_type": request.goal,
        "difficulty_level": request.difficulty,
        "duration_weeks": request.duration,
        "description": f"基于AI算法生成的个性化{request.goal}训练计划",
        "exercises": exercises,
        "is_active": True,
        "created_at": now,
        "updated_at": now
    }
    
    workout_plans_db[plan_id] = plan
    
    ai_suggestions = [
        f"建议每周训练{request.duration}次",
        "注意动作标准性",
        "循序渐进增加强度",
        "保持充足休息"
    ]
    
    return AIPlanResponse(
        plan=TrainingPlanResponse(**plan),
        ai_suggestions=ai_suggestions,
        confidence_score=0.85
    )

@app.post("/api/v1/workout/exercises/{exercise_id}/feedback")
async def submit_exercise_feedback(exercise_id: str, feedback_data: dict, user_id: str):
    """提交动作反馈"""
    return {
        "feedback": "动作标准，继续保持",
        "suggestions": [
            "注意呼吸节奏",
            "保持核心稳定",
            "控制动作速度"
        ],
        "correctness_score": 0.85,
        "improvement_tips": [
            "增加训练频率",
            "注意营养补充",
            "保证充足睡眠"
        ]
    }

# 用户管理端点
@app.get("/api/v1/users/")
async def get_users(skip: int = 0, limit: int = 20):
    """获取用户列表"""
    user_list = list(users_db.values())
    return user_list[skip:skip+limit]

@app.get("/api/v1/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: str):
    """获取特定用户信息"""
    if user_id not in users_db:
        raise HTTPException(status_code=404, detail="用户不存在")
    
    user = users_db[user_id]
    return UserResponse(**user)

# 错误处理测试端点
@app.get("/api/v1/invalid/endpoint")
async def invalid_endpoint():
    """无效端点测试"""
    raise HTTPException(status_code=404, detail="端点不存在")

if __name__ == "__main__":
    import uvicorn
    print("启动 FitTracker API 测试服务器...")
    print("访问 http://localhost:8000/docs 查看API文档")
    uvicorn.run(app, host="0.0.0.0", port=8000)
