#!/bin/bash

# 简化版Figma重构UI启动脚本
echo "🎨 启动简化版Figma重构UI..."
echo "📱 基于Figma设计规范，无依赖问题"
echo ""

# 进入前端目录
cd frontend

# 清理并重新获取依赖
echo "🧹 清理构建缓存..."
flutter clean
flutter pub get

echo ""
echo "🚀 启动简化版应用..."
echo "📋 特性："
echo "   ✅ 基于Figma设计的主题系统"
echo "   ✅ 重构的底部导航栏 (渐变浮动按钮)"
echo "   ✅ 优化的训练页面UI (28px标题字体)"
echo "   ✅ 改进的社区页面设计 (Tab切换器)"
echo "   ✅ 更新的消息页面界面 (系统通知卡片)"
echo "   ✅ 美化的个人资料页面 (统一头部设计)"
echo "   ✅ 浮动操作菜单 (开始训练/拍照记录/邀请好友/创建挑战)"
echo ""

# 在macOS上运行
flutter run lib/main_simple.dart --device-id=macos

echo ""
echo "🎉 应用启动完成！"
echo "💡 提示："
echo "   - 点击底部中央的+按钮查看浮动菜单"
echo "   - 切换不同Tab查看重构后的UI效果"
echo "   - 所有UI都按照Figma设计规范实现"
