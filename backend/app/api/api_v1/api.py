"""
FitTracker Backend - API路由配置
"""

from fastapi import APIRouter
from app.api.api_v1.endpoints import auth, users, workout, bmi

api_router = APIRouter()

# 认证路由
api_router.include_router(auth.router, prefix="/auth", tags=["认证"])

# 用户路由
api_router.include_router(users.router, prefix="/users", tags=["用户"])

# BMI计算器路由
api_router.include_router(bmi.router, prefix="/bmi", tags=["BMI计算器"])
