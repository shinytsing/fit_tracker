import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

/// 第三方认证服务
class ThirdPartyAuthService {
  static const MethodChannel _channel = MethodChannel('third_party_auth');
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// 获取设备信息
  static Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      final deviceInfo = await _deviceInfo.deviceInfo;
      return {
        'platform': deviceInfo.data['platform'],
        'model': deviceInfo.data['model'],
        'systemVersion': deviceInfo.data['systemVersion'],
        'identifierForVendor': deviceInfo.data['identifierForVendor'],
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 苹果登录
  static Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      // 检查是否支持苹果登录
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw Exception('当前设备不支持苹果登录');
      }

      // 执行苹果登录
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (credential.userIdentifier != null) {
        // 获取设备信息
        final deviceInfo = await _getDeviceInfo();
        
        print('✅ 苹果登录成功: ${credential.userIdentifier}');
        
        return {
          'success': true,
          'userId': credential.userIdentifier,
          'email': credential.email,
          'fullName': credential.givenName != null && credential.familyName != null
              ? '${credential.givenName} ${credential.familyName}'
              : null,
          'identityToken': credential.identityToken,
          'authorizationCode': credential.authorizationCode,
          'deviceInfo': deviceInfo,
          'provider': 'apple',
        };
      } else {
        throw Exception('苹果登录失败：未获取到用户信息');
      }
    } on SignInWithAppleException catch (e) {
      throw Exception('苹果登录失败: ${e.toString()}');
    } catch (e) {
      throw Exception('苹果登录失败: $e');
    }
  }

  /// 微信登录
  static Future<Map<String, dynamic>?> signInWithWeChat() async {
    try {
      // 模拟微信登录（实际项目中需要集成微信SDK）
      // 检查微信是否已安装
      // final isInstalled = await fluwx.isWeChatInstalled;
      // if (!isInstalled) {
      //   throw Exception('未安装微信应用');
      // }

      // 注册微信应用
      // await fluwx.registerWxApi(
      //   appId: 'your_wechat_app_id', // 需要替换为实际的微信AppID
      //   doOnAndroid: true,
      //   doOnIOS: true,
      // );

      // 执行微信登录
      // final result = await fluwx.sendWeChatAuth(
      //   scope: 'snsapi_userinfo',
      //   state: 'gymates_login_${DateTime.now().millisecondsSinceEpoch}',
      // );

      // 模拟微信登录结果
      final mockResult = {
        'isSuccessful': true,
        'result': 'mock_wechat_code_${DateTime.now().millisecondsSinceEpoch}',
        'errorMsg': null,
      };

      if (mockResult['isSuccessful'] == true) {
        // 获取设备信息
        final deviceInfo = await _getDeviceInfo();
        
        print('✅ 微信登录成功: ${mockResult['result']}');
        
        return {
          'success': true,
          'code': mockResult['result'],
          'deviceInfo': deviceInfo,
          'provider': 'wechat',
        };
      } else {
        print('❌ 微信登录失败: ${mockResult['errorMsg']}');
        throw Exception('微信登录失败: ${mockResult['errorMsg']}');
      }
    } catch (e) {
      throw Exception('微信登录失败: $e');
    }
  }

  /// 手机号一键登录（模拟实现）
  static Future<Map<String, dynamic>?> oneClickLogin() async {
    try {
      // 获取设备信息
      final deviceInfo = await _getDeviceInfo();
      
      // 模拟一键登录（实际项目中需要集成运营商SDK）
      // 这里返回模拟的手机号
      final mockPhoneNumber = '166****3484';
      
      print('🎯 模拟一键登录成功: $mockPhoneNumber');
      
      return {
        'success': true,
        'phoneNumber': mockPhoneNumber,
        'deviceInfo': deviceInfo,
        'provider': 'one_click',
        'message': '模拟一键登录成功',
      };
    } catch (e) {
      throw Exception('一键登录失败: $e');
    }
  }

  /// 发送短信验证码（模拟实现）
  static Future<bool> sendSMS(String phoneNumber) async {
    try {
      // 验证手机号格式
      if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phoneNumber)) {
        throw Exception('手机号格式不正确');
      }

      // 模拟发送短信验证码
      // 实际项目中需要集成短信服务商（如阿里云、腾讯云等）
      await Future.delayed(const Duration(seconds: 1));
      
      // 在开发环境中，可以打印验证码到控制台
      print('🎯 模拟短信验证码发送到 $phoneNumber: 123456');
      print('📱 开发环境验证码: 123456');
      
      return true;
    } catch (e) {
      throw Exception('发送验证码失败: $e');
    }
  }

  /// 验证短信验证码（模拟实现）
  static Future<Map<String, dynamic>?> verifySMS(
    String phoneNumber,
    String code,
  ) async {
    try {
      // 验证手机号格式
      if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phoneNumber)) {
        throw Exception('手机号格式不正确');
      }

      // 验证验证码格式
      if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
        throw Exception('验证码格式不正确');
      }

      // 模拟验证码验证（开发环境）
      if (code == '123456') {
        // 获取设备信息
        final deviceInfo = await _getDeviceInfo();
        
        print('✅ 验证码验证成功: $phoneNumber');
        
        return {
          'success': true,
          'phoneNumber': phoneNumber,
          'deviceInfo': deviceInfo,
          'provider': 'sms',
          'message': '验证码验证成功',
        };
      } else {
        print('❌ 验证码错误: $code (正确验证码: 123456)');
        throw Exception('验证码错误，开发环境请使用: 123456');
      }
    } catch (e) {
      throw Exception('验证码验证失败: $e');
    }
  }
}
