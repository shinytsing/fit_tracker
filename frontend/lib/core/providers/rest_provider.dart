import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/rest_api_service.dart';
import '../config/storage_service.dart';

// 组间休息状态
class RestState {
  final RestSession? currentSession;
  final RestFeed? restFeed;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final int remainingSeconds;
  final bool isResting;

  RestState({
    this.currentSession,
    this.restFeed,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.remainingSeconds = 0,
    this.isResting = false,
  });

  RestState copyWith({
    RestSession? currentSession,
    RestFeed? restFeed,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
    int? remainingSeconds,
    bool? isResting,
  }) {
    return RestState(
      currentSession: currentSession ?? this.currentSession,
      restFeed: restFeed ?? this.restFeed,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isResting: isResting ?? this.isResting,
    );
  }
}

class RestNotifier extends StateNotifier<RestState> {
  Timer? _timer;

  RestNotifier() : super(RestState());

  // 开始休息
  Future<void> startRest({
    required int duration,
    String? notes,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final token = await StorageService.getToken();
      final session = await RestApiService.startRest(
        duration: duration,
        notes: notes,
        token: token,
      );

      // 开始倒计时
      state = state.copyWith(
        currentSession: session,
        remainingSeconds: duration,
        isResting: true,
        isLoading: false,
      );

      _startTimer();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // 完成休息
  Future<void> completeRest({String? notes}) async {
    if (state.currentSession == null) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final token = await StorageService.getToken();
      await RestApiService.completeRest(
        sessionId: state.currentSession!.id,
        notes: notes,
        token: token,
      );

      // 停止倒计时
      _stopTimer();
      state = state.copyWith(
        isResting: false,
        remainingSeconds: 0,
        currentSession: null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // 获取组间动态流
  Future<void> loadRestFeed({bool refresh = false}) async {
    try {
      if (refresh) {
        state = state.copyWith(
          currentPage: 1,
          hasMore: true,
        );
      }

      if (!state.hasMore) return;

      state = state.copyWith(isLoading: true, error: null);

      final token = await StorageService.getToken();
      final feed = await RestApiService.getRestFeed(
        page: state.currentPage,
        limit: 10,
        token: token,
      );

      RestFeed updatedFeed;
      if (refresh || state.restFeed == null) {
        updatedFeed = feed;
      } else {
        // 合并数据
        updatedFeed = RestFeed(
          posts: [...state.restFeed!.posts, ...feed.posts],
          jokes: feed.jokes, // 段子每次都重新获取
          knowledge: feed.knowledge, // 知识卡片每次都重新获取
          total: feed.total,
          hasMore: feed.hasMore,
        );
      }

      state = state.copyWith(
        restFeed: updatedFeed,
        currentPage: state.currentPage + 1,
        hasMore: feed.hasMore,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // 创建组间动态
  Future<void> createRestPost({
    required String content,
    String? imageUrl,
    required String type,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final token = await StorageService.getToken();
      final newPost = await RestApiService.createRestPost(
        content: content,
        imageUrl: imageUrl,
        type: type,
        token: token,
      );

      // 添加到动态流
      if (state.restFeed != null) {
        final updatedFeed = RestFeed(
          posts: [newPost, ...state.restFeed!.posts],
          jokes: state.restFeed!.jokes,
          knowledge: state.restFeed!.knowledge,
          total: state.restFeed!.total + 1,
          hasMore: state.restFeed!.hasMore,
        );
        state = state.copyWith(restFeed: updatedFeed);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // 点赞组间动态
  Future<void> likeRestPost(int postId) async {
    try {
      final token = await StorageService.getToken();
      await RestApiService.likeRestPost(
        postId: postId,
        token: token,
      );

      // 更新本地数据
      if (state.restFeed != null) {
        _updatePostLikeStatus(postId);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 评论组间动态
  Future<void> commentRestPost({
    required int postId,
    required String content,
  }) async {
    try {
      final token = await StorageService.getToken();
      await RestApiService.commentRestPost(
        postId: postId,
        content: content,
        token: token,
      );

      // 更新本地数据
      if (state.restFeed != null) {
        _updatePostCommentCount(postId);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 开始倒计时
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _stopTimer();
        state = state.copyWith(isResting: false);
      }
    });
  }

  // 停止倒计时
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // 更新动态点赞状态
  void _updatePostLikeStatus(int postId) {
    if (state.restFeed == null) return;

    final updatedPosts = state.restFeed!.posts.map((post) {
      if (post.id == postId) {
        return post.copyWith(
          isLiked: !post.isLiked,
          likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
        );
      }
      return post;
    }).toList();

    final updatedFeed = RestFeed(
      posts: updatedPosts,
      jokes: state.restFeed!.jokes,
      knowledge: state.restFeed!.knowledge,
      total: state.restFeed!.total,
      hasMore: state.restFeed!.hasMore,
    );

    state = state.copyWith(restFeed: updatedFeed);
  }

  // 更新动态评论数
  void _updatePostCommentCount(int postId) {
    if (state.restFeed == null) return;

    final updatedPosts = state.restFeed!.posts.map((post) {
      if (post.id == postId) {
        return post.copyWith(
          commentsCount: post.commentsCount + 1,
        );
      }
      return post;
    }).toList();

    final updatedFeed = RestFeed(
      posts: updatedPosts,
      jokes: state.restFeed!.jokes,
      knowledge: state.restFeed!.knowledge,
      total: state.restFeed!.total,
      hasMore: state.restFeed!.hasMore,
    );

    state = state.copyWith(restFeed: updatedFeed);
  }

  // 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  // 重置状态
  void reset() {
    _stopTimer();
    state = RestState();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

final restProvider = StateNotifierProvider<RestNotifier, RestState>((ref) {
  return RestNotifier();
});
