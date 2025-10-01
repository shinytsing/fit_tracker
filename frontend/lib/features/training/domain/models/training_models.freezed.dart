// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrainingExercise _$TrainingExerciseFromJson(Map<String, dynamic> json) {
  return _TrainingExercise.fromJson(json);
}

/// @nodoc
mixin _$TrainingExercise {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  ExerciseType get type => throw _privateConstructorUsedError;
  List<ExerciseSet> get sets => throw _privateConstructorUsedError;
  int get restTime => throw _privateConstructorUsedError;
  String get instructions => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get videoUrl => throw _privateConstructorUsedError;
  List<String> get muscles => throw _privateConstructorUsedError;
  List<String> get equipment => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrainingExerciseCopyWith<TrainingExercise> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingExerciseCopyWith<$Res> {
  factory $TrainingExerciseCopyWith(
          TrainingExercise value, $Res Function(TrainingExercise) then) =
      _$TrainingExerciseCopyWithImpl<$Res, TrainingExercise>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      ExerciseType type,
      List<ExerciseSet> sets,
      int restTime,
      String instructions,
      String? imageUrl,
      String? videoUrl,
      List<String> muscles,
      List<String> equipment});
}

/// @nodoc
class _$TrainingExerciseCopyWithImpl<$Res, $Val extends TrainingExercise>
    implements $TrainingExerciseCopyWith<$Res> {
  _$TrainingExerciseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? sets = null,
    Object? restTime = null,
    Object? instructions = null,
    Object? imageUrl = freezed,
    Object? videoUrl = freezed,
    Object? muscles = null,
    Object? equipment = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ExerciseType,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<ExerciseSet>,
      restTime: null == restTime
          ? _value.restTime
          : restTime // ignore: cast_nullable_to_non_nullable
              as int,
      instructions: null == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      muscles: null == muscles
          ? _value.muscles
          : muscles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      equipment: null == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrainingExerciseImplCopyWith<$Res>
    implements $TrainingExerciseCopyWith<$Res> {
  factory _$$TrainingExerciseImplCopyWith(_$TrainingExerciseImpl value,
          $Res Function(_$TrainingExerciseImpl) then) =
      __$$TrainingExerciseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      ExerciseType type,
      List<ExerciseSet> sets,
      int restTime,
      String instructions,
      String? imageUrl,
      String? videoUrl,
      List<String> muscles,
      List<String> equipment});
}

/// @nodoc
class __$$TrainingExerciseImplCopyWithImpl<$Res>
    extends _$TrainingExerciseCopyWithImpl<$Res, _$TrainingExerciseImpl>
    implements _$$TrainingExerciseImplCopyWith<$Res> {
  __$$TrainingExerciseImplCopyWithImpl(_$TrainingExerciseImpl _value,
      $Res Function(_$TrainingExerciseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? sets = null,
    Object? restTime = null,
    Object? instructions = null,
    Object? imageUrl = freezed,
    Object? videoUrl = freezed,
    Object? muscles = null,
    Object? equipment = null,
  }) {
    return _then(_$TrainingExerciseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ExerciseType,
      sets: null == sets
          ? _value._sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<ExerciseSet>,
      restTime: null == restTime
          ? _value.restTime
          : restTime // ignore: cast_nullable_to_non_nullable
              as int,
      instructions: null == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      muscles: null == muscles
          ? _value._muscles
          : muscles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      equipment: null == equipment
          ? _value._equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainingExerciseImpl implements _TrainingExercise {
  const _$TrainingExerciseImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.type,
      required final List<ExerciseSet> sets,
      required this.restTime,
      required this.instructions,
      this.imageUrl,
      this.videoUrl,
      final List<String> muscles = const [],
      final List<String> equipment = const []})
      : _sets = sets,
        _muscles = muscles,
        _equipment = equipment;

  factory _$TrainingExerciseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingExerciseImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final ExerciseType type;
  final List<ExerciseSet> _sets;
  @override
  List<ExerciseSet> get sets {
    if (_sets is EqualUnmodifiableListView) return _sets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sets);
  }

  @override
  final int restTime;
  @override
  final String instructions;
  @override
  final String? imageUrl;
  @override
  final String? videoUrl;
  final List<String> _muscles;
  @override
  @JsonKey()
  List<String> get muscles {
    if (_muscles is EqualUnmodifiableListView) return _muscles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_muscles);
  }

  final List<String> _equipment;
  @override
  @JsonKey()
  List<String> get equipment {
    if (_equipment is EqualUnmodifiableListView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipment);
  }

  @override
  String toString() {
    return 'TrainingExercise(id: $id, name: $name, description: $description, type: $type, sets: $sets, restTime: $restTime, instructions: $instructions, imageUrl: $imageUrl, videoUrl: $videoUrl, muscles: $muscles, equipment: $equipment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingExerciseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._sets, _sets) &&
            (identical(other.restTime, restTime) ||
                other.restTime == restTime) &&
            (identical(other.instructions, instructions) ||
                other.instructions == instructions) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            const DeepCollectionEquality().equals(other._muscles, _muscles) &&
            const DeepCollectionEquality()
                .equals(other._equipment, _equipment));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      type,
      const DeepCollectionEquality().hash(_sets),
      restTime,
      instructions,
      imageUrl,
      videoUrl,
      const DeepCollectionEquality().hash(_muscles),
      const DeepCollectionEquality().hash(_equipment));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingExerciseImplCopyWith<_$TrainingExerciseImpl> get copyWith =>
      __$$TrainingExerciseImplCopyWithImpl<_$TrainingExerciseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingExerciseImplToJson(
      this,
    );
  }
}

abstract class _TrainingExercise implements TrainingExercise {
  const factory _TrainingExercise(
      {required final String id,
      required final String name,
      required final String description,
      required final ExerciseType type,
      required final List<ExerciseSet> sets,
      required final int restTime,
      required final String instructions,
      final String? imageUrl,
      final String? videoUrl,
      final List<String> muscles,
      final List<String> equipment}) = _$TrainingExerciseImpl;

  factory _TrainingExercise.fromJson(Map<String, dynamic> json) =
      _$TrainingExerciseImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  ExerciseType get type;
  @override
  List<ExerciseSet> get sets;
  @override
  int get restTime;
  @override
  String get instructions;
  @override
  String? get imageUrl;
  @override
  String? get videoUrl;
  @override
  List<String> get muscles;
  @override
  List<String> get equipment;
  @override
  @JsonKey(ignore: true)
  _$$TrainingExerciseImplCopyWith<_$TrainingExerciseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExerciseSet _$ExerciseSetFromJson(Map<String, dynamic> json) {
  return _ExerciseSet.fromJson(json);
}

/// @nodoc
mixin _$ExerciseSet {
  int get reps => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  int get restTime => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseSetCopyWith<ExerciseSet> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseSetCopyWith<$Res> {
  factory $ExerciseSetCopyWith(
          ExerciseSet value, $Res Function(ExerciseSet) then) =
      _$ExerciseSetCopyWithImpl<$Res, ExerciseSet>;
  @useResult
  $Res call(
      {int reps, double weight, int restTime, bool isCompleted, String? notes});
}

/// @nodoc
class _$ExerciseSetCopyWithImpl<$Res, $Val extends ExerciseSet>
    implements $ExerciseSetCopyWith<$Res> {
  _$ExerciseSetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reps = null,
    Object? weight = null,
    Object? restTime = null,
    Object? isCompleted = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      restTime: null == restTime
          ? _value.restTime
          : restTime // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseSetImplCopyWith<$Res>
    implements $ExerciseSetCopyWith<$Res> {
  factory _$$ExerciseSetImplCopyWith(
          _$ExerciseSetImpl value, $Res Function(_$ExerciseSetImpl) then) =
      __$$ExerciseSetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int reps, double weight, int restTime, bool isCompleted, String? notes});
}

/// @nodoc
class __$$ExerciseSetImplCopyWithImpl<$Res>
    extends _$ExerciseSetCopyWithImpl<$Res, _$ExerciseSetImpl>
    implements _$$ExerciseSetImplCopyWith<$Res> {
  __$$ExerciseSetImplCopyWithImpl(
      _$ExerciseSetImpl _value, $Res Function(_$ExerciseSetImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reps = null,
    Object? weight = null,
    Object? restTime = null,
    Object? isCompleted = null,
    Object? notes = freezed,
  }) {
    return _then(_$ExerciseSetImpl(
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      restTime: null == restTime
          ? _value.restTime
          : restTime // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseSetImpl implements _ExerciseSet {
  const _$ExerciseSetImpl(
      {required this.reps,
      required this.weight,
      required this.restTime,
      this.isCompleted = false,
      this.notes});

  factory _$ExerciseSetImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseSetImplFromJson(json);

  @override
  final int reps;
  @override
  final double weight;
  @override
  final int restTime;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  final String? notes;

  @override
  String toString() {
    return 'ExerciseSet(reps: $reps, weight: $weight, restTime: $restTime, isCompleted: $isCompleted, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseSetImpl &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.restTime, restTime) ||
                other.restTime == restTime) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, reps, weight, restTime, isCompleted, notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseSetImplCopyWith<_$ExerciseSetImpl> get copyWith =>
      __$$ExerciseSetImplCopyWithImpl<_$ExerciseSetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseSetImplToJson(
      this,
    );
  }
}

abstract class _ExerciseSet implements ExerciseSet {
  const factory _ExerciseSet(
      {required final int reps,
      required final double weight,
      required final int restTime,
      final bool isCompleted,
      final String? notes}) = _$ExerciseSetImpl;

  factory _ExerciseSet.fromJson(Map<String, dynamic> json) =
      _$ExerciseSetImpl.fromJson;

  @override
  int get reps;
  @override
  double get weight;
  @override
  int get restTime;
  @override
  bool get isCompleted;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseSetImplCopyWith<_$ExerciseSetImpl> get copyWith =>
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
  DateTime get date => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  int get caloriesBurned => throw _privateConstructorUsedError;
  List<TrainingExercise> get exercises => throw _privateConstructorUsedError;
  TrainingStatus get status => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  Map<String, dynamic>? get extra => throw _privateConstructorUsedError;

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
      DateTime date,
      int duration,
      int caloriesBurned,
      List<TrainingExercise> exercises,
      TrainingStatus status,
      String? notes,
      Map<String, dynamic>? extra});
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
    Object? date = null,
    Object? duration = null,
    Object? caloriesBurned = null,
    Object? exercises = null,
    Object? status = null,
    Object? notes = freezed,
    Object? extra = freezed,
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
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TrainingStatus,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      extra: freezed == extra
          ? _value.extra
          : extra // ignore: cast_nullable_to_non_nullable
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
      DateTime date,
      int duration,
      int caloriesBurned,
      List<TrainingExercise> exercises,
      TrainingStatus status,
      String? notes,
      Map<String, dynamic>? extra});
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
    Object? date = null,
    Object? duration = null,
    Object? caloriesBurned = null,
    Object? exercises = null,
    Object? status = null,
    Object? notes = freezed,
    Object? extra = freezed,
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
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TrainingStatus,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      extra: freezed == extra
          ? _value._extra
          : extra // ignore: cast_nullable_to_non_nullable
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
      required this.date,
      required this.duration,
      required this.caloriesBurned,
      required final List<TrainingExercise> exercises,
      required this.status,
      this.notes,
      final Map<String, dynamic>? extra})
      : _exercises = exercises,
        _extra = extra;

  factory _$TrainingHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingHistoryImplFromJson(json);

  @override
  final String id;
  @override
  final String planId;
  @override
  final String planName;
  @override
  final DateTime date;
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

  @override
  final TrainingStatus status;
  @override
  final String? notes;
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
    return 'TrainingHistory(id: $id, planId: $planId, planName: $planName, date: $date, duration: $duration, caloriesBurned: $caloriesBurned, exercises: $exercises, status: $status, notes: $notes, extra: $extra)';
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
            (identical(other.date, date) || other.date == date) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.caloriesBurned, caloriesBurned) ||
                other.caloriesBurned == caloriesBurned) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._extra, _extra));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      planId,
      planName,
      date,
      duration,
      caloriesBurned,
      const DeepCollectionEquality().hash(_exercises),
      status,
      notes,
      const DeepCollectionEquality().hash(_extra));

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
      required final DateTime date,
      required final int duration,
      required final int caloriesBurned,
      required final List<TrainingExercise> exercises,
      required final TrainingStatus status,
      final String? notes,
      final Map<String, dynamic>? extra}) = _$TrainingHistoryImpl;

  factory _TrainingHistory.fromJson(Map<String, dynamic> json) =
      _$TrainingHistoryImpl.fromJson;

  @override
  String get id;
  @override
  String get planId;
  @override
  String get planName;
  @override
  DateTime get date;
  @override
  int get duration;
  @override
  int get caloriesBurned;
  @override
  List<TrainingExercise> get exercises;
  @override
  TrainingStatus get status;
  @override
  String? get notes;
  @override
  Map<String, dynamic>? get extra;
  @override
  @JsonKey(ignore: true)
  _$$TrainingHistoryImplCopyWith<_$TrainingHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CheckIn _$CheckInFromJson(Map<String, dynamic> json) {
  return _CheckIn.fromJson(json);
}

/// @nodoc
mixin _$CheckIn {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  CheckInType get type => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  Map<String, dynamic>? get extra => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
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
@JsonSerializable()
class _$CheckInImpl implements _CheckIn {
  const _$CheckInImpl(
      {required this.id,
      required this.date,
      required this.type,
      required this.content,
      final List<String> images = const [],
      this.location,
      final Map<String, dynamic>? extra})
      : _images = images,
        _extra = extra;

  factory _$CheckInImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckInImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime date;
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
    return 'CheckIn(id: $id, date: $date, type: $type, content: $content, images: $images, location: $location, extra: $extra)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckInImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other._extra, _extra));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      date,
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

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckInImplToJson(
      this,
    );
  }
}

abstract class _CheckIn implements CheckIn {
  const factory _CheckIn(
      {required final String id,
      required final DateTime date,
      required final CheckInType type,
      required final String content,
      final List<String> images,
      final String? location,
      final Map<String, dynamic>? extra}) = _$CheckInImpl;

  factory _CheckIn.fromJson(Map<String, dynamic> json) = _$CheckInImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get date;
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

TrainingStats _$TrainingStatsFromJson(Map<String, dynamic> json) {
  return _TrainingStats.fromJson(json);
}

/// @nodoc
mixin _$TrainingStats {
  int get totalWorkouts => throw _privateConstructorUsedError;
  int get totalMinutes => throw _privateConstructorUsedError;
  int get totalCaloriesBurned => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  int get maxStreak => throw _privateConstructorUsedError;
  int get averageWorkoutDuration => throw _privateConstructorUsedError;
  double get workoutFrequency => throw _privateConstructorUsedError;
  int get maxWeightLifted => throw _privateConstructorUsedError;
  double get totalDistanceCovered => throw _privateConstructorUsedError;
  int get weeklyWorkouts => throw _privateConstructorUsedError;
  int get weeklyMinutes => throw _privateConstructorUsedError;
  int get weeklyCalories => throw _privateConstructorUsedError;
  int get monthlyWorkouts => throw _privateConstructorUsedError;
  int get monthlyMinutes => throw _privateConstructorUsedError;
  int get monthlyCalories => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrainingStatsCopyWith<TrainingStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingStatsCopyWith<$Res> {
  factory $TrainingStatsCopyWith(
          TrainingStats value, $Res Function(TrainingStats) then) =
      _$TrainingStatsCopyWithImpl<$Res, TrainingStats>;
  @useResult
  $Res call(
      {int totalWorkouts,
      int totalMinutes,
      int totalCaloriesBurned,
      int currentStreak,
      int maxStreak,
      int averageWorkoutDuration,
      double workoutFrequency,
      int maxWeightLifted,
      double totalDistanceCovered,
      int weeklyWorkouts,
      int weeklyMinutes,
      int weeklyCalories,
      int monthlyWorkouts,
      int monthlyMinutes,
      int monthlyCalories});
}

/// @nodoc
class _$TrainingStatsCopyWithImpl<$Res, $Val extends TrainingStats>
    implements $TrainingStatsCopyWith<$Res> {
  _$TrainingStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalWorkouts = null,
    Object? totalMinutes = null,
    Object? totalCaloriesBurned = null,
    Object? currentStreak = null,
    Object? maxStreak = null,
    Object? averageWorkoutDuration = null,
    Object? workoutFrequency = null,
    Object? maxWeightLifted = null,
    Object? totalDistanceCovered = null,
    Object? weeklyWorkouts = null,
    Object? weeklyMinutes = null,
    Object? weeklyCalories = null,
    Object? monthlyWorkouts = null,
    Object? monthlyMinutes = null,
    Object? monthlyCalories = null,
  }) {
    return _then(_value.copyWith(
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      totalCaloriesBurned: null == totalCaloriesBurned
          ? _value.totalCaloriesBurned
          : totalCaloriesBurned // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      maxStreak: null == maxStreak
          ? _value.maxStreak
          : maxStreak // ignore: cast_nullable_to_non_nullable
              as int,
      averageWorkoutDuration: null == averageWorkoutDuration
          ? _value.averageWorkoutDuration
          : averageWorkoutDuration // ignore: cast_nullable_to_non_nullable
              as int,
      workoutFrequency: null == workoutFrequency
          ? _value.workoutFrequency
          : workoutFrequency // ignore: cast_nullable_to_non_nullable
              as double,
      maxWeightLifted: null == maxWeightLifted
          ? _value.maxWeightLifted
          : maxWeightLifted // ignore: cast_nullable_to_non_nullable
              as int,
      totalDistanceCovered: null == totalDistanceCovered
          ? _value.totalDistanceCovered
          : totalDistanceCovered // ignore: cast_nullable_to_non_nullable
              as double,
      weeklyWorkouts: null == weeklyWorkouts
          ? _value.weeklyWorkouts
          : weeklyWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyMinutes: null == weeklyMinutes
          ? _value.weeklyMinutes
          : weeklyMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyCalories: null == weeklyCalories
          ? _value.weeklyCalories
          : weeklyCalories // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyWorkouts: null == monthlyWorkouts
          ? _value.monthlyWorkouts
          : monthlyWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyMinutes: null == monthlyMinutes
          ? _value.monthlyMinutes
          : monthlyMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyCalories: null == monthlyCalories
          ? _value.monthlyCalories
          : monthlyCalories // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrainingStatsImplCopyWith<$Res>
    implements $TrainingStatsCopyWith<$Res> {
  factory _$$TrainingStatsImplCopyWith(
          _$TrainingStatsImpl value, $Res Function(_$TrainingStatsImpl) then) =
      __$$TrainingStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalWorkouts,
      int totalMinutes,
      int totalCaloriesBurned,
      int currentStreak,
      int maxStreak,
      int averageWorkoutDuration,
      double workoutFrequency,
      int maxWeightLifted,
      double totalDistanceCovered,
      int weeklyWorkouts,
      int weeklyMinutes,
      int weeklyCalories,
      int monthlyWorkouts,
      int monthlyMinutes,
      int monthlyCalories});
}

/// @nodoc
class __$$TrainingStatsImplCopyWithImpl<$Res>
    extends _$TrainingStatsCopyWithImpl<$Res, _$TrainingStatsImpl>
    implements _$$TrainingStatsImplCopyWith<$Res> {
  __$$TrainingStatsImplCopyWithImpl(
      _$TrainingStatsImpl _value, $Res Function(_$TrainingStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalWorkouts = null,
    Object? totalMinutes = null,
    Object? totalCaloriesBurned = null,
    Object? currentStreak = null,
    Object? maxStreak = null,
    Object? averageWorkoutDuration = null,
    Object? workoutFrequency = null,
    Object? maxWeightLifted = null,
    Object? totalDistanceCovered = null,
    Object? weeklyWorkouts = null,
    Object? weeklyMinutes = null,
    Object? weeklyCalories = null,
    Object? monthlyWorkouts = null,
    Object? monthlyMinutes = null,
    Object? monthlyCalories = null,
  }) {
    return _then(_$TrainingStatsImpl(
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      totalCaloriesBurned: null == totalCaloriesBurned
          ? _value.totalCaloriesBurned
          : totalCaloriesBurned // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      maxStreak: null == maxStreak
          ? _value.maxStreak
          : maxStreak // ignore: cast_nullable_to_non_nullable
              as int,
      averageWorkoutDuration: null == averageWorkoutDuration
          ? _value.averageWorkoutDuration
          : averageWorkoutDuration // ignore: cast_nullable_to_non_nullable
              as int,
      workoutFrequency: null == workoutFrequency
          ? _value.workoutFrequency
          : workoutFrequency // ignore: cast_nullable_to_non_nullable
              as double,
      maxWeightLifted: null == maxWeightLifted
          ? _value.maxWeightLifted
          : maxWeightLifted // ignore: cast_nullable_to_non_nullable
              as int,
      totalDistanceCovered: null == totalDistanceCovered
          ? _value.totalDistanceCovered
          : totalDistanceCovered // ignore: cast_nullable_to_non_nullable
              as double,
      weeklyWorkouts: null == weeklyWorkouts
          ? _value.weeklyWorkouts
          : weeklyWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyMinutes: null == weeklyMinutes
          ? _value.weeklyMinutes
          : weeklyMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyCalories: null == weeklyCalories
          ? _value.weeklyCalories
          : weeklyCalories // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyWorkouts: null == monthlyWorkouts
          ? _value.monthlyWorkouts
          : monthlyWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyMinutes: null == monthlyMinutes
          ? _value.monthlyMinutes
          : monthlyMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyCalories: null == monthlyCalories
          ? _value.monthlyCalories
          : monthlyCalories // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainingStatsImpl implements _TrainingStats {
  const _$TrainingStatsImpl(
      {this.totalWorkouts = 0,
      this.totalMinutes = 0,
      this.totalCaloriesBurned = 0,
      this.currentStreak = 0,
      this.maxStreak = 0,
      this.averageWorkoutDuration = 0,
      this.workoutFrequency = 0.0,
      this.maxWeightLifted = 0,
      this.totalDistanceCovered = 0.0,
      this.weeklyWorkouts = 0,
      this.weeklyMinutes = 0,
      this.weeklyCalories = 0,
      this.monthlyWorkouts = 0,
      this.monthlyMinutes = 0,
      this.monthlyCalories = 0});

  factory _$TrainingStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingStatsImplFromJson(json);

  @override
  @JsonKey()
  final int totalWorkouts;
  @override
  @JsonKey()
  final int totalMinutes;
  @override
  @JsonKey()
  final int totalCaloriesBurned;
  @override
  @JsonKey()
  final int currentStreak;
  @override
  @JsonKey()
  final int maxStreak;
  @override
  @JsonKey()
  final int averageWorkoutDuration;
  @override
  @JsonKey()
  final double workoutFrequency;
  @override
  @JsonKey()
  final int maxWeightLifted;
  @override
  @JsonKey()
  final double totalDistanceCovered;
  @override
  @JsonKey()
  final int weeklyWorkouts;
  @override
  @JsonKey()
  final int weeklyMinutes;
  @override
  @JsonKey()
  final int weeklyCalories;
  @override
  @JsonKey()
  final int monthlyWorkouts;
  @override
  @JsonKey()
  final int monthlyMinutes;
  @override
  @JsonKey()
  final int monthlyCalories;

  @override
  String toString() {
    return 'TrainingStats(totalWorkouts: $totalWorkouts, totalMinutes: $totalMinutes, totalCaloriesBurned: $totalCaloriesBurned, currentStreak: $currentStreak, maxStreak: $maxStreak, averageWorkoutDuration: $averageWorkoutDuration, workoutFrequency: $workoutFrequency, maxWeightLifted: $maxWeightLifted, totalDistanceCovered: $totalDistanceCovered, weeklyWorkouts: $weeklyWorkouts, weeklyMinutes: $weeklyMinutes, weeklyCalories: $weeklyCalories, monthlyWorkouts: $monthlyWorkouts, monthlyMinutes: $monthlyMinutes, monthlyCalories: $monthlyCalories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingStatsImpl &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts) &&
            (identical(other.totalMinutes, totalMinutes) ||
                other.totalMinutes == totalMinutes) &&
            (identical(other.totalCaloriesBurned, totalCaloriesBurned) ||
                other.totalCaloriesBurned == totalCaloriesBurned) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.maxStreak, maxStreak) ||
                other.maxStreak == maxStreak) &&
            (identical(other.averageWorkoutDuration, averageWorkoutDuration) ||
                other.averageWorkoutDuration == averageWorkoutDuration) &&
            (identical(other.workoutFrequency, workoutFrequency) ||
                other.workoutFrequency == workoutFrequency) &&
            (identical(other.maxWeightLifted, maxWeightLifted) ||
                other.maxWeightLifted == maxWeightLifted) &&
            (identical(other.totalDistanceCovered, totalDistanceCovered) ||
                other.totalDistanceCovered == totalDistanceCovered) &&
            (identical(other.weeklyWorkouts, weeklyWorkouts) ||
                other.weeklyWorkouts == weeklyWorkouts) &&
            (identical(other.weeklyMinutes, weeklyMinutes) ||
                other.weeklyMinutes == weeklyMinutes) &&
            (identical(other.weeklyCalories, weeklyCalories) ||
                other.weeklyCalories == weeklyCalories) &&
            (identical(other.monthlyWorkouts, monthlyWorkouts) ||
                other.monthlyWorkouts == monthlyWorkouts) &&
            (identical(other.monthlyMinutes, monthlyMinutes) ||
                other.monthlyMinutes == monthlyMinutes) &&
            (identical(other.monthlyCalories, monthlyCalories) ||
                other.monthlyCalories == monthlyCalories));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalWorkouts,
      totalMinutes,
      totalCaloriesBurned,
      currentStreak,
      maxStreak,
      averageWorkoutDuration,
      workoutFrequency,
      maxWeightLifted,
      totalDistanceCovered,
      weeklyWorkouts,
      weeklyMinutes,
      weeklyCalories,
      monthlyWorkouts,
      monthlyMinutes,
      monthlyCalories);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingStatsImplCopyWith<_$TrainingStatsImpl> get copyWith =>
      __$$TrainingStatsImplCopyWithImpl<_$TrainingStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingStatsImplToJson(
      this,
    );
  }
}

abstract class _TrainingStats implements TrainingStats {
  const factory _TrainingStats(
      {final int totalWorkouts,
      final int totalMinutes,
      final int totalCaloriesBurned,
      final int currentStreak,
      final int maxStreak,
      final int averageWorkoutDuration,
      final double workoutFrequency,
      final int maxWeightLifted,
      final double totalDistanceCovered,
      final int weeklyWorkouts,
      final int weeklyMinutes,
      final int weeklyCalories,
      final int monthlyWorkouts,
      final int monthlyMinutes,
      final int monthlyCalories}) = _$TrainingStatsImpl;

  factory _TrainingStats.fromJson(Map<String, dynamic> json) =
      _$TrainingStatsImpl.fromJson;

  @override
  int get totalWorkouts;
  @override
  int get totalMinutes;
  @override
  int get totalCaloriesBurned;
  @override
  int get currentStreak;
  @override
  int get maxStreak;
  @override
  int get averageWorkoutDuration;
  @override
  double get workoutFrequency;
  @override
  int get maxWeightLifted;
  @override
  double get totalDistanceCovered;
  @override
  int get weeklyWorkouts;
  @override
  int get weeklyMinutes;
  @override
  int get weeklyCalories;
  @override
  int get monthlyWorkouts;
  @override
  int get monthlyMinutes;
  @override
  int get monthlyCalories;
  @override
  @JsonKey(ignore: true)
  _$$TrainingStatsImplCopyWith<_$TrainingStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AITrainingPlanRequest _$AITrainingPlanRequestFromJson(
    Map<String, dynamic> json) {
  return _AITrainingPlanRequest.fromJson(json);
}

/// @nodoc
mixin _$AITrainingPlanRequest {
  String get goal => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  TrainingDifficulty get difficulty => throw _privateConstructorUsedError;
  List<String> get preferences => throw _privateConstructorUsedError;
  List<String> get availableEquipment => throw _privateConstructorUsedError;
  List<String> get targetMuscles => throw _privateConstructorUsedError;
  int get experienceLevel => throw _privateConstructorUsedError;
  int get availableTimePerDay => throw _privateConstructorUsedError;
  List<String> get restrictions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AITrainingPlanRequestCopyWith<AITrainingPlanRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AITrainingPlanRequestCopyWith<$Res> {
  factory $AITrainingPlanRequestCopyWith(AITrainingPlanRequest value,
          $Res Function(AITrainingPlanRequest) then) =
      _$AITrainingPlanRequestCopyWithImpl<$Res, AITrainingPlanRequest>;
  @useResult
  $Res call(
      {String goal,
      int duration,
      TrainingDifficulty difficulty,
      List<String> preferences,
      List<String> availableEquipment,
      List<String> targetMuscles,
      int experienceLevel,
      int availableTimePerDay,
      List<String> restrictions});
}

/// @nodoc
class _$AITrainingPlanRequestCopyWithImpl<$Res,
        $Val extends AITrainingPlanRequest>
    implements $AITrainingPlanRequestCopyWith<$Res> {
  _$AITrainingPlanRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goal = null,
    Object? duration = null,
    Object? difficulty = null,
    Object? preferences = null,
    Object? availableEquipment = null,
    Object? targetMuscles = null,
    Object? experienceLevel = null,
    Object? availableTimePerDay = null,
    Object? restrictions = null,
  }) {
    return _then(_value.copyWith(
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as TrainingDifficulty,
      preferences: null == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as List<String>,
      availableEquipment: null == availableEquipment
          ? _value.availableEquipment
          : availableEquipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      targetMuscles: null == targetMuscles
          ? _value.targetMuscles
          : targetMuscles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      experienceLevel: null == experienceLevel
          ? _value.experienceLevel
          : experienceLevel // ignore: cast_nullable_to_non_nullable
              as int,
      availableTimePerDay: null == availableTimePerDay
          ? _value.availableTimePerDay
          : availableTimePerDay // ignore: cast_nullable_to_non_nullable
              as int,
      restrictions: null == restrictions
          ? _value.restrictions
          : restrictions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AITrainingPlanRequestImplCopyWith<$Res>
    implements $AITrainingPlanRequestCopyWith<$Res> {
  factory _$$AITrainingPlanRequestImplCopyWith(
          _$AITrainingPlanRequestImpl value,
          $Res Function(_$AITrainingPlanRequestImpl) then) =
      __$$AITrainingPlanRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String goal,
      int duration,
      TrainingDifficulty difficulty,
      List<String> preferences,
      List<String> availableEquipment,
      List<String> targetMuscles,
      int experienceLevel,
      int availableTimePerDay,
      List<String> restrictions});
}

/// @nodoc
class __$$AITrainingPlanRequestImplCopyWithImpl<$Res>
    extends _$AITrainingPlanRequestCopyWithImpl<$Res,
        _$AITrainingPlanRequestImpl>
    implements _$$AITrainingPlanRequestImplCopyWith<$Res> {
  __$$AITrainingPlanRequestImplCopyWithImpl(_$AITrainingPlanRequestImpl _value,
      $Res Function(_$AITrainingPlanRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goal = null,
    Object? duration = null,
    Object? difficulty = null,
    Object? preferences = null,
    Object? availableEquipment = null,
    Object? targetMuscles = null,
    Object? experienceLevel = null,
    Object? availableTimePerDay = null,
    Object? restrictions = null,
  }) {
    return _then(_$AITrainingPlanRequestImpl(
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as TrainingDifficulty,
      preferences: null == preferences
          ? _value._preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as List<String>,
      availableEquipment: null == availableEquipment
          ? _value._availableEquipment
          : availableEquipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      targetMuscles: null == targetMuscles
          ? _value._targetMuscles
          : targetMuscles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      experienceLevel: null == experienceLevel
          ? _value.experienceLevel
          : experienceLevel // ignore: cast_nullable_to_non_nullable
              as int,
      availableTimePerDay: null == availableTimePerDay
          ? _value.availableTimePerDay
          : availableTimePerDay // ignore: cast_nullable_to_non_nullable
              as int,
      restrictions: null == restrictions
          ? _value._restrictions
          : restrictions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AITrainingPlanRequestImpl implements _AITrainingPlanRequest {
  const _$AITrainingPlanRequestImpl(
      {required this.goal,
      required this.duration,
      required this.difficulty,
      final List<String> preferences = const [],
      final List<String> availableEquipment = const [],
      final List<String> targetMuscles = const [],
      this.experienceLevel = 0,
      this.availableTimePerDay = 0,
      final List<String> restrictions = const []})
      : _preferences = preferences,
        _availableEquipment = availableEquipment,
        _targetMuscles = targetMuscles,
        _restrictions = restrictions;

  factory _$AITrainingPlanRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AITrainingPlanRequestImplFromJson(json);

  @override
  final String goal;
  @override
  final int duration;
  @override
  final TrainingDifficulty difficulty;
  final List<String> _preferences;
  @override
  @JsonKey()
  List<String> get preferences {
    if (_preferences is EqualUnmodifiableListView) return _preferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferences);
  }

  final List<String> _availableEquipment;
  @override
  @JsonKey()
  List<String> get availableEquipment {
    if (_availableEquipment is EqualUnmodifiableListView)
      return _availableEquipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableEquipment);
  }

  final List<String> _targetMuscles;
  @override
  @JsonKey()
  List<String> get targetMuscles {
    if (_targetMuscles is EqualUnmodifiableListView) return _targetMuscles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetMuscles);
  }

  @override
  @JsonKey()
  final int experienceLevel;
  @override
  @JsonKey()
  final int availableTimePerDay;
  final List<String> _restrictions;
  @override
  @JsonKey()
  List<String> get restrictions {
    if (_restrictions is EqualUnmodifiableListView) return _restrictions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_restrictions);
  }

  @override
  String toString() {
    return 'AITrainingPlanRequest(goal: $goal, duration: $duration, difficulty: $difficulty, preferences: $preferences, availableEquipment: $availableEquipment, targetMuscles: $targetMuscles, experienceLevel: $experienceLevel, availableTimePerDay: $availableTimePerDay, restrictions: $restrictions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AITrainingPlanRequestImpl &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality()
                .equals(other._preferences, _preferences) &&
            const DeepCollectionEquality()
                .equals(other._availableEquipment, _availableEquipment) &&
            const DeepCollectionEquality()
                .equals(other._targetMuscles, _targetMuscles) &&
            (identical(other.experienceLevel, experienceLevel) ||
                other.experienceLevel == experienceLevel) &&
            (identical(other.availableTimePerDay, availableTimePerDay) ||
                other.availableTimePerDay == availableTimePerDay) &&
            const DeepCollectionEquality()
                .equals(other._restrictions, _restrictions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      goal,
      duration,
      difficulty,
      const DeepCollectionEquality().hash(_preferences),
      const DeepCollectionEquality().hash(_availableEquipment),
      const DeepCollectionEquality().hash(_targetMuscles),
      experienceLevel,
      availableTimePerDay,
      const DeepCollectionEquality().hash(_restrictions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AITrainingPlanRequestImplCopyWith<_$AITrainingPlanRequestImpl>
      get copyWith => __$$AITrainingPlanRequestImplCopyWithImpl<
          _$AITrainingPlanRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AITrainingPlanRequestImplToJson(
      this,
    );
  }
}

abstract class _AITrainingPlanRequest implements AITrainingPlanRequest {
  const factory _AITrainingPlanRequest(
      {required final String goal,
      required final int duration,
      required final TrainingDifficulty difficulty,
      final List<String> preferences,
      final List<String> availableEquipment,
      final List<String> targetMuscles,
      final int experienceLevel,
      final int availableTimePerDay,
      final List<String> restrictions}) = _$AITrainingPlanRequestImpl;

  factory _AITrainingPlanRequest.fromJson(Map<String, dynamic> json) =
      _$AITrainingPlanRequestImpl.fromJson;

  @override
  String get goal;
  @override
  int get duration;
  @override
  TrainingDifficulty get difficulty;
  @override
  List<String> get preferences;
  @override
  List<String> get availableEquipment;
  @override
  List<String> get targetMuscles;
  @override
  int get experienceLevel;
  @override
  int get availableTimePerDay;
  @override
  List<String> get restrictions;
  @override
  @JsonKey(ignore: true)
  _$$AITrainingPlanRequestImplCopyWith<_$AITrainingPlanRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
