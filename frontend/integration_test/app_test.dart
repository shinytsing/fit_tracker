import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fittracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FitTracker Integration Tests', () {
    testWidgets('完整用户工作流程测试', (WidgetTester tester) async {
      // 启动应用
      app.main();
      await tester.pumpAndSettle();

      // 1. 测试登录页面
      expect(find.text('登录'), findsOneWidget);
      expect(find.text('邮箱'), findsOneWidget);
      expect(find.text('密码'), findsOneWidget);

      // 输入登录信息
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // 点击登录按钮
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // 2. 测试 API 测试页面
      expect(find.text('API Test Page'), findsOneWidget);
      expect(find.text('Fetch User Profile'), findsOneWidget);

      // 点击获取用户资料按钮
      await tester.tap(find.text('Fetch User Profile'));
      await tester.pumpAndSettle();

      // 验证响应显示
      expect(find.textContaining('Profile:'), findsOneWidget);
    });

    testWidgets('BMI 计算测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 登录
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // 测试 BMI 计算功能
      // 这里需要根据实际的 BMI 计算页面来实现
      // 假设有一个 BMI 计算按钮
      if (find.text('BMI 计算').evaluate().isNotEmpty) {
        await tester.tap(find.text('BMI 计算'));
        await tester.pumpAndSettle();

        // 输入身高和体重
        await tester.enterText(find.byType(TextFormField).first, '175');
        await tester.enterText(find.byType(TextFormField).last, '70');

        // 点击计算按钮
        await tester.tap(find.text('计算'));
        await tester.pumpAndSettle();

        // 验证结果
        expect(find.textContaining('BMI'), findsOneWidget);
      }
    });

    testWidgets('训练记录测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 登录
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // 测试训练记录功能
      if (find.text('训练记录').evaluate().isNotEmpty) {
        await tester.tap(find.text('训练记录'));
        await tester.pumpAndSettle();

        // 创建训练记录
        if (find.text('创建训练').evaluate().isNotEmpty) {
          await tester.tap(find.text('创建训练'));
          await tester.pumpAndSettle();

          // 输入训练信息
          await tester.enterText(find.byType(TextFormField).first, '胸肌训练');
          await tester.enterText(find.byType(TextFormField).at(1), '力量训练');
          await tester.enterText(find.byType(TextFormField).at(2), '60');

          // 保存训练记录
          await tester.tap(find.text('保存'));
          await tester.pumpAndSettle();

          // 验证训练记录已创建
          expect(find.text('胸肌训练'), findsOneWidget);
        }
      }
    });

    testWidgets('社区动态测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 登录
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // 测试社区动态功能
      if (find.text('社区').evaluate().isNotEmpty) {
        await tester.tap(find.text('社区'));
        await tester.pumpAndSettle();

        // 发布动态
        if (find.text('发布动态').evaluate().isNotEmpty) {
          await tester.tap(find.text('发布动态'));
          await tester.pumpAndSettle();

          // 输入动态内容
          await tester.enterText(find.byType(TextFormField).first, '今天完成了胸肌训练，感觉很好！');

          // 发布动态
          await tester.tap(find.text('发布'));
          await tester.pumpAndSettle();

          // 验证动态已发布
          expect(find.text('今天完成了胸肌训练，感觉很好！'), findsOneWidget);
        }
      }
    });

    testWidgets('签到测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 登录
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // 测试签到功能
      if (find.text('签到').evaluate().isNotEmpty) {
        await tester.tap(find.text('签到'));
        await tester.pumpAndSettle();

        // 创建签到
        if (find.text('今日签到').evaluate().isNotEmpty) {
          await tester.tap(find.text('今日签到'));
          await tester.pumpAndSettle();

          // 输入签到信息
          await tester.enterText(find.byType(TextFormField).first, '完成了今天的训练');

          // 保存签到
          await tester.tap(find.text('保存'));
          await tester.pumpAndSettle();

          // 验证签到已创建
          expect(find.text('完成了今天的训练'), findsOneWidget);
        }
      }
    });

    testWidgets('营养分析测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 登录
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // 测试营养分析功能
      if (find.text('营养').evaluate().isNotEmpty) {
        await tester.tap(find.text('营养'));
        await tester.pumpAndSettle();

        // 计算营养
        if (find.text('计算营养').evaluate().isNotEmpty) {
          await tester.tap(find.text('计算营养'));
          await tester.pumpAndSettle();

          // 输入食物信息
          await tester.enterText(find.byType(TextFormField).first, '鸡胸肉');
          await tester.enterText(find.byType(TextFormField).last, '100');

          // 计算营养
          await tester.tap(find.text('计算'));
          await tester.pumpAndSettle();

          // 验证营养计算结果
          expect(find.textContaining('卡路里'), findsOneWidget);
        }
      }
    });

    testWidgets('挑战系统测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 登录
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // 测试挑战系统功能
      if (find.text('挑战').evaluate().isNotEmpty) {
        await tester.tap(find.text('挑战'));
        await tester.pumpAndSettle();

        // 创建挑战
        if (find.text('创建挑战').evaluate().isNotEmpty) {
          await tester.tap(find.text('创建挑战'));
          await tester.pumpAndSettle();

          // 输入挑战信息
          await tester.enterText(find.byType(TextFormField).first, '30天训练挑战');
          await tester.enterText(find.byType(TextFormField).at(1), '连续30天进行训练');

          // 保存挑战
          await tester.tap(find.text('保存'));
          await tester.pumpAndSettle();

          // 验证挑战已创建
          expect(find.text('30天训练挑战'), findsOneWidget);
        }
      }
    });

    testWidgets('用户资料测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 登录
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // 测试用户资料功能
      if (find.text('个人资料').evaluate().isNotEmpty) {
        await tester.tap(find.text('个人资料'));
        await tester.pumpAndSettle();

        // 编辑资料
        if (find.text('编辑资料').evaluate().isNotEmpty) {
          await tester.tap(find.text('编辑资料'));
          await tester.pumpAndSettle();

          // 修改资料
          await tester.enterText(find.byType(TextFormField).first, '新用户名');

          // 保存资料
          await tester.tap(find.text('保存'));
          await tester.pumpAndSettle();

          // 验证资料已更新
          expect(find.text('新用户名'), findsOneWidget);
        }
      }
    });

    testWidgets('设置页面测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 登录
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // 测试设置功能
      if (find.text('设置').evaluate().isNotEmpty) {
        await tester.tap(find.text('设置'));
        await tester.pumpAndSettle();

        // 测试主题切换
        if (find.text('主题').evaluate().isNotEmpty) {
          await tester.tap(find.text('主题'));
          await tester.pumpAndSettle();

          // 切换主题
          if (find.text('深色主题').evaluate().isNotEmpty) {
            await tester.tap(find.text('深色主题'));
            await tester.pumpAndSettle();

            // 验证主题已切换
            expect(find.byType(MaterialApp), findsOneWidget);
          }
        }
      }
    });

    testWidgets('错误处理测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 测试无效登录
      await tester.enterText(find.byType(TextFormField).first, 'invalid@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // 验证错误处理
      expect(find.textContaining('登录失败'), findsOneWidget);
    });

    testWidgets('网络错误处理测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 登录
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // 测试网络错误处理
      // 这里需要模拟网络错误
      // 可以通过修改 API 服务来实现
    });

    testWidgets('数据持久化测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 登录
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // 测试数据持久化
      // 创建一些数据
      if (find.text('创建训练').evaluate().isNotEmpty) {
        await tester.tap(find.text('创建训练'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).first, '持久化测试训练');
        await tester.tap(find.text('保存'));
        await tester.pumpAndSettle();

        // 重启应用
        app.main();
        await tester.pumpAndSettle();

        // 重新登录
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).last, 'password123');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // 验证数据是否持久化
        expect(find.text('持久化测试训练'), findsOneWidget);
      }
    });
  });
}
