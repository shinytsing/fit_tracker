#!/bin/bash

echo "🚀 FitTracker 真机运行指南"
echo "=================================="
echo ""
echo "要在iPhone真机上运行，需要完成以下步骤："
echo ""
echo "1. 📱 在Xcode中配置Apple ID："
echo "   - 打开 ios/Runner.xcworkspace"
echo "   - 选择 Runner 项目"
echo "   - 在 Signing & Capabilities 中："
echo "     * 勾选 'Automatically manage signing'"
echo "     * 在 Team 中选择您的 Apple ID"
echo "     * Bundle Identifier 改为: com.gaojie.fittracker2024"
echo ""
echo "2. 🔑 在iPhone上信任开发者证书："
echo "   - 设置 > 通用 > VPN与设备管理"
echo "   - 找到您的开发者证书并点击'信任'"
echo ""
echo "3. 🚀 运行应用："
echo "   flutter run -d 00008130-0004158404298D3A"
echo ""
echo "当前可用的替代方案："
echo "✅ Web版本: http://localhost:3000"
echo "✅ iOS模拟器: 正在启动中..."
echo "✅ Android模拟器: 可用"
echo ""
echo "选择运行方式："
echo "1. 配置Xcode后运行真机"
echo "2. 使用iOS模拟器"
echo "3. 使用Web版本"
echo "4. 使用Android模拟器"

read -p "请选择 (1-4): " choice

case $choice in
    1)
        echo "📱 请在Xcode中完成配置后运行："
        echo "flutter run -d 00008130-0004158404298D3A"
        ;;
    2)
        echo "📱 启动iOS模拟器..."
        flutter run -d 22360110-D504-489D-8CCE-049CABF009AE
        ;;
    3)
        echo "🌐 启动Web版本..."
        flutter run -d chrome --web-port 3000
        ;;
    4)
        echo "📱 启动Android模拟器..."
        flutter run -d emulator-5554
        ;;
    *)
        echo "❌ 无效选择"
        ;;
esac
