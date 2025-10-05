#!/bin/bash

# FitTracker 按钮驱动 API 联调测试执行脚本
# 自动化执行所有按钮测试，生成详细报告

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
BACKEND_URL="http://localhost:8080"
FRONTEND_DIR="frontend"
BACKEND_DIR="backend"
TEST_RESULTS_DIR="test_results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEST_REPORT_FILE="$TEST_RESULTS_DIR/button_driven_test_report_$TIMESTAMP.json"

# 创建测试结果目录
mkdir -p $TEST_RESULTS_DIR

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}FitTracker 按钮驱动 API 联调测试${NC}"
echo -e "${BLUE}========================================${NC}"
echo "测试时间: $(date)"
echo "测试报告: $TEST_REPORT_FILE"
echo ""

# 初始化测试结果
init_test_results() {
    cat > $TEST_REPORT_FILE << EOF
{
    "test_info": {
        "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
        "test_type": "button_driven_api_test",
        "environment": "development"
    },
    "test_results": {
        "total_tests": 0,
        "passed_tests": 0,
        "failed_tests": 0,
        "skipped_tests": 0,
        "success_rate": 0
    },
    "button_tests": []
}
EOF
}

# 更新测试结果
update_test_result() {
    local button_name="$1"
    local status="$2"
    local details="$3"
    local api_endpoint="$4"
    local http_status="$5"
    
    # 创建临时文件来更新JSON
    local temp_file=$(mktemp)
    
    # 使用jq更新JSON（如果jq可用）
    if command -v jq &> /dev/null; then
        jq --arg button "$button_name" \
           --arg status "$status" \
           --arg details "$details" \
           --arg endpoint "$api_endpoint" \
           --arg http_status "$http_status" \
           --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
           '.button_tests += [{
               "button_name": $button,
               "status": $status,
               "details": $details,
               "api_endpoint": $endpoint,
               "http_status": $http_status,
               "timestamp": $timestamp
           }]' $TEST_REPORT_FILE > $temp_file
        mv $temp_file $TEST_REPORT_FILE
    else
        # 如果没有jq，使用简单的文本追加
        echo "    {
        \"button_name\": \"$button_name\",
        \"status\": \"$status\",
        \"details\": \"$details\",
        \"api_endpoint\": \"$api_endpoint\",
        \"http_status\": \"$http_status\",
        \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"
    }," >> $TEST_RESULTS_DIR/temp_results.txt
    fi
}

# 检查服务状态
check_services() {
    echo -e "${YELLOW}1. 检查服务状态...${NC}"
    
    # 检查后端服务
    if curl -s "$BACKEND_URL/health" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✅ 后端服务运行正常${NC}"
        return 0
    else
        echo -e "  ${RED}❌ 后端服务未运行${NC}"
        echo -e "  ${YELLOW}请先启动后端服务:${NC}"
        echo -e "  ${BLUE}cd $BACKEND_DIR && python main.py${NC}"
        return 1
    fi
}

# 测试认证相关按钮
test_auth_buttons() {
    echo -e "${YELLOW}2. 测试认证相关按钮...${NC}"
    
    # 测试注册按钮
    echo -e "  ${BLUE}测试注册按钮...${NC}"
    local register_response=$(curl -s -w "%{http_code}" -X POST "$BACKEND_URL/api/v1/auth/register" \
        -H "Content-Type: application/json" \
        -d '{
            "username": "testuser_'$(date +%s)'",
            "email": "test_'$(date +%s)'@example.com",
            "password": "TestPassword123!",
            "first_name": "Test",
            "last_name": "User"
        }')
    
    local register_http_code="${register_response: -3}"
    local register_body="${register_response%???}"
    
    if [[ "$register_http_code" == "200" || "$register_http_code" == "201" ]]; then
        echo -e "    ${GREEN}✅ 注册按钮测试通过${NC}"
        update_test_result "注册按钮" "通过" "用户注册成功" "/auth/register" "$register_http_code"
    else
        echo -e "    ${RED}❌ 注册按钮测试失败 (HTTP $register_http_code)${NC}"
        update_test_result "注册按钮" "失败" "HTTP $register_http_code" "/auth/register" "$register_http_code"
    fi
    
    # 测试登录按钮
    echo -e "  ${BLUE}测试登录按钮...${NC}"
    local login_response=$(curl -s -w "%{http_code}" -X POST "$BACKEND_URL/api/v1/auth/login" \
        -H "Content-Type: application/json" \
        -d '{
            "email": "test@example.com",
            "password": "TestPassword123!"
        }')
    
    local login_http_code="${login_response: -3}"
    local login_body="${login_response%???}"
    
    if [[ "$login_http_code" == "200" ]]; then
        echo -e "    ${GREEN}✅ 登录按钮测试通过${NC}"
        update_test_result "登录按钮" "通过" "登录成功" "/auth/login" "$login_http_code"
        
        # 提取token用于后续测试
        AUTH_TOKEN=$(echo "$login_body" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
        if [[ -n "$AUTH_TOKEN" ]]; then
            echo -e "    ${GREEN}✅ Token获取成功${NC}"
        fi
    else
        echo -e "    ${RED}❌ 登录按钮测试失败 (HTTP $login_http_code)${NC}"
        update_test_result "登录按钮" "失败" "HTTP $login_http_code" "/auth/login" "$login_http_code"
    fi
}

# 测试BMI计算器按钮
test_bmi_buttons() {
    echo -e "${YELLOW}3. 测试BMI计算器按钮...${NC}"
    
    if [[ -z "$AUTH_TOKEN" ]]; then
        echo -e "  ${YELLOW}⚠️ 跳过BMI测试 - 需要认证token${NC}"
        update_test_result "BMI计算按钮" "跳过" "需要认证token" "/bmi/calculate" "N/A"
        return
    fi
    
    # 测试BMI计算按钮
    echo -e "  ${BLUE}测试BMI计算按钮...${NC}"
    local bmi_response=$(curl -s -w "%{http_code}" -X POST "$BACKEND_URL/api/v1/bmi/calculate" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $AUTH_TOKEN" \
        -d '{
            "height": 175.0,
            "weight": 70.0,
            "age": 25,
            "gender": "male"
        }')
    
    local bmi_http_code="${bmi_response: -3}"
    local bmi_body="${bmi_response%???}"
    
    if [[ "$bmi_http_code" == "200" ]]; then
        echo -e "    ${GREEN}✅ BMI计算按钮测试通过${NC}"
        update_test_result "BMI计算按钮" "通过" "BMI计算成功" "/bmi/calculate" "$bmi_http_code"
    else
        echo -e "    ${RED}❌ BMI计算按钮测试失败 (HTTP $bmi_http_code)${NC}"
        update_test_result "BMI计算按钮" "失败" "HTTP $bmi_http_code" "/bmi/calculate" "$bmi_http_code"
    fi
    
    # 测试BMI历史记录按钮
    echo -e "  ${BLUE}测试BMI历史记录按钮...${NC}"
    local bmi_history_response=$(curl -s -w "%{http_code}" -X GET "$BACKEND_URL/api/v1/bmi/records" \
        -H "Authorization: Bearer $AUTH_TOKEN")
    
    local bmi_history_http_code="${bmi_history_response: -3}"
    
    if [[ "$bmi_history_http_code" == "200" ]]; then
        echo -e "    ${GREEN}✅ BMI历史记录按钮测试通过${NC}"
        update_test_result "BMI历史记录按钮" "通过" "获取历史记录成功" "/bmi/records" "$bmi_history_http_code"
    else
        echo -e "    ${RED}❌ BMI历史记录按钮测试失败 (HTTP $bmi_history_http_code)${NC}"
        update_test_result "BMI历史记录按钮" "失败" "HTTP $bmi_history_http_code" "/bmi/records" "$bmi_history_http_code"
    fi
}

# 测试社区功能按钮
test_community_buttons() {
    echo -e "${YELLOW}4. 测试社区功能按钮...${NC}"
    
    if [[ -z "$AUTH_TOKEN" ]]; then
        echo -e "  ${YELLOW}⚠️ 跳过社区测试 - 需要认证token${NC}"
        update_test_result "发布动态按钮" "跳过" "需要认证token" "/community/posts" "N/A"
        return
    fi
    
    # 测试发布动态按钮
    echo -e "  ${BLUE}测试发布动态按钮...${NC}"
    local post_response=$(curl -s -w "%{http_code}" -X POST "$BACKEND_URL/api/v1/community/posts" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $AUTH_TOKEN" \
        -d '{
            "content": "自动化测试动态 - '$(date)'",
            "type": "训练",
            "is_public": true,
            "images": [],
            "tags": ["测试", "自动化"]
        }')
    
    local post_http_code="${post_response: -3}"
    local post_body="${post_response%???}"
    
    if [[ "$post_http_code" == "200" || "$post_http_code" == "201" ]]; then
        echo -e "    ${GREEN}✅ 发布动态按钮测试通过${NC}"
        update_test_result "发布动态按钮" "通过" "动态发布成功" "/community/posts" "$post_http_code"
        
        # 提取动态ID用于后续测试
        POST_ID=$(echo "$post_body" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
        if [[ -n "$POST_ID" ]]; then
            echo -e "    ${GREEN}✅ 动态ID获取成功: $POST_ID${NC}"
        fi
    else
        echo -e "    ${RED}❌ 发布动态按钮测试失败 (HTTP $post_http_code)${NC}"
        update_test_result "发布动态按钮" "失败" "HTTP $post_http_code" "/community/posts" "$post_http_code"
    fi
    
    # 测试点赞按钮
    if [[ -n "$POST_ID" ]]; then
        echo -e "  ${BLUE}测试点赞按钮...${NC}"
        local like_response=$(curl -s -w "%{http_code}" -X POST "$BACKEND_URL/api/v1/community/posts/$POST_ID/like" \
            -H "Authorization: Bearer $AUTH_TOKEN")
        
        local like_http_code="${like_response: -3}"
        
        if [[ "$like_http_code" == "200" || "$like_http_code" == "201" ]]; then
            echo -e "    ${GREEN}✅ 点赞按钮测试通过${NC}"
            update_test_result "点赞按钮" "通过" "点赞成功" "/community/posts/$POST_ID/like" "$like_http_code"
        else
            echo -e "    ${RED}❌ 点赞按钮测试失败 (HTTP $like_http_code)${NC}"
            update_test_result "点赞按钮" "失败" "HTTP $like_http_code" "/community/posts/$POST_ID/like" "$like_http_code"
        fi
        
        # 测试评论按钮
        echo -e "  ${BLUE}测试评论按钮...${NC}"
        local comment_response=$(curl -s -w "%{http_code}" -X POST "$BACKEND_URL/api/v1/community/posts/$POST_ID/comments" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $AUTH_TOKEN" \
            -d '{
                "content": "这是一条自动化测试评论"
            }')
        
        local comment_http_code="${comment_response: -3}"
        
        if [[ "$comment_http_code" == "200" || "$comment_http_code" == "201" ]]; then
            echo -e "    ${GREEN}✅ 评论按钮测试通过${NC}"
            update_test_result "评论按钮" "通过" "评论发布成功" "/community/posts/$POST_ID/comments" "$comment_http_code"
        else
            echo -e "    ${RED}❌ 评论按钮测试失败 (HTTP $comment_http_code)${NC}"
            update_test_result "评论按钮" "失败" "HTTP $comment_http_code" "/community/posts/$POST_ID/comments" "$comment_http_code"
        fi
    fi
    
    # 测试获取动态列表按钮
    echo -e "  ${BLUE}测试获取动态列表按钮...${NC}"
    local posts_response=$(curl -s -w "%{http_code}" -X GET "$BACKEND_URL/api/v1/community/posts" \
        -H "Authorization: Bearer $AUTH_TOKEN")
    
    local posts_http_code="${posts_response: -3}"
    
    if [[ "$posts_http_code" == "200" ]]; then
        echo -e "    ${GREEN}✅ 获取动态列表按钮测试通过${NC}"
        update_test_result "获取动态列表按钮" "通过" "获取动态列表成功" "/community/posts" "$posts_http_code"
    else
        echo -e "    ${RED}❌ 获取动态列表按钮测试失败 (HTTP $posts_http_code)${NC}"
        update_test_result "获取动态列表按钮" "失败" "HTTP $posts_http_code" "/community/posts" "$posts_http_code"
    fi
}

# 测试训练计划按钮
test_training_plan_buttons() {
    echo -e "${YELLOW}5. 测试训练计划按钮...${NC}"
    
    if [[ -z "$AUTH_TOKEN" ]]; then
        echo -e "  ${YELLOW}⚠️ 跳过训练计划测试 - 需要认证token${NC}"
        update_test_result "获取训练计划按钮" "跳过" "需要认证token" "/workout/plans" "N/A"
        return
    fi
    
    # 测试获取训练计划按钮
    echo -e "  ${BLUE}测试获取训练计划按钮...${NC}"
    local plans_response=$(curl -s -w "%{http_code}" -X GET "$BACKEND_URL/api/v1/workout/plans" \
        -H "Authorization: Bearer $AUTH_TOKEN")
    
    local plans_http_code="${plans_response: -3}"
    
    if [[ "$plans_http_code" == "200" ]]; then
        echo -e "    ${GREEN}✅ 获取训练计划按钮测试通过${NC}"
        update_test_result "获取训练计划按钮" "通过" "获取训练计划成功" "/workout/plans" "$plans_http_code"
    else
        echo -e "    ${RED}❌ 获取训练计划按钮测试失败 (HTTP $plans_http_code)${NC}"
        update_test_result "获取训练计划按钮" "失败" "HTTP $plans_http_code" "/workout/plans" "$plans_http_code"
    fi
    
    # 测试创建训练计划按钮
    echo -e "  ${BLUE}测试创建训练计划按钮...${NC}"
    local create_plan_response=$(curl -s -w "%{http_code}" -X POST "$BACKEND_URL/api/v1/workout/plans" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $AUTH_TOKEN" \
        -d '{
            "name": "自动化测试训练计划",
            "description": "通过按钮测试创建的训练计划",
            "type": "力量训练",
            "difficulty": "中级",
            "duration_weeks": 4,
            "exercises": [
                {
                    "name": "俯卧撑",
                    "sets": 3,
                    "reps": 15,
                    "rest_seconds": 60
                }
            ]
        }')
    
    local create_plan_http_code="${create_plan_response: -3}"
    
    if [[ "$create_plan_http_code" == "200" || "$create_plan_http_code" == "201" ]]; then
        echo -e "    ${GREEN}✅ 创建训练计划按钮测试通过${NC}"
        update_test_result "创建训练计划按钮" "通过" "训练计划创建成功" "/workout/plans" "$create_plan_http_code"
    else
        echo -e "    ${RED}❌ 创建训练计划按钮测试失败 (HTTP $create_plan_http_code)${NC}"
        update_test_result "创建训练计划按钮" "失败" "HTTP $create_plan_http_code" "/workout/plans" "$create_plan_http_code"
    fi
}

# 测试AI功能按钮
test_ai_buttons() {
    echo -e "${YELLOW}6. 测试AI功能按钮...${NC}"
    
    if [[ -z "$AUTH_TOKEN" ]]; then
        echo -e "  ${YELLOW}⚠️ 跳过AI测试 - 需要认证token${NC}"
        update_test_result "AI训练计划按钮" "跳过" "需要认证token" "/ai/training-plan" "N/A"
        return
    fi
    
    # 测试AI训练计划生成按钮
    echo -e "  ${BLUE}测试AI训练计划生成按钮...${NC}"
    local ai_plan_response=$(curl -s -w "%{http_code}" -X POST "$BACKEND_URL/api/v1/ai/training-plan" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $AUTH_TOKEN" \
        -d '{
            "goal": "增肌",
            "duration": 30,
            "difficulty": "中级",
            "equipment": ["哑铃", "杠铃"],
            "time_per_day": 60,
            "preferences": "力量训练"
        }')
    
    local ai_plan_http_code="${ai_plan_response: -3}"
    
    if [[ "$ai_plan_http_code" == "200" ]]; then
        echo -e "    ${GREEN}✅ AI训练计划生成按钮测试通过${NC}"
        update_test_result "AI训练计划生成按钮" "通过" "AI生成训练计划成功" "/ai/training-plan" "$ai_plan_http_code"
    else
        echo -e "    ${RED}❌ AI训练计划生成按钮测试失败 (HTTP $ai_plan_http_code)${NC}"
        update_test_result "AI训练计划生成按钮" "失败" "HTTP $ai_plan_http_code" "/ai/training-plan" "$ai_plan_http_code"
    fi
    
    # 测试AI健康建议按钮
    echo -e "  ${BLUE}测试AI健康建议按钮...${NC}"
    local ai_advice_response=$(curl -s -w "%{http_code}" -X POST "$BACKEND_URL/api/v1/ai/health-advice" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $AUTH_TOKEN" \
        -d '{
            "bmi": 22.5,
            "age": 25,
            "gender": "male",
            "activity_level": "moderate"
        }')
    
    local ai_advice_http_code="${ai_advice_response: -3}"
    
    if [[ "$ai_advice_http_code" == "200" ]]; then
        echo -e "    ${GREEN}✅ AI健康建议按钮测试通过${NC}"
        update_test_result "AI健康建议按钮" "通过" "AI生成健康建议成功" "/ai/health-advice" "$ai_advice_http_code"
    else
        echo -e "    ${RED}❌ AI健康建议按钮测试失败 (HTTP $ai_advice_http_code)${NC}"
        update_test_result "AI健康建议按钮" "失败" "HTTP $ai_advice_http_code" "/ai/health-advice" "$ai_advice_http_code"
    fi
}

# 测试签到功能按钮
test_checkin_buttons() {
    echo -e "${YELLOW}7. 测试签到功能按钮...${NC}"
    
    if [[ -z "$AUTH_TOKEN" ]]; then
        echo -e "  ${YELLOW}⚠️ 跳过签到测试 - 需要认证token${NC}"
        update_test_result "签到按钮" "跳过" "需要认证token" "/checkins" "N/A"
        return
    fi
    
    # 测试签到按钮
    echo -e "  ${BLUE}测试签到按钮...${NC}"
    local checkin_response=$(curl -s -w "%{http_code}" -X POST "$BACKEND_URL/api/v1/checkins" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $AUTH_TOKEN" \
        -d '{
            "type": "训练",
            "notes": "自动化测试签到",
            "mood": "开心",
            "energy": 8,
            "motivation": 9
        }')
    
    local checkin_http_code="${checkin_response: -3}"
    
    if [[ "$checkin_http_code" == "200" || "$checkin_http_code" == "201" ]]; then
        echo -e "    ${GREEN}✅ 签到按钮测试通过${NC}"
        update_test_result "签到按钮" "通过" "签到成功" "/checkins" "$checkin_http_code"
    else
        echo -e "    ${RED}❌ 签到按钮测试失败 (HTTP $checkin_http_code)${NC}"
        update_test_result "签到按钮" "失败" "HTTP $checkin_http_code" "/checkins" "$checkin_http_code"
    fi
    
    # 测试签到统计按钮
    echo -e "  ${BLUE}测试签到统计按钮...${NC}"
    local checkin_stats_response=$(curl -s -w "%{http_code}" -X GET "$BACKEND_URL/api/v1/checkins/streak" \
        -H "Authorization: Bearer $AUTH_TOKEN")
    
    local checkin_stats_http_code="${checkin_stats_response: -3}"
    
    if [[ "$checkin_stats_http_code" == "200" ]]; then
        echo -e "    ${GREEN}✅ 签到统计按钮测试通过${NC}"
        update_test_result "签到统计按钮" "通过" "获取签到统计成功" "/checkins/streak" "$checkin_stats_http_code"
    else
        echo -e "    ${RED}❌ 签到统计按钮测试失败 (HTTP $checkin_stats_http_code)${NC}"
        update_test_result "签到统计按钮" "失败" "HTTP $checkin_stats_http_code" "/checkins/streak" "$checkin_stats_http_code"
    fi
}

# 生成测试报告
generate_test_report() {
    echo -e "${YELLOW}8. 生成测试报告...${NC}"
    
    # 计算测试统计
    local total_tests=$(grep -c "button_name" $TEST_REPORT_FILE 2>/dev/null || echo "0")
    local passed_tests=$(grep -c '"status": "通过"' $TEST_REPORT_FILE 2>/dev/null || echo "0")
    local failed_tests=$(grep -c '"status": "失败"' $TEST_REPORT_FILE 2>/dev/null || echo "0")
    local skipped_tests=$(grep -c '"status": "跳过"' $TEST_REPORT_FILE 2>/dev/null || echo "0")
    
    local success_rate=0
    if [[ $total_tests -gt 0 ]]; then
        success_rate=$((passed_tests * 100 / total_tests))
    fi
    
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}测试报告摘要${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo "测试时间: $(date)"
    echo "总测试数: $total_tests"
    echo "通过测试: $passed_tests"
    echo "失败测试: $failed_tests"
    echo "跳过测试: $skipped_tests"
    echo "成功率: $success_rate%"
    echo ""
    
    # 生成HTML报告
    local html_report="$TEST_RESULTS_DIR/button_driven_test_report_$TIMESTAMP.html"
    cat > $html_report << EOF
<!DOCTYPE html>
<html>
<head>
    <title>FitTracker 按钮驱动 API 测试报告</title>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        .summary { background-color: #e8f5e8; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .test-result { margin: 10px 0; padding: 10px; border-left: 4px solid #ccc; }
        .passed { border-left-color: #4CAF50; background-color: #f1f8e9; }
        .failed { border-left-color: #f44336; background-color: #ffebee; }
        .skipped { border-left-color: #ff9800; background-color: #fff3e0; }
        .timestamp { color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="header">
        <h1>FitTracker 按钮驱动 API 测试报告</h1>
        <p class="timestamp">测试时间: $(date)</p>
    </div>
    
    <div class="summary">
        <h2>测试摘要</h2>
        <p>总测试数: $total_tests</p>
        <p>通过测试: $passed_tests</p>
        <p>失败测试: $failed_tests</p>
        <p>跳过测试: $skipped_tests</p>
        <p>成功率: $success_rate%</p>
    </div>
    
    <h2>详细测试结果</h2>
EOF
    
    # 添加测试结果到HTML报告
    if [[ -f $TEST_RESULTS_DIR/temp_results.txt ]]; then
        while IFS= read -r line; do
            if [[ $line == *"button_name"* ]]; then
                local button_name=$(echo "$line" | grep -o '"button_name": "[^"]*"' | cut -d'"' -f4)
                local status=$(echo "$line" | grep -o '"status": "[^"]*"' | cut -d'"' -f4)
                local details=$(echo "$line" | grep -o '"details": "[^"]*"' | cut -d'"' -f4)
                local endpoint=$(echo "$line" | grep -o '"api_endpoint": "[^"]*"' | cut -d'"' -f4)
                
                local class=""
                case $status in
                    "通过") class="passed" ;;
                    "失败") class="failed" ;;
                    "跳过") class="skipped" ;;
                esac
                
                cat >> $html_report << EOF
    <div class="test-result $class">
        <h3>$button_name</h3>
        <p><strong>状态:</strong> $status</p>
        <p><strong>详情:</strong> $details</p>
        <p><strong>API端点:</strong> $endpoint</p>
    </div>
EOF
            fi
        done < $TEST_RESULTS_DIR/temp_results.txt
    fi
    
    cat >> $html_report << EOF
</body>
</html>
EOF
    
    echo -e "${GREEN}✅ HTML报告已生成: $html_report${NC}"
    echo -e "${GREEN}✅ JSON报告已生成: $TEST_REPORT_FILE${NC}"
    
    # 清理临时文件
    rm -f $TEST_RESULTS_DIR/temp_results.txt
}

# 主函数
main() {
    echo "开始执行按钮驱动 API 联调测试..."
    
    # 初始化测试结果
    init_test_results
    
    # 检查服务状态
    if ! check_services; then
        echo -e "${RED}❌ 服务检查失败，退出测试${NC}"
        exit 1
    fi
    
    # 执行各项测试
    test_auth_buttons
    test_bmi_buttons
    test_community_buttons
    test_training_plan_buttons
    test_ai_buttons
    test_checkin_buttons
    
    # 生成测试报告
    generate_test_report
    
    echo ""
    echo -e "${GREEN}🎉 按钮驱动 API 联调测试完成！${NC}"
    echo -e "${BLUE}测试报告位置: $TEST_RESULTS_DIR/${NC}"
    echo ""
    echo -e "${YELLOW}下一步操作:${NC}"
    echo "1. 查看测试报告了解详细结果"
    echo "2. 修复失败的测试用例"
    echo "3. 在移动端进行UI验证测试"
    echo "4. 运行回归测试确保功能稳定"
}

# 执行主函数
main "$@"
