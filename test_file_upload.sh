#!/bin/bash

# 测试文件上传功能
echo "=== 测试文件上传功能 ==="

# 1. 用户注册和登录
echo "1. 用户注册和登录测试"
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser_upload",
    "email": "testuser_upload@example.com",
    "password": "password123"
  }')

echo "注册响应: $REGISTER_RESPONSE"

# 提取token
TOKEN=$(echo $REGISTER_RESPONSE | jq -r '.data.token')
echo "获取到Token: $TOKEN"

# 2. 创建测试图片文件
echo "2. 创建测试图片文件"
TEST_IMAGE_PATH="/tmp/test_image.jpg"

# 创建一个简单的测试图片（1x1像素的JPEG）
cat > /tmp/create_test_image.py << 'EOF'
from PIL import Image
import os

# 创建一个1x1像素的红色图片
img = Image.new('RGB', (1, 1), color='red')
img.save('/tmp/test_image.jpg', 'JPEG')
print("测试图片创建成功")
EOF

# 检查是否有PIL库
if python3 -c "from PIL import Image" 2>/dev/null; then
    python3 /tmp/create_test_image.py
else
    # 如果没有PIL，创建一个简单的文本文件作为测试
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -d > /tmp/test_image.png
    TEST_IMAGE_PATH="/tmp/test_image.png"
fi

# 3. 测试头像上传
echo "3. 测试头像上传"
AVATAR_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/upload/avatar \
  -H "Authorization: Bearer $TOKEN" \
  -F "avatar=@$TEST_IMAGE_PATH")

echo "头像上传响应: $AVATAR_RESPONSE"

# 检查头像上传是否成功
if echo "$AVATAR_RESPONSE" | grep -q "头像上传成功"; then
    echo "✅ 头像上传功能正常"
else
    echo "❌ 头像上传功能异常"
fi

# 4. 测试图片上传
echo "4. 测试图片上传"
IMAGE_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/upload/image \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@$TEST_IMAGE_PATH")

echo "图片上传响应: $IMAGE_RESPONSE"

# 检查图片上传是否成功
if echo "$IMAGE_RESPONSE" | grep -q "图片上传成功"; then
    echo "✅ 图片上传功能正常"
else
    echo "❌ 图片上传功能异常"
fi

# 5. 测试媒体文件上传
echo "5. 测试媒体文件上传"
MEDIA_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/upload/media \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@$TEST_IMAGE_PATH" \
  -F "type=image")

echo "媒体文件上传响应: $MEDIA_RESPONSE"

# 检查媒体文件上传是否成功
if echo "$MEDIA_RESPONSE" | grep -q "文件上传成功"; then
    echo "✅ 媒体文件上传功能正常"
else
    echo "❌ 媒体文件上传功能异常"
fi

# 6. 测试文件类型验证
echo "6. 测试文件类型验证"

# 创建一个文本文件
echo "This is a test file" > /tmp/test_file.txt

# 尝试上传不支持的文件类型
INVALID_TYPE_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/upload/image \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@/tmp/test_file.txt")

echo "无效文件类型上传响应: $INVALID_TYPE_RESPONSE"

# 检查是否正确拒绝无效文件类型
if echo "$INVALID_TYPE_RESPONSE" | grep -q "不支持的图片格式"; then
    echo "✅ 文件类型验证功能正常"
else
    echo "❌ 文件类型验证功能异常"
fi

# 7. 测试文件大小限制
echo "7. 测试文件大小限制"

# 创建一个大文件（11MB）
dd if=/dev/zero of=/tmp/large_file.jpg bs=1M count=11 2>/dev/null

# 尝试上传大文件
LARGE_FILE_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/upload/image \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@/tmp/large_file.jpg")

echo "大文件上传响应: $LARGE_FILE_RESPONSE"

# 检查是否正确拒绝大文件
if echo "$LARGE_FILE_RESPONSE" | grep -q "图片大小超出限制"; then
    echo "✅ 文件大小限制功能正常"
else
    echo "❌ 文件大小限制功能异常"
fi

# 8. 测试未认证用户上传
echo "8. 测试未认证用户上传"
UNAUTH_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/upload/image \
  -F "image=@$TEST_IMAGE_PATH")

echo "未认证用户上传响应: $UNAUTH_RESPONSE"

# 检查是否正确拒绝未认证用户
if echo "$UNAUTH_RESPONSE" | grep -q "未认证用户"; then
    echo "✅ 认证验证功能正常"
else
    echo "❌ 认证验证功能异常"
fi

# 9. 清理测试文件
echo "9. 清理测试文件"
rm -f /tmp/test_image.jpg /tmp/test_image.png /tmp/test_file.txt /tmp/large_file.jpg /tmp/create_test_image.py

echo "=== 文件上传功能测试完成 ==="
echo ""
echo "如果文件上传测试失败，请检查："
echo "1. 上传目录权限是否正确"
echo "2. Nginx配置是否正确"
echo "3. 文件大小限制是否合理"
echo "4. 文件类型验证是否完整"
