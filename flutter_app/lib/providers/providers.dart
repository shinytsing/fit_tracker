import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/api_services.dart';

// API服务提供者
final authApiServiceProvider = Provider<AuthApiService>((ref) => AuthApiService());
final workoutApiServiceProvider = Provider<WorkoutApiService>((ref) => WorkoutApiService());
final communityApiServiceProvider = Provider<CommunityApiService>((ref) => CommunityApiService());
final checkinApiServiceProvider = Provider<CheckinApiService>((ref) => CheckinApiService());
final messageApiServiceProvider = Provider<MessageApiService>((ref) => MessageApiService());
final bmiApiServiceProvider = Provider<BMIApiService>((ref) => BMIApiService());
final aiApiServiceProvider = Provider<AIApiService>((ref) => AIApiService());

// 认证状态
class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isAuthenticated => user != null && token != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApiService _authApiService;

  AuthNotifier(this._authApiService) : super(AuthState());

  // 登录
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authResponse = await _authApiService.login(
        email: email,
        password: password,
      );
      state = state.copyWith(
        user: authResponse.user,
        token: authResponse.token,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 注册
  Future<void> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authResponse = await _authApiService.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      state = state.copyWith(
        user: authResponse.user,
        token: authResponse.token,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 登出
  Future<void> logout() async {
    try {
      await _authApiService.logout();
      state = AuthState();
    } catch (e) {
      // 即使登出失败，也清除本地状态
      state = AuthState();
    }
  }

  // 获取用户资料
  Future<void> loadProfile() async {
    if (!state.isAuthenticated) return;
    
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authApiService.getProfile();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authApiServiceProvider));
});

// 训练状态
class WorkoutState {
  final List<Workout> workouts;
  final List<TrainingPlan> plans;
  final TrainingPlan? todayPlan;
  final bool isLoading;
  final String? error;

  WorkoutState({
    this.workouts = const [],
    this.plans = const [],
    this.todayPlan,
    this.isLoading = false,
    this.error,
  });

  WorkoutState copyWith({
    List<Workout>? workouts,
    List<TrainingPlan>? plans,
    TrainingPlan? todayPlan,
    bool? isLoading,
    String? error,
  }) {
    return WorkoutState(
      workouts: workouts ?? this.workouts,
      plans: plans ?? this.plans,
      todayPlan: todayPlan ?? this.todayPlan,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class WorkoutNotifier extends StateNotifier<WorkoutState> {
  final WorkoutApiService _workoutApiService;

  WorkoutNotifier(this._workoutApiService) : super(WorkoutState());

  // 加载训练记录
  Future<void> loadWorkouts({String? type}) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _workoutApiService.getWorkouts(type: type);
      state = state.copyWith(
        workouts: response.data,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 加载训练计划
  Future<void> loadTrainingPlans({String? difficulty, String? type}) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _workoutApiService.getTrainingPlans(
        difficulty: difficulty,
        type: type,
      );
      state = state.copyWith(
        plans: response.data,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 加载今日训练计划
  Future<void> loadTodayPlan() async {
    try {
      final todayPlan = await _workoutApiService.getTodayPlan();
      state = state.copyWith(todayPlan: todayPlan);
    } catch (e) {
      print('加载今日训练计划失败: $e');
    }
  }

  // 开始训练
  Future<void> startWorkout(int planId, {String? notes}) async {
    try {
      await _workoutApiService.startWorkout(planId: planId, notes: notes);
      // 重新加载训练记录
      await loadWorkouts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 完成训练
  Future<void> completeWorkout({
    required int workoutId,
    int duration = 0,
    int calories = 0,
    double rating = 0.0,
    String? notes,
  }) async {
    try {
      await _workoutApiService.completeWorkout(
        workoutId: workoutId,
        duration: duration,
        calories: calories,
        rating: rating,
        notes: notes,
      );
      // 重新加载训练记录
      await loadWorkouts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final workoutProvider = StateNotifierProvider<WorkoutNotifier, WorkoutState>((ref) {
  return WorkoutNotifier(ref.read(workoutApiServiceProvider));
});

// 社区状态
class CommunityState {
  final List<Post> posts;
  final List<Challenge> challenges;
  final String activeTab;
  final bool isLoading;
  final String? error;

  CommunityState({
    this.posts = const [],
    this.challenges = const [],
    this.activeTab = 'following',
    this.isLoading = false,
    this.error,
  });

  CommunityState copyWith({
    List<Post>? posts,
    List<Challenge>? challenges,
    String? activeTab,
    bool? isLoading,
    String? error,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      challenges: challenges ?? this.challenges,
      activeTab: activeTab ?? this.activeTab,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CommunityNotifier extends StateNotifier<CommunityState> {
  final CommunityApiService _communityApiService;

  CommunityNotifier(this._communityApiService) : super(CommunityState());

  // 切换标签页
  void setActiveTab(String tab) {
    state = state.copyWith(activeTab: tab);
    loadPosts(type: tab);
  }

  // 加载动态
  Future<void> loadPosts({String? type}) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _communityApiService.getPosts(type: type);
      state = state.copyWith(
        posts: response.data,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 加载挑战
  Future<void> loadChallenges() async {
    try {
      final response = await _communityApiService.getChallenges();
      state = state.copyWith(challenges: response.data);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 点赞动态
  Future<void> likePost(int postId) async {
    try {
      await _communityApiService.likePost(postId);
      // 更新本地状态
      final updatedPosts = state.posts.map((post) {
        if (post.id == postId) {
          return Post(
            id: post.id,
            user: post.user,
            content: post.content,
            images: post.images,
            type: post.type,
            isPublic: post.isPublic,
            likesCount: post.likesCount + 1,
            commentsCount: post.commentsCount,
            isLiked: true,
            createdAt: post.createdAt,
            tags: post.tags,
          );
        }
        return post;
      }).toList();
      state = state.copyWith(posts: updatedPosts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 取消点赞
  Future<void> unlikePost(int postId) async {
    try {
      await _communityApiService.unlikePost(postId);
      // 更新本地状态
      final updatedPosts = state.posts.map((post) {
        if (post.id == postId) {
          return Post(
            id: post.id,
            user: post.user,
            content: post.content,
            images: post.images,
            type: post.type,
            isPublic: post.isPublic,
            likesCount: post.likesCount - 1,
            commentsCount: post.commentsCount,
            isLiked: false,
            createdAt: post.createdAt,
            tags: post.tags,
          );
        }
        return post;
      }).toList();
      state = state.copyWith(posts: updatedPosts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 发布动态
  Future<void> createPost({
    required String content,
    List<String>? images,
    String? type,
    List<String>? tags,
  }) async {
    try {
      await _communityApiService.createPost(
        content: content,
        images: images,
        type: type,
        tags: tags,
      );
      // 重新加载动态
      await loadPosts(type: state.activeTab);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 参与挑战
  Future<void> joinChallenge(int challengeId) async {
    try {
      await _communityApiService.joinChallenge(challengeId);
      // 更新本地状态
      final updatedChallenges = state.challenges.map((challenge) {
        if (challenge.id == challengeId) {
          return Challenge(
            id: challenge.id,
            name: challenge.name,
            description: challenge.description,
            difficulty: challenge.difficulty,
            type: challenge.type,
            duration: challenge.duration,
            participantsCount: challenge.participantsCount + 1,
            isJoined: true,
            startDate: challenge.startDate,
            endDate: challenge.endDate,
          );
        }
        return challenge;
      }).toList();
      state = state.copyWith(challenges: updatedChallenges);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final communityProvider = StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  return CommunityNotifier(ref.read(communityApiServiceProvider));
});

// 消息状态
class MessageState {
  final List<Map<String, dynamic>> messages;
  final List<Map<String, dynamic>> notifications;
  final bool isLoading;
  final String? error;

  MessageState({
    this.messages = const [],
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  MessageState copyWith({
    List<Map<String, dynamic>>? messages,
    List<Map<String, dynamic>>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return MessageState(
      messages: messages ?? this.messages,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MessageNotifier extends StateNotifier<MessageState> {
  final MessageApiService _messageApiService;

  MessageNotifier(this._messageApiService) : super(MessageState());

  // 加载消息
  Future<void> loadMessages() async {
    state = state.copyWith(isLoading: true);
    try {
      final messages = await _messageApiService.getMessages();
      state = state.copyWith(
        messages: messages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 加载通知
  Future<void> loadNotifications() async {
    try {
      final notifications = await _messageApiService.getNotifications();
      state = state.copyWith(notifications: notifications);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 标记通知为已读
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _messageApiService.markNotificationAsRead(notificationId);
      // 更新本地状态
      final updatedNotifications = state.notifications.map((notification) {
        if (notification['id'] == notificationId) {
          return {...notification, 'is_read': true};
        }
        return notification;
      }).toList();
      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final messageProvider = StateNotifierProvider<MessageNotifier, MessageState>((ref) {
  return MessageNotifier(ref.read(messageApiServiceProvider));
});

// BMI状态
class BMIState {
  final BMICalculation? currentBMI;
  final List<BMIRecord> records;
  final Map<String, dynamic>? stats;
  final bool isLoading;
  final String? error;

  BMIState({
    this.currentBMI,
    this.records = const [],
    this.stats,
    this.isLoading = false,
    this.error,
  });

  BMIState copyWith({
    BMICalculation? currentBMI,
    List<BMIRecord>? records,
    Map<String, dynamic>? stats,
    bool? isLoading,
    String? error,
  }) {
    return BMIState(
      currentBMI: currentBMI ?? this.currentBMI,
      records: records ?? this.records,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class BMINotifier extends StateNotifier<BMIState> {
  final BMIApiService _bmiApiService;

  BMINotifier(this._bmiApiService) : super(BMIState());

  // 计算BMI
  Future<void> calculateBMI({
    required double height,
    required double weight,
    required int age,
    required String gender,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final calculation = await _bmiApiService.calculateBMI(
        height: height,
        weight: weight,
        age: age,
        gender: gender,
      );
      state = state.copyWith(
        currentBMI: calculation,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 保存BMI记录
  Future<void> saveBMIRecord({
    required double height,
    required double weight,
    required int age,
    required String gender,
    String? notes,
  }) async {
    try {
      await _bmiApiService.createBMIRecord(
        height: height,
        weight: weight,
        age: age,
        gender: gender,
        notes: notes,
      );
      // 重新加载记录
      await loadBMIRecords();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 加载BMI记录
  Future<void> loadBMIRecords() async {
    state = state.copyWith(isLoading: true);
    try {
      final records = await _bmiApiService.getBMIRecords();
      state = state.copyWith(
        records: records,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 加载BMI统计
  Future<void> loadBMIStats() async {
    try {
      final stats = await _bmiApiService.getBMIStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final bmiProvider = StateNotifierProvider<BMINotifier, BMIState>((ref) {
  return BMINotifier(ref.read(bmiApiServiceProvider));
});
