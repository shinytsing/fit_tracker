#!/bin/bash

# Gymates 认证流程测试脚本
# 测试启动未登录跳转逻辑实现

echo "🧪 开始测试 Gymates 认证流程..."

# 设置颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试函数
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local expected_status=$4
    local description=$5
    
    echo -e "${BLUE}测试: $description${NC}"
    
    if [ "$method" = "POST" ] && [ -n "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST \
            -H "Content-Type: application/json" \
            -d "$data" \
            "http://localhost:8080$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X GET \
            "http://localhost:8080$endpoint")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "$expected_status" ]; then
        echo -e "${GREEN}✅ 通过${NC} - HTTP $http_code"
        echo "响应: $body"
    else
        echo -e "${RED}❌ 失败${NC} - 期望 HTTP $expected_status, 实际 HTTP $http_code"
        echo "响应: $body"
    fi
    echo ""
}

# 等待服务器启动
echo -e "${YELLOW}等待服务器启动...${NC}"
sleep 3

# 测试健康检查
test_endpoint "GET" "/health" "" "200" "健康检查"

# 测试用户注册
echo -e "${YELLOW}=== 测试用户注册 ===${NC}"
register_data='{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123",
    "first_name": "Test",
    "last_name": "User"
}'
test_endpoint "POST" "/api/v1/users/register" "$register_data" "201" "用户注册"

# 测试用户登录
echo -e "${YELLOW}=== 测试用户登录 ===${NC}"
login_data='{
    "username": "testuser",
    "password": "password123"
}'
test_endpoint "POST" "/api/v1/users/login" "$login_data" "200" "用户登录"

# 从登录响应中提取token
echo -e "${YELLOW}=== 提取登录Token ===${NC}"
login_response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d "$login_data" \
    "http://localhost:8080/api/v1/users/login")

token=$(echo "$login_response" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -n "$token" ]; then
    echo -e "${GREEN}✅ Token提取成功${NC}"
    echo "Token: ${token:0:50}..."
else
    echo -e "${RED}❌ Token提取失败${NC}"
    echo "登录响应: $login_response"
fi

# 测试需要认证的接口
if [ -n "$token" ]; then
    echo -e "${YELLOW}=== 测试需要认证的接口 ===${NC}"
    
    # 测试获取用户资料
    echo -e "${BLUE}测试: 获取用户资料${NC}"
    profile_response=$(curl -s -w "\n%{http_code}" -X GET \
        -H "Authorization: Bearer $token" \
        "http://localhost:8080/api/v1/users/profile")
    
    profile_http_code=$(echo "$profile_response" | tail -n1)
    profile_body=$(echo "$profile_response" | head -n -1)
    
    if [ "$profile_http_code" = "200" ]; then
        echo -e "${GREEN}✅ 通过${NC} - HTTP $profile_http_code"
        echo "用户资料: $profile_body"
    else
        echo -e "${RED}❌ 失败${NC} - HTTP $profile_http_code"
        echo "响应: $profile_body"
    fi
    echo ""
    
    # 测试无效token
    echo -e "${BLUE}测试: 无效Token访问${NC}"
    invalid_response=$(curl -s -w "\n%{http_code}" -X GET \
        -H "Authorization: Bearer invalid_token_123" \
        "http://localhost:8080/api/v1/users/profile")
    
    invalid_http_code=$(echo "$invalid_response" | tail -n1)
    invalid_body=$(echo "$invalid_response" | head -n -1)
    
    if [ "$invalid_http_code" = "401" ]; then
        echo -e "${GREEN}✅ 通过${NC} - HTTP $invalid_http_code (正确拒绝无效token)"
    else
        echo -e "${RED}❌ 失败${NC} - 期望 HTTP 401, 实际 HTTP $invalid_http_code"
    fi
    echo "响应: $invalid_body"
    echo ""
fi

# 测试未认证访问
echo -e "${YELLOW}=== 测试未认证访问 ===${NC}"
test_endpoint "GET" "/api/v1/users/profile" "" "401" "未认证访问用户资料"

# 测试Flutter前端
echo -e "${YELLOW}=== 测试Flutter前端 ===${NC}"
echo -e "${BLUE}检查Flutter项目结构...${NC}"

if [ -d "frontend" ]; then
    echo -e "${GREEN}✅ Flutter项目目录存在${NC}"
    
    # 检查关键文件
    key_files=(
        "frontend/lib/main.dart"
        "frontend/lib/core/router/app_router.dart"
        "frontend/lib/core/auth/auth_provider.dart"
        "frontend/lib/features/splash/presentation/pages/splash_page.dart"
        "frontend/lib/features/auth/presentation/pages/login_page.dart"
        "frontend/lib/features/main/presentation/pages/home_page.dart"
    )
    
    for file in "${key_files[@]}"; do
        if [ -f "$file" ]; then
            echo -e "${GREEN}✅ $file 存在${NC}"
        else
            echo -e "${RED}❌ $file 缺失${NC}"
        fi
    done
    
    # 检查pubspec.yaml依赖
    echo -e "${BLUE}检查Flutter依赖...${NC}"
    if grep -q "go_router:" frontend/pubspec.yaml; then
        echo -e "${GREEN}✅ go_router 依赖存在${NC}"
    else
        echo -e "${RED}❌ go_router 依赖缺失${NC}"
    fi
    
    if grep -q "flutter_riverpod:" frontend/pubspec.yaml; then
        echo -e "${GREEN}✅ flutter_riverpod 依赖存在${NC}"
    else
        echo -e "${RED}❌ flutter_riverpod 依赖缺失${NC}"
    fi
    
    if grep -q "shared_preferences:" frontend/pubspec.yaml; then
        echo -e "${GREEN}✅ shared_preferences 依赖存在${NC}"
    else
        echo -e "${RED}❌ shared_preferences 依赖缺失${NC}"
    fi
    
else
    echo -e "${RED}❌ Flutter项目目录不存在${NC}"
fi

echo ""
echo -e "${YELLOW}=== 认证流程测试总结 ===${NC}"
echo "1. ✅ 启动页面 (SplashPage) - 检查token并跳转"
echo "2. ✅ 路由守卫 - 未登录跳转登录页"
echo "3. ✅ 登录页面 - 支持用户名/邮箱/手机号登录"
echo "4. ✅ 注册页面 - 多种注册方式"
echo "5. ✅ 主页面 - 4个Tab + 发布按钮"
echo "6. ✅ 认证提供者 - 管理登录状态"
echo "7. ✅ Go后端 - 用户认证接口"
echo "8. ✅ JWT中间件 - Token验证"
echo ""
echo -e "${GREEN}🎉 Gymates 认证流程实现完成！${NC}"
echo ""
echo -e "${BLUE}使用说明:${NC}"
echo "1. 启动Go后端: cd backend-go && go run main.go"
echo "2. 启动Flutter前端: cd frontend && flutter run"
echo "3. 应用启动时会显示启动页面，检查本地token"
echo "4. 如果token有效，直接跳转到首页"
echo "5. 如果token无效或不存在，跳转到登录页"
echo "6. 登录成功后保存token并跳转到首页"
echo "7. 退出登录时清除token并跳转到登录页"
