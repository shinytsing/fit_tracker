// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TrainingState {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isGeneratingPlan => throw _privateConstructorUsedError;
  bool get isGeneratingAi => throw _privateConstructorUsedError;
  List<TrainingPlan> get plans => throw _privateConstructorUsedError;
  List<TrainingHistory> get history => throw _privateConstructorUsedError;
  List<Achievement> get achievements => throw _privateConstructorUsedError;
  List<CheckIn> get checkIns => throw _privateConstructorUsedError;
  TrainingPlan? get todayPlan => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  int get totalCaloriesBurned => throw _privateConstructorUsedError;
  int get totalWorkouts => throw _privateConstructorUsedError;
  UserStats? get stats => throw _privateConstructorUsedError;
  ChartData? get chartData => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TrainingStateCopyWith<TrainingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingStateCopyWith<$Res> {
  factory $TrainingStateCopyWith(
          TrainingState value, $Res Function(TrainingState) then) =
      _$TrainingStateCopyWithImpl<$Res, TrainingState>;
  @useResult
  $Res call(
      {bool isLoading,
      bool isGeneratingPlan,
      bool isGeneratingAi,
      List<TrainingPlan> plans,
      List<TrainingHistory> history,
      List<Achievement> achievements,
      List<CheckIn> checkIns,
      TrainingPlan? todayPlan,
      String? error,
      int currentStreak,
      int totalCaloriesBurned,
      int totalWorkouts,
      UserStats? stats,
      ChartData? chartData});
}

/// @nodoc
class _$TrainingStateCopyWithImpl<$Res, $Val extends TrainingState>
    implements $TrainingStateCopyWith<$Res> {
  _$TrainingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isGeneratingPlan = null,
    Object? isGeneratingAi = null,
    Object? plans = null,
    Object? history = null,
    Object? achievements = null,
    Object? checkIns = null,
    Object? todayPlan = freezed,
    Object? error = freezed,
    Object? currentStreak = null,
    Object? totalCaloriesBurned = null,
    Object? totalWorkouts = null,
    Object? stats = freezed,
    Object? chartData = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isGeneratingPlan: null == isGeneratingPlan
          ? _value.isGeneratingPlan
          : isGeneratingPlan // ignore: cast_nullable_to_non_nullable
              as bool,
      isGeneratingAi: null == isGeneratingAi
          ? _value.isGeneratingAi
          : isGeneratingAi // ignore: cast_nullable_to_non_nullable
              as bool,
      plans: null == plans
          ? _value.plans
          : plans // ignore: cast_nullable_to_non_nullable
              as List<TrainingPlan>,
      history: null == history
          ? _value.history
          : history // ignore: cast_nullable_to_non_nullable
              as List<TrainingHistory>,
      achievements: null == achievements
          ? _value.achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<Achievement>,
      checkIns: null == checkIns
          ? _value.checkIns
          : checkIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      todayPlan: freezed == todayPlan
          ? _value.todayPlan
          : todayPlan // ignore: cast_nullable_to_non_nullable
              as TrainingPlan?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalCaloriesBurned: null == totalCaloriesBurned
          ? _value.totalCaloriesBurned
          : totalCaloriesBurned // ignore: cast_nullable_to_non_nullable
              as int,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as UserStats?,
      chartData: freezed == chartData
          ? _value.chartData
          : chartData // ignore: cast_nullable_to_non_nullable
              as ChartData?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrainingStateImplCopyWith<$Res>
    implements $TrainingStateCopyWith<$Res> {
  factory _$$TrainingStateImplCopyWith(
          _$TrainingStateImpl value, $Res Function(_$TrainingStateImpl) then) =
      __$$TrainingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isGeneratingPlan,
      bool isGeneratingAi,
      List<TrainingPlan> plans,
      List<TrainingHistory> history,
      List<Achievement> achievements,
      List<CheckIn> checkIns,
      TrainingPlan? todayPlan,
      String? error,
      int currentStreak,
      int totalCaloriesBurned,
      int totalWorkouts,
      UserStats? stats,
      ChartData? chartData});
}

/// @nodoc
class __$$TrainingStateImplCopyWithImpl<$Res>
    extends _$TrainingStateCopyWithImpl<$Res, _$TrainingStateImpl>
    implements _$$TrainingStateImplCopyWith<$Res> {
  __$$TrainingStateImplCopyWithImpl(
      _$TrainingStateImpl _value, $Res Function(_$TrainingStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isGeneratingPlan = null,
    Object? isGeneratingAi = null,
    Object? plans = null,
    Object? history = null,
    Object? achievements = null,
    Object? checkIns = null,
    Object? todayPlan = freezed,
    Object? error = freezed,
    Object? currentStreak = null,
    Object? totalCaloriesBurned = null,
    Object? totalWorkouts = null,
    Object? stats = freezed,
    Object? chartData = freezed,
  }) {
    return _then(_$TrainingStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isGeneratingPlan: null == isGeneratingPlan
          ? _value.isGeneratingPlan
          : isGeneratingPlan // ignore: cast_nullable_to_non_nullable
              as bool,
      isGeneratingAi: null == isGeneratingAi
          ? _value.isGeneratingAi
          : isGeneratingAi // ignore: cast_nullable_to_non_nullable
              as bool,
      plans: null == plans
          ? _value._plans
          : plans // ignore: cast_nullable_to_non_nullable
              as List<TrainingPlan>,
      history: null == history
          ? _value._history
          : history // ignore: cast_nullable_to_non_nullable
              as List<TrainingHistory>,
      achievements: null == achievements
          ? _value._achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<Achievement>,
      checkIns: null == checkIns
          ? _value._checkIns
          : checkIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      todayPlan: freezed == todayPlan
          ? _value.todayPlan
          : todayPlan // ignore: cast_nullable_to_non_nullable
              as TrainingPlan?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalCaloriesBurned: null == totalCaloriesBurned
          ? _value.totalCaloriesBurned
          : totalCaloriesBurned // ignore: cast_nullable_to_non_nullable
              as int,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as UserStats?,
      chartData: freezed == chartData
          ? _value.chartData
          : chartData // ignore: cast_nullable_to_non_nullable
              as ChartData?,
    ));
  }
}

/// @nodoc

class _$TrainingStateImpl implements _TrainingState {
  const _$TrainingStateImpl(
      {this.isLoading = false,
      this.isGeneratingPlan = false,
      this.isGeneratingAi = false,
      final List<TrainingPlan> plans = const [],
      final List<TrainingHistory> history = const [],
      final List<Achievement> achievements = const [],
      final List<CheckIn> checkIns = const [],
      this.todayPlan = null,
      this.error = null,
      this.currentStreak = 0,
      this.totalCaloriesBurned = 0,
      this.totalWorkouts = 0,
      this.stats = null,
      this.chartData = null})
      : _plans = plans,
        _history = history,
        _achievements = achievements,
        _checkIns = checkIns;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isGeneratingPlan;
  @override
  @JsonKey()
  final bool isGeneratingAi;
  final List<TrainingPlan> _plans;
  @override
  @JsonKey()
  List<TrainingPlan> get plans {
    if (_plans is EqualUnmodifiableListView) return _plans;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_plans);
  }

  final List<TrainingHistory> _history;
  @override
  @JsonKey()
  List<TrainingHistory> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  final List<Achievement> _achievements;
  @override
  @JsonKey()
  List<Achievement> get achievements {
    if (_achievements is EqualUnmodifiableListView) return _achievements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_achievements);
  }

  final List<CheckIn> _checkIns;
  @override
  @JsonKey()
  List<CheckIn> get checkIns {
    if (_checkIns is EqualUnmodifiableListView) return _checkIns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_checkIns);
  }

  @override
  @JsonKey()
  final TrainingPlan? todayPlan;
  @override
  @JsonKey()
  final String? error;
  @override
  @JsonKey()
  final int currentStreak;
  @override
  @JsonKey()
  final int totalCaloriesBurned;
  @override
  @JsonKey()
  final int totalWorkouts;
  @override
  @JsonKey()
  final UserStats? stats;
  @override
  @JsonKey()
  final ChartData? chartData;

  @override
  String toString() {
    return 'TrainingState(isLoading: $isLoading, isGeneratingPlan: $isGeneratingPlan, isGeneratingAi: $isGeneratingAi, plans: $plans, history: $history, achievements: $achievements, checkIns: $checkIns, todayPlan: $todayPlan, error: $error, currentStreak: $currentStreak, totalCaloriesBurned: $totalCaloriesBurned, totalWorkouts: $totalWorkouts, stats: $stats, chartData: $chartData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isGeneratingPlan, isGeneratingPlan) ||
                other.isGeneratingPlan == isGeneratingPlan) &&
            (identical(other.isGeneratingAi, isGeneratingAi) ||
                other.isGeneratingAi == isGeneratingAi) &&
            const DeepCollectionEquality().equals(other._plans, _plans) &&
            const DeepCollectionEquality().equals(other._history, _history) &&
            const DeepCollectionEquality()
                .equals(other._achievements, _achievements) &&
            const DeepCollectionEquality().equals(other._checkIns, _checkIns) &&
            (identical(other.todayPlan, todayPlan) ||
                other.todayPlan == todayPlan) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.totalCaloriesBurned, totalCaloriesBurned) ||
                other.totalCaloriesBurned == totalCaloriesBurned) &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.chartData, chartData) ||
                other.chartData == chartData));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      isGeneratingPlan,
      isGeneratingAi,
      const DeepCollectionEquality().hash(_plans),
      const DeepCollectionEquality().hash(_history),
      const DeepCollectionEquality().hash(_achievements),
      const DeepCollectionEquality().hash(_checkIns),
      todayPlan,
      error,
      currentStreak,
      totalCaloriesBurned,
      totalWorkouts,
      stats,
      chartData);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingStateImplCopyWith<_$TrainingStateImpl> get copyWith =>
      __$$TrainingStateImplCopyWithImpl<_$TrainingStateImpl>(this, _$identity);
}

abstract class _TrainingState implements TrainingState {
  const factory _TrainingState(
      {final bool isLoading,
      final bool isGeneratingPlan,
      final bool isGeneratingAi,
      final List<TrainingPlan> plans,
      final List<TrainingHistory> history,
      final List<Achievement> achievements,
      final List<CheckIn> checkIns,
      final TrainingPlan? todayPlan,
      final String? error,
      final int currentStreak,
      final int totalCaloriesBurned,
      final int totalWorkouts,
      final UserStats? stats,
      final ChartData? chartData}) = _$TrainingStateImpl;

  @override
  bool get isLoading;
  @override
  bool get isGeneratingPlan;
  @override
  bool get isGeneratingAi;
  @override
  List<TrainingPlan> get plans;
  @override
  List<TrainingHistory> get history;
  @override
  List<Achievement> get achievements;
  @override
  List<CheckIn> get checkIns;
  @override
  TrainingPlan? get todayPlan;
  @override
  String? get error;
  @override
  int get currentStreak;
  @override
  int get totalCaloriesBurned;
  @override
  int get totalWorkouts;
  @override
  UserStats? get stats;
  @override
  ChartData? get chartData;
  @override
  @JsonKey(ignore: true)
  _$$TrainingStateImplCopyWith<_$TrainingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrainingHistory _$TrainingHistoryFromJson(Map<String, dynamic> json) {
  return _TrainingHistory.fromJson(json);
}

/// @nodoc
mixin _$TrainingHistory {
  String get id => throw _privateConstructorUsedError;
  String get planId => throw _privateConstructorUsedError;
  String get planName => throw _privateConstructorUsedError;
  DateTime get completedAt => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  int get caloriesBurned => throw _privateConstructorUsedError;
  List<TrainingExercise> get exercises => throw _privateConstructorUsedError;
  Map<String, dynamic>? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrainingHistoryCopyWith<TrainingHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingHistoryCopyWith<$Res> {
  factory $TrainingHistoryCopyWith(
          TrainingHistory value, $Res Function(TrainingHistory) then) =
      _$TrainingHistoryCopyWithImpl<$Res, TrainingHistory>;
  @useResult
  $Res call(
      {String id,
      String planId,
      String planName,
      DateTime completedAt,
      int duration,
      int caloriesBurned,
      List<TrainingExercise> exercises,
      Map<String, dynamic>? notes});
}

/// @nodoc
class _$TrainingHistoryCopyWithImpl<$Res, $Val extends TrainingHistory>
    implements $TrainingHistoryCopyWith<$Res> {
  _$TrainingHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? planId = null,
    Object? planName = null,
    Object? completedAt = null,
    Object? duration = null,
    Object? caloriesBurned = null,
    Object? exercises = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      planName: null == planName
          ? _value.planName
          : planName // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      caloriesBurned: null == caloriesBurned
          ? _value.caloriesBurned
          : caloriesBurned // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<TrainingExercise>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrainingHistoryImplCopyWith<$Res>
    implements $TrainingHistoryCopyWith<$Res> {
  factory _$$TrainingHistoryImplCopyWith(_$TrainingHistoryImpl value,
          $Res Function(_$TrainingHistoryImpl) then) =
      __$$TrainingHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String planId,
      String planName,
      DateTime completedAt,
      int duration,
      int caloriesBurned,
      List<TrainingExercise> exercises,
      Map<String, dynamic>? notes});
}

/// @nodoc
class __$$TrainingHistoryImplCopyWithImpl<$Res>
    extends _$TrainingHistoryCopyWithImpl<$Res, _$TrainingHistoryImpl>
    implements _$$TrainingHistoryImplCopyWith<$Res> {
  __$$TrainingHistoryImplCopyWithImpl(
      _$TrainingHistoryImpl _value, $Res Function(_$TrainingHistoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? planId = null,
    Object? planName = null,
    Object? completedAt = null,
    Object? duration = null,
    Object? caloriesBurned = null,
    Object? exercises = null,
    Object? notes = freezed,
  }) {
    return _then(_$TrainingHistoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      planName: null == planName
          ? _value.planName
          : planName // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      caloriesBurned: null == caloriesBurned
          ? _value.caloriesBurned
          : caloriesBurned // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<TrainingExercise>,
      notes: freezed == notes
          ? _value._notes
          : notes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainingHistoryImpl implements _TrainingHistory {
  const _$TrainingHistoryImpl(
      {required this.id,
      required this.planId,
      required this.planName,
      required this.completedAt,
      required this.duration,
      required this.caloriesBurned,
      required final List<TrainingExercise> exercises,
      final Map<String, dynamic>? notes})
      : _exercises = exercises,
        _notes = notes;

  factory _$TrainingHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingHistoryImplFromJson(json);

  @override
  final String id;
  @override
  final String planId;
  @override
  final String planName;
  @override
  final DateTime completedAt;
  @override
  final int duration;
  @override
  final int caloriesBurned;
  final List<TrainingExercise> _exercises;
  @override
  List<TrainingExercise> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  final Map<String, dynamic>? _notes;
  @override
  Map<String, dynamic>? get notes {
    final value = _notes;
    if (value == null) return null;
    if (_notes is EqualUnmodifiableMapView) return _notes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'TrainingHistory(id: $id, planId: $planId, planName: $planName, completedAt: $completedAt, duration: $duration, caloriesBurned: $caloriesBurned, exercises: $exercises, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingHistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.planName, planName) ||
                other.planName == planName) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.caloriesBurned, caloriesBurned) ||
                other.caloriesBurned == caloriesBurned) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises) &&
            const DeepCollectionEquality().equals(other._notes, _notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      planId,
      planName,
      completedAt,
      duration,
      caloriesBurned,
      const DeepCollectionEquality().hash(_exercises),
      const DeepCollectionEquality().hash(_notes));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingHistoryImplCopyWith<_$TrainingHistoryImpl> get copyWith =>
      __$$TrainingHistoryImplCopyWithImpl<_$TrainingHistoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingHistoryImplToJson(
      this,
    );
  }
}

abstract class _TrainingHistory implements TrainingHistory {
  const factory _TrainingHistory(
      {required final String id,
      required final String planId,
      required final String planName,
      required final DateTime completedAt,
      required final int duration,
      required final int caloriesBurned,
      required final List<TrainingExercise> exercises,
      final Map<String, dynamic>? notes}) = _$TrainingHistoryImpl;

  factory _TrainingHistory.fromJson(Map<String, dynamic> json) =
      _$TrainingHistoryImpl.fromJson;

  @override
  String get id;
  @override
  String get planId;
  @override
  String get planName;
  @override
  DateTime get completedAt;
  @override
  int get duration;
  @override
  int get caloriesBurned;
  @override
  List<TrainingExercise> get exercises;
  @override
  Map<String, dynamic>? get notes;
  @override
  @JsonKey(ignore: true)
  _$$TrainingHistoryImplCopyWith<_$TrainingHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CheckIn {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  DateTime get checkInTime => throw _privateConstructorUsedError;
  CheckInType get type => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  Map<String, dynamic>? get extra => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CheckInCopyWith<CheckIn> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckInCopyWith<$Res> {
  factory $CheckInCopyWith(CheckIn value, $Res Function(CheckIn) then) =
      _$CheckInCopyWithImpl<$Res, CheckIn>;
  @useResult
  $Res call(
      {String id,
      DateTime date,
      DateTime checkInTime,
      CheckInType type,
      String content,
      List<String> images,
      String? location,
      Map<String, dynamic>? extra});
}

/// @nodoc
class _$CheckInCopyWithImpl<$Res, $Val extends CheckIn>
    implements $CheckInCopyWith<$Res> {
  _$CheckInCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? checkInTime = null,
    Object? type = null,
    Object? content = null,
    Object? images = null,
    Object? location = freezed,
    Object? extra = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      checkInTime: null == checkInTime
          ? _value.checkInTime
          : checkInTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CheckInType,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      extra: freezed == extra
          ? _value.extra
          : extra // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheckInImplCopyWith<$Res> implements $CheckInCopyWith<$Res> {
  factory _$$CheckInImplCopyWith(
          _$CheckInImpl value, $Res Function(_$CheckInImpl) then) =
      __$$CheckInImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime date,
      DateTime checkInTime,
      CheckInType type,
      String content,
      List<String> images,
      String? location,
      Map<String, dynamic>? extra});
}

/// @nodoc
class __$$CheckInImplCopyWithImpl<$Res>
    extends _$CheckInCopyWithImpl<$Res, _$CheckInImpl>
    implements _$$CheckInImplCopyWith<$Res> {
  __$$CheckInImplCopyWithImpl(
      _$CheckInImpl _value, $Res Function(_$CheckInImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? checkInTime = null,
    Object? type = null,
    Object? content = null,
    Object? images = null,
    Object? location = freezed,
    Object? extra = freezed,
  }) {
    return _then(_$CheckInImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      checkInTime: null == checkInTime
          ? _value.checkInTime
          : checkInTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CheckInType,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      extra: freezed == extra
          ? _value._extra
          : extra // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$CheckInImpl implements _CheckIn {
  const _$CheckInImpl(
      {required this.id,
      required this.date,
      required this.checkInTime,
      required this.type,
      required this.content,
      final List<String> images = const [],
      this.location,
      final Map<String, dynamic>? extra})
      : _images = images,
        _extra = extra;

  @override
  final String id;
  @override
  final DateTime date;
  @override
  final DateTime checkInTime;
  @override
  final CheckInType type;
  @override
  final String content;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final String? location;
  final Map<String, dynamic>? _extra;
  @override
  Map<String, dynamic>? get extra {
    final value = _extra;
    if (value == null) return null;
    if (_extra is EqualUnmodifiableMapView) return _extra;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'CheckIn(id: $id, date: $date, checkInTime: $checkInTime, type: $type, content: $content, images: $images, location: $location, extra: $extra)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckInImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.checkInTime, checkInTime) ||
                other.checkInTime == checkInTime) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other._extra, _extra));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      date,
      checkInTime,
      type,
      content,
      const DeepCollectionEquality().hash(_images),
      location,
      const DeepCollectionEquality().hash(_extra));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckInImplCopyWith<_$CheckInImpl> get copyWith =>
      __$$CheckInImplCopyWithImpl<_$CheckInImpl>(this, _$identity);
}

abstract class _CheckIn implements CheckIn {
  const factory _CheckIn(
      {required final String id,
      required final DateTime date,
      required final DateTime checkInTime,
      required final CheckInType type,
      required final String content,
      final List<String> images,
      final String? location,
      final Map<String, dynamic>? extra}) = _$CheckInImpl;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  DateTime get checkInTime;
  @override
  CheckInType get type;
  @override
  String get content;
  @override
  List<String> get images;
  @override
  String? get location;
  @override
  Map<String, dynamic>? get extra;
  @override
  @JsonKey(ignore: true)
  _$$CheckInImplCopyWith<_$CheckInImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
