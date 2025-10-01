import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/models/models.dart';

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
      // TODO: 从API加载关注流数据
      await Future.delayed(const Duration(seconds: 1));
      
      final posts = _generateMockFollowingPosts();
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
      // TODO: 从API加载推荐流数据
      await Future.delayed(const Duration(seconds: 1));
      
      final posts = _generateMockRecommendPosts();
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

  Future<void> refreshPosts() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // TODO: 从API加载通用帖子数据
      await Future.delayed(const Duration(seconds: 1));
      
      final posts = _generateMockRecommendPosts();
      state = state.copyWith(
        isLoading: false,
        posts: posts,
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
    // 更新关注流
    final updatedFollowingPosts = state.followingPosts.map((post) {
      if (post.id == postId) {
        return post.copyWith(
          isLiked: !post.isLiked,
          likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
      }
      return post;
    }).toList();

    // 更新推荐流
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

    // TODO: 调用API更新点赞状态
  }

  Future<void> toggleFollow(String userId) async {
    // 更新关注流
    final updatedFollowingPosts = state.followingPosts.map((post) {
      if (post.authorId == userId) {
        return post.copyWith(isFollowed: !post.isFollowed);
      }
      return post;
    }).toList();

    // 更新推荐流
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

    // TODO: 调用API更新关注状态
  }

  List<Post> _generateMockFollowingPosts() {
    return List.generate(10, (index) {
      return Post(
        id: 'following_$index',
        userId: 'user_$index',
        content: '今天完成了${index + 1}组训练，感觉棒极了！💪',
        isPublic: true,
        isFeatured: false,
        viewCount: 100 + index * 10,
        shareCount: index,
        likesCount: 10 + index * 5,
        commentsCount: 3 + index,
        sharesCount: index,
        createdAt: DateTime.now().subtract(Duration(hours: index)),
        updatedAt: DateTime.now().subtract(Duration(hours: index)),
        type: PostType.text.name,
        images: index % 3 == 0 ? ['https://via.placeholder.com/300'] : [],
        tags: ['健身', '训练', '打卡'],
        likeCount: 10 + index * 5,
        commentCount: 3 + index,
        isLiked: index % 2 == 0,
        isFollowed: true,
        authorId: 'user_$index',
        authorName: '健身达人${index + 1}',
        authorAvatar: 'https://via.placeholder.com/40',
        workoutData: index % 4 == 0 ? WorkoutData(
          name: '胸肌训练',
          exerciseName: '胸肌训练',
          duration: 45,
          calories: 300,
          exercises: ['平板卧推', '上斜卧推', '飞鸟'],
        ) : null,
      );
    });
  }

  List<Post> _generateMockRecommendPosts() {
    return List.generate(15, (index) {
      return Post(
        id: 'recommend_$index',
        userId: 'user_${index + 10}',
        content: '分享一个超有效的训练动作！🔥',
        isPublic: true,
        isFeatured: false,
        viewCount: 200 + index * 15,
        shareCount: index + 1,
        likesCount: 20 + index * 3,
        commentsCount: 5 + index,
        sharesCount: index + 1,
        createdAt: DateTime.now().subtract(Duration(hours: index + 2)),
        updatedAt: DateTime.now().subtract(Duration(hours: index + 2)),
        type: PostType.image.name,
        images: ['https://via.placeholder.com/300'],
        tags: ['推荐', '训练', '技巧'],
        likeCount: 20 + index * 3,
        commentCount: 5 + index,
        isLiked: index % 3 == 0,
        isFollowed: false,
        authorId: 'user_${index + 10}',
        authorName: '推荐用户${index + 1}',
        authorAvatar: 'https://via.placeholder.com/40',
      );
    });
  }

  List<Topic> _generateMockTopics() {
    return [
      Topic(
        id: '1',
        name: '减脂训练',
        description: '分享减脂训练心得',
        postsCount: 1250,
        postCount: 1250,
        followersCount: 500,
        isHot: true,
        isOfficial: false,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        updatedAt: DateTime.now().subtract(Duration(days: 1)),
        trend: 15.5,
      ),
      Topic(
        id: '2',
        name: '增肌计划',
        description: '增肌训练计划分享',
        postsCount: 980,
        postCount: 980,
        followersCount: 300,
        isHot: true,
        isOfficial: false,
        createdAt: DateTime.now().subtract(Duration(days: 25)),
        updatedAt: DateTime.now().subtract(Duration(days: 2)),
        trend: 12.3,
      ),
      Topic(
        id: '3',
        name: '瑜伽练习',
        description: '瑜伽练习技巧',
        postsCount: 756,
        postCount: 756,
        followersCount: 200,
        isHot: false,
        isOfficial: true,
        createdAt: DateTime.now().subtract(Duration(days: 20)),
        updatedAt: DateTime.now().subtract(Duration(days: 3)),
        trend: 8.7,
      ),
    ];
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true);
    // TODO: 实现数据加载
  }

  Future<void> loadMorePosts() async {
    // TODO: 实现加载更多帖子
  }

  Future<void> loadMoreFollowingPosts() async {
    // TODO: 实现加载更多关注帖子
  }

  Future<void> loadMoreRecommendPosts() async {
    // TODO: 实现加载更多推荐帖子
  }

  Future<void> likePost(String postId) async {
    // TODO: 实现点赞帖子
  }

  Future<void> followUser(String userId) async {
    // TODO: 实现关注用户
  }

  Future<void> joinChallenge(String challengeId) async {
    // TODO: 实现加入挑战
  }
}
