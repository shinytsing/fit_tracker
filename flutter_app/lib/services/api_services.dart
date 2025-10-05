import 'api_service.dart';
import '../models/models.dart';

class AuthApiService {
  final ApiService _apiService = ApiService();

  // 用户注册
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    final response = await _apiService.post('/auth/register', data: {
      'username': username,
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
    });

    final authData = AuthResponse.fromJson(response.data['data']);
    await _apiService.setToken(authData.token);
    return authData;
  }

  // 用户登录
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    final authData = AuthResponse.fromJson(response.data['data']);
    await _apiService.setToken(authData.token);
    return authData;
  }

  // 用户登出
  Future<void> logout() async {
    await _apiService.post('/auth/logout');
    await _apiService.clearToken();
  }

  // 刷新Token
  Future<AuthResponse> refreshToken() async {
    final response = await _apiService.post('/auth/refresh');
    final authData = AuthResponse.fromJson(response.data['data']);
    await _apiService.setToken(authData.token);
    return authData;
  }

  // 获取用户资料
  Future<User> getProfile() async {
    final response = await _apiService.get('/users/profile');
    return User.fromJson(response.data['data']);
  }

  // 更新用户资料
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? avatar,
  }) async {
    final response = await _apiService.put('/users/profile', data: {
      'first_name': firstName,
      'last_name': lastName,
      'bio': bio,
      'avatar': avatar,
    });

    return User.fromJson(response.data['data']);
  }

  // 获取Token
  Future<String?> getToken() async {
    return await _apiService.getToken();
  }

  // 获取用户统计
  Future<Map<String, dynamic>> getUserStats() async {
    final response = await _apiService.get('/users/stats');
    return response.data['data'];
  }
}

class WorkoutApiService {
  final ApiService _apiService = ApiService();

  // 获取训练记录
  Future<ApiResponse<List<Workout>>> getWorkouts({
    int page = 1,
    int limit = 10,
    String? type,
  }) async {
    final response = await _apiService.get('/workouts', queryParameters: {
      'page': page,
      'limit': limit,
      if (type != null) 'type': type,
    });

    final workouts = (response.data['data'] as List)
        .map((json) => Workout.fromJson(json))
        .toList();

    return ApiResponse<List<Workout>>(
      data: workouts,
      pagination: response.data['pagination'],
    );
  }

  // 创建训练记录
  Future<Workout> createWorkout({
    required String name,
    required String type,
    int? planId,
    int duration = 0,
    int calories = 0,
    String difficulty = '',
    String? notes,
    double rating = 0.0,
    List<Map<String, dynamic>>? exercises,
  }) async {
    final response = await _apiService.post('/workouts', data: {
      'name': name,
      'type': type,
      'plan_id': planId,
      'duration': duration,
      'calories': calories,
      'difficulty': difficulty,
      'notes': notes,
      'rating': rating,
      'exercises': exercises,
    });

    return Workout.fromJson(response.data['data']);
  }

  // 开始训练（健身打卡）
  Future<Workout> startWorkout({
    required int planId,
    String? notes,
  }) async {
    final response = await _apiService.post('/workouts/track', data: {
      'plan_id': planId,
      'notes': notes,
      'started_at': DateTime.now().toIso8601String(),
    });

    return Workout.fromJson(response.data['data']);
  }

  // 完成训练
  Future<Workout> completeWorkout({
    required int workoutId,
    int duration = 0,
    int calories = 0,
    double rating = 0.0,
    String? notes,
  }) async {
    final response = await _apiService.put('/workouts/$workoutId/complete', data: {
      'duration': duration,
      'calories': calories,
      'rating': rating,
      'notes': notes,
      'completed_at': DateTime.now().toIso8601String(),
    });

    return Workout.fromJson(response.data['data']);
  }

  // 获取训练计划
  Future<ApiResponse<List<TrainingPlan>>> getTrainingPlans({
    int page = 1,
    int limit = 10,
    String? difficulty,
    String? type,
  }) async {
    final response = await _apiService.get('/workouts/plans', queryParameters: {
      'page': page,
      'limit': limit,
      if (difficulty != null) 'difficulty': difficulty,
      if (type != null) 'type': type,
    });

    final plans = (response.data['data'] as List)
        .map((json) => TrainingPlan.fromJson(json))
        .toList();

    return ApiResponse<List<TrainingPlan>>(
      data: plans,
      pagination: response.data['pagination'],
    );
  }

  // 获取今日训练计划
  Future<TrainingPlan?> getTodayPlan() async {
    try {
      final response = await _apiService.get('/workouts/plans/today');
      return TrainingPlan.fromJson(response.data['data']);
    } catch (e) {
      print('获取今日训练计划失败: $e');
      return null;
    }
  }

  // 计算BMI
  Future<BMICalculation> calculateBMI({
    required double height,
    required double weight,
    required int age,
    required String gender,
  }) async {
    try {
      final response = await _apiService.post('/bmi/calculate', data: {
        'height': height,
        'weight': weight,
        'age': age,
        'gender': gender,
      });

      return BMICalculation.fromJson(response.data['data']);
    } catch (e) {
      print('BMI计算API调用失败: $e');
      rethrow;
    }
  }
}

class CommunityApiService {
  final ApiService _apiService = ApiService();

  // 获取社区动态
  Future<ApiResponse<List<Post>>> getPosts({
    int page = 1,
    int limit = 10,
    String? type,
  }) async {
    final response = await _apiService.get('/community/posts', queryParameters: {
      'page': page,
      'limit': limit,
      if (type != null) 'type': type,
    });

    final posts = (response.data['data'] as List)
        .map((json) => Post.fromJson(json))
        .toList();

    return ApiResponse<List<Post>>(
      data: posts,
      pagination: response.data['pagination'],
    );
  }

  // 发布动态
  Future<Post> createPost({
    required String content,
    List<String>? images,
    String? type,
    bool isPublic = true,
    List<String>? tags,
  }) async {
    final response = await _apiService.post('/community/posts', data: {
      'content': content,
      'images': images,
      'type': type,
      'is_public': isPublic,
      'tags': tags,
    });

    return Post.fromJson(response.data['data']);
  }

  // 点赞动态
  Future<void> likePost(int id) async {
    await _apiService.post('/community/posts/$id/like');
  }

  // 取消点赞
  Future<void> unlikePost(int id) async {
    await _apiService.delete('/community/posts/$id/like');
  }

  // 创建评论
  Future<Map<String, dynamic>> createComment(int postId, String content) async {
    final response = await _apiService.post('/community/posts/$postId/comments', data: {
      'content': content,
    });

    return response.data['data'];
  }

  // 关注用户
  Future<void> followUser(int userId) async {
    await _apiService.post('/community/follow/$userId');
  }

  // 取消关注
  Future<void> unfollowUser(int userId) async {
    await _apiService.delete('/community/follow/$userId');
  }

  // 获取挑战列表
  Future<ApiResponse<List<Challenge>>> getChallenges({
    int page = 1,
    int limit = 10,
    String? difficulty,
    String? type,
  }) async {
    final response = await _apiService.get('/community/challenges', queryParameters: {
      'page': page,
      'limit': limit,
      if (difficulty != null) 'difficulty': difficulty,
      if (type != null) 'type': type,
    });

    final challenges = (response.data['data'] as List)
        .map((json) => Challenge.fromJson(json))
        .toList();

    return ApiResponse<List<Challenge>>(
      data: challenges,
      pagination: response.data['pagination'],
    );
  }

  // 参与挑战
  Future<void> joinChallenge(int challengeId) async {
    await _apiService.post('/community/challenges/$challengeId/join');
  }

  // 获取挑战排行榜
  Future<List<Map<String, dynamic>>> getChallengeLeaderboard(int challengeId, {
    int limit = 10,
  }) async {
    final response = await _apiService.get('/community/challenges/$challengeId/leaderboard', queryParameters: {
      'limit': limit,
    });

    return List<Map<String, dynamic>>.from(response.data['data']);
  }
}

class CheckinApiService {
  final ApiService _apiService = ApiService();

  // 创建签到记录
  Future<Checkin> createCheckin({
    required String type,
    String? notes,
    String? mood,
    int energy = 5,
    int motivation = 5,
  }) async {
    final response = await _apiService.post('/checkins', data: {
      'type': type,
      'notes': notes,
      'mood': mood,
      'energy': energy,
      'motivation': motivation,
    });

    return Checkin.fromJson(response.data['data']);
  }

  // 获取签到记录
  Future<List<Checkin>> getCheckins({
    int page = 1,
    int limit = 30,
  }) async {
    final response = await _apiService.get('/checkins', queryParameters: {
      'page': page,
      'limit': limit,
    });

    return (response.data['data'] as List)
        .map((json) => Checkin.fromJson(json))
        .toList();
  }

  // 获取签到连续天数
  Future<Map<String, dynamic>> getCheckinStreak() async {
    final response = await _apiService.get('/checkins/streak');
    return response.data['data'];
  }
}

class MessageApiService {
  final ApiService _apiService = ApiService();

  // 获取消息列表
  Future<List<Map<String, dynamic>>> getMessages({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiService.get('/messages', queryParameters: {
      'page': page,
      'limit': limit,
    });

    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  // 获取通知列表
  Future<List<Map<String, dynamic>>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiService.get('/notifications', queryParameters: {
      'page': page,
      'limit': limit,
    });

    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  // 标记通知为已读
  Future<void> markNotificationAsRead(int notificationId) async {
    await _apiService.put('/notifications/$notificationId/read');
  }

  // 发送消息
  Future<Map<String, dynamic>> sendMessage({
    required int receiverId,
    required String content,
    String? type,
  }) async {
    final response = await _apiService.post('/messages', data: {
      'receiver_id': receiverId,
      'content': content,
      'type': type ?? 'text',
    });

    return response.data['data'];
  }
}

class BMIApiService {
  final ApiService _apiService = ApiService();

  // 计算BMI
  Future<BMICalculation> calculateBMI({
    required double height,
    required double weight,
    required int age,
    required String gender,
  }) async {
    final response = await _apiService.post('/bmi/calculate', data: {
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
    });

    return BMICalculation.fromJson(response.data['data']);
  }

  // 获取BMI记录
  Future<List<BMIRecord>> getBMIRecords({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiService.get('/bmi/records', queryParameters: {
      'page': page,
      'limit': limit,
    });

    return (response.data['data'] as List)
        .map((json) => BMIRecord.fromJson(json))
        .toList();
  }

  // 创建BMI记录
  Future<BMIRecord> createBMIRecord({
    required double height,
    required double weight,
    required int age,
    required String gender,
    String? notes,
  }) async {
    final response = await _apiService.post('/bmi/records', data: {
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
      'notes': notes,
    });

    return BMIRecord.fromJson(response.data['data']);
  }

  // 获取BMI统计信息
  Future<Map<String, dynamic>> getBMIStats() async {
    final response = await _apiService.get('/bmi/stats');
    return response.data['data'];
  }
}

class AIApiService {
  final ApiService _apiService = ApiService();

  // AI生成训练计划
  Future<TrainingPlan> generateAIPlan({
    required String goal,
    required String level,
    required int duration,
    required String frequency,
    List<String>? equipment,
    List<String>? focus,
    String? constraints,
  }) async {
    final response = await _apiService.post('/workout/ai/generate-plan', data: {
      'goal': goal,
      'level': level,
      'duration': duration,
      'frequency': frequency,
      'equipment': equipment,
      'focus': focus,
      'constraints': constraints,
    });

    return TrainingPlan.fromJson(response.data['data']);
  }

  // AI教练对话
  Future<String> chatWithAICoach({
    required String message,
    String? context,
  }) async {
    final response = await _apiService.post('/ai/coach/chat', data: {
      'message': message,
      'context': context,
    });

    return response.data['data']['response'];
  }
}
