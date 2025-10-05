#!/bin/bash

echo "🚀 FitTracker 手机测试启动脚本"
echo "=================================="

# 检查设备连接
echo "📱 检查设备连接..."
flutter devices

echo ""
echo "选择运行方式："
echo "1. iPhone真机 (需要Apple ID)"
echo "2. iOS模拟器 (推荐)"
echo "3. Android模拟器"
echo "4. Web浏览器 (最简单)"

read -p "请选择 (1-4): " choice

case $choice in
    1)
        echo "📱 在iPhone真机上运行..."
        flutter run -d 00008130-0004158404298D3A
        ;;
    2)
        echo "📱 在iOS模拟器上运行..."
        flutter run -d 22360110-D504-489D-8CCE-049CABF009AE
        ;;
    3)
        echo "📱 在Android模拟器上运行..."
        flutter run -d emulator-5554
        ;;
    4)
        echo "🌐 在Web浏览器上运行..."
        flutter run -d chrome --web-port 3000
        ;;
    *)
        echo "❌ 无效选择"
        ;;
esac
