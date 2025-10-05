#!/bin/bash

echo "🔍 检查Xcode配置状态"
echo "=================================="

# 检查Xcode是否运行
if pgrep -x "Xcode" > /dev/null; then
    echo "✅ Xcode正在运行"
else
    echo "❌ Xcode未运行，正在打开..."
    open ios/Runner.xcworkspace
    sleep 5
fi

echo ""
echo "📋 请在Xcode中完成以下配置："
echo ""
echo "1. 🎯 选择项目："
echo "   - 左侧导航栏选择 'Runner' 项目（蓝色图标）"
echo "   - 选择 'Runner' target"
echo ""
echo "2. ⚙️ 配置签名："
echo "   - 点击 'Signing & Capabilities' 标签"
echo "   - 勾选 'Automatically manage signing'"
echo "   - 在 'Team' 下拉菜单中选择您的Apple ID"
echo "   - Bundle Identifier 应该是: com.gaojie.fittracker2024"
echo ""
echo "3. 🔧 如果Bundle ID冲突："
echo "   - 改为: com.gaojie.fittracker2024.$(date +%s)"
echo "   - 或者: com.gaojie.fittracker2024.unique"
echo ""
echo "4. ✅ 验证配置："
echo "   - 应该看到绿色的勾号"
echo "   - 没有红色错误信息"
echo ""
echo "配置完成后，按回车键尝试运行..."

read -p "按回车键继续..." 

echo ""
echo "🚀 尝试在真机上运行应用..."
cd /Users/gaojie/Desktop/fittraker/frontend
flutter run -d 00008130-0004158404298D3A
