import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _token;

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8080/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token过期，清除本地存储
          await _clearToken();
        }
        handler.next(error);
      },
    ));
  }

  // 设置Token
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // 获取Token
  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  // 清除Token
  Future<void> _clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // 清除Token（公开方法）
  Future<void> clearToken() async {
    await _clearToken();
  }

  // GET请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      // 记录错误日志
      print('API GET Error: ${e.message}');
      rethrow; // 重新抛出，让调用方处理
    }
  }

  // POST请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      // 记录错误日志
      print('API POST Error: ${e.message}');
      rethrow; // 重新抛出，让调用方处理
    }
  }

  // PUT请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 用户注册
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    String? phone,
    required String password,
    required String nickname,
  }) async {
    final response = await post('/users/register', data: {
      'username': username,
      'email': email,
      if (phone != null) 'phone': phone,
      'password': password,
      'nickname': nickname,
    });
    
    return response.data as Map<String, dynamic>;
  }

  // 用户登录
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await post('/users/login', data: {
      'username': username,
      'password': password,
    });
    
    return response.data as Map<String, dynamic>;
  }

  // 获取用户资料
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await get('/users/profile');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      // 如果获取资料失败，返回null
      return null;
    }
  }

  // 创建用户个人资料
  Future<Map<String, dynamic>> createUserProfile({
    required double height,
    required double weight,
    required int exerciseYears,
    required String fitnessGoal,
  }) async {
    final response = await post('/users/profile/data', data: {
      'height': height,
      'weight': weight,
      'exercise_years': exerciseYears,
      'fitness_goal': fitnessGoal,
    });
    return response.data as Map<String, dynamic>;
  }

  // 获取用户个人资料
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await get('/users/profile/data');
    return response.data as Map<String, dynamic>;
  }

  // 更新用户个人资料
  Future<Map<String, dynamic>> updateUserProfile({
    double? height,
    double? weight,
    int? exerciseYears,
    String? fitnessGoal,
  }) async {
    final data = <String, dynamic>{};
    if (height != null) data['height'] = height;
    if (weight != null) data['weight'] = weight;
    if (exerciseYears != null) data['exercise_years'] = exerciseYears;
    if (fitnessGoal != null) data['fitness_goal'] = fitnessGoal;

    final response = await put('/users/profile/data', data: data);
    return response.data as Map<String, dynamic>;
  }

  // 检查用户个人资料是否存在
  Future<Map<String, dynamic>> checkUserProfileExists() async {
    final response = await get('/users/profile/data/exists');
    return response.data as Map<String, dynamic>;
  }

  // 获取训练计划列表
  Future<Map<String, dynamic>> getTrainingPlans() async {
    final response = await get('/training/plans');
    return response.data as Map<String, dynamic>;
  }

  // 获取搭子团队列表
  Future<Map<String, dynamic>> getTeams() async {
    final response = await get('/teams');
    return response.data as Map<String, dynamic>;
  }

  // 创建搭子团队
  Future<Map<String, dynamic>> createTeam({
    required String name,
    required String description,
    required int maxMembers,
    required String location,
    required List<String> tags,
    bool isPublic = true,
  }) async {
    final response = await post('/teams', data: {
      'name': name,
      'description': description,
      'max_members': maxMembers,
      'location': location,
      'tags': tags,
      'is_public': isPublic,
    });
    return response.data as Map<String, dynamic>;
  }

  // 获取聊天列表
  Future<Map<String, dynamic>> getChats() async {
    final response = await get('/messages/chats');
    return response.data as Map<String, dynamic>;
  }

  // 创建聊天
  Future<Map<String, dynamic>> createChat({
    required String userId,
    required String message,
  }) async {
    final response = await post('/messages/chats', data: {
      'user_id': userId,
      'message': message,
    });
    return response.data as Map<String, dynamic>;
  }

  // 发送消息
  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String content,
    String? type,
    String? thumbnailUrl,
  }) async {
    final response = await post('/messages/chats/$chatId/messages', data: {
      'content': content,
      if (type != null) 'type': type,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
    });
    return response.data as Map<String, dynamic>;
  }

  // 获取通知
  Future<Map<String, dynamic>> getNotifications() async {
    final response = await get('/messages/notifications');
    return response.data as Map<String, dynamic>;
  }

  // 处理错误
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('网络连接超时，请检查网络设置');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['error'] ?? '服务器错误';
        return Exception('请求失败 ($statusCode): $message');
      case DioExceptionType.cancel:
        return Exception('请求已取消');
      case DioExceptionType.connectionError:
        return Exception('网络连接失败，请检查网络设置');
      default:
        return Exception('未知错误: ${error.message}');
    }
  }
}

// Provider for dependency injection
final apiServiceProvider = Provider<ApiService>((ref) {
  final apiService = ApiService();
  apiService.init();
  return apiService;
});
