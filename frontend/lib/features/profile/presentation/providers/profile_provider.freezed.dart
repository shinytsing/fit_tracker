// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProfileState _$ProfileStateFromJson(Map<String, dynamic> json) {
  return _ProfileState.fromJson(json);
}

/// @nodoc
mixin _$ProfileState {
  bool get isLoading => throw _privateConstructorUsedError;
  User? get user => throw _privateConstructorUsedError;
  ProfileStats? get stats => throw _privateConstructorUsedError;
  UserStats? get userStats => throw _privateConstructorUsedError;
  ChartData? get chartData => throw _privateConstructorUsedError;
  List<Achievement> get achievements => throw _privateConstructorUsedError;
  List<Activity> get recentActivity => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  TrainingPlan? get currentPlan => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<TrainingPlan> get planHistory => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  NutritionPlan? get nutritionPlan => throw _privateConstructorUsedError;
  List<Setting> get settings => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProfileStateCopyWith<ProfileState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileStateCopyWith<$Res> {
  factory $ProfileStateCopyWith(
          ProfileState value, $Res Function(ProfileState) then) =
      _$ProfileStateCopyWithImpl<$Res, ProfileState>;
  @useResult
  $Res call(
      {bool isLoading,
      User? user,
      ProfileStats? stats,
      UserStats? userStats,
      ChartData? chartData,
      List<Achievement> achievements,
      List<Activity> recentActivity,
      @JsonKey(includeFromJson: false, includeToJson: false)
      TrainingPlan? currentPlan,
      @JsonKey(includeFromJson: false, includeToJson: false)
      List<TrainingPlan> planHistory,
      @JsonKey(includeFromJson: false, includeToJson: false)
      NutritionPlan? nutritionPlan,
      List<Setting> settings,
      String? error});
}

/// @nodoc
class _$ProfileStateCopyWithImpl<$Res, $Val extends ProfileState>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? user = freezed,
    Object? stats = freezed,
    Object? userStats = freezed,
    Object? chartData = freezed,
    Object? achievements = null,
    Object? recentActivity = null,
    Object? currentPlan = freezed,
    Object? planHistory = null,
    Object? nutritionPlan = freezed,
    Object? settings = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as ProfileStats?,
      userStats: freezed == userStats
          ? _value.userStats
          : userStats // ignore: cast_nullable_to_non_nullable
              as UserStats?,
      chartData: freezed == chartData
          ? _value.chartData
          : chartData // ignore: cast_nullable_to_non_nullable
              as ChartData?,
      achievements: null == achievements
          ? _value.achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<Achievement>,
      recentActivity: null == recentActivity
          ? _value.recentActivity
          : recentActivity // ignore: cast_nullable_to_non_nullable
              as List<Activity>,
      currentPlan: freezed == currentPlan
          ? _value.currentPlan
          : currentPlan // ignore: cast_nullable_to_non_nullable
              as TrainingPlan?,
      planHistory: null == planHistory
          ? _value.planHistory
          : planHistory // ignore: cast_nullable_to_non_nullable
              as List<TrainingPlan>,
      nutritionPlan: freezed == nutritionPlan
          ? _value.nutritionPlan
          : nutritionPlan // ignore: cast_nullable_to_non_nullable
              as NutritionPlan?,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as List<Setting>,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProfileStateImplCopyWith<$Res>
    implements $ProfileStateCopyWith<$Res> {
  factory _$$ProfileStateImplCopyWith(
          _$ProfileStateImpl value, $Res Function(_$ProfileStateImpl) then) =
      __$$ProfileStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      User? user,
      ProfileStats? stats,
      UserStats? userStats,
      ChartData? chartData,
      List<Achievement> achievements,
      List<Activity> recentActivity,
      @JsonKey(includeFromJson: false, includeToJson: false)
      TrainingPlan? currentPlan,
      @JsonKey(includeFromJson: false, includeToJson: false)
      List<TrainingPlan> planHistory,
      @JsonKey(includeFromJson: false, includeToJson: false)
      NutritionPlan? nutritionPlan,
      List<Setting> settings,
      String? error});
}

/// @nodoc
class __$$ProfileStateImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$ProfileStateImpl>
    implements _$$ProfileStateImplCopyWith<$Res> {
  __$$ProfileStateImplCopyWithImpl(
      _$ProfileStateImpl _value, $Res Function(_$ProfileStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? user = freezed,
    Object? stats = freezed,
    Object? userStats = freezed,
    Object? chartData = freezed,
    Object? achievements = null,
    Object? recentActivity = null,
    Object? currentPlan = freezed,
    Object? planHistory = null,
    Object? nutritionPlan = freezed,
    Object? settings = null,
    Object? error = freezed,
  }) {
    return _then(_$ProfileStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as ProfileStats?,
      userStats: freezed == userStats
          ? _value.userStats
          : userStats // ignore: cast_nullable_to_non_nullable
              as UserStats?,
      chartData: freezed == chartData
          ? _value.chartData
          : chartData // ignore: cast_nullable_to_non_nullable
              as ChartData?,
      achievements: null == achievements
          ? _value._achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<Achievement>,
      recentActivity: null == recentActivity
          ? _value._recentActivity
          : recentActivity // ignore: cast_nullable_to_non_nullable
              as List<Activity>,
      currentPlan: freezed == currentPlan
          ? _value.currentPlan
          : currentPlan // ignore: cast_nullable_to_non_nullable
              as TrainingPlan?,
      planHistory: null == planHistory
          ? _value._planHistory
          : planHistory // ignore: cast_nullable_to_non_nullable
              as List<TrainingPlan>,
      nutritionPlan: freezed == nutritionPlan
          ? _value.nutritionPlan
          : nutritionPlan // ignore: cast_nullable_to_non_nullable
              as NutritionPlan?,
      settings: null == settings
          ? _value._settings
          : settings // ignore: cast_nullable_to_non_nullable
              as List<Setting>,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileStateImpl implements _ProfileState {
  const _$ProfileStateImpl(
      {this.isLoading = false,
      this.user,
      this.stats,
      this.userStats,
      this.chartData,
      final List<Achievement> achievements = const [],
      final List<Activity> recentActivity = const [],
      @JsonKey(includeFromJson: false, includeToJson: false) this.currentPlan,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final List<TrainingPlan> planHistory = const [],
      @JsonKey(includeFromJson: false, includeToJson: false) this.nutritionPlan,
      final List<Setting> settings = const [],
      this.error})
      : _achievements = achievements,
        _recentActivity = recentActivity,
        _planHistory = planHistory,
        _settings = settings;

  factory _$ProfileStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileStateImplFromJson(json);

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final User? user;
  @override
  final ProfileStats? stats;
  @override
  final UserStats? userStats;
  @override
  final ChartData? chartData;
  final List<Achievement> _achievements;
  @override
  @JsonKey()
  List<Achievement> get achievements {
    if (_achievements is EqualUnmodifiableListView) return _achievements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_achievements);
  }

  final List<Activity> _recentActivity;
  @override
  @JsonKey()
  List<Activity> get recentActivity {
    if (_recentActivity is EqualUnmodifiableListView) return _recentActivity;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentActivity);
  }

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final TrainingPlan? currentPlan;
  final List<TrainingPlan> _planHistory;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<TrainingPlan> get planHistory {
    if (_planHistory is EqualUnmodifiableListView) return _planHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_planHistory);
  }

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final NutritionPlan? nutritionPlan;
  final List<Setting> _settings;
  @override
  @JsonKey()
  List<Setting> get settings {
    if (_settings is EqualUnmodifiableListView) return _settings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_settings);
  }

  @override
  final String? error;

  @override
  String toString() {
    return 'ProfileState(isLoading: $isLoading, user: $user, stats: $stats, userStats: $userStats, chartData: $chartData, achievements: $achievements, recentActivity: $recentActivity, currentPlan: $currentPlan, planHistory: $planHistory, nutritionPlan: $nutritionPlan, settings: $settings, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.userStats, userStats) ||
                other.userStats == userStats) &&
            (identical(other.chartData, chartData) ||
                other.chartData == chartData) &&
            const DeepCollectionEquality()
                .equals(other._achievements, _achievements) &&
            const DeepCollectionEquality()
                .equals(other._recentActivity, _recentActivity) &&
            (identical(other.currentPlan, currentPlan) ||
                other.currentPlan == currentPlan) &&
            const DeepCollectionEquality()
                .equals(other._planHistory, _planHistory) &&
            (identical(other.nutritionPlan, nutritionPlan) ||
                other.nutritionPlan == nutritionPlan) &&
            const DeepCollectionEquality().equals(other._settings, _settings) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      user,
      stats,
      userStats,
      chartData,
      const DeepCollectionEquality().hash(_achievements),
      const DeepCollectionEquality().hash(_recentActivity),
      currentPlan,
      const DeepCollectionEquality().hash(_planHistory),
      nutritionPlan,
      const DeepCollectionEquality().hash(_settings),
      error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileStateImplCopyWith<_$ProfileStateImpl> get copyWith =>
      __$$ProfileStateImplCopyWithImpl<_$ProfileStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileStateImplToJson(
      this,
    );
  }
}

abstract class _ProfileState implements ProfileState {
  const factory _ProfileState(
      {final bool isLoading,
      final User? user,
      final ProfileStats? stats,
      final UserStats? userStats,
      final ChartData? chartData,
      final List<Achievement> achievements,
      final List<Activity> recentActivity,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final TrainingPlan? currentPlan,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final List<TrainingPlan> planHistory,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final NutritionPlan? nutritionPlan,
      final List<Setting> settings,
      final String? error}) = _$ProfileStateImpl;

  factory _ProfileState.fromJson(Map<String, dynamic> json) =
      _$ProfileStateImpl.fromJson;

  @override
  bool get isLoading;
  @override
  User? get user;
  @override
  ProfileStats? get stats;
  @override
  UserStats? get userStats;
  @override
  ChartData? get chartData;
  @override
  List<Achievement> get achievements;
  @override
  List<Activity> get recentActivity;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  TrainingPlan? get currentPlan;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<TrainingPlan> get planHistory;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  NutritionPlan? get nutritionPlan;
  @override
  List<Setting> get settings;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$ProfileStateImplCopyWith<_$ProfileStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
