#!/bin/bash

# 视频消息和视频通话功能集成测试脚本
# 测试前后端视频功能的完整集成

set -e

echo "🎥 开始测试视频消息和视频通话功能..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 测试函数
test_step() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "\n${BLUE}📋 测试: $test_name${NC}"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if eval "$test_command"; then
        echo -e "${GREEN}✅ $test_name 通过${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}❌ $test_name 失败${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# 检查后端服务是否运行
check_backend() {
    echo -e "\n${YELLOW}🔍 检查后端服务状态...${NC}"
    
    if curl -s http://localhost:8080/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 后端服务运行正常${NC}"
        return 0
    else
        echo -e "${RED}❌ 后端服务未运行或无法访问${NC}"
        echo "请先启动后端服务: cd backend-go && go run main.go"
        return 1
    fi
}

# 测试视频消息上传API
test_video_upload_api() {
    echo "测试视频消息上传API..."
    
    # 创建测试视频文件
    local test_video="/tmp/test_video.mp4"
    echo "创建测试视频文件: $test_video"
    
    # 使用ffmpeg创建测试视频（如果可用）
    if command -v ffmpeg &> /dev/null; then
        ffmpeg -f lavfi -i testsrc=duration=5:size=640x480:rate=30 -c:v libx264 -pix_fmt yuv420p "$test_video" -y > /dev/null 2>&1
    else
        # 如果没有ffmpeg，创建一个假的视频文件
        dd if=/dev/zero of="$test_video" bs=1024 count=100 > /dev/null 2>&1
    fi
    
    # 测试上传API
    local response=$(curl -s -X POST \
        -H "Authorization: Bearer test_token" \
        -F "video=@$test_video" \
        -F "thumbnail=@$test_video" \
        -F "duration=5" \
        http://localhost:8080/api/v1/messages/video/upload)
    
    # 清理测试文件
    rm -f "$test_video"
    
    if echo "$response" | grep -q "success"; then
        echo "上传API响应: $response"
        return 0
    else
        echo "上传API失败: $response"
        return 1
    fi
}

# 测试视频消息发送API
test_video_message_send() {
    echo "测试视频消息发送API..."
    
    local response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer test_token" \
        -d '{
            "chat_id": "test_chat_123",
            "video_url": "https://example.com/test_video.mp4",
            "thumbnail_url": "https://example.com/test_thumbnail.jpg",
            "duration": 30
        }' \
        http://localhost:8080/api/v1/messages/video-message/send)
    
    if echo "$response" | grep -q "success"; then
        echo "发送API响应: $response"
        return 0
    else
        echo "发送API失败: $response"
        return 1
    fi
}

# 测试视频通话发起API
test_video_call_start() {
    echo "测试视频通话发起API..."
    
    local response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer test_token" \
        -d '{
            "callee_id": "user_456",
            "chat_id": "test_chat_123"
        }' \
        http://localhost:8080/api/v1/messages/video-call/start)
    
    if echo "$response" | grep -q "success"; then
        echo "发起通话API响应: $response"
        return 0
    else
        echo "发起通话API失败: $response"
        return 1
    fi
}

# 测试WebSocket连接
test_websocket_connection() {
    echo "测试WebSocket连接..."
    
    # 使用websocat测试WebSocket连接（如果可用）
    if command -v websocat &> /dev/null; then
        echo "测试WebSocket连接..."
        timeout 5 websocat ws://localhost:8080/ws?user_id=test_user&token=test_token || return 1
        return 0
    else
        echo "websocat未安装，跳过WebSocket测试"
        return 0
    fi
}

# 测试前端Flutter代码编译
test_flutter_compilation() {
    echo "测试Flutter代码编译..."
    
    cd frontend
    
    # 检查Flutter环境
    if ! flutter doctor > /dev/null 2>&1; then
        echo "Flutter环境未配置"
        return 1
    fi
    
    # 分析代码
    if flutter analyze > /dev/null 2>&1; then
        echo "Flutter代码分析通过"
        return 0
    else
        echo "Flutter代码分析失败"
        flutter analyze
        return 1
    fi
}

# 测试视频相关依赖
test_video_dependencies() {
    echo "测试视频相关依赖..."
    
    cd frontend
    
    # 检查pubspec.yaml中的视频相关依赖
    if grep -q "camera:" pubspec.yaml && \
       grep -q "video_player:" pubspec.yaml && \
       grep -q "flutter_webrtc:" pubspec.yaml; then
        echo "视频相关依赖已配置"
        return 0
    else
        echo "缺少视频相关依赖"
        return 1
    fi
}

# 测试数据库模型
test_database_models() {
    echo "测试数据库模型..."
    
    cd backend-go
    
    # 检查模型文件
    if [ -f "internal/models/models.go" ]; then
        if grep -q "VideoCallSession" internal/models/models.go && \
           grep -q "VideoCallInvite" internal/models/models.go && \
           grep -q "MessageTypeVideo" internal/models/models.go; then
            echo "视频相关数据模型已定义"
            return 0
        else
            echo "缺少视频相关数据模型"
            return 1
        fi
    else
        echo "模型文件不存在"
        return 1
    fi
}

# 测试API路由
test_api_routes() {
    echo "测试API路由..."
    
    cd backend-go
    
    # 检查路由文件
    if [ -f "internal/routes/routes.go" ]; then
        if grep -q "video/upload" internal/routes/routes.go && \
           grep -q "video-call" internal/routes/routes.go && \
           grep -q "video-message" internal/routes/routes.go; then
            echo "视频相关API路由已配置"
            return 0
        else
            echo "缺少视频相关API路由"
            return 1
        fi
    else
        echo "路由文件不存在"
        return 1
    fi
}

# 主测试流程
main() {
    echo -e "${BLUE}🚀 开始视频功能集成测试${NC}"
    echo "=================================="
    
    # 基础检查
    test_step "检查后端服务" "check_backend"
    
    # 后端API测试
    test_step "测试视频消息上传API" "test_video_upload_api"
    test_step "测试视频消息发送API" "test_video_message_send"
    test_step "测试视频通话发起API" "test_video_call_start"
    test_step "测试WebSocket连接" "test_websocket_connection"
    
    # 代码结构测试
    test_step "测试数据库模型" "test_database_models"
    test_step "测试API路由" "test_api_routes"
    test_step "测试视频依赖" "test_video_dependencies"
    test_step "测试Flutter编译" "test_flutter_compilation"
    
    # 输出测试结果
    echo -e "\n${BLUE}📊 测试结果汇总${NC}"
    echo "=================================="
    echo -e "总测试数: ${TOTAL_TESTS}"
    echo -e "${GREEN}通过: ${PASSED_TESTS}${NC}"
    echo -e "${RED}失败: ${FAILED_TESTS}${NC}"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "\n${GREEN}🎉 所有测试通过！视频功能集成成功！${NC}"
        return 0
    else
        echo -e "\n${RED}❌ 有 $FAILED_TESTS 个测试失败，请检查相关功能${NC}"
        return 1
    fi
}

# 运行主函数
main "$@"
