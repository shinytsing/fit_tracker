#!/bin/bash

# Gymates Fitness App - Flutter 运行脚本

echo "🏋️ 启动 Gymates Fitness App..."

# 检查 Flutter 是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安装，请先安装 Flutter SDK"
    echo "   访问: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# 进入项目目录
cd "$(dirname "$0")"

# 检查项目是否存在
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 未找到 Flutter 项目文件"
    exit 1
fi

echo "📦 获取依赖包..."
flutter pub get

echo "🔍 检查代码..."
flutter analyze

echo "🚀 启动应用..."
echo "   选择设备后应用将自动运行"
echo "   按 'q' 退出应用"

flutter run

echo "✅ 应用已关闭"
