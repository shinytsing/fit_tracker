import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/community_api_service.dart';

part 'community_provider.freezed.dart';
part 'community_provider.g.dart';

@freezed
class CommunityState with _$CommunityState {
  const factory CommunityState({
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingRecommend,
    @Default([]) List<Post> followingPosts,
    @Default([]) List<Post> recommendPosts,
    @Default([]) List<Post> posts,
    @Default([]) List<Post> trendingPosts,
    @Default([]) List<User> followingUsers,
    @Default([]) List<Topic> trendingTopics,
    @Default([]) List<Topic> hotTopics,
    @Default([]) List<Topic> recommendedTopics,
    @Default([]) List<Topic> topics,
    @Default([]) List<Challenge> activeChallenges,
    @Default([]) List<Challenge> popularChallenges,
    @Default([]) List<dynamic> challenges,
    @Default([]) List<User> recommendUsers,
    @Default([]) List<User> searchResults,
    @Default([]) List<Comment> comments,
    @Default([]) List<User> users,
    @Default(false) bool hasMoreFollowing,
    @Default(false) bool hasMoreRecommend,
    @Default(false) bool hasMoreTrending,
    String? error,
  }) = _CommunityState;
}

@freezed
class WorkoutData with _$WorkoutData {
  const factory WorkoutData({
    required String name,
    required int duration,
    required int calories,
    @Default([]) List<String> exercises,
    int? exerciseCount,
    String? exerciseName,
  }) = _WorkoutData;

  factory WorkoutData.fromJson(Map<String, dynamic> json) => _$WorkoutDataFromJson(json);
}

enum PostType {
  text,
  image,
  video,
  workout,
  checkin,
}

// Provider
final communityProvider = StateNotifierProvider<CommunityNotifier, CommunityState>(
  (ref) => CommunityNotifier(),
);

class CommunityNotifier extends StateNotifier<CommunityState> {
  CommunityNotifier() : super(const CommunityState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      refreshFollowingPosts(),
      refreshRecommendPosts(),
      _loadTrendingTopics(),
    ]);
  }

  Future<void> refreshFollowingPosts() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // 调用真实 API 获取关注流数据
      final postsData = await CommunityApiService.getPosts(
        page: 1,
        pageSize: 20,
        type: 'following',
      );
      
      // 转换为 Post 模型
      final posts = postsData.map((data) => Post.fromJson(data)).toList();
      
      state = state.copyWith(
        isLoading: false,
        followingPosts: posts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshRecommendPosts() async {
    state = state.copyWith(isLoadingRecommend: true);
    
    try {
      // 调用真实 API 获取推荐流数据
      final postsData = await CommunityApiService.getPosts(
        page: 1,
        pageSize: 20,
        type: 'recommend',
      );
      
      // 转换为 Post 模型
      final posts = postsData.map((data) => Post.fromJson(data)).toList();
      
      state = state.copyWith(
        isLoadingRecommend: false,
        recommendPosts: posts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingRecommend: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshTrendingPosts() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // 调用真实 API 获取热门动态数据
      final postsData = await CommunityApiService.getPosts(
        page: 1,
        pageSize: 20,
        type: 'trending',
      );
      
      // 转换为 Post 模型
      final posts = postsData.map((data) => Post.fromJson(data)).toList();
      
      state = state.copyWith(
        isLoading: false,
        trendingPosts: posts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMoreTrendingPosts() async {
    if (state.isLoading || !state.hasMoreTrending) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final currentPage = (state.trendingPosts.length / 20).ceil() + 1;
      final postsData = await CommunityApiService.getPosts(
        page: currentPage,
        pageSize: 20,
        type: 'trending',
      );
      
      final newPosts = postsData.map((data) => Post.fromJson(data)).toList();
      
      state = state.copyWith(
        isLoading: false,
        trendingPosts: [...state.trendingPosts, ...newPosts],
        hasMoreTrending: newPosts.length == 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _loadTrendingTopics() async {
    // TODO: 加载热门话题
    final topics = _generateMockTopics();
    state = state.copyWith(trendingTopics: topics);
  }

  Future<void> toggleLike(String postId) async {
    // 先更新 UI 状态
    final updatedFollowingPosts = state.followingPosts.map((post) {
      if (post.id == postId) {
        return post.copyWith(
          isLiked: !post.isLiked,
          likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
      }
      return post;
    }).toList();

    final updatedRecommendPosts = state.recommendPosts.map((post) {
      if (post.id == postId) {
        return post.copyWith(
          isLiked: !post.isLiked,
          likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
      }
      return post;
    }).toList();

    state = state.copyWith(
      followingPosts: updatedFollowingPosts,
      recommendPosts: updatedRecommendPosts,
    );

    // 调用真实 API
    try {
      final post = state.followingPosts.firstWhere((p) => p.id == postId, 
          orElse: () => state.recommendPosts.firstWhere((p) => p.id == postId));
      
      if (post.isLiked) {
        await CommunityApiService.likePost(postId);
      } else {
        await CommunityApiService.unlikePost(postId);
      }
    } catch (e) {
      // 如果 API 调用失败，回滚 UI 状态
      final revertedFollowingPosts = state.followingPosts.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            isLiked: !post.isLiked,
            likeCount: post.isLiked ? post.likeCount + 1 : post.likeCount - 1,
          );
        }
        return post;
      }).toList();

      final revertedRecommendPosts = state.recommendPosts.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            isLiked: !post.isLiked,
            likeCount: post.isLiked ? post.likeCount + 1 : post.likeCount - 1,
          );
        }
        return post;
      }).toList();

      state = state.copyWith(
        followingPosts: revertedFollowingPosts,
        recommendPosts: revertedRecommendPosts,
        error: '点赞操作失败: ${e.toString()}',
      );
    }
  }

  Future<void> toggleFollow(String userId) async {
    // 先更新 UI 状态
    final updatedFollowingPosts = state.followingPosts.map((post) {
      if (post.authorId == userId) {
        return post.copyWith(isFollowed: !post.isFollowed);
      }
      return post;
    }).toList();

    final updatedRecommendPosts = state.recommendPosts.map((post) {
      if (post.authorId == userId) {
        return post.copyWith(isFollowed: !post.isFollowed);
      }
      return post;
    }).toList();

    state = state.copyWith(
      followingPosts: updatedFollowingPosts,
      recommendPosts: updatedRecommendPosts,
    );

    // 调用真实 API
    try {
      final post = state.followingPosts.firstWhere((p) => p.authorId == userId, 
          orElse: () => state.recommendPosts.firstWhere((p) => p.authorId == userId));
      
      if (post.isFollowed) {
        await CommunityApiService.followUser(userId);
      } else {
        await CommunityApiService.unfollowUser(userId);
      }
    } catch (e) {
      // 如果 API 调用失败，回滚 UI 状态
      final revertedFollowingPosts = state.followingPosts.map((post) {
        if (post.authorId == userId) {
          return post.copyWith(isFollowed: !post.isFollowed);
        }
        return post;
      }).toList();

      final revertedRecommendPosts = state.recommendPosts.map((post) {
        if (post.authorId == userId) {
          return post.copyWith(isFollowed: !post.isFollowed);
        }
        return post;
      }).toList();

      state = state.copyWith(
        followingPosts: revertedFollowingPosts,
        recommendPosts: revertedRecommendPosts,
        error: '关注操作失败: ${e.toString()}',
      );
    }
  }

  // 生成模拟数据的方法
  List<Topic> _generateMockTopics() {
    return [
      Topic(
        id: '1', 
        name: '健身', 
        description: '健身相关话题', 
        postCount: 1000,
        postsCount: 1000,
        followersCount: 500,
        isHot: true,
        isOfficial: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Topic(
        id: '2', 
        name: '减脂', 
        description: '减脂相关话题', 
        postCount: 800,
        postsCount: 800,
        followersCount: 400,
        isHot: true,
        isOfficial: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Topic(
        id: '3', 
        name: '增肌', 
        description: '增肌相关话题', 
        postCount: 600,
        postsCount: 600,
        followersCount: 300,
        isHot: false,
        isOfficial: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Topic(
        id: '4', 
        name: '瑜伽', 
        description: '瑜伽相关话题', 
        postCount: 400,
        postsCount: 400,
        followersCount: 200,
        isHot: false,
        isOfficial: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Topic(
        id: '5', 
        name: '跑步', 
        description: '跑步相关话题', 
        postCount: 500,
        postsCount: 500,
        followersCount: 250,
        isHot: false,
        isOfficial: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // 加载初始数据
  Future<void> loadInitialData() async {
    await _loadInitialData();
  }

  // 加载更多帖子
  Future<void> loadMorePosts() async {
    // TODO: 实现加载更多帖子
  }

  // 加载更多关注帖子
  Future<void> loadMoreFollowingPosts() async {
    // TODO: 实现加载更多关注帖子
  }

  // 加载更多推荐帖子
  Future<void> loadMoreRecommendPosts() async {
    // TODO: 实现加载更多推荐帖子
  }

  // 点赞帖子
  Future<void> likePost(String postId) async {
    await toggleLike(postId);
  }

  // 关注用户
  Future<void> followUser(String userId) async {
    await toggleFollow(userId);
  }

  // 参与挑战
  Future<void> joinChallenge(String challengeId) async {
    // TODO: 实现参与挑战
  }

  // 刷新帖子
  Future<void> refreshPosts() async {
    await refreshFollowingPosts();
  }
}