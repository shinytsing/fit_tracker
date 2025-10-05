import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// 认证 API 服务
class AuthApiService {
  static final Dio _dio = ApiService.instance;
  
  /// 用户注册
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '注册失败');
    }
  }
  
  /// 用户登录
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final formData = FormData.fromMap({
        'username': username,
        'password': password,
      });
      
      final response = await _dio.post('/auth/login', data: formData);
      
      // 保存 token 到本地存储
      if (response.data['access_token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response.data['access_token']);
        await prefs.setString('user_id', response.data['user']['id'].toString());
      }
      
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '登录失败');
    }
  }
  
  /// 获取当前用户信息
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取用户信息失败');
    }
  }
  
  /// 用户登出
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
    } catch (e) {
      print('Logout error: $e');
    }
  }
  
  /// 检查是否已登录
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
