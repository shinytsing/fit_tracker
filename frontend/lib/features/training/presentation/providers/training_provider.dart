import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/workout_api_service.dart';
import '../../../../core/models/models.dart';
import '../../domain/models/training_models.dart';

part 'training_provider.freezed.dart';
part 'training_provider.g.dart';

/// 训练状态
@freezed
class TrainingState with _$TrainingState {
  const factory TrainingState({
    @Default(false) bool isLoading,
    @Default(false) bool isGeneratingPlan,
    @Default(false) bool isGeneratingAi,
    @Default([]) List<TrainingPlan> plans,
    @Default([]) List<TrainingHistory> history,
    @Default([]) List<Achievement> achievements,
    @Default([]) List<CheckIn> checkIns,
    @Default(null) TrainingPlan? todayPlan,
    @Default(null) String? error,
    @Default(0) int currentStreak,
    @Default(0) int totalCaloriesBurned,
    @Default(0) int totalWorkouts,
    @Default(null) UserStats? stats,
    @Default(null) ChartData? chartData,
  }) = _TrainingState;
}

/// 训练历史模型
@freezed
class TrainingHistory with _$TrainingHistory {
  const factory TrainingHistory({
    required String id,
    required String planId,
    required String planName,
    required DateTime completedAt,
    required int duration,
    required int caloriesBurned,
    required List<TrainingExercise> exercises,
    Map<String, dynamic>? notes,
  }) = _TrainingHistory;

  factory TrainingHistory.fromJson(Map<String, dynamic> json) => _$TrainingHistoryFromJson(json);
}

/// 打卡记录模型
@freezed
class CheckIn with _$CheckIn {
  const factory CheckIn({
    required String id,
    required DateTime date,
    required DateTime checkInTime,
    required CheckInType type,
    required String content,
    @Default([]) List<String> images,
    String? location,
    Map<String, dynamic>? extra,
  }) = _CheckIn;
}

/// 训练计划类型
enum TrainingPlanType {
  ai,
  custom,
  template,
}

/// 训练难度
enum TrainingDifficulty {
  beginner,
  intermediate,
  advanced,
}

/// 训练计划状态
enum TrainingPlanStatus {
  draft,
  active,
  completed,
  paused,
  cancelled,
  planned,
  inProgress,
  skipped,
}

/// 成就类型
enum AchievementType {
  firstWorkout,
  streak7,
  streak30,
  streak100,
  totalWorkouts,
  caloriesBurned,
  weightLifted,
  distanceCovered,
  social,
  challenge,
  levelUp,
}

/// 打卡类型
enum CheckInType {
  workout,
  nutrition,
  mood,
  weight,
  measurement,
  photo,
  note,
}

/// 训练Notifier
class TrainingNotifier extends StateNotifier<TrainingState> {
  TrainingNotifier() : super(const TrainingState()) {
    loadInitialData();
  }

  /// 加载初始数据
  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // 并行加载所有数据
      final results = await Future.wait([
        _loadTodayPlan(),
        _loadTrainingHistory(),
        _loadAchievements(),
        _loadCheckIns(),
        _loadStats(),
      ]);

      state = state.copyWith(
        isLoading: false,
        todayPlan: results[0] as TrainingPlan?,
        history: results[1] as List<TrainingHistory>,
        achievements: results[2] as List<Achievement>,
        checkIns: results[3] as List<CheckIn>,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 加载今日计划
  Future<TrainingPlan?> _loadTodayPlan() async {
    try {
      final response = await ApiService.instance.get('/training/plans/today');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data != null ? TrainingPlan.fromJson(data) : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 加载训练历史
  Future<List<TrainingHistory>> _loadTrainingHistory() async {
    try {
      final response = await ApiService.instance.get('/training/plans/history');
      if (response.statusCode == 200) {
        final data = response.data['data']['history'] as List;
        return data.map((json) => TrainingHistory.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 加载成就
  Future<List<Achievement>> _loadAchievements() async {
    try {
      final response = await ApiService.instance.get('/training/achievements');
      if (response.statusCode == 200) {
        final data = response.data['data']['achievements'] as List;
        return data.map((json) => Achievement.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 加载打卡记录
  Future<List<CheckIn>> _loadCheckIns() async {
    try {
      final response = await ApiService.instance.get('/training/checkins');
      if (response.statusCode == 200) {
        final data = response.data['data']['checkins'] as List;
        return data.map((json) => CheckIn(
          id: json['id'],
          date: DateTime.parse(json['date']),
          checkInTime: DateTime.parse(json['check_in_time'] ?? json['date']),
          type: CheckInType.values.firstWhere((e) => e.name == json['type']),
          content: json['content'],
          images: List<String>.from(json['images'] ?? []),
          location: json['location'],
          extra: json['extra'],
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 加载统计数据
  Future<void> _loadStats() async {
    try {
      final response = await ApiService.instance.get('/training/stats');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        state = state.copyWith(
          currentStreak: data['current_streak'] ?? 0,
          totalCaloriesBurned: data['total_calories_burned'] ?? 0,
          totalWorkouts: data['total_workouts'] ?? 0,
        );
      }
    } catch (e) {
      // 忽略统计加载错误
    }
  }

  /// 生成AI训练计划
  Future<TrainingPlan?> generateAIPlan({
    required String goal,
    required int duration,
    required TrainingDifficulty difficulty,
    required List<String> preferences,
    required List<String> availableEquipment,
  }) async {
    state = state.copyWith(isGeneratingPlan: true, error: null);

    try {
      // 调用真实 API 生成 AI 训练计划
      final response = await WorkoutApiService.generateAIPlan(
        goal: goal,
        difficulty: difficulty.name,
        duration: duration,
        availableEquipment: availableEquipment,
        userPreferences: {'preferences': preferences},
      );
      
      // 解析响应数据
      final planData = response['plan'] ?? response;
      final aiSuggestions = response['ai_suggestions'] ?? [];
      final confidenceScore = response['confidence_score'] ?? 0.0;
      
      final plan = TrainingPlan(
        id: planData['id'].toString(),
        name: planData['name'] ?? 'AI训练计划',
        description: planData['description'] ?? '',
        type: TrainingPlanType.ai.name,
        difficulty: difficulty.name,
        duration: duration,
        status: TrainingPlanStatus.draft.name,
        exercises: (planData['exercises'] as List<dynamic>?)
            ?.map((e) => TrainingExercise.fromJson(e as Map<String, dynamic>))
            .cast<Exercise>()
            .toList() ?? [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isAi: true,
        isPublic: false,
      );

      state = state.copyWith(
        isGeneratingPlan: false,
        plans: [...state.plans, plan],
      );

      return plan;
    } catch (e) {
      state = state.copyWith(
        isGeneratingPlan: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// 开始训练
  Future<bool> startWorkout(String planId) async {
    try {
      final response = await ApiService.instance.post('/training/start', data: {
        'plan_id': planId,
      });

      if (response.statusCode == 200) {
        // 更新计划状态
        state = state.copyWith(
          plans: state.plans.map((plan) {
            if (plan.id == planId) {
              return plan.copyWith(status: TrainingPlanStatus.active.name);
            }
            return plan;
          }).toList(),
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 完成动作
  Future<bool> completeExercise(String planId, String exerciseId, int setIndex) async {
    try {
      final response = await ApiService.instance.post('/training/complete-exercise', data: {
        'plan_id': planId,
        'exercise_id': exerciseId,
        'set_index': setIndex,
      });

      if (response.statusCode == 200) {
        // 更新计划中的动作状态
        state = state.copyWith(
          plans: state.plans.map((plan) {
            if (plan.id == planId) {
              return plan.copyWith(
                exercises: plan.exercises?.map((exercise) {
                  if (exercise.id == exerciseId) {
                    return exercise.copyWith(
                      sets: exercise.sets?.asMap().entries.map((entry) {
                        if (entry.key == setIndex) {
                          return {
                            ...entry.value,
                            'isCompleted': true,
                          };
                        }
                        return entry.value;
                      }).toList(),
                    );
                  }
                  return exercise;
                }).toList(),
              );
            }
            return plan;
          }).toList(),
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 完成训练
  Future<bool> completeWorkout(String planId, {String? notes}) async {
    try {
      final response = await ApiService.instance.post('/training/complete', data: {
        'plan_id': planId,
        'notes': notes,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final history = TrainingHistory.fromJson(data);
        
        // 更新状态
        state = state.copyWith(
          history: [history, ...state.history],
          plans: state.plans.map((plan) {
            if (plan.id == planId) {
              return plan.copyWith(
                status: TrainingPlanStatus.completed.name,
                completedWorkouts: plan.completedWorkouts + 1,
              );
            }
            return plan;
          }).toList(),
        );
        
        // 重新加载统计数据
        _loadStats();
        
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 打卡签到
  Future<bool> checkIn({
    required CheckInType type,
    required String content,
    List<String>? images,
    String? location,
    Map<String, dynamic>? extra,
  }) async {
    try {
      final response = await ApiService.instance.post('/training/checkin', data: {
        'type': type.name,
        'content': content,
        'images': images,
        'location': location,
        'extra': extra,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final checkIn = CheckIn(
          id: data['id'],
          date: DateTime.parse(data['date']),
          checkInTime: DateTime.parse(data['check_in_time'] ?? data['date']),
          type: CheckInType.values.firstWhere((e) => e.name == data['type']),
          content: data['content'],
          images: List<String>.from(data['images'] ?? []),
          location: data['location'],
          extra: data['extra'],
        );
        
        state = state.copyWith(
          checkIns: [checkIn, ...state.checkIns],
        );
        
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 领取成就奖励
  Future<bool> claimAchievementReward(String achievementId) async {
    try {
      final response = await ApiService.instance.post('/training/achievements/$achievementId/claim');

      if (response.statusCode == 200) {
        // 更新成就状态
        state = state.copyWith(
          achievements: state.achievements.map((achievement) {
            if (achievement.id == achievementId) {
              return achievement.copyWith(isRewardClaimed: true);
            }
            return achievement;
          }).toList(),
        );
        
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 创建自定义训练计划
  Future<TrainingPlan?> createCustomPlan({
    required String name,
    required String description,
    required List<TrainingExercise> exercises,
    required TrainingDifficulty difficulty,
    List<String>? goals,
  }) async {
    try {
      final response = await ApiService.instance.post('/training/plans', data: {
        'name': name,
        'description': description,
        'type': 'custom',
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'difficulty': difficulty.name,
        'goals': goals,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final plan = TrainingPlan.fromJson(data);
        
        state = state.copyWith(
          plans: [...state.plans, plan],
        );
        
        return plan;
      }
      return null;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// 删除训练计划
  Future<bool> deletePlan(String planId) async {
    try {
      final response = await ApiService.instance.delete('/training/plans/$planId');

      if (response.statusCode == 200) {
        state = state.copyWith(
          plans: state.plans.where((plan) => plan.id != planId).toList(),
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 生成AI训练计划（简化版本）
  Future<void> generateAiPlan() async {
    state = state.copyWith(isGeneratingAi: true, error: null);

    try {
      // 模拟AI生成过程
      await Future.delayed(const Duration(seconds: 2));
      
      // 创建一个示例AI训练计划
      final aiPlan = TrainingPlan(
        id: 'ai_plan_${DateTime.now().millisecondsSinceEpoch}',
        name: 'AI智能训练计划',
        description: '基于您的目标自动生成的个性化训练计划',
        type: 'ai',
        difficulty: 'intermediate',
        duration: 30,
        isPublic: false,
        isAi: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'active',
        completedWorkouts: 0,
      );
      
      state = state.copyWith(
        isGeneratingAi: false,
        plans: [...state.plans, aiPlan],
        todayPlan: aiPlan,
      );
    } catch (e) {
      state = state.copyWith(
        isGeneratingAi: false,
        error: e.toString(),
      );
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider
final trainingProvider = StateNotifierProvider<TrainingNotifier, TrainingState>((ref) {
  return TrainingNotifier();
});