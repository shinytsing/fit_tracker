// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutDataImpl _$$WorkoutDataImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutDataImpl(
      name: json['name'] as String,
      duration: (json['duration'] as num).toInt(),
      calories: (json['calories'] as num).toInt(),
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      exerciseCount: (json['exerciseCount'] as num?)?.toInt(),
      exerciseName: json['exerciseName'] as String?,
    );

Map<String, dynamic> _$$WorkoutDataImplToJson(_$WorkoutDataImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'duration': instance.duration,
      'calories': instance.calories,
      'exercises': instance.exercises,
      'exerciseCount': instance.exerciseCount,
      'exerciseName': instance.exerciseName,
    };
