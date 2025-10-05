import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/api_services.dart';

// API服务提供者
final authApiServiceProvider = Provider<AuthApiService>((ref) => AuthApiService());
final workoutApiServiceProvider = Provider<WorkoutApiService>((ref) => WorkoutApiService());
final communityApiServiceProvider = Provider<CommunityApiService>((ref) => CommunityApiService());
final checkinApiServiceProvider = Provider<CheckinApiService>((ref) => CheckinApiService());
final nutritionApiServiceProvider = Provider<NutritionApiService>((ref) => NutritionApiService());

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

  AuthNotifier(this._authApiService) : super(AuthState()) {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await _authApiService.getToken();
      if (token != null) {
        final user = await _authApiService.getProfile();
        state = state.copyWith(
          user: user,
          token: token,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> login(String email, String password) async {
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
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> register({
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
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authApiService.logout();
    } catch (e) {
      // 即使登出失败也要清除本地状态
    }
    state = AuthState();
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? avatar,
  }) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedUser = await _authApiService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        bio: bio,
        avatar: avatar,
      );
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authApiServiceProvider));
});

// 训练记录状态
class WorkoutState {
  final List<Workout> workouts;
  final List<TrainingPlan> trainingPlans;
  final List<Exercise> exercises;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? pagination;

  WorkoutState({
    this.workouts = const [],
    this.trainingPlans = const [],
    this.exercises = const [],
    this.isLoading = false,
    this.error,
    this.pagination,
  });

  WorkoutState copyWith({
    List<Workout>? workouts,
    List<TrainingPlan>? trainingPlans,
    List<Exercise>? exercises,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? pagination,
  }) {
    return WorkoutState(
      workouts: workouts ?? this.workouts,
      trainingPlans: trainingPlans ?? this.trainingPlans,
      exercises: exercises ?? this.exercises,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      pagination: pagination ?? this.pagination,
    );
  }
}

class WorkoutNotifier extends StateNotifier<WorkoutState> {
  final WorkoutApiService _workoutApiService;

  WorkoutNotifier(this._workoutApiService) : super(WorkoutState());

  Future<void> loadWorkouts({int page = 1, String? type}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _workoutApiService.getWorkouts(
        page: page,
        type: type,
      );
      state = state.copyWith(
        workouts: response.data ?? [],
        pagination: response.pagination,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadTrainingPlans({int page = 1, String? difficulty, String? type}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _workoutApiService.getTrainingPlans(
        page: page,
        difficulty: difficulty,
        type: type,
      );
      state = state.copyWith(
        trainingPlans: response.data ?? [],
        pagination: response.pagination,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadExercises({int page = 1, String? category, String? difficulty}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _workoutApiService.getExercises(
        page: page,
        category: category,
        difficulty: difficulty,
      );
      state = state.copyWith(
        exercises: response.data ?? [],
        pagination: response.pagination,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> createWorkout({
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final workout = await _workoutApiService.createWorkout(
        name: name,
        type: type,
        planId: planId,
        duration: duration,
        calories: calories,
        difficulty: difficulty,
        notes: notes,
        rating: rating,
        exercises: exercises,
      );
      state = state.copyWith(
        workouts: [workout, ...state.workouts],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final workoutProvider = StateNotifierProvider<WorkoutNotifier, WorkoutState>((ref) {
  return WorkoutNotifier(ref.read(workoutApiServiceProvider));
});

// 社区状态
class CommunityState {
  final List<Post> posts;
  final List<Challenge> challenges;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? pagination;

  CommunityState({
    this.posts = const [],
    this.challenges = const [],
    this.isLoading = false,
    this.error,
    this.pagination,
  });

  CommunityState copyWith({
    List<Post>? posts,
    List<Challenge>? challenges,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? pagination,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      challenges: challenges ?? this.challenges,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      pagination: pagination ?? this.pagination,
    );
  }
}

class CommunityNotifier extends StateNotifier<CommunityState> {
  final CommunityApiService _communityApiService;

  CommunityNotifier(this._communityApiService) : super(CommunityState());

  Future<void> loadPosts({int page = 1, String? type}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _communityApiService.getPosts(
        page: page,
        type: type,
      );
      state = state.copyWith(
        posts: response.data ?? [],
        pagination: response.pagination,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadChallenges({int page = 1, String? difficulty, String? type}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _communityApiService.getChallenges(
        page: page,
        difficulty: difficulty,
        type: type,
      );
      state = state.copyWith(
        challenges: response.data ?? [],
        pagination: response.pagination,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> createPost({
    required String content,
    List<String>? images,
    String? type,
    bool isPublic = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final post = await _communityApiService.createPost(
        content: content,
        images: images,
        type: type,
        isPublic: isPublic,
      );
      state = state.copyWith(
        posts: [post, ...state.posts],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> likePost(int postId) async {
    try {
      await _communityApiService.likePost(postId);
      // 更新本地状态
      state = state.copyWith(
        posts: state.posts.map((post) {
          if (post.id == postId) {
            return Post(
              id: post.id,
              userId: post.userId,
              content: post.content,
              images: post.images,
              type: post.type,
              isPublic: post.isPublic,
              isFeatured: post.isFeatured,
              viewCount: post.viewCount,
              shareCount: post.shareCount,
              likesCount: post.likesCount + 1,
              commentsCount: post.commentsCount,
              sharesCount: post.sharesCount,
              user: post.user,
              createdAt: post.createdAt,
              updatedAt: post.updatedAt,
            );
          }
          return post;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final communityProvider = StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  return CommunityNotifier(ref.read(communityApiServiceProvider));
});

// 签到状态
class CheckinState {
  final List<Checkin> checkins;
  final Map<String, bool> calendar;
  final Map<String, dynamic> streak;
  final List<Map<String, dynamic>> achievements;
  final bool isLoading;
  final String? error;

  CheckinState({
    this.checkins = const [],
    this.calendar = const {},
    this.streak = const {},
    this.achievements = const [],
    this.isLoading = false,
    this.error,
  });

  CheckinState copyWith({
    List<Checkin>? checkins,
    Map<String, bool>? calendar,
    Map<String, dynamic>? streak,
    List<Map<String, dynamic>>? achievements,
    bool? isLoading,
    String? error,
  }) {
    return CheckinState(
      checkins: checkins ?? this.checkins,
      calendar: calendar ?? this.calendar,
      streak: streak ?? this.streak,
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CheckinNotifier extends StateNotifier<CheckinState> {
  final CheckinApiService _checkinApiService;

  CheckinNotifier(this._checkinApiService) : super(CheckinState());

  Future<void> loadCheckins({int page = 1}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final checkins = await _checkinApiService.getCheckins(page: page);
      state = state.copyWith(
        checkins: checkins,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadCalendar({int? year, int? month}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final calendar = await _checkinApiService.getCheckinCalendar(
        year: year,
        month: month,
      );
      state = state.copyWith(
        calendar: calendar,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadStreak() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final streak = await _checkinApiService.getCheckinStreak();
      state = state.copyWith(
        streak: streak,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadAchievements() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final achievements = await _checkinApiService.getAchievements();
      state = state.copyWith(
        achievements: achievements,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> createCheckin({
    required String type,
    String? notes,
    String? mood,
    int energy = 5,
    int motivation = 5,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final checkin = await _checkinApiService.createCheckin(
        type: type,
        notes: notes,
        mood: mood,
        energy: energy,
        motivation: motivation,
      );
      state = state.copyWith(
        checkins: [checkin, ...state.checkins],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final checkinProvider = StateNotifierProvider<CheckinNotifier, CheckinState>((ref) {
  return CheckinNotifier(ref.read(checkinApiServiceProvider));
});
