// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileStateImpl _$$ProfileStateImplFromJson(Map<String, dynamic> json) =>
    _$ProfileStateImpl(
      isLoading: json['isLoading'] as bool? ?? false,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      stats: json['stats'] == null
          ? null
          : ProfileStats.fromJson(json['stats'] as Map<String, dynamic>),
      userStats: json['userStats'] == null
          ? null
          : UserStats.fromJson(json['userStats'] as Map<String, dynamic>),
      chartData: json['chartData'] == null
          ? null
          : ChartData.fromJson(json['chartData'] as Map<String, dynamic>),
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recentActivity: (json['recentActivity'] as List<dynamic>?)
              ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      settings: (json['settings'] as List<dynamic>?)
              ?.map((e) => Setting.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$ProfileStateImplToJson(_$ProfileStateImpl instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'user': instance.user,
      'stats': instance.stats,
      'userStats': instance.userStats,
      'chartData': instance.chartData,
      'achievements': instance.achievements,
      'recentActivity': instance.recentActivity,
      'settings': instance.settings,
      'error': instance.error,
    };
