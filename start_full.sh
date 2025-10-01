#!/bin/bash

# FitTracker 完整启动脚本（使用国内镜像源）
echo "=========================================="
echo "🚀 FitTracker 完整启动脚本"
echo "=========================================="

# 设置错误时退出
set -e

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker未运行，请先启动Docker"
    exit 1
fi

echo "✅ Docker运行正常"

# 配置Docker镜像源
echo "🔧 配置Docker镜像源..."
mkdir -p ~/.docker
cat > ~/.docker/daemon.json << 'EOF'
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
EOF

# 重启Docker服务（如果需要）
echo "🔄 重启Docker服务..."
sudo systemctl restart docker 2>/dev/null || true

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

# 先拉取基础镜像
echo "📥 拉取基础镜像..."
docker pull postgres:15-alpine
docker pull redis:7-alpine
docker pull nginx:alpine
docker pull prom/prometheus:latest
docker pull grafana/grafana:latest

# 构建并启动服务
echo "🔨 构建并启动服务..."
docker-compose up --build -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 15

# 检查服务状态
echo "🔍 检查服务状态..."
docker-compose ps

# 等待数据库就绪
echo "⏳ 等待数据库就绪..."
sleep 20

# 检查数据库连接
echo "🔍 检查数据库连接..."
docker-compose exec postgres pg_isready -U fittracker -d fittracker

# 检查后端服务健康状态
echo "🔍 检查后端服务..."
sleep 10
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health || echo "000")
if [ "$BACKEND_STATUS" = "200" ]; then
    echo "✅ 后端服务运行正常"
else
    echo "⚠️ 后端服务可能还在启动中，状态码: $BACKEND_STATUS"
    echo "📋 查看后端日志："
    docker-compose logs backend
fi

# 检查前端服务
echo "🔍 检查前端服务..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 || echo "000")
if [ "$FRONTEND_STATUS" = "200" ]; then
    echo "✅ 前端服务运行正常"
else
    echo "⚠️ 前端服务可能还在启动中，状态码: $FRONTEND_STATUS"
    echo "📋 查看前端日志："
    docker-compose logs frontend
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
echo "🔄 重启服务："
echo "   docker-compose restart"
echo ""
echo "=========================================="
