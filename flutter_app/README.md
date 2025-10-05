# Gymates Fitness Social App - Flutter 版本

这是一个基于 Figma 设计完全还原的 Flutter 健身社交应用。

## 功能特性

### 🏋️ 训练页面
- 今日训练计划卡片
- AI 智能训练计划生成器
- 训练历史记录列表
- 训练进度统计

### 👥 社区页面
- 关注/推荐/热门动态切换
- 热门挑战卡片
- 用户动态信息流
- 快速操作入口

### 💬 消息页面
- 消息和通知切换
- 聊天列表
- 通知中心
- 在线状态显示

### 👤 个人资料页面
- 用户信息展示
- 训练数据统计
- 功能设置菜单
- 个人成就展示

### ➕ 浮动操作菜单
- 开始训练
- 拍照记录
- 邀请好友
- 创建挑战

## 技术栈

- **Flutter**: 跨平台移动应用开发框架
- **Material Design**: Google 设计规范
- **Google Fonts**: Inter 字体
- **Cached Network Image**: 网络图片缓存
- **Flutter SVG**: SVG 图标支持

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── screens/                  # 页面组件
│   ├── main_app.dart        # 主应用组件
│   ├── training_page.dart    # 训练页面
│   ├── community_page.dart   # 社区页面
│   ├── messages_page.dart    # 消息页面
│   └── profile_page.dart     # 个人资料页面
└── widgets/                  # 可复用组件
    ├── bottom_navigation.dart    # 底部导航栏
    ├── floating_action_menu.dart # 浮动操作菜单
    ├── training/                # 训练相关组件
    ├── community/               # 社区相关组件
    └── profile/                 # 个人资料相关组件
```

## 设计还原

### 颜色系统
- **主色调**: #6366F1 (Indigo)
- **背景色**: #F9FAFB (Gray-50)
- **文字色**: #1F2937 (Gray-900)
- **次要文字**: #6B7280 (Gray-500)
- **边框色**: #E5E7EB (Gray-200)

### 组件设计
- 完全按照 Figma 设计稿还原
- 保持原有的间距、圆角、阴影效果
- 响应式布局适配不同屏幕尺寸
- 保持原有的交互效果和动画

## 运行说明

1. 确保已安装 Flutter SDK
2. 在项目根目录运行 `flutter pub get`
3. 运行 `flutter run` 启动应用

## 依赖包

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  google_fonts: ^6.1.0
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9
```

## 注意事项

- 应用使用网络图片，需要网络连接
- 所有图片资源已配置缓存机制
- 支持深色模式（通过主题配置）
- 完全响应式设计，适配各种屏幕尺寸

## 开发说明

本项目严格按照 Figma 设计稿进行开发，确保：
- UI 完全还原，不添加额外功能
- 代码结构清晰，组件化开发
- 使用 StatelessWidget 优先，必要时使用 StatefulWidget
- 遵循 Flutter 最佳实践和 Material Design 规范
