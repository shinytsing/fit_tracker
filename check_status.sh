#!/bin/bash

# FitTracker 应用状态检查脚本

echo "🔍 FitTracker 应用状态检查"
echo "=========================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 1. 检查Docker服务
echo -e "${BLUE}📦 Docker服务状态:${NC}"
docker-compose ps 2>/dev/null | grep -E "(postgres|redis|backend)" || echo -e "${RED}❌ Docker服务未运行${NC}"

# 2. 检查API连接
echo -e "\n${BLUE}🌐 API连接测试:${NC}"
if curl -s http://localhost:8080/api/v1/community/posts >/dev/null 2>&1; then
    echo -e "${GREEN}✅ 后端API (端口8080) 正常${NC}"
else
    echo -e "${RED}❌ 后端API (端口8080) 异常${NC}"
fi

# 3. 检查数据库连接
echo -e "\n${BLUE}🗄️ 数据库连接测试:${NC}"
if docker exec fittracker-postgres pg_isready -U fittracker -d fittracker >/dev/null 2>&1; then
    echo -e "${GREEN}✅ PostgreSQL (端口5432) 正常${NC}"
else
    echo -e "${RED}❌ PostgreSQL (端口5432) 异常${NC}"
fi

# 4. 检查Redis连接
echo -e "\n${BLUE}🔴 Redis连接测试:${NC}"
if docker exec fittracker-redis redis-cli --raw incr ping >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Redis (端口6379) 正常${NC}"
else
    echo -e "${RED}❌ Redis (端口6379) 异常${NC}"
fi

# 5. 检查Flutter应用
echo -e "\n${BLUE}📱 Flutter应用状态:${NC}"
FLUTTER_PROCESSES=$(ps aux | grep "flutter run" | grep -v grep | wc -l)
if [ $FLUTTER_PROCESSES -gt 0 ]; then
    echo -e "${GREEN}✅ Flutter应用正在运行 ($FLUTTER_PROCESSES 个实例)${NC}"
    ps aux | grep "flutter run" | grep -v grep | awk '{print "  • " $11 " " $12 " " $13 " " $14}'
else
    echo -e "${YELLOW}⚠️ 没有Flutter应用在运行${NC}"
fi

# 6. 检查可用设备
echo -e "\n${BLUE}📲 可用设备:${NC}"
cd /Users/gaojie/Desktop/fittraker/frontend 2>/dev/null && flutter devices --machine | grep -E "(emulator|iPhone|macOS)" | head -3 || echo -e "${YELLOW}⚠️ 无法检查设备状态${NC}"

# 7. 显示服务地址
echo -e "\n${BLUE}🌐 服务地址:${NC}"
echo "  • 后端API: http://localhost:8080"
echo "  • PostgreSQL: localhost:5432"
echo "  • Redis: localhost:6379"
echo "  • 数据库管理: http://localhost:5050"
echo "  • Redis管理: http://localhost:8081"

# 8. 显示最近日志
echo -e "\n${BLUE}📋 最近的后端日志:${NC}"
docker logs fittracker-backend --tail 5 2>/dev/null | sed 's/^/  /' || echo -e "${YELLOW}⚠️ 无法获取日志${NC}"

echo -e "\n${GREEN}🎉 状态检查完成！${NC}"
