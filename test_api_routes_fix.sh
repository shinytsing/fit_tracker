#!/bin/bash

# 测试API路由修复
echo "=== 测试API路由修复 ==="

# 1. 用户注册和登录
echo "1. 用户注册和登录测试"
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser_routes",
    "email": "testuser_routes@example.com",
    "password": "password123"
  }')

echo "注册响应: $REGISTER_RESPONSE"

# 提取token
TOKEN=$(echo $REGISTER_RESPONSE | jq -r '.data.token')
echo "获取到Token: $TOKEN"

# 2. 测试 /community/feed 路由
echo "2. 测试 /community/feed 路由"
FEED_RESPONSE=$(curl -s -X GET http://localhost:8080/api/v1/community/feed \
  -H "Authorization: Bearer $TOKEN")

echo "推荐流响应: $FEED_RESPONSE"

# 检查是否返回404
if echo "$FEED_RESPONSE" | grep -q "404\|Not Found"; then
    echo "❌ /community/feed 路由仍然返回404"
else
    echo "✅ /community/feed 路由正常工作"
fi

# 3. 测试 /community/posts 路由
echo "3. 测试 /community/posts 路由"
POSTS_RESPONSE=$(curl -s -X GET http://localhost:8080/api/v1/community/posts \
  -H "Authorization: Bearer $TOKEN")

echo "动态列表响应: $POSTS_RESPONSE"

if echo "$POSTS_RESPONSE" | grep -q "404\|Not Found"; then
    echo "❌ /community/posts 路由返回404"
else
    echo "✅ /community/posts 路由正常工作"
fi

# 4. 测试 /community/posts/following 路由
echo "4. 测试 /community/posts/following 路由"
FOLLOWING_RESPONSE=$(curl -s -X GET http://localhost:8080/api/v1/community/posts/following \
  -H "Authorization: Bearer $TOKEN")

echo "关注动态响应: $FOLLOWING_RESPONSE"

if echo "$FOLLOWING_RESPONSE" | grep -q "404\|Not Found"; then
    echo "❌ /community/posts/following 路由返回404"
else
    echo "✅ /community/posts/following 路由正常工作"
fi

# 5. 测试 /community/posts/recommend 路由
echo "5. 测试 /community/posts/recommend 路由"
RECOMMEND_RESPONSE=$(curl -s -X GET http://localhost:8080/api/v1/community/posts/recommend \
  -H "Authorization: Bearer $TOKEN")

echo "推荐动态响应: $RECOMMEND_RESPONSE"

if echo "$RECOMMEND_RESPONSE" | grep -q "404\|Not Found"; then
    echo "❌ /community/posts/recommend 路由返回404"
else
    echo "✅ /community/posts/recommend 路由正常工作"
fi

# 6. 测试 /community/topics/trending 路由
echo "6. 测试 /community/topics/trending 路由"
TRENDING_RESPONSE=$(curl -s -X GET http://localhost:8080/api/v1/community/topics/trending \
  -H "Authorization: Bearer $TOKEN")

echo "热门话题响应: $TRENDING_RESPONSE"

if echo "$TRENDING_RESPONSE" | grep -q "404\|Not Found"; then
    echo "❌ /community/topics/trending 路由返回404"
else
    echo "✅ /community/topics/trending 路由正常工作"
fi

# 7. 测试发布动态
echo "7. 测试发布动态"
POST_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/community/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "测试路由修复",
    "type": "训练",
    "images": [],
    "tags": "测试,路由"
  }')

echo "发布动态响应: $POST_RESPONSE"

if echo "$POST_RESPONSE" | grep -q "404\|Not Found"; then
    echo "❌ 发布动态路由返回404"
else
    echo "✅ 发布动态路由正常工作"
fi

echo "=== API路由修复测试完成 ==="
