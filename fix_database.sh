#!/bin/bash

# FitTracker 数据库修复脚本
# 添加缺失的测试数据

echo "🔧 FitTracker 数据库修复开始..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查Docker容器状态
echo -e "${BLUE}检查Docker容器状态...${NC}"
if ! docker ps | grep -q fittracker-postgres; then
    echo -e "${RED}❌ PostgreSQL容器未运行${NC}"
    exit 1
fi

if ! docker ps | grep -q fittracker-backend; then
    echo -e "${RED}❌ Backend容器未运行${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker容器运行正常${NC}"

# 1. 添加训练计划数据
echo -e "${BLUE}1. 添加训练计划数据...${NC}"
docker exec fittracker-postgres psql -U fittracker -d fittracker -c "
INSERT INTO training_plans (name, description, type, difficulty, duration, is_public, created_at, updated_at) VALUES
('初级力量训练计划', '适合初学者的力量训练计划，包含基础动作', '力量训练', '初级', 4, true, NOW(), NOW()),
('中级有氧训练计划', '适合中级用户的有氧训练计划', '有氧训练', '中级', 6, true, NOW(), NOW()),
('高级综合训练计划', '适合高级用户的综合训练计划', '综合训练', '高级', 8, true, NOW(), NOW()),
('减脂训练计划', '专门针对减脂的训练计划', '减脂训练', '中级', 6, true, NOW(), NOW()),
('增肌训练计划', '专门针对增肌的训练计划', '增肌训练', '高级', 12, true, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 训练计划数据添加成功${NC}"
else
    echo -e "${RED}❌ 训练计划数据添加失败${NC}"
fi

# 2. 添加运动动作数据
echo -e "${BLUE}2. 添加运动动作数据...${NC}"
docker exec fittracker-postgres psql -U fittracker -d fittracker -c "
INSERT INTO exercises (name, description, category, muscle_groups, equipment, difficulty, instructions, created_at, updated_at) VALUES
('俯卧撑', '经典的上肢力量训练动作', '上肢训练', '胸肌,三头肌,肩部', '无器械', '初级', '双手撑地，身体保持直线，下降至胸部接近地面，然后推起', NOW(), NOW()),
('深蹲', '经典的下肢力量训练动作', '下肢训练', '股四头肌,臀肌,腘绳肌', '无器械', '初级', '双脚与肩同宽，下蹲至大腿平行地面，然后站起', NOW(), NOW()),
('平板支撑', '核心稳定性训练动作', '核心训练', '腹肌,背部', '无器械', '初级', '前臂撑地，身体保持直线，保持姿势', NOW(), NOW()),
('引体向上', '背部力量训练动作', '上肢训练', '背阔肌,二头肌', '单杠', '中级', '双手握杠，身体悬垂，向上拉至下巴过杠', NOW(), NOW()),
('硬拉', '全身力量训练动作', '全身训练', '背部,臀肌,腘绳肌', '杠铃', '高级', '双脚与肩同宽，弯腰抓杠铃，挺胸直背拉起', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 运动动作数据添加成功${NC}"
else
    echo -e "${RED}❌ 运动动作数据添加失败${NC}"
fi

# 3. 添加营养数据
echo -e "${BLUE}3. 添加营养数据...${NC}"
docker exec fittracker-postgres psql -U fittracker -d fittracker -c "
INSERT INTO nutrition_records (user_id, date, meal_type, food_name, quantity, unit, calories, protein, carbs, fat, fiber, sugar, sodium, created_at, updated_at) VALUES
(8, CURRENT_DATE, '早餐', '燕麦', 50, 'g', 194, 6.9, 33.5, 3.4, 5.1, 0.6, 2, NOW(), NOW()),
(8, CURRENT_DATE, '午餐', '鸡胸肉', 100, 'g', 165, 31, 0, 3.6, 0, 0, 74, NOW(), NOW()),
(8, CURRENT_DATE, '晚餐', '西兰花', 200, 'g', 68, 5.6, 13.4, 0.8, 5.2, 3.2, 64, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 营养数据添加成功${NC}"
else
    echo -e "${RED}❌ 营养数据添加失败${NC}"
fi

# 4. 验证数据
echo -e "${BLUE}4. 验证数据...${NC}"

# 检查训练计划数量
PLAN_COUNT=$(docker exec fittracker-postgres psql -U fittracker -d fittracker -t -c "SELECT COUNT(*) FROM training_plans;")
echo "训练计划数量: $PLAN_COUNT"

# 检查运动动作数量
EXERCISE_COUNT=$(docker exec fittracker-postgres psql -U fittracker -d fittracker -t -c "SELECT COUNT(*) FROM exercises;")
echo "运动动作数量: $EXERCISE_COUNT"

# 检查营养记录数量
NUTRITION_COUNT=$(docker exec fittracker-postgres psql -U fittracker -d fittracker -t -c "SELECT COUNT(*) FROM nutrition_records;")
echo "营养记录数量: $NUTRITION_COUNT"

# 5. 重启后端服务以应用更改
echo -e "${BLUE}5. 重启后端服务...${NC}"
docker-compose restart backend

# 等待服务启动
sleep 5

# 6. 测试API
echo -e "${BLUE}6. 测试修复后的API...${NC}"

# 测试训练计划API
echo "测试训练计划API..."
TRAINING_RESPONSE=$(curl -s -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo4LCJlbWFpbCI6InRlc3RAZXhhbXBsZS5jb20iLCJleHAiOjE3NTk4MjA4MTEsIm5iZiI6MTc1OTIxNjAxMSwiaWF0IjoxNzU5MjE2MDExfQ.dlBzSHoSqPoZn11Fn-objsI3IuHHnfNdFMil3U04HAE" http://localhost:8080/api/v1/workouts/plans)

if echo "$TRAINING_RESPONSE" | grep -q "data"; then
    echo -e "${GREEN}✅ 训练计划API修复成功${NC}"
else
    echo -e "${RED}❌ 训练计划API仍有问题${NC}"
    echo "响应: $TRAINING_RESPONSE"
fi

# 测试营养搜索API
echo "测试营养搜索API..."
NUTRITION_RESPONSE=$(curl -s -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo4LCJlbWFpbCI6InRlc3RAZXhhbXBsZS5jb20iLCJleHAiOjE3NTk4MjA4MTEsIm5iZiI6MTc1OTIxNjAxMSwiaWF0IjoxNzU5MjE2MDExfQ.dlBzSHoSqPoZn11Fn-objsI3IuHHnfNdFMil3U04HAE" "http://localhost:8080/api/v1/nutrition/foods?q=苹果")

if echo "$NUTRITION_RESPONSE" | grep -q "data\|foods"; then
    echo -e "${GREEN}✅ 营养搜索API修复成功${NC}"
else
    echo -e "${RED}❌ 营养搜索API仍有问题${NC}"
    echo "响应: $NUTRITION_RESPONSE"
fi

# 测试用户资料API
echo "测试用户资料API..."
PROFILE_RESPONSE=$(curl -s -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo4LCJlbWFpbCI6InRlc3RAZXhhbXBsZS5jb20iLCJleHAiOjE3NTk4MjA4MTEsIm5iZiI6MTc1OTIxNjAxMSwiaWF0IjoxNzU5MjE2MDExfQ.dlBzSHoSqPoZn11Fn-objsI3IuHHnfNdFMil3U04HAE" http://localhost:8080/api/v1/users/profile)

if echo "$PROFILE_RESPONSE" | grep -q "data\|user"; then
    echo -e "${GREEN}✅ 用户资料API修复成功${NC}"
else
    echo -e "${RED}❌ 用户资料API仍有问题${NC}"
    echo "响应: $PROFILE_RESPONSE"
fi

echo -e "\n${GREEN}🎉 数据库修复完成！${NC}"
