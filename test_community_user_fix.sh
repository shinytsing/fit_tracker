#!/bin/bash

# 测试社区动态用户信息修复
echo "=== 测试社区动态用户信息修复 ==="

# 1. 用户注册和登录
echo "1. 用户注册和登录测试"
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser_fix",
    "email": "testuser_fix@example.com",
    "password": "password123"
  }')

echo "注册响应: $REGISTER_RESPONSE"

# 提取token
TOKEN=$(echo $REGISTER_RESPONSE | jq -r '.data.token')
echo "获取到Token: $TOKEN"

# 2. 发布动态测试
echo "2. 发布动态测试"
POST_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/community/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "测试修复后的用户信息显示",
    "type": "训练",
    "images": [],
    "tags": "测试,修复"
  }')

echo "发布动态响应: $POST_RESPONSE"

# 检查用户信息是否正确
USER_ID=$(echo $POST_RESPONSE | jq -r '.data.user.id')
USER_CREATED_AT=$(echo $POST_RESPONSE | jq -r '.data.user.created_at')

echo "用户ID: $USER_ID"
echo "用户创建时间: $USER_CREATED_AT"

if [ "$USER_ID" != "0" ] && [ "$USER_CREATED_AT" != "0001-01-01T00:00:00Z" ]; then
    echo "✅ 用户信息显示正常"
else
    echo "❌ 用户信息显示异常"
fi

# 3. 获取动态列表测试
echo "3. 获取动态列表测试"
POSTS_RESPONSE=$(curl -s -X GET http://localhost:8080/api/v1/community/posts \
  -H "Authorization: Bearer $TOKEN")

echo "动态列表响应: $POSTS_RESPONSE"

# 检查列表中的用户信息
FIRST_POST_USER_ID=$(echo $POSTS_RESPONSE | jq -r '.data[0].user.id')
FIRST_POST_USER_CREATED_AT=$(echo $POSTS_RESPONSE | jq -r '.data[0].user.created_at')

echo "第一个动态的用户ID: $FIRST_POST_USER_ID"
echo "第一个动态的用户创建时间: $FIRST_POST_USER_CREATED_AT"

if [ "$FIRST_POST_USER_ID" != "0" ] && [ "$FIRST_POST_USER_CREATED_AT" != "0001-01-01T00:00:00Z" ]; then
    echo "✅ 动态列表用户信息显示正常"
else
    echo "❌ 动态列表用户信息显示异常"
fi

# 4. 测试推荐流
echo "4. 测试推荐流"
FEED_RESPONSE=$(curl -s -X GET http://localhost:8080/api/v1/community/feed \
  -H "Authorization: Bearer $TOKEN")

echo "推荐流响应: $FEED_RESPONSE"

# 检查推荐流中的用户信息
FEED_USER_ID=$(echo $FEED_RESPONSE | jq -r '.data[0].user.id // "null"')
FEED_USER_CREATED_AT=$(echo $FEED_RESPONSE | jq -r '.data[0].user.created_at // "null"')

echo "推荐流第一个动态的用户ID: $FEED_USER_ID"
echo "推荐流第一个动态的用户创建时间: $FEED_USER_CREATED_AT"

if [ "$FEED_USER_ID" != "0" ] && [ "$FEED_USER_ID" != "null" ] && [ "$FEED_USER_CREATED_AT" != "0001-01-01T00:00:00Z" ]; then
    echo "✅ 推荐流用户信息显示正常"
else
    echo "❌ 推荐流用户信息显示异常"
fi

echo "=== 社区动态用户信息修复测试完成 ==="
