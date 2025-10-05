#!/bin/bash

echo "🚀 启动Figma UI集成的Gymates应用..."

# 进入Flutter项目目录
cd /Users/gaojie/Desktop/fittraker/flutter_app

# 清理并获取依赖
echo "📦 清理项目并获取依赖..."
flutter clean
flutter pub get

# 检查代码
echo "🔍 检查代码..."
flutter analyze

# 运行应用
echo "🎯 启动应用..."
flutter run --debug

echo "✅ 应用启动完成！"
