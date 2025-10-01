// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingExerciseImpl _$$TrainingExerciseImplFromJson(
        Map<String, dynamic> json) =>
    _$TrainingExerciseImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$ExerciseTypeEnumMap, json['type']),
      sets: (json['sets'] as List<dynamic>)
          .map((e) => ExerciseSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      restTime: (json['restTime'] as num).toInt(),
      instructions: json['instructions'] as String,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      muscles: (json['muscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      equipment: (json['equipment'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TrainingExerciseImplToJson(
        _$TrainingExerciseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$ExerciseTypeEnumMap[instance.type]!,
      'sets': instance.sets,
      'restTime': instance.restTime,
      'instructions': instance.instructions,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
      'muscles': instance.muscles,
      'equipment': instance.equipment,
    };

const _$ExerciseTypeEnumMap = {
  ExerciseType.strength: 'strength',
  ExerciseType.cardio: 'cardio',
  ExerciseType.flexibility: 'flexibility',
  ExerciseType.balance: 'balance',
  ExerciseType.sports: 'sports',
};

_$ExerciseSetImpl _$$ExerciseSetImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseSetImpl(
      reps: (json['reps'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      restTime: (json['restTime'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$ExerciseSetImplToJson(_$ExerciseSetImpl instance) =>
    <String, dynamic>{
      'reps': instance.reps,
      'weight': instance.weight,
      'restTime': instance.restTime,
      'isCompleted': instance.isCompleted,
      'notes': instance.notes,
    };

_$TrainingHistoryImpl _$$TrainingHistoryImplFromJson(
        Map<String, dynamic> json) =>
    _$TrainingHistoryImpl(
      id: json['id'] as String,
      planId: json['planId'] as String,
      planName: json['planName'] as String,
      date: DateTime.parse(json['date'] as String),
      duration: (json['duration'] as num).toInt(),
      caloriesBurned: (json['caloriesBurned'] as num).toInt(),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => TrainingExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: $enumDecode(_$TrainingStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      extra: json['extra'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$TrainingHistoryImplToJson(
        _$TrainingHistoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planId': instance.planId,
      'planName': instance.planName,
      'date': instance.date.toIso8601String(),
      'duration': instance.duration,
      'caloriesBurned': instance.caloriesBurned,
      'exercises': instance.exercises,
      'status': _$TrainingStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'extra': instance.extra,
    };

const _$TrainingStatusEnumMap = {
  TrainingStatus.pending: 'pending',
  TrainingStatus.planned: 'planned',
  TrainingStatus.inProgress: 'in_progress',
  TrainingStatus.completed: 'completed',
  TrainingStatus.skipped: 'skipped',
};

_$CheckInImpl _$$CheckInImplFromJson(Map<String, dynamic> json) =>
    _$CheckInImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: $enumDecode(_$CheckInTypeEnumMap, json['type']),
      content: json['content'] as String,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      location: json['location'] as String?,
      extra: json['extra'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$CheckInImplToJson(_$CheckInImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'type': _$CheckInTypeEnumMap[instance.type]!,
      'content': instance.content,
      'images': instance.images,
      'location': instance.location,
      'extra': instance.extra,
    };

const _$CheckInTypeEnumMap = {
  CheckInType.workout: 'workout',
  CheckInType.nutrition: 'nutrition',
  CheckInType.mood: 'mood',
  CheckInType.weight: 'weight',
  CheckInType.measurement: 'measurement',
  CheckInType.photo: 'photo',
  CheckInType.note: 'note',
};

_$TrainingStatsImpl _$$TrainingStatsImplFromJson(Map<String, dynamic> json) =>
    _$TrainingStatsImpl(
      totalWorkouts: (json['totalWorkouts'] as num?)?.toInt() ?? 0,
      totalMinutes: (json['totalMinutes'] as num?)?.toInt() ?? 0,
      totalCaloriesBurned: (json['totalCaloriesBurned'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      maxStreak: (json['maxStreak'] as num?)?.toInt() ?? 0,
      averageWorkoutDuration:
          (json['averageWorkoutDuration'] as num?)?.toInt() ?? 0,
      workoutFrequency: (json['workoutFrequency'] as num?)?.toDouble() ?? 0.0,
      maxWeightLifted: (json['maxWeightLifted'] as num?)?.toInt() ?? 0,
      totalDistanceCovered:
          (json['totalDistanceCovered'] as num?)?.toDouble() ?? 0.0,
      weeklyWorkouts: (json['weeklyWorkouts'] as num?)?.toInt() ?? 0,
      weeklyMinutes: (json['weeklyMinutes'] as num?)?.toInt() ?? 0,
      weeklyCalories: (json['weeklyCalories'] as num?)?.toInt() ?? 0,
      monthlyWorkouts: (json['monthlyWorkouts'] as num?)?.toInt() ?? 0,
      monthlyMinutes: (json['monthlyMinutes'] as num?)?.toInt() ?? 0,
      monthlyCalories: (json['monthlyCalories'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TrainingStatsImplToJson(_$TrainingStatsImpl instance) =>
    <String, dynamic>{
      'totalWorkouts': instance.totalWorkouts,
      'totalMinutes': instance.totalMinutes,
      'totalCaloriesBurned': instance.totalCaloriesBurned,
      'currentStreak': instance.currentStreak,
      'maxStreak': instance.maxStreak,
      'averageWorkoutDuration': instance.averageWorkoutDuration,
      'workoutFrequency': instance.workoutFrequency,
      'maxWeightLifted': instance.maxWeightLifted,
      'totalDistanceCovered': instance.totalDistanceCovered,
      'weeklyWorkouts': instance.weeklyWorkouts,
      'weeklyMinutes': instance.weeklyMinutes,
      'weeklyCalories': instance.weeklyCalories,
      'monthlyWorkouts': instance.monthlyWorkouts,
      'monthlyMinutes': instance.monthlyMinutes,
      'monthlyCalories': instance.monthlyCalories,
    };

_$AITrainingPlanRequestImpl _$$AITrainingPlanRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$AITrainingPlanRequestImpl(
      goal: json['goal'] as String,
      duration: (json['duration'] as num).toInt(),
      difficulty: $enumDecode(_$TrainingDifficultyEnumMap, json['difficulty']),
      preferences: (json['preferences'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      availableEquipment: (json['availableEquipment'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      targetMuscles: (json['targetMuscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      experienceLevel: (json['experienceLevel'] as num?)?.toInt() ?? 0,
      availableTimePerDay: (json['availableTimePerDay'] as num?)?.toInt() ?? 0,
      restrictions: (json['restrictions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$AITrainingPlanRequestImplToJson(
        _$AITrainingPlanRequestImpl instance) =>
    <String, dynamic>{
      'goal': instance.goal,
      'duration': instance.duration,
      'difficulty': _$TrainingDifficultyEnumMap[instance.difficulty]!,
      'preferences': instance.preferences,
      'availableEquipment': instance.availableEquipment,
      'targetMuscles': instance.targetMuscles,
      'experienceLevel': instance.experienceLevel,
      'availableTimePerDay': instance.availableTimePerDay,
      'restrictions': instance.restrictions,
    };

const _$TrainingDifficultyEnumMap = {
  TrainingDifficulty.beginner: 'beginner',
  TrainingDifficulty.intermediate: 'intermediate',
  TrainingDifficulty.advanced: 'advanced',
};
