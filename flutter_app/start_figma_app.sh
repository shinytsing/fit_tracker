#!/bin/bash

echo "🚀 启动Figma UI集成的Gymates应用..."

# 进入Flutter项目目录
cd /Users/gaojie/Desktop/fittraker/flutter_app

# 清理项目
echo "🧹 清理项目..."
flutter clean

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

# 检查代码（忽略警告）
echo "🔍 检查代码..."
flutter analyze --no-fatal-infos --no-fatal-warnings || true

# 启动应用
echo "🎯 启动应用..."
flutter run --debug -d emulator-5554

echo "✅ 应用启动完成！"
