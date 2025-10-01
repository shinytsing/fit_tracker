import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';

part 'profile_provider.freezed.dart';
part 'profile_provider.g.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(false) bool isLoading,
    User? user,
    ProfileStats? stats,
    UserStats? userStats,
    ChartData? chartData,
    @Default([]) List<Achievement> achievements,
    @Default([]) List<Activity> recentActivity,
    @JsonKey(includeFromJson: false, includeToJson: false) TrainingPlan? currentPlan,
    @JsonKey(includeFromJson: false, includeToJson: false) @Default([]) List<TrainingPlan> planHistory,
    @JsonKey(includeFromJson: false, includeToJson: false) NutritionPlan? nutritionPlan,
    @Default([]) List<Setting> settings,
    String? error,
  }) = _ProfileState;

  factory ProfileState.fromJson(Map<String, dynamic> json) => _$ProfileStateFromJson(json);
}

// Provider
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);









enum SettingType {
  switchSetting,
  badgeSetting,
  valueSetting,
  dangerousSetting,
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState()) {
    loadInitialData();
  }

  /// 加载初始数据
  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // 并行加载所有数据
      final results = await Future.wait([
        _loadUserProfile(),
        _loadUserStats(),
        _loadChartData(),
        _loadAchievements(),
        _loadRecentActivity(),
        _loadCurrentPlan(),
        _loadPlanHistory(),
        _loadNutritionPlan(),
        _loadSettings(),
      ]);

      state = state.copyWith(
        isLoading: false,
        user: results[0] as User?,
        userStats: results[1] as UserStats?,
        chartData: results[2] as ChartData?,
        achievements: results[3] as List<Achievement>,
        recentActivity: results[4] as List<Activity>,
        currentPlan: results[5] as TrainingPlan?,
        planHistory: results[6] as List<TrainingPlan>,
        nutritionPlan: results[7] as NutritionPlan?,
        settings: results[8] as List<Setting>,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 加载用户资料
  Future<User?> _loadUserProfile() async {
    try {
      final response = await ApiService.instance.get('/profile');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data != null ? User.fromJson(data) : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 加载用户统计
  Future<UserStats?> _loadUserStats() async {
    try {
      final response = await ApiService.instance.get('/profile/stats');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data != null ? UserStats.fromJson(data) : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 加载图表数据
  Future<ChartData?> _loadChartData() async {
    try {
      final response = await ApiService.instance.get('/profile/chart-data');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data != null ? ChartData.fromJson(data) : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 加载成就
  Future<List<Achievement>> _loadAchievements() async {
    try {
      final response = await ApiService.instance.get('/profile/achievements');
      if (response.statusCode == 200) {
        final data = response.data['data']['achievements'] as List;
        return data.map((json) => Achievement.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 加载最近活动
  Future<List<Activity>> _loadRecentActivity() async {
    try {
      final response = await ApiService.instance.get('/profile/activities');
      if (response.statusCode == 200) {
        final data = response.data['data']['activities'] as List;
        return data.map((json) => Activity.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 加载当前计划
  Future<TrainingPlan?> _loadCurrentPlan() async {
    try {
      final response = await ApiService.instance.get('/profile/current-plan');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data != null ? TrainingPlan.fromJson(data) : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 加载计划历史
  Future<List<TrainingPlan>> _loadPlanHistory() async {
    try {
      final response = await ApiService.instance.get('/profile/plan-history');
      if (response.statusCode == 200) {
        final data = response.data['data']['plans'] as List;
        return data.map((json) => TrainingPlan.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 加载营养计划
  Future<NutritionPlan?> _loadNutritionPlan() async {
    try {
      final response = await ApiService.instance.get('/profile/nutrition-plan');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data != null ? NutritionPlan.fromJson(data) : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 加载设置
  Future<List<Setting>> _loadSettings() async {
    try {
      final response = await ApiService.instance.get('/profile/settings');
      if (response.statusCode == 200) {
        final data = response.data['data']['settings'] as List;
        return data.map((json) => Setting.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 刷新资料
  Future<void> refreshProfile() async {
    await loadInitialData();
  }

  /// 更新用户资料
  Future<bool> updateProfile({
    String? nickname,
    String? bio,
    String? avatar,
    String? fitnessGoal,
    String? location,
  }) async {
    try {
      final response = await ApiService.instance.put('/profile', data: {
        if (nickname != null) 'nickname': nickname,
        if (bio != null) 'bio': bio,
        if (avatar != null) 'avatar': avatar,
        if (fitnessGoal != null) 'fitness_goal': fitnessGoal,
        if (location != null) 'location': location,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final updatedUser = User.fromJson(data);
        
        state = state.copyWith(user: updatedUser);
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
      final response = await ApiService.instance.post('/profile/achievements/$achievementId/claim');

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

  /// 更新设置
  Future<bool> updateSetting(String settingId, bool isEnabled) async {
    try {
      final response = await ApiService.instance.put('/profile/settings/$settingId', data: {
        'is_enabled': isEnabled,
      });

      if (response.statusCode == 200) {
        // 更新设置状态
        state = state.copyWith(
          settings: state.settings.map((setting) {
            if (setting.id == settingId) {
              return setting.copyWith(isEnabled: isEnabled);
            }
            return setting;
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

  /// 登出
  Future<void> logout() async {
    try {
      await ApiService.instance.post('/auth/logout');
      state = const ProfileState();
    } catch (e) {
      // 即使登出失败也清除状态
      state = const ProfileState();
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}
