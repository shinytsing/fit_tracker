#!/bin/bash

# FitTracker 虚拟机启动脚本
echo "=========================================="
echo "🚀 FitTracker 虚拟机启动脚本"
echo "=========================================="

# 设置错误时退出
set -e

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker未运行，请先启动Docker"
    exit 1
fi

echo "✅ Docker运行正常"

# 清理旧容器
echo "🧹 清理旧容器..."
docker-compose down --remove-orphans 2>/dev/null || true

# 创建必要的目录
echo "📁 创建必要目录..."
mkdir -p backend-go/uploads/{images,videos,audio,files,avatars}
mkdir -p logs
mkdir -p ssl_certs

# 设置权限
chmod 755 backend-go/uploads
chmod 755 logs

# 构建并启动服务
echo "🔨 构建并启动服务..."
docker-compose up --build -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 10

# 检查服务状态
echo "🔍 检查服务状态..."
docker-compose ps

# 等待数据库就绪
echo "⏳ 等待数据库就绪..."
sleep 15

# 检查数据库连接
echo "🔍 检查数据库连接..."
docker-compose exec postgres pg_isready -U fittracker -d fittracker

# 检查后端服务健康状态
echo "🔍 检查后端服务..."
sleep 5
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health || echo "000")
if [ "$BACKEND_STATUS" = "200" ]; then
    echo "✅ 后端服务运行正常"
else
    echo "⚠️ 后端服务可能还在启动中，状态码: $BACKEND_STATUS"
fi

# 检查前端服务
echo "🔍 检查前端服务..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 || echo "000")
if [ "$FRONTEND_STATUS" = "200" ]; then
    echo "✅ 前端服务运行正常"
else
    echo "⚠️ 前端服务可能还在启动中，状态码: $FRONTEND_STATUS"
fi

# 显示访问信息
echo ""
echo "=========================================="
echo "🎉 FitTracker 启动完成！"
echo "=========================================="
echo ""
echo "📱 访问地址："
echo "   前端应用: http://localhost:3000"
echo "   后端API:  http://localhost:8080"
echo "   数据库:   localhost:5432"
echo "   Redis:    localhost:6379"
echo ""
echo "🔧 管理工具："
echo "   Prometheus: http://localhost:9090"
echo "   Grafana:    http://localhost:3001 (admin/admin)"
echo ""
echo "📊 服务状态："
docker-compose ps
echo ""
echo "📝 查看日志："
echo "   docker-compose logs -f backend"
echo "   docker-compose logs -f frontend"
echo ""
echo "🛑 停止服务："
echo "   docker-compose down"
echo ""
echo "=========================================="
