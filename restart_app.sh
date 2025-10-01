#!/bin/bash

# FitTracker 应用重启脚本
# 用于快速重启所有服务

set -e

echo "🔄 FitTracker 应用重启中..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="/Users/gaojie/Desktop/fittraker"

# 1. 停止所有相关进程
echo -e "${BLUE}1. 停止现有进程...${NC}"
pkill -f "flutter run" 2>/dev/null || true
pkill -f "go run" 2>/dev/null || true
pkill -f "fittracker" 2>/dev/null || true

# 2. 停止Docker服务
echo -e "${BLUE}2. 停止Docker服务...${NC}"
cd $PROJECT_ROOT
docker-compose down 2>/dev/null || true

# 3. 启动核心服务
echo -e "${BLUE}3. 启动核心服务 (PostgreSQL, Redis, Backend)...${NC}"
docker-compose up -d postgres redis backend

# 4. 等待服务启动
echo -e "${BLUE}4. 等待服务启动...${NC}"
sleep 10

# 5. 检查服务状态
echo -e "${BLUE}5. 检查服务状态...${NC}"
docker-compose ps

# 6. 测试API
echo -e "${BLUE}6. 测试API连接...${NC}"
if curl -s http://localhost:8080/api/v1/community/posts | grep -q "MISSING_TOKEN"; then
    echo -e "${GREEN}✅ 后端API正常运行${NC}"
else
    echo -e "${RED}❌ 后端API异常${NC}"
fi

# 7. 启动Flutter应用
echo -e "${BLUE}7. 启动Flutter应用...${NC}"
cd $PROJECT_ROOT/frontend

# 检查可用设备
echo "可用设备："
flutter devices --machine | grep -E "(emulator|iPhone|macOS)" | head -3

# 启动Android模拟器版本
echo -e "${YELLOW}启动Android版本...${NC}"
flutter run -d emulator-5554 &
ANDROID_PID=$!

# 启动iOS模拟器版本
echo -e "${YELLOW}启动iOS版本...${NC}"
flutter run -d "iPhone 16 Pro" &
IOS_PID=$!

# 启动macOS版本
echo -e "${YELLOW}启动macOS版本...${NC}"
flutter run -d macos &
MACOS_PID=$!

echo -e "${GREEN}🎉 FitTracker 应用重启完成！${NC}"
echo ""
echo -e "${BLUE}📱 运行中的应用:${NC}"
echo "  • Android模拟器: PID $ANDROID_PID"
echo "  • iOS模拟器: PID $IOS_PID" 
echo "  • macOS桌面: PID $MACOS_PID"
echo ""
echo -e "${BLUE}🌐 服务地址:${NC}"
echo "  • 后端API: http://localhost:8080"
echo "  • PostgreSQL: localhost:5432"
echo "  • Redis: localhost:6379"
echo ""
echo -e "${BLUE}📊 管理工具:${NC}"
echo "  • 数据库管理: http://localhost:5050 (admin@fittracker.com / admin123)"
echo "  • Redis管理: http://localhost:8081"
echo ""
echo -e "${YELLOW}💡 提示: 使用 'docker-compose logs -f' 查看服务日志${NC}"
echo -e "${YELLOW}💡 提示: 使用 'flutter devices' 查看可用设备${NC}"
