import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/models.dart';
import 'api_service.dart';

class CommunityApiService {
  final ApiService _apiService = ApiService();

  // 获取推荐流
  Future<ApiResponse<List<Post>>> getFeed({
    int page = 1,
    int limit = 10,
    String sortBy = 'hot',
  }) async {
    final response = await _apiService.get('/community/feed', queryParameters: {
      'page': page,
      'limit': limit,
      'sort': sortBy,
    });

    final posts = (response.data['data'] as List)
        .map((json) => Post.fromJson(json))
        .toList();

    return ApiResponse<List<Post>>(
      data: posts,
      pagination: response.data['pagination'],
    );
  }

  // 获取社区动态
  Future<ApiResponse<List<Post>>> getPosts({
    int page = 1,
    int limit = 10,
    String? type,
  }) async {
    final response = await _apiService.get('/community/posts', queryParameters: {
      'page': page,
      'limit': limit,
      if (type != null) 'type': type,
    });

    final posts = (response.data['data'] as List)
        .map((json) => Post.fromJson(json))
        .toList();

    return ApiResponse<List<Post>>(
      data: posts,
      pagination: response.data['pagination'],
    );
  }

  // 发布动态
  Future<Post> createPost({
    required String content,
    List<String>? images,
    String? videoUrl,
    String? type,
    List<String>? tags,
    String? location,
    String? workoutData,
    bool isPublic = true,
  }) async {
    final response = await _apiService.post('/community/posts', data: {
      'content': content,
      'images': images,
      'video_url': videoUrl,
      'type': type,
      'tags': tags,
      'location': location,
      'workout_data': workoutData,
      'is_public': isPublic,
    });

    return Post.fromJson(response.data['data']);
  }

  // 获取单个动态
  Future<Post> getPost(int id) async {
    final response = await _apiService.get('/community/posts/$id');
    return Post.fromJson(response.data['data']);
  }

  // 点赞/取消点赞动态
  Future<Map<String, dynamic>> likePost(int id) async {
    final response = await _apiService.post('/community/posts/$id/like');
    return response.data;
  }

  // 取消点赞
  Future<void> unlikePost(int id) async {
    await _apiService.delete('/community/posts/$id/like');
  }

  // 收藏/取消收藏动态
  Future<Map<String, dynamic>> favoritePost(int id) async {
    final response = await _apiService.post('/community/posts/$id/favorite');
    return response.data;
  }

  // 创建评论
  Future<Comment> createComment({
    required int postId,
    required String content,
    int? parentId,
    int? replyToUserId,
  }) async {
    final response = await _apiService.post('/community/posts/$postId/comment', data: {
      'content': content,
      'parent_id': parentId,
      'reply_to_user_id': replyToUserId,
    });

    return Comment.fromJson(response.data['data']);
  }

  // 获取评论列表
  Future<ApiResponse<List<Comment>>> getComments(int postId, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiService.get('/community/posts/$postId/comments', queryParameters: {
      'page': page,
      'limit': limit,
    });

    final comments = (response.data['data'] as List)
        .map((json) => Comment.fromJson(json))
        .toList();

    return ApiResponse<List<Comment>>(
      data: comments,
      pagination: response.data['pagination'],
    );
  }

  // 获取热门话题
  Future<List<Topic>> getHotTopics({int limit = 10}) async {
    final response = await _apiService.get('/community/topics/hot', queryParameters: {
      'limit': limit,
    });

    return (response.data['data'] as List)
        .map((json) => Topic.fromJson(json))
        .toList();
  }

  // 获取话题相关动态
  Future<ApiResponse<List<Post>>> getTopicPosts(String topicName, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiService.get('/community/topics/$topicName/posts', queryParameters: {
      'page': page,
      'limit': limit,
    });

    final posts = (response.data['data'] as List)
        .map((json) => Post.fromJson(json))
        .toList();

    return ApiResponse<List<Post>>(
      data: posts,
      pagination: response.data['pagination'],
    );
  }

  // 关注/取消关注用户
  Future<Map<String, dynamic>> followUser(int userId) async {
    final response = await _apiService.post('/community/follow/$userId');
    return response.data;
  }

  // 取消关注用户
  Future<void> unfollowUser(int userId) async {
    await _apiService.delete('/community/follow/$userId');
  }

  // 获取用户主页
  Future<Map<String, dynamic>> getUserProfile(int userId, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiService.get('/community/users/$userId', queryParameters: {
      'page': page,
      'limit': limit,
    });

    return response.data;
  }

  // 搜索功能
  Future<ApiResponse<dynamic>> search({
    required String query,
    String type = 'post', // post, user, topic
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiService.get('/community/search', queryParameters: {
      'q': query,
      'type': type,
      'page': page,
      'limit': limit,
    });

    dynamic data;
    switch (type) {
      case 'post':
        data = (response.data['data'] as List)
            .map((json) => Post.fromJson(json))
            .toList();
        break;
      case 'user':
        data = (response.data['data'] as List)
            .map((json) => User.fromJson(json))
            .toList();
        break;
      case 'topic':
        data = (response.data['data'] as List)
            .map((json) => Topic.fromJson(json))
            .toList();
        break;
    }

    return ApiResponse<dynamic>(
      data: data,
      pagination: response.data['pagination'],
    );
  }

  // 挑战赛相关API

  // 获取挑战赛列表
  Future<ApiResponse<List<Challenge>>> getChallenges({
    int page = 1,
    int limit = 10,
    String? difficulty,
    String? type,
    String status = 'active',
  }) async {
    final response = await _apiService.get('/community/challenges', queryParameters: {
      'page': page,
      'limit': limit,
      if (difficulty != null) 'difficulty': difficulty,
      if (type != null) 'type': type,
      'status': status,
    });

    final challenges = (response.data['data'] as List)
        .map((json) => Challenge.fromJson(json))
        .toList();

    return ApiResponse<List<Challenge>>(
      data: challenges,
      pagination: response.data['pagination'],
    );
  }

  // 获取挑战赛详情
  Future<Map<String, dynamic>> getChallenge(int id) async {
    final response = await _apiService.get('/community/challenges/$id');
    return response.data;
  }

  // 参与挑战赛
  Future<ChallengeParticipant> joinChallenge(int challengeId) async {
    final response = await _apiService.post('/community/challenges/$challengeId/join');
    return ChallengeParticipant.fromJson(response.data['data']);
  }

  // 退出挑战赛
  Future<void> leaveChallenge(int challengeId) async {
    await _apiService.delete('/community/challenges/$challengeId/leave');
  }

  // 挑战赛打卡
  Future<ChallengeCheckin> checkinChallenge({
    required int challengeId,
    String? content,
    List<String>? images,
    int calories = 0,
    int duration = 0,
    String? notes,
  }) async {
    final response = await _apiService.post('/community/challenges/$challengeId/checkin', data: {
      'content': content,
      'images': images,
      'calories': calories,
      'duration': duration,
      'notes': notes,
    });

    return ChallengeCheckin.fromJson(response.data['data']);
  }

  // 获取挑战赛排行榜
  Future<List<ChallengeParticipant>> getChallengeLeaderboard(int challengeId, {
    int limit = 20,
  }) async {
    final response = await _apiService.get('/community/challenges/$challengeId/leaderboard', queryParameters: {
      'limit': limit,
    });

    return (response.data['data'] as List)
        .map((json) => ChallengeParticipant.fromJson(json))
        .toList();
  }

  // 获取挑战赛打卡记录
  Future<ApiResponse<List<ChallengeCheckin>>> getChallengeCheckins(int challengeId, {
    int? userId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiService.get('/community/challenges/$challengeId/checkins', queryParameters: {
      if (userId != null) 'user_id': userId,
      'page': page,
      'limit': limit,
    });

    final checkins = (response.data['data'] as List)
        .map((json) => ChallengeCheckin.fromJson(json))
        .toList();

    return ApiResponse<List<ChallengeCheckin>>(
      data: checkins,
      pagination: response.data['pagination'],
    );
  }

  // 获取用户参与的挑战赛
  Future<ApiResponse<List<ChallengeParticipant>>> getUserChallenges({
    int page = 1,
    int limit = 10,
    String status = 'active',
  }) async {
    final response = await _apiService.get('/community/user/challenges', queryParameters: {
      'page': page,
      'limit': limit,
      'status': status,
    });

    final participants = (response.data['data'] as List)
        .map((json) => ChallengeParticipant.fromJson(json))
        .toList();

    return ApiResponse<List<ChallengeParticipant>>(
      data: participants,
      pagination: response.data['pagination'],
    );
  }

  // 创建挑战赛（管理员功能）
  Future<Challenge> createChallenge({
    required String name,
    String? description,
    required String type,
    required String difficulty,
    required DateTime startDate,
    required DateTime endDate,
    String? coverImage,
    String? rules,
    String? rewards,
    List<String>? tags,
    int? maxParticipants,
    double entryFee = 0.0,
  }) async {
    final response = await _apiService.post('/community/challenges', data: {
      'name': name,
      'description': description,
      'type': type,
      'difficulty': difficulty,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'cover_image': coverImage,
      'rules': rules,
      'rewards': rewards,
      'tags': tags,
      'max_participants': maxParticipants,
      'entry_fee': entryFee,
    });

    return Challenge.fromJson(response.data['data']);
  }
}
