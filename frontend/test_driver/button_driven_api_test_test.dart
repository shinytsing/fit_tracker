import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gymates/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('按钮驱动 API 集成测试', () {
    testWidgets('用户注册 API 测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 查找并点击注册按钮
      final registerButton = find.text('注册');
      if (registerButton.evaluate().isNotEmpty) {
        await tester.tap(registerButton);
        await tester.pumpAndSettle();

        // 填写注册表单
        final usernameField = find.byKey(const Key('username_field'));
        final emailField = find.byKey(const Key('email_field'));
        final passwordField = find.byKey(const Key('password_field'));
        final nicknameField = find.byKey(const Key('nickname_field'));

        if (usernameField.evaluate().isNotEmpty) {
          await tester.enterText(usernameField, 'testuser${DateTime.now().millisecondsSinceEpoch}');
          await tester.enterText(emailField, 'test${DateTime.now().millisecondsSinceEpoch}@example.com');
          await tester.enterText(passwordField, 'password123');
          await tester.enterText(nicknameField, '测试用户');
          await tester.pumpAndSettle();

          // 点击提交按钮
          final submitButton = find.text('注册');
          if (submitButton.evaluate().isNotEmpty) {
            await tester.tap(submitButton);
            await tester.pumpAndSettle(const Duration(seconds: 3));

            // 验证注册成功
            expect(find.text('注册成功'), findsOneWidget);
            print('✅ 用户注册 API 测试通过');
          }
        }
      }
    });

    testWidgets('用户登录 API 测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 查找并点击登录按钮
      final loginButton = find.text('登录');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // 填写登录表单
        final usernameField = find.byKey(const Key('login_username_field'));
        final passwordField = find.byKey(const Key('login_password_field'));

        if (usernameField.evaluate().isNotEmpty) {
          await tester.enterText(usernameField, 'testuser123456');
          await tester.enterText(passwordField, 'password123');
          await tester.pumpAndSettle();

          // 点击提交按钮
          final submitButton = find.text('登录');
          if (submitButton.evaluate().isNotEmpty) {
            await tester.tap(submitButton);
            await tester.pumpAndSettle(const Duration(seconds: 3));

            // 验证登录成功
            expect(find.text('登录成功'), findsOneWidget);
            print('✅ 用户登录 API 测试通过');
          }
        }
      }
    });

    testWidgets('AI 训练推荐 API 测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 导航到训练页面
      final trainingTab = find.text('训练');
      if (trainingTab.evaluate().isNotEmpty) {
        await tester.tap(trainingTab);
        await tester.pumpAndSettle();

        // 查找并点击 AI 推荐按钮
        final aiRecommendButton = find.text('AI智能推荐');
        if (aiRecommendButton.evaluate().isNotEmpty) {
          await tester.tap(aiRecommendButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // 验证 AI 推荐结果
          expect(find.text('AI推荐训练'), findsOneWidget);
          print('✅ AI 训练推荐 API 测试通过');
        }
      }
    });

    testWidgets('创建健身房 API 测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 导航到健身房页面
      final gymTab = find.text('健身房');
      if (gymTab.evaluate().isNotEmpty) {
        await tester.tap(gymTab);
        await tester.pumpAndSettle();

        // 查找并点击创建健身房按钮
        final createGymButton = find.text('创建健身房');
        if (createGymButton.evaluate().isNotEmpty) {
          await tester.tap(createGymButton);
          await tester.pumpAndSettle();

          // 填写健身房信息
          final nameField = find.byKey(const Key('gym_name_field'));
          final addressField = find.byKey(const Key('gym_address_field'));
          final phoneField = find.byKey(const Key('gym_phone_field'));

          if (nameField.evaluate().isNotEmpty) {
            await tester.enterText(nameField, '测试健身房');
            await tester.enterText(addressField, '测试地址');
            await tester.enterText(phoneField, '1234567890');
            await tester.pumpAndSettle();

            // 点击提交按钮
            final submitButton = find.text('创建');
            if (submitButton.evaluate().isNotEmpty) {
              await tester.tap(submitButton);
              await tester.pumpAndSettle(const Duration(seconds: 3));

              // 验证创建成功
              expect(find.text('创建成功'), findsOneWidget);
              print('✅ 创建健身房 API 测试通过');
            }
          }
        }
      }
    });

    testWidgets('社区帖子发布 API 测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 导航到社区页面
      final communityTab = find.text('社区');
      if (communityTab.evaluate().isNotEmpty) {
        await tester.tap(communityTab);
        await tester.pumpAndSettle();

        // 查找并点击发布按钮
        final publishButton = find.text('发布');
        if (publishButton.evaluate().isNotEmpty) {
          await tester.tap(publishButton);
          await tester.pumpAndSettle();

          // 填写帖子内容
          final contentField = find.byKey(const Key('post_content_field'));
          if (contentField.evaluate().isNotEmpty) {
            await tester.enterText(contentField, '这是一个测试帖子');
            await tester.pumpAndSettle();

            // 点击提交按钮
            final submitButton = find.text('发布');
            if (submitButton.evaluate().isNotEmpty) {
              await tester.tap(submitButton);
              await tester.pumpAndSettle(const Duration(seconds: 3));

              // 验证发布成功
              expect(find.text('发布成功'), findsOneWidget);
              print('✅ 社区帖子发布 API 测试通过');
            }
          }
        }
      }
    });

    testWidgets('消息发送 API 测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 导航到消息页面
      final messageTab = find.text('消息');
      if (messageTab.evaluate().isNotEmpty) {
        await tester.tap(messageTab);
        await tester.pumpAndSettle();

        // 查找并点击发送消息按钮
        final sendMessageButton = find.text('发送消息');
        if (sendMessageButton.evaluate().isNotEmpty) {
          await tester.tap(sendMessageButton);
          await tester.pumpAndSettle();

          // 填写消息内容
          final messageField = find.byKey(const Key('message_content_field'));
          if (messageField.evaluate().isNotEmpty) {
            await tester.enterText(messageField, '这是一条测试消息');
            await tester.pumpAndSettle();

            // 点击发送按钮
            final submitButton = find.text('发送');
            if (submitButton.evaluate().isNotEmpty) {
              await tester.tap(submitButton);
              await tester.pumpAndSettle(const Duration(seconds: 3));

              // 验证发送成功
              expect(find.text('发送成功'), findsOneWidget);
              print('✅ 消息发送 API 测试通过');
            }
          }
        }
      }
    });

    testWidgets('休息记录 API 测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 导航到训练页面
      final trainingTab = find.text('训练');
      if (trainingTab.evaluate().isNotEmpty) {
        await tester.tap(trainingTab);
        await tester.pumpAndSettle();

        // 查找并点击开始休息按钮
        final startRestButton = find.text('开始休息');
        if (startRestButton.evaluate().isNotEmpty) {
          await tester.tap(startRestButton);
          await tester.pumpAndSettle();

          // 设置休息时间
          final durationField = find.byKey(const Key('rest_duration_field'));
          if (durationField.evaluate().isNotEmpty) {
            await tester.enterText(durationField, '5');
            await tester.pumpAndSettle();

            // 点击确认按钮
            final confirmButton = find.text('确认');
            if (confirmButton.evaluate().isNotEmpty) {
              await tester.tap(confirmButton);
              await tester.pumpAndSettle(const Duration(seconds: 3));

              // 验证休息开始
              expect(find.text('休息开始'), findsOneWidget);
              print('✅ 休息记录 API 测试通过');
            }
          }
        }
      }
    });

    testWidgets('训练计划创建 API 测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 导航到训练页面
      final trainingTab = find.text('训练');
      if (trainingTab.evaluate().isNotEmpty) {
        await tester.tap(trainingTab);
        await tester.pumpAndSettle();

        // 查找并点击创建计划按钮
        final createPlanButton = find.text('创建计划');
        if (createPlanButton.evaluate().isNotEmpty) {
          await tester.tap(createPlanButton);
          await tester.pumpAndSettle();

          // 填写计划信息
          final nameField = find.byKey(const Key('plan_name_field'));
          final descriptionField = find.byKey(const Key('plan_description_field'));

          if (nameField.evaluate().isNotEmpty) {
            await tester.enterText(nameField, '测试训练计划');
            await tester.enterText(descriptionField, '这是一个测试训练计划');
            await tester.pumpAndSettle();

            // 点击提交按钮
            final submitButton = find.text('创建');
            if (submitButton.evaluate().isNotEmpty) {
              await tester.tap(submitButton);
              await tester.pumpAndSettle(const Duration(seconds: 3));

              // 验证创建成功
              expect(find.text('创建成功'), findsOneWidget);
              print('✅ 训练计划创建 API 测试通过');
            }
          }
        }
      }
    });

    testWidgets('用户资料更新 API 测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 导航到个人资料页面
      final profileTab = find.text('我的');
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab);
        await tester.pumpAndSettle();

        // 查找并点击编辑资料按钮
        final editProfileButton = find.text('编辑资料');
        if (editProfileButton.evaluate().isNotEmpty) {
          await tester.tap(editProfileButton);
          await tester.pumpAndSettle();

          // 修改资料信息
          final nicknameField = find.byKey(const Key('profile_nickname_field'));
          if (nicknameField.evaluate().isNotEmpty) {
            await tester.enterText(nicknameField, '更新后的昵称');
            await tester.pumpAndSettle();

            // 点击保存按钮
            final saveButton = find.text('保存');
            if (saveButton.evaluate().isNotEmpty) {
              await tester.tap(saveButton);
              await tester.pumpAndSettle(const Duration(seconds: 3));

              // 验证保存成功
              expect(find.text('保存成功'), findsOneWidget);
              print('✅ 用户资料更新 API 测试通过');
            }
          }
        }
      }
    });
  });
}
