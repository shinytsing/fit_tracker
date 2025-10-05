import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fittracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('健身房找搭子流程测试', () {
    testWidgets('完整的健身房找搭子流程', (WidgetTester tester) async {
      // 启动应用
      app.main();
      await tester.pumpAndSettle();

      // 等待应用完全加载
      await tester.pumpAndSettle(Duration(seconds: 3));

      // 1. 检查是否在登录页面
      expect(find.text('登录'), findsOneWidget);
      
      // 2. 输入用户名和密码
      await tester.enterText(find.byKey(Key('username_field')), 'testuser');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.pumpAndSettle();

      // 3. 点击登录按钮
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // 4. 检查是否成功登录并进入主页面
      expect(find.text('社区'), findsOneWidget);
      
      // 5. 点击社区标签
      await tester.tap(find.text('社区'));
      await tester.pumpAndSettle();

      // 6. 查找"找搭子"按钮
      expect(find.text('找搭子'), findsOneWidget);
      
      // 7. 点击"找搭子"按钮
      await tester.tap(find.text('找搭子'));
      await tester.pumpAndSettle();

      // 8. 检查是否进入健身房列表页面
      expect(find.text('健身房列表'), findsOneWidget);
      
      // 9. 查找第一个健身房
      final gymCard = find.byType(Card).first;
      expect(gymCard, findsOneWidget);
      
      // 10. 点击健身房卡片
      await tester.tap(gymCard);
      await tester.pumpAndSettle();

      // 11. 检查是否进入健身房详情页面
      expect(find.text('健身房详情'), findsOneWidget);
      
      // 12. 查找"加入"按钮
      expect(find.text('加入'), findsOneWidget);
      
      // 13. 点击"加入"按钮
      await tester.tap(find.text('加入'));
      await tester.pumpAndSettle();

      // 14. 检查是否弹出加入申请表单
      expect(find.text('申请加入'), findsOneWidget);
      
      // 15. 填写申请表单
      await tester.enterText(find.byKey(Key('goal_field')), '增肌');
      await tester.enterText(find.byKey(Key('message_field')), '希望找到健身搭子一起训练');
      await tester.pumpAndSettle();

      // 16. 提交申请
      await tester.tap(find.text('提交申请'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // 17. 检查是否显示成功消息
      expect(find.text('申请提交成功'), findsOneWidget);
      
      // 18. 返回健身房详情页面
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      // 19. 检查搭子数量是否增加
      final buddiesCountText = find.textContaining('当前搭子数');
      expect(buddiesCountText, findsOneWidget);
      
      // 20. 返回健身房列表
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 21. 验证返回成功
      expect(find.text('健身房列表'), findsOneWidget);
    });

    testWidgets('发布动态流程测试', (WidgetTester tester) async {
      // 启动应用
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      // 1. 登录（复用之前的登录逻辑）
      await tester.enterText(find.byKey(Key('username_field')), 'testuser');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // 2. 进入社区页面
      await tester.tap(find.text('社区'));
      await tester.pumpAndSettle();

      // 3. 查找"发布"按钮
      expect(find.byIcon(Icons.add), findsOneWidget);
      
      // 4. 点击"发布"按钮
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 5. 检查是否进入发布页面
      expect(find.text('发布动态'), findsOneWidget);
      
      // 6. 输入动态内容
      await tester.enterText(
        find.byKey(Key('content_field')), 
        '今天完成了30分钟的跑步训练！感觉很棒！'
      );
      await tester.pumpAndSettle();

      // 7. 选择动态类型
      await tester.tap(find.text('训练'));
      await tester.pumpAndSettle();

      // 8. 添加标签
      await tester.enterText(find.byKey(Key('tags_field')), '健身,跑步,打卡');
      await tester.pumpAndSettle();

      // 9. 发布动态
      await tester.tap(find.text('发布'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // 10. 检查是否显示成功消息
      expect(find.text('发布成功'), findsOneWidget);
      
      // 11. 返回动态列表
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      // 12. 检查动态是否出现在列表中
      expect(find.text('今天完成了30分钟的跑步训练！感觉很棒！'), findsOneWidget);
      
      // 13. 验证动态类型标签
      expect(find.text('训练'), findsOneWidget);
    });

    testWidgets('用户注册流程测试', (WidgetTester tester) async {
      // 启动应用
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      // 1. 点击"注册"按钮
      await tester.tap(find.text('注册'));
      await tester.pumpAndSettle();

      // 2. 检查是否进入注册页面
      expect(find.text('用户注册'), findsOneWidget);
      
      // 3. 填写注册信息
      await tester.enterText(find.byKey(Key('username_field')), 'newuser');
      await tester.enterText(find.byKey(Key('email_field')), 'newuser@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.enterText(find.byKey(Key('confirm_password_field')), 'password123');
      await tester.enterText(find.byKey(Key('nickname_field')), '新用户');
      await tester.pumpAndSettle();

      // 4. 提交注册
      await tester.tap(find.text('注册'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // 5. 检查是否显示成功消息
      expect(find.text('注册成功'), findsOneWidget);
      
      // 6. 自动跳转到登录页面
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      // 7. 使用新账号登录
      await tester.enterText(find.byKey(Key('username_field')), 'newuser');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // 8. 检查是否成功登录
      expect(find.text('社区'), findsOneWidget);
    });

    testWidgets('用户资料更新测试', (WidgetTester tester) async {
      // 启动应用并登录
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      await tester.enterText(find.byKey(Key('username_field')), 'testuser');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // 1. 进入个人中心
      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle();

      // 2. 点击"编辑资料"
      await tester.tap(find.text('编辑资料'));
      await tester.pumpAndSettle();

      // 3. 检查是否进入编辑页面
      expect(find.text('编辑个人资料'), findsOneWidget);
      
      // 4. 更新昵称
      await tester.enterText(find.byKey(Key('nickname_field')), '更新的昵称');
      await tester.pumpAndSettle();

      // 5. 更新个人简介
      await tester.enterText(find.byKey(Key('bio_field')), '热爱健身，希望和大家一起进步！');
      await tester.pumpAndSettle();

      // 6. 选择性别
      await tester.tap(find.text('男'));
      await tester.pumpAndSettle();

      // 7. 保存更改
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // 8. 检查是否显示成功消息
      expect(find.text('保存成功'), findsOneWidget);
      
      // 9. 返回个人中心
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      // 10. 验证资料已更新
      expect(find.text('更新的昵称'), findsOneWidget);
      expect(find.text('热爱健身，希望和大家一起进步！'), findsOneWidget);
    });
  });
}
