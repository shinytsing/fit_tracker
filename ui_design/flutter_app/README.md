# Gymates Fitness Social App - Flutter版本

这是一个健身社交应用的Flutter版本，帮助用户找到健身伙伴，分享训练动态，并跟踪健身进度。

## 功能特性

### 🔐 认证系统
- **登录页面**: 支持一键登录、手机号登录和社交登录
- **注册页面**: 用户注册和账号创建
- **引导页面**: 个性化设置（身高、体重、经验、目标）

### 🏋️ 主要功能
- **训练页面**: 今日计划、AI训练计划生成器、训练历史
- **社区页面**: 动态分享、挑战参与、内容浏览
- **搭子页面**: 滑动卡片寻找健身伙伴，AI推荐匹配
- **消息页面**: 私聊消息和系统通知
- **个人资料**: 用户信息管理、数据统计、设置

### 🎨 设计系统
- **双主题支持**: iOS风格和Android Material 3风格
- **响应式设计**: 适配不同屏幕尺寸
- **流畅动画**: 使用flutter_animate实现丰富的交互动画
- **现代化UI**: 遵循平台设计规范

## 技术栈

- **Flutter**: 跨平台移动应用开发框架
- **Provider**: 状态管理
- **GoRouter**: 路由管理
- **Cached Network Image**: 图片缓存和加载
- **Flutter Animate**: 动画效果
- **Shared Preferences**: 本地数据存储

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── providers/                # 状态管理
│   ├── theme_provider.dart   # 主题管理
│   └── auth_provider.dart    # 认证状态管理
├── screens/                  # 页面
│   ├── auth/                 # 认证相关页面
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── onboarding_screen.dart
│   ├── main/                 # 主页面
│   │   └── main_screen.dart
│   ├── training/             # 训练页面
│   │   └── training_screen.dart
│   ├── community/            # 社区页面
│   │   └── community_screen.dart
│   ├── mates/                # 搭子页面
│   │   └── mates_screen.dart
│   ├── messages/             # 消息页面
│   │   └── messages_screen.dart
│   └── profile/              # 个人资料页面
│       └── profile_screen.dart
└── widgets/                  # 可复用组件
    ├── custom_button.dart
    ├── custom_card.dart
    ├── stats_card.dart
    ├── today_plan_card.dart
    ├── ai_plan_generator.dart
    ├── training_history_list.dart
    ├── post_creator.dart
    ├── challenge_cards.dart
    └── feed_list.dart
```

## 安装和运行

### 前置要求
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- iOS开发需要Xcode (macOS)

### 安装步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd flutter_app
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行应用**
   ```bash
   # 调试模式
   flutter run
   
   # 发布模式
   flutter run --release
   ```

### 平台特定设置

#### Android
- 确保Android SDK已安装
- 配置Android模拟器或连接真机

#### iOS
- 确保Xcode已安装
- 配置iOS模拟器或连接真机
- 运行 `cd ios && pod install` 安装iOS依赖

## 主要功能说明

### 1. 认证流程
- 用户首次打开应用会看到登录页面
- 支持一键登录、手机号注册
- 注册后进入引导页面设置个人信息
- 完成引导后进入主应用

### 2. 训练功能
- **今日计划**: 显示当天的训练计划
- **AI计划生成器**: 基于用户目标生成个性化训练计划
- **训练历史**: 查看历史训练记录和统计数据

### 3. 社区功能
- **动态分享**: 发布训练记录、饮食分享、心情动态
- **挑战参与**: 参与社区挑战活动
- **内容浏览**: 关注、推荐、热门内容分类浏览

### 4. 搭子功能
- **滑动匹配**: Tinder风格的卡片滑动寻找健身伙伴
- **AI推荐**: 基于用户偏好和位置推荐合适的搭子
- **详细信息**: 查看搭子的详细资料和匹配度

### 5. 消息功能
- **私聊消息**: 与搭子和朋友进行私聊
- **系统通知**: 接收训练提醒、挑战更新等通知
- **音视频通话**: 支持语音和视频通话功能

### 6. 个人资料
- **用户信息**: 查看和编辑个人资料
- **数据统计**: 训练次数、消耗卡路里、目标完成度
- **功能入口**: 训练记录、饮食记录、数据统计等
- **设置选项**: 通知设置、隐私设置、帮助中心等

## 主题系统

应用支持两种设计风格：

### iOS风格
- 圆角设计 (12px-20px)
- 无阴影或轻微阴影
- SF Pro Display字体
- 更大的字体权重差异

### Android风格
- Material 3设计规范
- 适中的圆角 (8px-12px)
- 标准阴影效果
- Material Design字体权重

主题会根据设备类型自动检测，用户也可以在设置中手动切换。

## 状态管理

使用Provider进行状态管理：

- **ThemeProvider**: 管理主题状态和切换
- **AuthProvider**: 管理用户认证状态和用户信息

## 路由管理

使用GoRouter进行路由管理，支持：
- 认证流程路由
- 主应用路由
- 页面间导航
- 路由守卫

## 性能优化

- **图片缓存**: 使用cached_network_image优化图片加载
- **懒加载**: 列表使用懒加载减少内存占用
- **动画优化**: 使用flutter_animate提供流畅动画
- **状态管理**: 合理使用Provider避免不必要的重建

## 扩展功能

### 可以添加的功能
- 实时聊天功能
- 视频通话集成
- 地图集成显示附近健身房
- 健康数据同步
- 社交分享功能
- 推送通知
- 离线模式支持

### 后端集成
- 用户认证API
- 训练数据同步
- 社交功能API
- 推送通知服务
- 文件上传服务

## 注意事项

1. **网络图片**: 应用使用了Unsplash的示例图片，实际使用时需要替换为真实图片
2. **API集成**: 当前使用模拟数据，需要集成真实的后端API
3. **权限管理**: 需要添加相机、位置等权限请求
4. **错误处理**: 需要完善网络错误和异常处理
5. **国际化**: 当前只支持中文，可以添加多语言支持

## 贡献指南

1. Fork项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建Pull Request

## 许可证

本项目采用MIT许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 联系方式

如有问题或建议，请通过以下方式联系：
- 邮箱: your-email@example.com
- GitHub Issues: [项目Issues页面]

---

**注意**: 这是一个演示项目，展示了如何将React应用转换为Flutter应用。实际使用时需要根据具体需求进行调整和完善。
