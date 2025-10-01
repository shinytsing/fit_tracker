import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_models.freezed.dart';
part 'training_models.g.dart';

/// 训练计划模型
/// 训练动作模型
@freezed
class TrainingExercise with _$TrainingExercise {
  const factory TrainingExercise({
    required String id,
    required String name,
    required String description,
    required ExerciseType type,
    required List<ExerciseSet> sets,
    required int restTime,
    required String instructions,
    String? imageUrl,
    String? videoUrl,
    @Default([]) List<String> muscles,
    @Default([]) List<String> equipment,
  }) = _TrainingExercise;

  factory TrainingExercise.fromJson(Map<String, dynamic> json) => _$TrainingExerciseFromJson(json);
}

/// 动作组模型
@freezed
class ExerciseSet with _$ExerciseSet {
  const factory ExerciseSet({
    required int reps,
    required double weight,
    required int restTime,
    @Default(false) bool isCompleted,
    String? notes,
  }) = _ExerciseSet;

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => _$ExerciseSetFromJson(json);
}

/// 训练历史模型
@freezed
class TrainingHistory with _$TrainingHistory {
  const factory TrainingHistory({
    required String id,
    required String planId,
    required String planName,
    required DateTime date,
    required int duration,
    required int caloriesBurned,
    required List<TrainingExercise> exercises,
    required TrainingStatus status,
    String? notes,
    Map<String, dynamic>? extra,
  }) = _TrainingHistory;

  factory TrainingHistory.fromJson(Map<String, dynamic> json) => _$TrainingHistoryFromJson(json);
}

/// 成就模型
/// 打卡记录模型
@freezed
class CheckIn with _$CheckIn {
  const factory CheckIn({
    required String id,
    required DateTime date,
    required CheckInType type,
    required String content,
    @Default([]) List<String> images,
    String? location,
    Map<String, dynamic>? extra,
  }) = _CheckIn;

  factory CheckIn.fromJson(Map<String, dynamic> json) => _$CheckInFromJson(json);
}

/// 训练统计模型
@freezed
class TrainingStats with _$TrainingStats {
  const factory TrainingStats({
    @Default(0) int totalWorkouts,
    @Default(0) int totalMinutes,
    @Default(0) int totalCaloriesBurned,
    @Default(0) int currentStreak,
    @Default(0) int maxStreak,
    @Default(0) int averageWorkoutDuration,
    @Default(0.0) double workoutFrequency,
    @Default(0) int maxWeightLifted,
    @Default(0.0) double totalDistanceCovered,
    @Default(0) int weeklyWorkouts,
    @Default(0) int weeklyMinutes,
    @Default(0) int weeklyCalories,
    @Default(0) int monthlyWorkouts,
    @Default(0) int monthlyMinutes,
    @Default(0) int monthlyCalories,
  }) = _TrainingStats;

  factory TrainingStats.fromJson(Map<String, dynamic> json) => _$TrainingStatsFromJson(json);
}

/// AI训练计划请求模型
@freezed
class AITrainingPlanRequest with _$AITrainingPlanRequest {
  const factory AITrainingPlanRequest({
    required String goal,
    required int duration,
    required TrainingDifficulty difficulty,
    @Default([]) List<String> preferences,
    @Default([]) List<String> availableEquipment,
    @Default([]) List<String> targetMuscles,
    @Default(0) int experienceLevel,
    @Default(0) int availableTimePerDay,
    @Default([]) List<String> restrictions,
  }) = _AITrainingPlanRequest;

  factory AITrainingPlanRequest.fromJson(Map<String, dynamic> json) => _$AITrainingPlanRequestFromJson(json);
}

/// 训练计划类型
enum TrainingPlanType {
  @JsonValue('ai')
  ai,
  @JsonValue('custom')
  custom,
  @JsonValue('template')
  template,
}

/// 训练难度
enum TrainingDifficulty {
  @JsonValue('beginner')
  beginner,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
}

/// 训练计划状态
enum TrainingPlanStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('active')
  active,
  @JsonValue('completed')
  completed,
  @JsonValue('paused')
  paused,
  @JsonValue('cancelled')
  cancelled,
}

/// 动作类型
enum ExerciseType {
  @JsonValue('strength')
  strength,
  @JsonValue('cardio')
  cardio,
  @JsonValue('flexibility')
  flexibility,
  @JsonValue('balance')
  balance,
  @JsonValue('sports')
  sports,
}

/// 训练状态
enum TrainingStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('planned')
  planned,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('skipped')
  skipped,
}

/// 成就类型
enum AchievementType {
  @JsonValue('first_workout')
  firstWorkout,
  @JsonValue('streak_7')
  streak7,
  @JsonValue('streak_30')
  streak30,
  @JsonValue('streak_100')
  streak100,
  @JsonValue('total_workouts')
  totalWorkouts,
  @JsonValue('calories_burned')
  caloriesBurned,
  @JsonValue('weight_lifted')
  weightLifted,
  @JsonValue('distance_covered')
  distanceCovered,
  @JsonValue('social')
  social,
  @JsonValue('challenge')
  challenge,
  @JsonValue('level_up')
  levelUp,
}

/// 打卡类型
enum CheckInType {
  @JsonValue('workout')
  workout,
  @JsonValue('nutrition')
  nutrition,
  @JsonValue('mood')
  mood,
  @JsonValue('weight')
  weight,
  @JsonValue('measurement')
  measurement,
  @JsonValue('photo')
  photo,
  @JsonValue('note')
  note,
}
