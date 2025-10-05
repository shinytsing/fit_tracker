#!/bin/bash

# Gymates Flutter App - 快速启动脚本

echo "🏋️ Gymates Fitness Social App - Flutter版本"
echo "=============================================="

# 检查Flutter是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter未安装，请先安装Flutter SDK"
    echo "   访问: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# 检查Flutter版本
echo "📱 Flutter版本:"
flutter --version

echo ""
echo "🔧 检查项目依赖..."

# 进入项目目录
cd "$(dirname "$0")"

# 获取依赖
echo "📦 安装依赖包..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ 依赖安装失败"
    exit 1
fi

echo ""
echo "🔍 检查代码质量..."
flutter analyze

if [ $? -ne 0 ]; then
    echo "⚠️  代码分析发现问题，但应用仍可运行"
fi

echo ""
echo "🧪 运行测试..."
flutter test

if [ $? -ne 0 ]; then
    echo "⚠️  测试失败，但应用仍可运行"
fi

echo ""
echo "🚀 启动应用..."
echo "选择运行平台:"
echo "1) Android模拟器"
echo "2) iOS模拟器 (仅macOS)"
echo "3) Chrome浏览器"
echo "4) 已连接的设备"

read -p "请输入选择 (1-4): " choice

case $choice in
    1)
        echo "📱 启动Android模拟器..."
        flutter run -d android
        ;;
    2)
        echo "🍎 启动iOS模拟器..."
        flutter run -d ios
        ;;
    3)
        echo "🌐 启动Chrome浏览器..."
        flutter run -d chrome
        ;;
    4)
        echo "📱 在已连接设备上运行..."
        flutter run
        ;;
    *)
        echo "❌ 无效选择，默认在已连接设备上运行..."
        flutter run
        ;;
esac

echo ""
echo "✅ 应用启动完成！"
echo ""
echo "📚 使用说明:"
echo "- 首次启动会显示登录页面"
echo "- 点击'一键登录'进入注册页面"
echo "- 完成注册后进入引导页面设置个人信息"
echo "- 引导完成后进入主应用"
echo ""
echo "🎨 主题切换:"
echo "- 应用会自动检测设备类型"
echo "- iOS设备显示iOS风格界面"
echo "- Android设备显示Material 3风格界面"
echo ""
echo "🔧 开发模式:"
echo "- 热重载: r"
echo "- 热重启: R"
echo "- 退出: q"
echo ""
echo "📖 更多信息请查看README.md文件"
