#!/bin/bash

# FitTracker 项目启动脚本

echo "🚀 启动 FitTracker 项目..."

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose 未安装，请先安装 Docker Compose"
    exit 1
fi

# 检查 Flutter 是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安装，请先安装 Flutter"
    exit 1
fi

# 检查 Python 是否安装
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 未安装，请先安装 Python 3"
    exit 1
fi

echo "✅ 环境检查通过"

# 创建必要的目录
echo "📁 创建必要的目录..."
mkdir -p backend/uploads
mkdir -p frontend/assets/{images,icons,animations,fonts}

# 设置后端环境
echo "🔧 设置后端环境..."
cd backend
if [ ! -f .env ]; then
    cp env.example .env
    echo "📝 已创建 .env 文件，请根据需要修改配置"
fi

# 安装 Python 依赖
echo "📦 安装 Python 依赖..."
pip install -r requirements.txt

cd ..

# 设置前端环境
echo "🔧 设置前端环境..."
cd frontend

# 安装 Flutter 依赖
echo "📦 安装 Flutter 依赖..."
flutter pub get

cd ..

# 启动数据库服务
echo "🗄️ 启动数据库服务..."
docker-compose -f infra/docker-compose.yml up -d db redis

# 等待数据库启动
echo "⏳ 等待数据库启动..."
sleep 10

# 运行数据库迁移
echo "🔄 运行数据库迁移..."
cd backend
python -c "
from app.core.database import engine
from app.models import Base
Base.metadata.create_all(bind=engine)
print('✅ 数据库表创建成功')
"

cd ..

echo "🎉 FitTracker 项目启动完成！"
echo ""
echo "📱 前端应用: http://localhost:3000"
echo "🔧 后端API: http://localhost:8000"
echo "📚 API文档: http://localhost:8000/docs"
echo "🗄️ 数据库: localhost:5432"
echo "💾 Redis: localhost:6379"
echo ""
echo "💡 使用以下命令启动完整服务:"
echo "   docker-compose -f infra/docker-compose.yml up -d"
echo ""
echo "💡 使用以下命令启动开发服务:"
echo "   后端: cd backend && python main.py"
echo "   前端: cd frontend && flutter run"
