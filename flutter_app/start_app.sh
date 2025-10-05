#!/bin/bash

echo "🚀 启动Figma UI集成的Gymates应用..."

# 进入Flutter项目目录
cd /Users/gaojie/Desktop/fittraker/flutter_app

# 显示可用设备
echo "📱 可用设备："
flutter devices

echo ""
echo "选择启动设备："
echo "1) Android模拟器 (emulator-5554)"
echo "2) iOS模拟器 (iPhone 16 Pro)"
echo "3) macOS桌面版"
echo "4) 无线连接的iPhone"
echo "5) 所有设备"

read -p "请输入选择 (1-5): " choice

case $choice in
    1)
        echo "🤖 在Android模拟器上启动..."
        flutter run --debug -d emulator-5554
        ;;
    2)
        echo "🍎 在iOS模拟器上启动..."
        flutter run --debug -d 5F4DCB30-4D5B-411E-B582-631D6263462F
        ;;
    3)
        echo "💻 在macOS上启动..."
        flutter run --debug -d macos
        ;;
    4)
        echo "📱 在无线iPhone上启动..."
        flutter run --debug -d 00008130-0004158404298D3A
        ;;
    5)
        echo "🌐 在所有设备上启动..."
        flutter run --debug -d all
        ;;
    *)
        echo "❌ 无效选择，默认在Android模拟器上启动..."
        flutter run --debug -d emulator-5554
        ;;
esac

echo "✅ 应用启动完成！"
