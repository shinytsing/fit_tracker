#!/bin/bash

echo "🔧 iPhone真机配置自动化脚本"
echo "=================================="

# 检查Xcode是否打开
if pgrep -x "Xcode" > /dev/null; then
    echo "✅ Xcode已打开"
else
    echo "❌ 请先打开Xcode: ios/Runner.xcworkspace"
    exit 1
fi

echo ""
echo "📋 请在Xcode中完成以下步骤："
echo ""
echo "1. 🔐 登录Apple ID："
echo "   - Xcode > Preferences > Accounts"
echo "   - 点击 '+' 添加Apple ID"
echo "   - 输入您的Apple ID和密码"
echo ""
echo "2. ⚙️ 配置项目签名："
echo "   - 选择左侧 'Runner' 项目"
echo "   - 选择 'Runner' target"
echo "   - 点击 'Signing & Capabilities' 标签"
echo "   - 勾选 'Automatically manage signing'"
echo "   - 在 'Team' 中选择您的Apple ID"
echo "   - Bundle Identifier: com.gaojie.fittracker2024"
echo ""
echo "3. 📱 在iPhone上信任证书："
echo "   - 设置 > 通用 > VPN与设备管理"
echo "   - 找到开发者证书并点击'信任'"
echo ""
echo "完成后按任意键继续..."

read -p "按回车键继续..." 

echo ""
echo "🚀 尝试在真机上运行应用..."
cd /Users/gaojie/Desktop/fittraker/frontend
flutter run -d 00008130-0004158404298D3A
