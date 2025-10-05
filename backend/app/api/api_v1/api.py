"""
FitTracker Backend - API路由配置
"""

from fastapi import APIRouter
from app.api.api_v1.endpoints import auth, users, workout, bmi, community, messages, publish, buddies

api_router = APIRouter()

# 认证路由
api_router.include_router(auth.router, prefix="/auth", tags=["认证"])

# 用户路由
api_router.include_router(users.router, prefix="/users", tags=["用户"])

# BMI计算器路由
api_router.include_router(bmi.router, prefix="/bmi", tags=["BMI计算器"])

# 训练路由
api_router.include_router(workout.router, prefix="/workout", tags=["训练"])

# 社区路由
api_router.include_router(community.router, prefix="/community", tags=["社区"])

# 消息路由
api_router.include_router(messages.router, prefix="/messages", tags=["消息"])

# 发布路由
api_router.include_router(publish.router, prefix="/publish", tags=["发布"])

# 搭子路由
api_router.include_router(buddies.router, prefix="/buddies", tags=["搭子"])
