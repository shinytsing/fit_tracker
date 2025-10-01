import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_provider.freezed.dart';

enum PostType {
  text,
  image,
  video,
  workout,
  checkin,
}

@freezed
class PostState with _$PostState {
  const factory PostState({
    @Default(false) bool isPosting,
    @Default(false) bool isLoading,
    String? error,
  }) = _PostState;
}

@freezed
class CreatePostRequest with _$CreatePostRequest {
  const factory CreatePostRequest({
    required String content,
    required String type,
    @Default([]) List<String> images,
    String? location,
    WorkoutData? workoutData,
  }) = _CreatePostRequest;
}

@freezed
class WorkoutData with _$WorkoutData {
  const factory WorkoutData({
    required String exerciseName,
    required int duration,
    required int calories,
    @Default([]) List<String> exercises,
  }) = _WorkoutData;
}


// Provider
final postProvider = StateNotifierProvider<PostNotifier, PostState>(
  (ref) => PostNotifier(),
);

class PostNotifier extends StateNotifier<PostState> {
  PostNotifier() : super(const PostState());

  Future<bool> createPost(CreatePostRequest request) async {
    state = state.copyWith(isPosting: true);
    
    try {
      // TODO: 调用API创建帖子
      await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求
      
      state = state.copyWith(isPosting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isPosting: false,
        error: e.toString(),
      );
      return false;
    }
  }
}
