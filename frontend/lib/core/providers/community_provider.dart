import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/community_api_service.dart';

// 社区状态
class CommunityState {
  final List<Post> posts;
  final List<Topic> hotTopics;
  final List<Challenge> challenges;
  final List<ChallengeParticipant> userChallenges;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? pagination;
  final String sortBy;
  final String? searchQuery;
  final String searchType;

  CommunityState({
    this.posts = const [],
    this.hotTopics = const [],
    this.challenges = const [],
    this.userChallenges = const [],
    this.isLoading = false,
    this.error,
    this.pagination,
    this.sortBy = 'hot',
    this.searchQuery,
    this.searchType = 'post',
  });

  CommunityState copyWith({
    List<Post>? posts,
    List<Topic>? hotTopics,
    List<Challenge>? challenges,
    List<ChallengeParticipant>? userChallenges,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? pagination,
    String? sortBy,
    String? searchQuery,
    String? searchType,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      hotTopics: hotTopics ?? this.hotTopics,
      challenges: challenges ?? this.challenges,
      userChallenges: userChallenges ?? this.userChallenges,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      pagination: pagination ?? this.pagination,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
      searchType: searchType ?? this.searchType,
    );
  }
}

// 社区状态管理
class CommunityNotifier extends StateNotifier<CommunityState> {
  final CommunityApiService _communityApiService;

  CommunityNotifier(this._communityApiService) : super(CommunityState());

  // 加载推荐流
  Future<void> loadFeed({int page = 1, String? sortBy}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _communityApiService.getFeed(
        page: page,
        sortBy: sortBy ?? state.sortBy,
      );
      
      List<Post> newPosts = response.data ?? [];
      if (page > 1) {
        newPosts = [...state.posts, ...newPosts];
      }
      
      state = state.copyWith(
        posts: newPosts,
        pagination: response.pagination,
        isLoading: false,
        sortBy: sortBy ?? state.sortBy,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 刷新推荐流
  Future<void> refreshFeed() async {
    await loadFeed(page: 1);
  }

  // 加载热门话题
  Future<void> loadHotTopics() async {
    try {
      final topics = await _communityApiService.getHotTopics();
      state = state.copyWith(hotTopics: topics);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 发布动态
  Future<bool> createPost({
    required String content,
    List<String>? images,
    String? videoUrl,
    String? type,
    List<String>? tags,
    String? location,
    String? workoutData,
    bool isPublic = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final post = await _communityApiService.createPost(
        content: content,
        images: images,
        videoUrl: videoUrl,
        type: type,
        tags: tags,
        location: location,
        workoutData: workoutData,
        isPublic: isPublic,
      );
      
      state = state.copyWith(
        posts: [post, ...state.posts],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // 点赞动态
  Future<void> likePost(int postId) async {
    try {
      await _communityApiService.likePost(postId);
      
      // 更新本地状态
      final updatedPosts = state.posts.map((post) {
        if (post.id == postId) {
          return Post(
            id: post.id,
            userId: post.userId,
            content: post.content,
            images: post.images,
            videoUrl: post.videoUrl,
            type: post.type,
            isPublic: post.isPublic,
            tags: post.tags,
            location: post.location,
            workoutData: post.workoutData,
            isFeatured: post.isFeatured,
            viewCount: post.viewCount,
            shareCount: post.shareCount,
            likesCount: post.likesCount + 1,
            commentsCount: post.commentsCount,
            sharesCount: post.sharesCount,
            user: post.user,
            topics: post.topics,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
          );
        }
        return post;
      }).toList();
      
      state = state.copyWith(posts: updatedPosts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 收藏动态
  Future<void> favoritePost(int postId) async {
    try {
      await _communityApiService.favoritePost(postId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 关注用户
  Future<void> followUser(int userId) async {
    try {
      await _communityApiService.followUser(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 搜索
  Future<void> search({
    required String query,
    String type = 'post',
    int page = 1,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _communityApiService.search(
        query: query,
        type: type,
        page: page,
      );
      
      state = state.copyWith(
        searchQuery: query,
        searchType: type,
        isLoading: false,
        pagination: response.pagination,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 加载挑战赛
  Future<void> loadChallenges({
    int page = 1,
    String? difficulty,
    String? type,
    String status = 'active',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _communityApiService.getChallenges(
        page: page,
        difficulty: difficulty,
        type: type,
        status: status,
      );
      
      List<Challenge> newChallenges = response.data ?? [];
      if (page > 1) {
        newChallenges = [...state.challenges, ...newChallenges];
      }
      
      state = state.copyWith(
        challenges: newChallenges,
        pagination: response.pagination,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 参与挑战赛
  Future<bool> joinChallenge(int challengeId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final participant = await _communityApiService.joinChallenge(challengeId);
      
      // 更新挑战赛参与人数
      final updatedChallenges = state.challenges.map((challenge) {
        if (challenge.id == challengeId) {
          return Challenge(
            id: challenge.id,
            name: challenge.name,
            description: challenge.description,
            type: challenge.type,
            difficulty: challenge.difficulty,
            startDate: challenge.startDate,
            endDate: challenge.endDate,
            isActive: challenge.isActive,
            participantsCount: challenge.participantsCount + 1,
            createdAt: challenge.createdAt,
            updatedAt: challenge.updatedAt,
          );
        }
        return challenge;
      }).toList();
      
      state = state.copyWith(
        challenges: updatedChallenges,
        userChallenges: [participant, ...state.userChallenges],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // 挑战赛打卡
  Future<bool> checkinChallenge({
    required int challengeId,
    String? content,
    List<String>? images,
    int calories = 0,
    int duration = 0,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final checkin = await _communityApiService.checkinChallenge(
        challengeId: challengeId,
        content: content,
        images: images,
        calories: calories,
        duration: duration,
        notes: notes,
      );
      
      // 更新用户挑战赛进度
      final updatedUserChallenges = state.userChallenges.map((participant) {
        if (participant.challengeId == challengeId) {
          return ChallengeParticipant(
            id: participant.id,
            userId: participant.userId,
            challengeId: participant.challengeId,
            progress: participant.progress,
            joinedAt: participant.joinedAt,
            lastCheckinAt: DateTime.now(),
            checkinCount: participant.checkinCount + 1,
            totalCalories: participant.totalCalories + calories,
            status: participant.status,
            rank: participant.rank,
            user: participant.user,
            challenge: participant.challenge,
            createdAt: participant.createdAt,
            updatedAt: participant.updatedAt,
          );
        }
        return participant;
      }).toList();
      
      state = state.copyWith(
        userChallenges: updatedUserChallenges,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // 加载用户参与的挑战赛
  Future<void> loadUserChallenges({
    int page = 1,
    String status = 'active',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _communityApiService.getUserChallenges(
        page: page,
        status: status,
      );
      
      List<ChallengeParticipant> newUserChallenges = response.data ?? [];
      if (page > 1) {
        newUserChallenges = [...state.userChallenges, ...newUserChallenges];
      }
      
      state = state.copyWith(
        userChallenges: newUserChallenges,
        pagination: response.pagination,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  // 重置状态
  void reset() {
    state = CommunityState();
  }
}

// Provider
final communityApiServiceProvider = Provider<CommunityApiService>((ref) {
  return CommunityApiService();
});

final communityNotifierProvider = StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  final apiService = ref.watch(communityApiServiceProvider);
  return CommunityNotifier(apiService);
});
