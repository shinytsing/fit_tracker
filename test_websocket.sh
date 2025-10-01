#!/bin/bash

# 测试WebSocket实时通信功能
echo "=== 测试WebSocket实时通信功能 ==="

# 1. 用户注册和登录
echo "1. 用户注册和登录测试"
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser_ws1",
    "email": "testuser_ws1@example.com",
    "password": "password123"
  }')

echo "用户1注册响应: $REGISTER_RESPONSE"

# 提取token
TOKEN1=$(echo $REGISTER_RESPONSE | jq -r '.data.token')
echo "用户1 Token: $TOKEN1"

# 注册第二个用户
REGISTER_RESPONSE2=$(curl -s -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser_ws2",
    "email": "testuser_ws2@example.com",
    "password": "password123"
  }')

echo "用户2注册响应: $REGISTER_RESPONSE2"

# 提取第二个用户的token
TOKEN2=$(echo $REGISTER_RESPONSE2 | jq -r '.data.token')
echo "用户2 Token: $TOKEN2"

# 2. 测试WebSocket连接
echo "2. 测试WebSocket连接"

# 创建WebSocket测试脚本
cat > /tmp/websocket_test.js << 'EOF'
const WebSocket = require('ws');

// 测试WebSocket连接
const ws = new WebSocket('ws://localhost:8080/ws?user_id=testuser_ws1');

ws.on('open', function open() {
    console.log('✅ WebSocket连接成功');
    
    // 发送心跳消息
    ws.send(JSON.stringify({
        type: 'ping',
        time: Date.now()
    }));
    
    // 发送测试消息
    setTimeout(() => {
        ws.send(JSON.stringify({
            type: 'message',
            content: 'Hello WebSocket!',
            timestamp: Date.now()
        }));
    }, 1000);
    
    // 发送正在输入状态
    setTimeout(() => {
        ws.send(JSON.stringify({
            type: 'typing',
            chat_id: 'test_chat',
            is_typing: true
        }));
    }, 2000);
    
    // 关闭连接
    setTimeout(() => {
        ws.close();
    }, 5000);
});

ws.on('message', function message(data) {
    console.log('📨 收到消息:', data.toString());
});

ws.on('error', function error(err) {
    console.log('❌ WebSocket错误:', err.message);
});

ws.on('close', function close() {
    console.log('🔌 WebSocket连接已关闭');
});
EOF

# 检查是否安装了Node.js和ws模块
if ! command -v node &> /dev/null; then
    echo "❌ Node.js未安装，无法测试WebSocket"
    echo "请安装Node.js: https://nodejs.org/"
    exit 1
fi

# 检查是否安装了ws模块
if ! npm list ws &> /dev/null; then
    echo "安装ws模块..."
    npm install ws
fi

# 运行WebSocket测试
echo "运行WebSocket测试..."
node /tmp/websocket_test.js

# 3. 测试消息API
echo "3. 测试消息API"

# 创建聊天
CHAT_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/messages/chats \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN1" \
  -d '{
    "user_id": "testuser_ws2"
  }')

echo "创建聊天响应: $CHAT_RESPONSE"

# 发送消息
MESSAGE_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/messages/chats/1/messages \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN1" \
  -d '{
    "type": "text",
    "content": "Hello from WebSocket test!"
  }')

echo "发送消息响应: $MESSAGE_RESPONSE"

# 4. 测试在线用户列表
echo "4. 测试在线用户列表"
ONLINE_RESPONSE=$(curl -s -X GET http://localhost:8080/api/v1/messages/online \
  -H "Authorization: Bearer $TOKEN1")

echo "在线用户响应: $ONLINE_RESPONSE"

# 5. 清理测试文件
rm -f /tmp/websocket_test.js

echo "=== WebSocket实时通信功能测试完成 ==="
echo ""
echo "如果WebSocket测试失败，请检查："
echo "1. 服务器是否支持WebSocket"
echo "2. Nginx配置是否正确"
echo "3. 防火墙是否阻止WebSocket连接"
echo "4. 浏览器是否支持WebSocket"
