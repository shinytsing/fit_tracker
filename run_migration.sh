#!/bin/bash

# 导航重构数据库迁移执行脚本
# 按照功能重排表更新数据库结构

set -e

echo "🚀 开始执行导航重构数据库迁移..."

# 检查环境变量
if [ -z "$DATABASE_URL" ]; then
    echo "❌ 错误: 请设置 DATABASE_URL 环境变量"
    exit 1
fi

# 检查PostgreSQL连接
echo "📡 检查数据库连接..."
psql "$DATABASE_URL" -c "SELECT version();" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ 错误: 无法连接到数据库"
    exit 1
fi

echo "✅ 数据库连接成功"

# 执行迁移脚本
echo "📝 执行数据库迁移脚本..."
psql "$DATABASE_URL" -f backend/migrations/001_navigation_refactor.sql

if [ $? -eq 0 ]; then
    echo "✅ 数据库迁移执行成功"
else
    echo "❌ 数据库迁移执行失败"
    exit 1
fi

# 验证迁移结果
echo "🔍 验证迁移结果..."

# 检查新表是否创建成功
TABLES=("drafts" "coaches" "experience_articles" "online_courses" "course_enrollments" "nutrition_logs" "water_logs" "body_metrics" "ai_conversations")

for table in "${TABLES[@]}"; do
    if psql "$DATABASE_URL" -c "SELECT 1 FROM $table LIMIT 1;" > /dev/null 2>&1; then
        echo "✅ 表 $table 创建成功"
    else
        echo "❌ 表 $table 创建失败"
        exit 1
    fi
done

# 检查索引是否创建成功
echo "📊 检查索引创建情况..."
INDEX_COUNT=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'public' AND indexname LIKE 'idx_%';")
echo "✅ 创建了 $INDEX_COUNT 个索引"

# 检查视图是否创建成功
VIEWS=("coach_profiles" "published_articles" "published_courses")
for view in "${VIEWS[@]}"; do
    if psql "$DATABASE_URL" -c "SELECT 1 FROM $view LIMIT 1;" > /dev/null 2>&1; then
        echo "✅ 视图 $view 创建成功"
    else
        echo "❌ 视图 $view 创建失败"
        exit 1
    fi
done

# 检查示例数据
COACH_COUNT=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM coaches;")
echo "✅ 插入了 $COACH_COUNT 个教练示例数据"

echo ""
echo "🎉 导航重构数据库迁移完成！"
echo ""
echo "📋 迁移摘要："
echo "   - 更新了 posts 表，添加新的发布类型支持"
echo "   - 创建了 9 个新表支持新功能"
echo "   - 创建了 15 个索引提高查询性能"
echo "   - 创建了 3 个视图便于查询"
echo "   - 插入了示例数据"
echo ""
echo "🔧 新功能支持："
echo "   ✅ 发布动态（文字、图片、视频、训练成果）"
echo "   ✅ 快速打卡"
echo "   ✅ 分享心情/饮食"
echo "   ✅ 保存草稿"
echo "   ✅ 热门流"
echo "   ✅ 教练专区"
echo "   ✅ 营养管理"
echo "   ✅ 身体指标"
echo "   ✅ AI助手"
echo ""
echo "🚀 现在可以启动应用进行测试了！"
