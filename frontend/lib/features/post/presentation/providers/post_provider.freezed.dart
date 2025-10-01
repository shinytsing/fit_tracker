// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PostState {
  bool get isPosting => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PostStateCopyWith<PostState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostStateCopyWith<$Res> {
  factory $PostStateCopyWith(PostState value, $Res Function(PostState) then) =
      _$PostStateCopyWithImpl<$Res, PostState>;
  @useResult
  $Res call({bool isPosting, bool isLoading, String? error});
}

/// @nodoc
class _$PostStateCopyWithImpl<$Res, $Val extends PostState>
    implements $PostStateCopyWith<$Res> {
  _$PostStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPosting = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      isPosting: null == isPosting
          ? _value.isPosting
          : isPosting // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostStateImplCopyWith<$Res>
    implements $PostStateCopyWith<$Res> {
  factory _$$PostStateImplCopyWith(
          _$PostStateImpl value, $Res Function(_$PostStateImpl) then) =
      __$$PostStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isPosting, bool isLoading, String? error});
}

/// @nodoc
class __$$PostStateImplCopyWithImpl<$Res>
    extends _$PostStateCopyWithImpl<$Res, _$PostStateImpl>
    implements _$$PostStateImplCopyWith<$Res> {
  __$$PostStateImplCopyWithImpl(
      _$PostStateImpl _value, $Res Function(_$PostStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPosting = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$PostStateImpl(
      isPosting: null == isPosting
          ? _value.isPosting
          : isPosting // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PostStateImpl implements _PostState {
  const _$PostStateImpl(
      {this.isPosting = false, this.isLoading = false, this.error});

  @override
  @JsonKey()
  final bool isPosting;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'PostState(isPosting: $isPosting, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostStateImpl &&
            (identical(other.isPosting, isPosting) ||
                other.isPosting == isPosting) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isPosting, isLoading, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PostStateImplCopyWith<_$PostStateImpl> get copyWith =>
      __$$PostStateImplCopyWithImpl<_$PostStateImpl>(this, _$identity);
}

abstract class _PostState implements PostState {
  const factory _PostState(
      {final bool isPosting,
      final bool isLoading,
      final String? error}) = _$PostStateImpl;

  @override
  bool get isPosting;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$PostStateImplCopyWith<_$PostStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CreatePostRequest {
  String get content => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  WorkoutData? get workoutData => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CreatePostRequestCopyWith<CreatePostRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreatePostRequestCopyWith<$Res> {
  factory $CreatePostRequestCopyWith(
          CreatePostRequest value, $Res Function(CreatePostRequest) then) =
      _$CreatePostRequestCopyWithImpl<$Res, CreatePostRequest>;
  @useResult
  $Res call(
      {String content,
      String type,
      List<String> images,
      String? location,
      WorkoutData? workoutData});

  $WorkoutDataCopyWith<$Res>? get workoutData;
}

/// @nodoc
class _$CreatePostRequestCopyWithImpl<$Res, $Val extends CreatePostRequest>
    implements $CreatePostRequestCopyWith<$Res> {
  _$CreatePostRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? type = null,
    Object? images = null,
    Object? location = freezed,
    Object? workoutData = freezed,
  }) {
    return _then(_value.copyWith(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutData: freezed == workoutData
          ? _value.workoutData
          : workoutData // ignore: cast_nullable_to_non_nullable
              as WorkoutData?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WorkoutDataCopyWith<$Res>? get workoutData {
    if (_value.workoutData == null) {
      return null;
    }

    return $WorkoutDataCopyWith<$Res>(_value.workoutData!, (value) {
      return _then(_value.copyWith(workoutData: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreatePostRequestImplCopyWith<$Res>
    implements $CreatePostRequestCopyWith<$Res> {
  factory _$$CreatePostRequestImplCopyWith(_$CreatePostRequestImpl value,
          $Res Function(_$CreatePostRequestImpl) then) =
      __$$CreatePostRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String content,
      String type,
      List<String> images,
      String? location,
      WorkoutData? workoutData});

  @override
  $WorkoutDataCopyWith<$Res>? get workoutData;
}

/// @nodoc
class __$$CreatePostRequestImplCopyWithImpl<$Res>
    extends _$CreatePostRequestCopyWithImpl<$Res, _$CreatePostRequestImpl>
    implements _$$CreatePostRequestImplCopyWith<$Res> {
  __$$CreatePostRequestImplCopyWithImpl(_$CreatePostRequestImpl _value,
      $Res Function(_$CreatePostRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? type = null,
    Object? images = null,
    Object? location = freezed,
    Object? workoutData = freezed,
  }) {
    return _then(_$CreatePostRequestImpl(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutData: freezed == workoutData
          ? _value.workoutData
          : workoutData // ignore: cast_nullable_to_non_nullable
              as WorkoutData?,
    ));
  }
}

/// @nodoc

class _$CreatePostRequestImpl implements _CreatePostRequest {
  const _$CreatePostRequestImpl(
      {required this.content,
      required this.type,
      final List<String> images = const [],
      this.location,
      this.workoutData})
      : _images = images;

  @override
  final String content;
  @override
  final String type;
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
  @override
  final WorkoutData? workoutData;

  @override
  String toString() {
    return 'CreatePostRequest(content: $content, type: $type, images: $images, location: $location, workoutData: $workoutData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreatePostRequestImpl &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.workoutData, workoutData) ||
                other.workoutData == workoutData));
  }

  @override
  int get hashCode => Object.hash(runtimeType, content, type,
      const DeepCollectionEquality().hash(_images), location, workoutData);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreatePostRequestImplCopyWith<_$CreatePostRequestImpl> get copyWith =>
      __$$CreatePostRequestImplCopyWithImpl<_$CreatePostRequestImpl>(
          this, _$identity);
}

abstract class _CreatePostRequest implements CreatePostRequest {
  const factory _CreatePostRequest(
      {required final String content,
      required final String type,
      final List<String> images,
      final String? location,
      final WorkoutData? workoutData}) = _$CreatePostRequestImpl;

  @override
  String get content;
  @override
  String get type;
  @override
  List<String> get images;
  @override
  String? get location;
  @override
  WorkoutData? get workoutData;
  @override
  @JsonKey(ignore: true)
  _$$CreatePostRequestImplCopyWith<_$CreatePostRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WorkoutData {
  String get exerciseName => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  int get calories => throw _privateConstructorUsedError;
  List<String> get exercises => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WorkoutDataCopyWith<WorkoutData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutDataCopyWith<$Res> {
  factory $WorkoutDataCopyWith(
          WorkoutData value, $Res Function(WorkoutData) then) =
      _$WorkoutDataCopyWithImpl<$Res, WorkoutData>;
  @useResult
  $Res call(
      {String exerciseName,
      int duration,
      int calories,
      List<String> exercises});
}

/// @nodoc
class _$WorkoutDataCopyWithImpl<$Res, $Val extends WorkoutData>
    implements $WorkoutDataCopyWith<$Res> {
  _$WorkoutDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? duration = null,
    Object? calories = null,
    Object? exercises = null,
  }) {
    return _then(_value.copyWith(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutDataImplCopyWith<$Res>
    implements $WorkoutDataCopyWith<$Res> {
  factory _$$WorkoutDataImplCopyWith(
          _$WorkoutDataImpl value, $Res Function(_$WorkoutDataImpl) then) =
      __$$WorkoutDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseName,
      int duration,
      int calories,
      List<String> exercises});
}

/// @nodoc
class __$$WorkoutDataImplCopyWithImpl<$Res>
    extends _$WorkoutDataCopyWithImpl<$Res, _$WorkoutDataImpl>
    implements _$$WorkoutDataImplCopyWith<$Res> {
  __$$WorkoutDataImplCopyWithImpl(
      _$WorkoutDataImpl _value, $Res Function(_$WorkoutDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? duration = null,
    Object? calories = null,
    Object? exercises = null,
  }) {
    return _then(_$WorkoutDataImpl(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$WorkoutDataImpl implements _WorkoutData {
  const _$WorkoutDataImpl(
      {required this.exerciseName,
      required this.duration,
      required this.calories,
      final List<String> exercises = const []})
      : _exercises = exercises;

  @override
  final String exerciseName;
  @override
  final int duration;
  @override
  final int calories;
  final List<String> _exercises;
  @override
  @JsonKey()
  List<String> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  String toString() {
    return 'WorkoutData(exerciseName: $exerciseName, duration: $duration, calories: $calories, exercises: $exercises)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutDataImpl &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises));
  }

  @override
  int get hashCode => Object.hash(runtimeType, exerciseName, duration, calories,
      const DeepCollectionEquality().hash(_exercises));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutDataImplCopyWith<_$WorkoutDataImpl> get copyWith =>
      __$$WorkoutDataImplCopyWithImpl<_$WorkoutDataImpl>(this, _$identity);
}

abstract class _WorkoutData implements WorkoutData {
  const factory _WorkoutData(
      {required final String exerciseName,
      required final int duration,
      required final int calories,
      final List<String> exercises}) = _$WorkoutDataImpl;

  @override
  String get exerciseName;
  @override
  int get duration;
  @override
  int get calories;
  @override
  List<String> get exercises;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutDataImplCopyWith<_$WorkoutDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
