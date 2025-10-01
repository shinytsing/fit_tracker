// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingHistoryImpl _$$TrainingHistoryImplFromJson(
        Map<String, dynamic> json) =>
    _$TrainingHistoryImpl(
      id: json['id'] as String,
      planId: json['planId'] as String,
      planName: json['planName'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      duration: (json['duration'] as num).toInt(),
      caloriesBurned: (json['caloriesBurned'] as num).toInt(),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => TrainingExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$TrainingHistoryImplToJson(
        _$TrainingHistoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planId': instance.planId,
      'planName': instance.planName,
      'completedAt': instance.completedAt.toIso8601String(),
      'duration': instance.duration,
      'caloriesBurned': instance.caloriesBurned,
      'exercises': instance.exercises,
      'notes': instance.notes,
    };
