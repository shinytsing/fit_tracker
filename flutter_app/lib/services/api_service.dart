import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _token;

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/api/v1', // Android模拟器访问本地服务器
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
    } catch (e) {
      print('GET请求失败: $e');
      rethrow;
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
    } catch (e) {
      print('POST请求失败: $e');
      rethrow;
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
    } catch (e) {
      print('PUT请求失败: $e');
      rethrow;
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
    } catch (e) {
      print('DELETE请求失败: $e');
      rethrow;
    }
  }

  // ==================== 训练相关API ====================

  // 获取今日训练计划
  Future<Response> getTodayPlan() async {
    return await get('/training/today-plan');
  }

  // 获取历史训练计划
  Future<Response> getHistoryPlans({int skip = 0, int limit = 20}) async {
    return await get('/training/plans', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
  }

  // 创建训练计划
  Future<Response> createPlan(Map<String, dynamic> planData) async {
    return await post('/training/plans', data: planData);
  }

  // 更新训练计划
  Future<Response> updatePlan(int planId, Map<String, dynamic> planData) async {
    return await put('/training/plans/$planId', data: planData);
  }

  // 删除训练计划
  Future<Response> deletePlan(int planId) async {
    return await delete('/training/plans/$planId');
  }

  // 生成AI训练计划
  Future<Response> generateAIPlan(Map<String, dynamic> aiRequest) async {
    return await post('/training/ai-plan', data: aiRequest);
  }

  // 开始训练
  Future<Response> startWorkout(Map<String, dynamic> workoutData) async {
    return await post('/training/start', data: workoutData);
  }

  // 结束训练
  Future<Response> endWorkout(Map<String, dynamic> workoutData) async {
    return await post('/training/end', data: workoutData);
  }

  // 完成动作
  Future<Response> completeExercise(Map<String, dynamic> exerciseData) async {
    return await post('/training/complete-exercise', data: exerciseData);
  }

  // 提交动作反馈
  Future<Response> submitFeedback(Map<String, dynamic> feedbackData) async {
    return await post('/training/feedback', data: feedbackData);
  }

  // 获取训练历史
  Future<Response> getWorkoutHistory({int skip = 0, int limit = 20}) async {
    return await get('/training/history', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
  }

  // 获取训练统计
  Future<Response> getTrainingStats() async {
    return await get('/training/stats');
  }

  // ==================== 用户相关API ====================

  // 获取用户资料
  Future<Response> getUserProfile() async {
    return await get('/users/profile/detailed');
  }

  // 更新用户资料
  Future<Response> updateUserProfile(Map<String, dynamic> profileData) async {
    return await put('/users/profile/detailed', data: profileData);
  }

  // 上传用户头像
  Future<Response> uploadUserAvatar(String imagePath) async {
    FormData formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(imagePath),
    });
    return await post('/users/profile/avatar', data: formData);
  }

  // 获取用户设置
  Future<Response> getUserSettings() async {
    return await get('/users/profile/settings');
  }

  // 更新用户设置
  Future<Response> updateUserSettings(Map<String, dynamic> settingsData) async {
    return await put('/users/profile/settings', data: settingsData);
  }

  // 修改密码
  Future<Response> changePassword(Map<String, dynamic> passwordData) async {
    return await post('/users/profile/password', data: passwordData);
  }

  // 获取用户统计
  Future<Response> getUserStats() async {
    return await get('/users/profile/stats');
  }

  // 获取用户成就
  Future<Response> getUserAchievements() async {
    return await get('/users/profile/achievements');
  }

  // 搜索用户
  Future<Response> searchUsers(Map<String, dynamic> searchData) async {
    return await post('/users/search', data: searchData);
  }

  // 关注用户
  Future<Response> followUser(Map<String, dynamic> followData) async {
    return await post('/users/profile/follow', data: followData);
  }

  // 取消关注用户
  Future<Response> unfollowUser(String userId) async {
    return await delete('/users/profile/follow/$userId');
  }

  // ==================== 搭子相关API ====================

  // 获取搭子推荐
  Future<Response> getBuddyRecommendations({int skip = 0, int limit = 10}) async {
    return await get('/buddies/recommendations', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
  }

  // 发送搭子申请
  Future<Response> requestBuddy(Map<String, dynamic> requestData) async {
    return await post('/buddies/request', data: requestData);
  }

  // 获取搭子申请列表
  Future<Response> getBuddyRequests({String type = 'received', int skip = 0, int limit = 20}) async {
    return await get('/buddies/requests', queryParameters: {
      'type': type,
      'skip': skip,
      'limit': limit,
    });
  }

  // 接受搭子申请
  Future<Response> acceptBuddyRequest(int requestId, {String? message}) async {
    return await put('/buddies/requests/$requestId/accept', data: {
      'message': message ?? '',
    });
  }

  // 拒绝搭子申请
  Future<Response> rejectBuddyRequest(int requestId, {String? reason}) async {
    return await put('/buddies/requests/$requestId/reject', data: {
      'reason': reason ?? '',
    });
  }

  // 获取我的搭子列表
  Future<Response> getMyBuddies({int skip = 0, int limit = 20}) async {
    return await get('/buddies', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
  }

  // 删除搭子关系
  Future<Response> deleteBuddy(String buddyId) async {
    return await delete('/buddies/$buddyId');
  }

  // ==================== 社区相关API ====================

  // 获取社区动态
  Future<Response> getCommunityPosts({int skip = 0, int limit = 20}) async {
    return await get('/community/posts', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
  }

  // 创建社区动态
  Future<Response> createCommunityPost(Map<String, dynamic> postData) async {
    return await post('/community/posts', data: postData);
  }

  // 获取单个动态详情
  Future<Response> getCommunityPost(int postId) async {
    return await get('/community/posts/$postId');
  }

  // 更新社区动态
  Future<Response> updateCommunityPost(int postId, Map<String, dynamic> postData) async {
    return await put('/community/posts/$postId', data: postData);
  }

  // 删除社区动态
  Future<Response> deleteCommunityPost(int postId) async {
    return await delete('/community/posts/$postId');
  }

  // 点赞动态
  Future<Response> likeCommunityPost(int postId) async {
    return await post('/community/posts/$postId/like');
  }

  // 取消点赞动态
  Future<Response> unlikeCommunityPost(int postId) async {
    return await delete('/community/posts/$postId/like');
  }

  // 评论动态
  Future<Response> commentCommunityPost(int postId, Map<String, dynamic> commentData) async {
    return await post('/community/posts/$postId/comment', data: commentData);
  }

  // 获取动态评论
  Future<Response> getCommunityComments(int postId, {int skip = 0, int limit = 20}) async {
    return await get('/community/posts/$postId/comments', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
  }

  // 获取热门动态
  Future<Response> getTrendingPosts({int skip = 0, int limit = 20}) async {
    return await get('/community/trending', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
  }

  // 获取推荐教练
  Future<Response> getRecommendedCoaches({int skip = 0, int limit = 10}) async {
    return await get('/community/coaches', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
  }

  // ==================== 消息相关API ====================

  // 获取聊天列表
  Future<Response> getChats({int skip = 0, int limit = 20}) async {
    return await get('/messages/chats', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
  }

  // 创建聊天
  Future<Response> createChat(Map<String, dynamic> chatData) async {
    return await post('/messages/chats', data: chatData);
  }

  // 获取聊天详情
  Future<Response> getChat(int chatId) async {
    return await get('/messages/chats/$chatId');
  }

  // 获取聊天消息
  Future<Response> getMessages(int chatId, {int skip = 0, int limit = 50}) async {
    return await get('/messages/chats/$chatId/messages', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
  }

  // 发送消息
  Future<Response> sendMessage(int chatId, Map<String, dynamic> messageData) async {
    return await post('/messages/chats/$chatId/messages', data: messageData);
  }

  // 标记消息为已读
  Future<Response> markMessageAsRead(int messageId) async {
    return await put('/messages/messages/$messageId/read');
  }

  // 获取通知列表
  Future<Response> getNotifications({int skip = 0, int limit = 20}) async {
    return await get('/messages/notifications', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
  }

  // 创建通知
  Future<Response> createNotification(Map<String, dynamic> notificationData) async {
    return await post('/messages/notifications', data: notificationData);
  }

  // 标记通知为已读
  Future<Response> markNotificationAsRead(int notificationId) async {
    return await put('/messages/notifications/$notificationId/read');
  }

  // 获取未读数量
  Future<Response> getUnreadCount() async {
    return await get('/messages/unread-count');
  }
}
