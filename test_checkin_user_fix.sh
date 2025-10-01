#!/bin/bash

# 测试签到记录用户信息修复
echo "=== 测试签到记录用户信息修复 ==="

# 1. 用户注册和登录
echo "1. 用户注册和登录测试"
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser_checkin",
    "email": "testuser_checkin@example.com",
    "password": "password123"
  }')

echo "注册响应: $REGISTER_RESPONSE"

# 提取token
TOKEN=$(echo $REGISTER_RESPONSE | jq -r '.data.token')
echo "获取到Token: $TOKEN"

# 2. 创建签到记录测试
echo "2. 创建签到记录测试"
CHECKIN_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/checkins \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "type": "训练",
    "notes": "完成了今天的训练计划",
    "mood": "开心",
    "energy": 8,
    "motivation": 9
  }')

echo "签到响应: $CHECKIN_RESPONSE"

# 检查用户信息是否正确
CHECKIN_USER_ID=$(echo $CHECKIN_RESPONSE | jq -r '.data.user.id')
CHECKIN_USER_CREATED_AT=$(echo $CHECKIN_RESPONSE | jq -r '.data.user.created_at')

echo "签到记录的用户ID: $CHECKIN_USER_ID"
echo "签到记录的用户创建时间: $CHECKIN_USER_CREATED_AT"

if [ "$CHECKIN_USER_ID" != "0" ] && [ "$CHECKIN_USER_CREATED_AT" != "0001-01-01T00:00:00Z" ]; then
    echo "✅ 签到记录用户信息显示正常"
else
    echo "❌ 签到记录用户信息显示异常"
fi

# 3. 获取签到记录列表测试
echo "3. 获取签到记录列表测试"
CHECKINS_RESPONSE=$(curl -s -X GET http://localhost:8080/api/v1/checkins \
  -H "Authorization: Bearer $TOKEN")

echo "签到记录列表响应: $CHECKINS_RESPONSE"

# 检查列表中的用户信息
FIRST_CHECKIN_USER_ID=$(echo $CHECKINS_RESPONSE | jq -r '.data[0].user.id // "null"')
FIRST_CHECKIN_USER_CREATED_AT=$(echo $CHECKINS_RESPONSE | jq -r '.data[0].user.created_at // "null"')

echo "第一个签到记录的用户ID: $FIRST_CHECKIN_USER_ID"
echo "第一个签到记录的用户创建时间: $FIRST_CHECKIN_USER_CREATED_AT"

if [ "$FIRST_CHECKIN_USER_ID" != "0" ] && [ "$FIRST_CHECKIN_USER_ID" != "null" ] && [ "$FIRST_CHECKIN_USER_CREATED_AT" != "0001-01-01T00:00:00Z" ]; then
    echo "✅ 签到记录列表用户信息显示正常"
else
    echo "❌ 签到记录列表用户信息显示异常"
fi

# 4. 测试签到日历
echo "4. 测试签到日历"
CALENDAR_RESPONSE=$(curl -s -X GET http://localhost:8080/api/v1/checkins/calendar \
  -H "Authorization: Bearer $TOKEN")

echo "签到日历响应: $CALENDAR_RESPONSE"

# 5. 测试签到统计
echo "5. 测试签到统计"
STREAK_RESPONSE=$(curl -s -X GET http://localhost:8080/api/v1/checkins/streak \
  -H "Authorization: Bearer $TOKEN")

echo "签到统计响应: $STREAK_RESPONSE"

echo "=== 签到记录用户信息修复测试完成 ==="
