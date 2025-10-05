import 'dart:convert';

class User {
  final String id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final String? bio;
  final String? fitnessTags;
  final String? fitnessGoal;
  final String? location;
  final bool isVerified;
  final int followersCount;
  final int followingCount;
  final int totalWorkouts;
  final int totalCheckins;
  final int currentStreak;
  final int longestStreak;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Additional fields for UI compatibility
  final String? nickname;
  final bool isOnline;
  final int likesCount;
  final int trainingDays;
  final int level;
  final int points;
  final DateTime? lastLoginAt;
  final int totalTrainingMinutes;
  final int completedWorkouts;
  final int achievementsCount;
  
  // Additional fields from backend
  final double? height;
  final double? weight;
  final double? bmi;
  final String? gender;
  final DateTime? birthday;
  final int followerCount;
  final int postCount;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatar,
    this.bio,
    this.fitnessTags,
    this.fitnessGoal,
    this.location,
    required this.isVerified,
    required this.followersCount,
    required this.followingCount,
    required this.totalWorkouts,
    required this.totalCheckins,
    required this.currentStreak,
    required this.longestStreak,
    required this.createdAt,
    required this.updatedAt,
    this.nickname,
    this.isOnline = false,
    this.likesCount = 0,
    this.trainingDays = 0,
    this.level = 1,
    this.points = 0,
    this.lastLoginAt,
    this.totalTrainingMinutes = 0,
    this.completedWorkouts = 0,
    this.achievementsCount = 0,
    this.height,
    this.weight,
    this.bmi,
    this.gender,
    this.birthday,
    this.followerCount = 0,
    this.postCount = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      avatar: json['avatar'],
      bio: json['bio'],
      fitnessTags: json['fitness_tags'],
      fitnessGoal: json['fitness_goal'],
      location: json['location'],
      isVerified: json['is_verified'] ?? false,
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      totalWorkouts: json['total_workouts'] ?? 0,
      totalCheckins: json['total_checkins'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      nickname: json['nickname'] ?? json['username'],
      isOnline: json['is_online'] ?? false,
      likesCount: json['likes_count'] ?? 0,
      trainingDays: json['training_days'] ?? 0,
      level: json['level'] ?? 1,
      points: json['points'] ?? 0,
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at'])
          : null,
      totalTrainingMinutes: json['total_training_minutes'] ?? 0,
      completedWorkouts: json['completed_workouts'] ?? 0,
      achievementsCount: json['achievements_count'] ?? 0,
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      bmi: json['bmi']?.toDouble(),
      gender: json['gender'],
      birthday: json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      followerCount: json['follower_count'] ?? 0,
      postCount: json['post_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
      'bio': bio,
      'fitness_tags': fitnessTags,
      'fitness_goal': fitnessGoal,
      'location': location,
      'is_verified': isVerified,
      'followers_count': followersCount,
      'following_count': followingCount,
      'total_workouts': totalWorkouts,
      'total_checkins': totalCheckins,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nickname': nickname,
      'is_online': isOnline,
      'likes_count': likesCount,
      'training_days': trainingDays,
      'level': level,
      'points': points,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'total_training_minutes': totalTrainingMinutes,
      'completed_workouts': completedWorkouts,
      'achievements_count': achievementsCount,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'gender': gender,
      'birthday': birthday?.toIso8601String(),
      'follower_count': followerCount,
      'post_count': postCount,
    };
  }
}

class AuthResponse {
  final String token;
  final User user;
  final DateTime expiresAt;

  AuthResponse({
    required this.token,
    required this.user,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: User.fromJson(json['user']),
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }
}

class Workout {
  final String id;
  final String userId;
  final String? planId;
  final String name;
  final String type;
  final int duration;
  final int calories;
  final String difficulty;
  final String? notes;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  Workout({
    required this.id,
    required this.userId,
    this.planId,
    required this.name,
    required this.type,
    required this.duration,
    required this.calories,
    required this.difficulty,
    this.notes,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      userId: json['user_id'],
      planId: json['plan_id'],
      name: json['name'],
      type: json['type'],
      duration: json['duration'] ?? 0,
      calories: json['calories'] ?? 0,
      difficulty: json['difficulty'] ?? '',
      notes: json['notes'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class TrainingPlan {
  final String id;
  final String name;
  final String? description;
  final String type;
  final String difficulty;
  final int duration;
  final bool isPublic;
  final bool isAi;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final int completedWorkouts;
  
  // Additional fields for UI compatibility
  final List<Exercise>? exercises;
  final int? calories;
  final DateTime? date;

  TrainingPlan({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.difficulty,
    required this.duration,
    required this.isPublic,
    required this.isAi,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'active',
    this.completedWorkouts = 0,
    this.exercises,
    this.calories,
    this.date,
  });

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    return TrainingPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      difficulty: json['difficulty'],
      duration: json['duration'] ?? 0,
      isPublic: json['is_public'] ?? false,
      isAi: json['is_ai'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      status: json['status'] ?? 'active',
      completedWorkouts: json['completed_workouts'] ?? 0,
      exercises: json['exercises'] != null 
          ? (json['exercises'] as List).map((exercise) => Exercise.fromJson(exercise)).toList()
          : null,
      calories: json['calories'],
      date: json['date'] != null 
          ? DateTime.parse(json['date'])
          : null,
    );
  }

  TrainingPlan copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? difficulty,
    int? duration,
    bool? isPublic,
    bool? isAi,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    int? completedWorkouts,
    List<Exercise>? exercises,
    int? calories,
    DateTime? date,
  }) {
    return TrainingPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      isPublic: isPublic ?? this.isPublic,
      isAi: isAi ?? this.isAi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      completedWorkouts: completedWorkouts ?? this.completedWorkouts,
      exercises: exercises ?? this.exercises,
      calories: calories ?? this.calories,
      date: date ?? this.date,
    );
  }
}

class Exercise {
  final String id;
  final String name;
  final String? description;
  final String? category;
  final String? muscleGroups;
  final String? equipment;
  final String? difficulty;
  final String? instructions;
  final String? videoUrl;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Map<String, dynamic>>? sets;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.muscleGroups,
    this.equipment,
    this.difficulty,
    this.instructions,
    this.videoUrl,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.sets,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      muscleGroups: json['muscle_groups'],
      equipment: json['equipment'],
      difficulty: json['difficulty'],
      instructions: json['instructions'],
      videoUrl: json['video_url'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      sets: json['sets'] != null 
          ? List<Map<String, dynamic>>.from(json['sets'])
          : null,
    );
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? muscleGroups,
    String? equipment,
    String? difficulty,
    String? instructions,
    String? videoUrl,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? sets,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      equipment: equipment ?? this.equipment,
      difficulty: difficulty ?? this.difficulty,
      instructions: instructions ?? this.instructions,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sets: sets ?? this.sets,
    );
  }
}

class Checkin {
  final String id;
  final String userId;
  final DateTime date;
  final String type;
  final String? notes;
  final String? mood;
  final int energy;
  final int motivation;
  final DateTime createdAt;
  final DateTime updatedAt;

  Checkin({
    required this.id,
    required this.userId,
    required this.date,
    required this.type,
    this.notes,
    this.mood,
    required this.energy,
    required this.motivation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Checkin.fromJson(Map<String, dynamic> json) {
    return Checkin(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      notes: json['notes'],
      mood: json['mood'],
      energy: json['energy'] ?? 0,
      motivation: json['motivation'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

enum MediaType {
  image,
  video,
  audio,
  file,
}

class MediaItem {
  final String id;
  final String url;
  final MediaType type;
  final int? duration;
  final String? thumbnail;

  MediaItem({
    required this.id,
    required this.url,
    required this.type,
    this.duration,
    this.thumbnail,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'],
      url: json['url'],
      type: MediaType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MediaType.image,
      ),
      duration: json['duration'],
      thumbnail: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'type': type.name,
      'duration': duration,
      'thumbnail': thumbnail,
    };
  }
}

class CheckInData {
  final String id;
  final String userId;
  final String? location;
  final String? description;
  final String? mood;
  final DateTime checkInTime;
  final DateTime createdAt;

  CheckInData({
    required this.id,
    required this.userId,
    this.location,
    this.description,
    this.mood,
    required this.checkInTime,
    required this.createdAt,
  });

  factory CheckInData.fromJson(Map<String, dynamic> json) {
    return CheckInData(
      id: json['id'],
      userId: json['user_id'],
      location: json['location'],
      description: json['description'],
      mood: json['mood'],
      checkInTime: DateTime.parse(json['check_in_time']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'location': location,
      'description': description,
      'mood': mood,
      'check_in_time': checkInTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Post {
  final String id;
  final String userId;
  final String content;
  final List<String>? images;
  final String? videoUrl;
  final String? type;
  final bool isPublic;
  final List<String>? tags;
  final String? location;
  final dynamic workoutData;
  final bool isFeatured;
  final int viewCount;
  final int shareCount;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final User? user;
  final List<Topic>? topics;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Additional fields for UI compatibility
  final String? userName;
  final String? userAvatar;
  final bool isLiked;
  final bool isFollowing;
  final List<Comment>? comments;
  final String? authorId;
  final String? authorName;
  final String? authorAvatar;
  final int likeCount;
  final int commentCount;
  final bool isFollowed;
  final List<MediaItem>? media;
  final CheckInData? checkInData;
  final bool isFavorited;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    this.images,
    this.videoUrl,
    this.type,
    required this.isPublic,
    this.tags,
    this.location,
    this.workoutData,
    required this.isFeatured,
    required this.viewCount,
    required this.shareCount,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    this.user,
    this.topics,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userAvatar,
    this.isLiked = false,
    this.isFollowing = false,
    this.comments,
    this.authorId,
    this.authorName,
    this.authorAvatar,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isFollowed = false,
    this.media,
    this.checkInData,
    this.isFavorited = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      images: json['images'] != null 
          ? (json['images'] is List 
              ? List<String>.from(json['images'])
              : [json['images'].toString()])
          : null,
      videoUrl: json['video_url'],
      type: json['type']?.toString(),
      isPublic: json['is_public'] ?? true,
      tags: json['tags'] != null 
          ? (json['tags'] is List 
              ? List<String>.from(json['tags'])
              : [json['tags'].toString()])
          : null,
      location: json['location'],
      workoutData: json['workout_data'],
      isFeatured: json['is_featured'] ?? false,
      viewCount: json['view_count'] ?? 0,
      shareCount: json['share_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      topics: json['topics'] != null 
          ? (json['topics'] as List).map((topic) => Topic.fromJson(topic)).toList()
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userName: json['user_name'] ?? json['user']?['username'],
      userAvatar: json['user_avatar'] ?? json['user']?['avatar'],
      isLiked: json['is_liked'] ?? false,
      isFollowing: json['is_following'] ?? false,
      comments: json['comments'] != null 
          ? (json['comments'] as List).map((comment) => Comment.fromJson(comment)).toList()
          : null,
      authorId: json['author_id'] ?? json['user_id'],
      authorName: json['author_name'] ?? json['user_name'] ?? json['user']?['username'],
      authorAvatar: json['author_avatar'] ?? json['user_avatar'] ?? json['user']?['avatar'],
      likeCount: json['like_count'] ?? json['likes_count'] ?? 0,
      commentCount: json['comment_count'] ?? json['comments_count'] ?? 0,
      isFollowed: json['is_followed'] ?? false,
      media: json['media'] != null 
          ? (json['media'] as List).map((media) => MediaItem.fromJson(media)).toList()
          : null,
      checkInData: json['check_in_data'] != null 
          ? CheckInData.fromJson(json['check_in_data'])
          : null,
      isFavorited: json['is_favorited'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'images': images,
      'video_url': videoUrl,
      'type': type,
      'is_public': isPublic,
      'tags': tags,
      'location': location,
      'workout_data': workoutData,
      'is_featured': isFeatured,
      'view_count': viewCount,
      'share_count': shareCount,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'user': user?.toJson(),
      'topics': topics?.map((topic) => topic.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_name': userName,
      'user_avatar': userAvatar,
      'is_liked': isLiked,
      'is_following': isFollowing,
      'comments': comments?.map((comment) => comment.toJson()).toList(),
      'author_id': authorId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_followed': isFollowed,
      'media': media?.map((media) => media.toJson()).toList(),
      'check_in_data': checkInData?.toJson(),
      'is_favorited': isFavorited,
    };
  }

  // copyWith method for immutable updates
  Post copyWith({
    String? id,
    String? userId,
    String? content,
    List<String>? images,
    String? videoUrl,
    String? type,
    bool? isPublic,
    List<String>? tags,
    String? location,
    dynamic workoutData,
    bool? isFeatured,
    int? viewCount,
    int? shareCount,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    User? user,
    List<Topic>? topics,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userAvatar,
    bool? isLiked,
    bool? isFollowing,
    List<Comment>? comments,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    int? likeCount,
    int? commentCount,
    bool? isFollowed,
    List<MediaItem>? media,
    CheckInData? checkInData,
    bool? isFavorited,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      type: type ?? this.type,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      workoutData: workoutData ?? this.workoutData,
      isFeatured: isFeatured ?? this.isFeatured,
      viewCount: viewCount ?? this.viewCount,
      shareCount: shareCount ?? this.shareCount,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      user: user ?? this.user,
      topics: topics ?? this.topics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      isLiked: isLiked ?? this.isLiked,
      isFollowing: isFollowing ?? this.isFollowing,
      comments: comments ?? this.comments,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isFollowed: isFollowed ?? this.isFollowed,
      media: media ?? this.media,
      checkInData: checkInData ?? this.checkInData,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }

  // Getters for convenience
  List<String> get imageList => images ?? [];
  List<String> get tagList => tags ?? [];
}

class Challenge {
  final String id;
  final String name;
  final String description;
  final String type;
  final String difficulty;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int participantsCount;
  final String? coverImage;
  final String? rules;
  final String? rewards;
  final String? tags;
  final bool isFeatured;
  final int? maxParticipants;
  final double? entryFee;
  final DateTime createdAt;
  final DateTime updatedAt;

  Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.participantsCount,
    this.coverImage,
    this.rules,
    this.rewards,
    this.tags,
    this.isFeatured = false,
    this.maxParticipants,
    this.entryFee,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      difficulty: json['difficulty'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isActive: json['is_active'] ?? false,
      participantsCount: json['participants_count'] ?? 0,
      coverImage: json['cover_image'],
      rules: json['rules'],
      rewards: json['rewards'],
      tags: json['tags'],
      isFeatured: json['is_featured'] ?? false,
      maxParticipants: json['max_participants'],
      entryFee: json['entry_fee']?.toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'difficulty': difficulty,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'participants_count': participantsCount,
      'cover_image': coverImage,
      'rules': rules,
      'rewards': rewards,
      'tags': tags,
      'is_featured': isFeatured,
      'max_participants': maxParticipants,
      'entry_fee': entryFee,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class BMICalculation {
  final double bmi;
  final String category;
  final IdealWeight idealWeight;
  final double bodyFat;
  final double bmr;
  final double tdee;

  BMICalculation({
    required this.bmi,
    required this.category,
    required this.idealWeight,
    required this.bodyFat,
    required this.bmr,
    required this.tdee,
  });

  factory BMICalculation.fromJson(Map<String, dynamic> json) {
    return BMICalculation(
      bmi: (json['bmi'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
      idealWeight: IdealWeight.fromJson(json['ideal_weight']),
      bodyFat: (json['body_fat'] ?? 0.0).toDouble(),
      bmr: (json['bmr'] ?? 0.0).toDouble(),
      tdee: (json['tdee'] ?? 0.0).toDouble(),
    );
  }
}

class IdealWeight {
  final double min;
  final double max;

  IdealWeight({
    required this.min,
    required this.max,
  });

  factory IdealWeight.fromJson(Map<String, dynamic> json) {
    return IdealWeight(
      min: (json['min'] ?? 0.0).toDouble(),
      max: (json['max'] ?? 0.0).toDouble(),
    );
  }
}

class NutritionRecord {
  final int id;
  final int userId;
  final DateTime date;
  final String mealType;
  final String foodName;
  final double quantity;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  NutritionRecord({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.foodName,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NutritionRecord.fromJson(Map<String, dynamic> json) {
    return NutritionRecord(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      mealType: json['meal_type'],
      foodName: json['food_name'],
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? '',
      calories: (json['calories'] ?? 0.0).toDouble(),
      protein: (json['protein'] ?? 0.0).toDouble(),
      carbs: (json['carbs'] ?? 0.0).toDouble(),
      fat: (json['fat'] ?? 0.0).toDouble(),
      fiber: (json['fiber'] ?? 0.0).toDouble(),
      sugar: (json['sugar'] ?? 0.0).toDouble(),
      sodium: (json['sodium'] ?? 0.0).toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class ApiResponse<T> {
  final String? message;
  final T? data;
  final Map<String, dynamic>? pagination;

  ApiResponse({
    this.message,
    this.data,
    this.pagination,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      pagination: json['pagination'],
    );
  }
}

// 社区相关模型

class Topic {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final int postsCount;
  final int postCount;
  final int followersCount;
  final bool isHot;
  final bool isOfficial;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? trend;

  Topic({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    required this.postsCount,
    required this.postCount,
    required this.followersCount,
    required this.isHot,
    required this.isOfficial,
    required this.createdAt,
    required this.updatedAt,
    this.trend,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      postsCount: json['posts_count'] ?? 0,
      postCount: json['post_count'] ?? json['posts_count'] ?? 0,
      followersCount: json['followers_count'] ?? 0,
      isHot: json['is_hot'] ?? false,
      isOfficial: json['is_official'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      trend: json['trend']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'posts_count': postsCount,
      'followers_count': followersCount,
      'is_hot': isHot,
      'is_official': isOfficial,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Comment {
  final String id;
  final String userId;
  final String postId;
  final String content;
  final String? parentId;
  final String? replyToUserId;
  final int likesCount;
  final int repliesCount;
  final User? user;
  final User? replyToUser;
  final List<Comment>? replies;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Additional fields for UI compatibility
  final String? userName;
  final String? userAvatar;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.content,
    this.parentId,
    this.replyToUserId,
    required this.likesCount,
    required this.repliesCount,
    this.user,
    this.replyToUser,
    this.replies,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userAvatar,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'],
      postId: json['post_id'],
      content: json['content'],
      parentId: json['parent_id'],
      replyToUserId: json['reply_to_user_id'],
      likesCount: json['likes_count'] ?? 0,
      repliesCount: json['replies_count'] ?? 0,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      replyToUser: json['reply_to_user'] != null ? User.fromJson(json['reply_to_user']) : null,
      replies: json['replies'] != null 
          ? (json['replies'] as List).map((reply) => Comment.fromJson(reply)).toList()
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userName: json['user_name'] ?? json['user']?['username'],
      userAvatar: json['user_avatar'] ?? json['user']?['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'content': content,
      'parent_id': parentId,
      'reply_to_user_id': replyToUserId,
      'likes_count': likesCount,
      'replies_count': repliesCount,
      'user': user?.toJson(),
      'reply_to_user': replyToUser?.toJson(),
      'replies': replies?.map((reply) => reply.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ChallengeParticipant {
  final int id;
  final int userId;
  final int challengeId;
  final int progress;
  final DateTime joinedAt;
  final DateTime? lastCheckinAt;
  final int checkinCount;
  final int totalCalories;
  final String status;
  final int? rank;
  final User? user;
  final Challenge? challenge;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChallengeParticipant({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.progress,
    required this.joinedAt,
    this.lastCheckinAt,
    required this.checkinCount,
    required this.totalCalories,
    required this.status,
    this.rank,
    this.user,
    this.challenge,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChallengeParticipant.fromJson(Map<String, dynamic> json) {
    return ChallengeParticipant(
      id: json['id'],
      userId: json['user_id'],
      challengeId: json['challenge_id'],
      progress: json['progress'] ?? 0,
      joinedAt: DateTime.parse(json['joined_at']),
      lastCheckinAt: json['last_checkin_at'] != null 
          ? DateTime.parse(json['last_checkin_at']) 
          : null,
      checkinCount: json['checkin_count'] ?? 0,
      totalCalories: json['total_calories'] ?? 0,
      status: json['status'] ?? 'active',
      rank: json['rank'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      challenge: json['challenge'] != null ? Challenge.fromJson(json['challenge']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'challenge_id': challengeId,
      'progress': progress,
      'joined_at': joinedAt.toIso8601String(),
      'last_checkin_at': lastCheckinAt?.toIso8601String(),
      'checkin_count': checkinCount,
      'total_calories': totalCalories,
      'status': status,
      'rank': rank,
      'user': user?.toJson(),
      'challenge': challenge?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ChallengeCheckin {
  final int id;
  final int userId;
  final int challengeId;
  final int participantId;
  final DateTime checkinDate;
  final String? content;
  final String? images;
  final int calories;
  final int duration;
  final String? notes;
  final User? user;
  final Challenge? challenge;
  final ChallengeParticipant? participant;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChallengeCheckin({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.participantId,
    required this.checkinDate,
    this.content,
    this.images,
    required this.calories,
    required this.duration,
    this.notes,
    this.user,
    this.challenge,
    this.participant,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChallengeCheckin.fromJson(Map<String, dynamic> json) {
    return ChallengeCheckin(
      id: json['id'],
      userId: json['user_id'],
      challengeId: json['challenge_id'],
      participantId: json['participant_id'],
      checkinDate: DateTime.parse(json['checkin_date']),
      content: json['content'],
      images: json['images'],
      calories: json['calories'] ?? 0,
      duration: json['duration'] ?? 0,
      notes: json['notes'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      challenge: json['challenge'] != null ? Challenge.fromJson(json['challenge']) : null,
      participant: json['participant'] != null ? ChallengeParticipant.fromJson(json['participant']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'challenge_id': challengeId,
      'participant_id': participantId,
      'checkin_date': checkinDate.toIso8601String(),
      'content': content,
      'images': images,
      'calories': calories,
      'duration': duration,
      'notes': notes,
      'user': user?.toJson(),
      'challenge': challenge?.toJson(),
      'participant': participant?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // 获取图片列表
  List<String> get imageList {
    if (images == null || images!.isEmpty) return [];
    try {
      return List<String>.from(jsonDecode(images!));
    } catch (e) {
      return [];
    }
  }
}

class NutritionPlan {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final List<NutritionMeal>? meals;
  final DateTime createdAt;
  final DateTime updatedAt;

  NutritionPlan({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    this.meals,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NutritionPlan.fromJson(Map<String, dynamic> json) {
    return NutritionPlan(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      targetCalories: json['target_calories'] ?? 0,
      targetProtein: json['target_protein'] ?? 0,
      targetCarbs: json['target_carbs'] ?? 0,
      targetFat: json['target_fat'] ?? 0,
      meals: json['meals'] != null 
          ? (json['meals'] as List).map((meal) => NutritionMeal.fromJson(meal)).toList()
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'target_calories': targetCalories,
      'target_protein': targetProtein,
      'target_carbs': targetCarbs,
      'target_fat': targetFat,
      'meals': meals?.map((meal) => meal.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class NutritionMeal {
  final String id;
  final String nutritionPlanId;
  final String name;
  final String mealType;
  final List<NutritionFood>? foods;
  final DateTime createdAt;
  final DateTime updatedAt;

  NutritionMeal({
    required this.id,
    required this.nutritionPlanId,
    required this.name,
    required this.mealType,
    this.foods,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NutritionMeal.fromJson(Map<String, dynamic> json) {
    return NutritionMeal(
      id: json['id'],
      nutritionPlanId: json['nutrition_plan_id'],
      name: json['name'],
      mealType: json['meal_type'],
      foods: json['foods'] != null 
          ? (json['foods'] as List).map((food) => NutritionFood.fromJson(food)).toList()
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nutrition_plan_id': nutritionPlanId,
      'name': name,
      'meal_type': mealType,
      'foods': foods?.map((food) => food.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class NutritionFood {
  final String id;
  final String nutritionMealId;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final double quantity;
  final String unit;
  final DateTime createdAt;
  final DateTime updatedAt;

  NutritionFood({
    required this.id,
    required this.nutritionMealId,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.quantity,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NutritionFood.fromJson(Map<String, dynamic> json) {
    return NutritionFood(
      id: json['id'],
      nutritionMealId: json['nutrition_meal_id'],
      name: json['name'],
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fat: json['fat'] ?? 0,
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'g',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nutrition_meal_id': nutritionMealId,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'quantity': quantity,
      'unit': unit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Setting {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? route;
  final String category;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 新增字段
  final String? title;
  final String? subtitle;
  final String? type;
  final bool? switchValue;
  final String? badge;
  final String? badgeColor;
  final String? value;
  final String? color;

  Setting({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.route,
    required this.category,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
    this.title,
    this.subtitle,
    this.type,
    this.switchValue,
    this.badge,
    this.badgeColor,
    this.value,
    this.color,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      route: json['route'],
      category: json['category'],
      isEnabled: json['is_enabled'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      title: json['title'],
      subtitle: json['subtitle'],
      type: json['type'],
      switchValue: json['switch_value'],
      badge: json['badge'],
      badgeColor: json['badge_color'],
      value: json['value'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'route': route,
      'category': category,
      'is_enabled': isEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'title': title,
      'subtitle': subtitle,
      'type': type,
      'switch_value': switchValue,
      'badge': badge,
      'badge_color': badgeColor,
      'value': value,
      'color': color,
    };
  }

  Setting copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? route,
    String? category,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? subtitle,
    String? type,
    bool? switchValue,
    String? badge,
    String? badgeColor,
    String? value,
    String? color,
  }) {
    return Setting(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      category: category ?? this.category,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      type: type ?? this.type,
      switchValue: switchValue ?? this.switchValue,
      badge: badge ?? this.badge,
      badgeColor: badgeColor ?? this.badgeColor,
      value: value ?? this.value,
      color: color ?? this.color,
    );
  }
}

class UserStats {
  final int totalWorkouts;
  final int totalMinutes;
  final int totalCaloriesBurned;
  final int currentStreak;
  final int maxStreak;
  final int averageWorkoutDuration;
  final double workoutFrequency;
  final int maxWeightLifted;
  final double totalDistanceCovered;
  final int weeklyWorkouts;
  final int weeklyMinutes;
  final int weeklyCalories;
  final int monthlyWorkouts;
  final int monthlyMinutes;
  final int monthlyCalories;
  final int totalTrainingMinutes;
  final int completedWorkouts;
  final WeeklyGoal? weeklyGoal;

  UserStats({
    this.totalWorkouts = 0,
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
    this.monthlyCalories = 0,
    this.totalTrainingMinutes = 0,
    this.completedWorkouts = 0,
    this.weeklyGoal,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalWorkouts: json['total_workouts'] ?? 0,
      totalMinutes: json['total_minutes'] ?? 0,
      totalCaloriesBurned: json['total_calories_burned'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      maxStreak: json['max_streak'] ?? 0,
      averageWorkoutDuration: json['average_workout_duration'] ?? 0,
      workoutFrequency: (json['workout_frequency'] ?? 0.0).toDouble(),
      maxWeightLifted: json['max_weight_lifted'] ?? 0,
      totalDistanceCovered: (json['total_distance_covered'] ?? 0.0).toDouble(),
      weeklyWorkouts: json['weekly_workouts'] ?? 0,
      weeklyMinutes: json['weekly_minutes'] ?? 0,
      weeklyCalories: json['weekly_calories'] ?? 0,
      monthlyWorkouts: json['monthly_workouts'] ?? 0,
      monthlyMinutes: json['monthly_minutes'] ?? 0,
      monthlyCalories: json['monthly_calories'] ?? 0,
      totalTrainingMinutes: json['total_training_minutes'] ?? 0,
      completedWorkouts: json['completed_workouts'] ?? 0,
      weeklyGoal: json['weekly_goal'] != null 
          ? WeeklyGoal.fromJson(json['weekly_goal'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_workouts': totalWorkouts,
      'total_minutes': totalMinutes,
      'total_calories_burned': totalCaloriesBurned,
      'current_streak': currentStreak,
      'max_streak': maxStreak,
      'average_workout_duration': averageWorkoutDuration,
      'workout_frequency': workoutFrequency,
      'max_weight_lifted': maxWeightLifted,
      'total_distance_covered': totalDistanceCovered,
      'weekly_workouts': weeklyWorkouts,
      'weekly_minutes': weeklyMinutes,
      'weekly_calories': weeklyCalories,
      'monthly_workouts': monthlyWorkouts,
      'monthly_minutes': monthlyMinutes,
      'monthly_calories': monthlyCalories,
      'total_training_minutes': totalTrainingMinutes,
      'completed_workouts': completedWorkouts,
      'weekly_goal': weeklyGoal?.toJson(),
    };
  }
}

class WeeklyGoal {
  final int current;
  final int target;
  final String unit;
  final int progress;

  WeeklyGoal({
    required this.current,
    required this.target,
    required this.unit,
    required this.progress,
  });

  factory WeeklyGoal.fromJson(Map<String, dynamic> json) {
    return WeeklyGoal(
      current: json['current'] ?? 0,
      target: json['target'] ?? 0,
      unit: json['unit'] ?? '',
      progress: json['progress'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'target': target,
      'unit': unit,
      'progress': progress,
    };
  }
}

class ChartData {
  final List<ChartDataPoint> workoutData;
  final List<ChartDataPoint> caloriesData;
  final List<ChartDataPoint> weightData;
  final List<ChartDataPoint> bodyFatData;
  final List<ChartDataPoint> bmiData;
  final List<ChartDataPoint> trainingDurationData;
  final List<ChartDataPoint> workoutFrequencyData;
  final List<ChartDataPoint> exerciseDistributionData;

  ChartData({
    this.workoutData = const [],
    this.caloriesData = const [],
    this.weightData = const [],
    this.bodyFatData = const [],
    this.bmiData = const [],
    this.trainingDurationData = const [],
    this.workoutFrequencyData = const [],
    this.exerciseDistributionData = const [],
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      workoutData: json['workout_data'] != null 
          ? (json['workout_data'] as List).map((point) => ChartDataPoint.fromJson(point)).toList()
          : [],
      caloriesData: json['calories_data'] != null 
          ? (json['calories_data'] as List).map((point) => ChartDataPoint.fromJson(point)).toList()
          : [],
      weightData: json['weight_data'] != null 
          ? (json['weight_data'] as List).map((point) => ChartDataPoint.fromJson(point)).toList()
          : [],
      bodyFatData: json['body_fat_data'] != null 
          ? (json['body_fat_data'] as List).map((point) => ChartDataPoint.fromJson(point)).toList()
          : [],
      bmiData: json['bmi_data'] != null 
          ? (json['bmi_data'] as List).map((point) => ChartDataPoint.fromJson(point)).toList()
          : [],
      trainingDurationData: json['training_duration_data'] != null 
          ? (json['training_duration_data'] as List).map((point) => ChartDataPoint.fromJson(point)).toList()
          : [],
      workoutFrequencyData: json['workout_frequency_data'] != null 
          ? (json['workout_frequency_data'] as List).map((point) => ChartDataPoint.fromJson(point)).toList()
          : [],
      exerciseDistributionData: json['exercise_distribution_data'] != null 
          ? (json['exercise_distribution_data'] as List).map((point) => ChartDataPoint.fromJson(point)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workout_data': workoutData.map((point) => point.toJson()).toList(),
      'calories_data': caloriesData.map((point) => point.toJson()).toList(),
      'weight_data': weightData.map((point) => point.toJson()).toList(),
      'body_fat_data': bodyFatData.map((point) => point.toJson()).toList(),
      'bmi_data': bmiData.map((point) => point.toJson()).toList(),
      'training_duration_data': trainingDurationData.map((point) => point.toJson()).toList(),
      'workout_frequency_data': workoutFrequencyData.map((point) => point.toJson()).toList(),
      'exercise_distribution_data': exerciseDistributionData.map((point) => point.toJson()).toList(),
    };
  }
}

class ChartDataPoint {
  final DateTime date;
  final double value;
  final String? label;

  ChartDataPoint({
    required this.date,
    required this.value,
    this.label,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      date: DateTime.parse(json['date']),
      value: (json['value'] ?? 0.0).toDouble(),
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'label': label,
    };
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isUnlocked;
  final bool isCompleted;
  final DateTime? unlockedAt;
  final String? title;
  final String? type;
  final bool? isRewardClaimed;
  final AchievementProgress? progress;
  final int? pointsReward;
  final String? badgeReward;
  final DateTime? completedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.unlockedAt,
    this.title,
    this.type,
    this.isRewardClaimed,
    this.progress,
    this.pointsReward,
    this.badgeReward,
    this.completedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      isUnlocked: json['is_unlocked'] ?? false,
      isCompleted: json['is_completed'] ?? false,
      unlockedAt: json['unlocked_at'] != null 
          ? DateTime.parse(json['unlocked_at'])
          : null,
      title: json['title'] ?? json['name'],
      type: json['type'] ?? 'general',
      isRewardClaimed: json['is_reward_claimed'] ?? false,
      progress: json['progress'] != null 
          ? AchievementProgress.fromJson(json['progress'])
          : null,
      pointsReward: json['points_reward'] ?? 0,
      badgeReward: json['badge_reward'],
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'is_unlocked': isUnlocked,
      'is_completed': isCompleted,
      'unlocked_at': unlockedAt?.toIso8601String(),
      'title': title,
      'type': type,
      'is_reward_claimed': isRewardClaimed,
      'progress': progress?.toJson(),
      'points_reward': pointsReward,
      'badge_reward': badgeReward,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    bool? isUnlocked,
    bool? isCompleted,
    DateTime? unlockedAt,
    String? title,
    String? type,
    bool? isRewardClaimed,
    AchievementProgress? progress,
    int? pointsReward,
    String? badgeReward,
    DateTime? completedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      title: title ?? this.title,
      type: type ?? this.type,
      isRewardClaimed: isRewardClaimed ?? this.isRewardClaimed,
      progress: progress ?? this.progress,
      pointsReward: pointsReward ?? this.pointsReward,
      badgeReward: badgeReward ?? this.badgeReward,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class AchievementProgress {
  final int current;
  final int target;

  AchievementProgress({
    required this.current,
    required this.target,
  });

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      current: json['current'] ?? 0,
      target: json['target'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'target': target,
    };
  }
}

class Activity {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.data,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'data': data,
    };
  }
}

class Chat {
  final String id;
  final String name;
  final String? avatar;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final bool isPinned;
  final bool isMuted;

  Chat({
    required this.id,
    required this.name,
    this.avatar,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isPinned = false,
    this.isMuted = false,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      isOnline: json['is_online'] ?? false,
      isPinned: json['is_pinned'] ?? false,
      isMuted: json['is_muted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'unread_count': unreadCount,
      'is_online': isOnline,
      'is_pinned': isPinned,
      'is_muted': isMuted,
    };
  }

  Chat copyWith({
    String? id,
    String? name,
    String? avatar,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
    bool? isPinned,
    bool? isMuted,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

class Group {
  final String id;
  final String name;
  final String? avatar;
  final List<String> memberIds;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final bool isPinned;
  final bool isMuted;

  Group({
    required this.id,
    required this.name,
    this.avatar,
    required this.memberIds,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isPinned = false,
    this.isMuted = false,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      memberIds: List<String>.from(json['member_ids'] ?? []),
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      isOnline: json['is_online'] ?? false,
      isPinned: json['is_pinned'] ?? false,
      isMuted: json['is_muted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'member_ids': memberIds,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'unread_count': unreadCount,
      'is_online': isOnline,
      'is_pinned': isPinned,
      'is_muted': isMuted,
    };
  }

  Chat toChat() {
    return Chat(
      id: id,
      name: name,
      avatar: avatar,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
      isOnline: isOnline,
      isPinned: isPinned,
      isMuted: isMuted,
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String? content;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    this.content,
    required this.type,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      data: json['data'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.name,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? content,
    NotificationType? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRead;
  final bool isDelivered;
  final bool isEdited;
  final String? replyToMessageId;
  final List<String>? attachments;
  final String? senderName;
  final String? senderAvatar;
  
  // 新增字段
  final String? mediaUrl;
  final String? thumbnailUrl;
  final int? duration;
  final String? fileName;
  final int? fileSize;
  final String? locationName;
  final String? locationAddress;
  final String? contactName;
  final String? contactPhone;
  final String? contactAvatar;
  final MessageStatus? status;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.createdAt,
    required this.updatedAt,
    this.isRead = false,
    this.isDelivered = false,
    this.isEdited = false,
    this.replyToMessageId,
    this.attachments,
    this.senderName,
    this.senderAvatar,
    this.mediaUrl,
    this.thumbnailUrl,
    this.duration,
    this.fileName,
    this.fileSize,
    this.locationName,
    this.locationAddress,
    this.contactName,
    this.contactPhone,
    this.contactAvatar,
    this.status,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatId: json['chat_id'],
      senderId: json['sender_id'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      createdAt: DateTime.parse(json['created_at'] ?? json['timestamp']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['created_at'] ?? json['timestamp']),
      isRead: json['is_read'] ?? false,
      isDelivered: json['is_delivered'] ?? false,
      isEdited: json['is_edited'] ?? false,
      replyToMessageId: json['reply_to_message_id'],
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      senderName: json['sender_name'],
      senderAvatar: json['sender_avatar'],
      mediaUrl: json['media_url'],
      thumbnailUrl: json['thumbnail_url'],
      duration: json['duration'],
      fileName: json['file_name'],
      fileSize: json['file_size'],
      locationName: json['location_name'],
      locationAddress: json['location_address'],
      contactName: json['contact_name'],
      contactPhone: json['contact_phone'],
      contactAvatar: json['contact_avatar'],
      status: json['status'] != null 
          ? MessageStatus.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => MessageStatus.sent,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_read': isRead,
      'is_delivered': isDelivered,
      'is_edited': isEdited,
      'reply_to_message_id': replyToMessageId,
      'attachments': attachments,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
      'file_name': fileName,
      'file_size': fileSize,
      'location_name': locationName,
      'location_address': locationAddress,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_avatar': contactAvatar,
      'status': status?.name,
    };
  }

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRead,
    bool? isDelivered,
    bool? isEdited,
    String? replyToMessageId,
    List<String>? attachments,
    String? senderName,
    String? senderAvatar,
    String? mediaUrl,
    String? thumbnailUrl,
    int? duration,
    String? fileName,
    int? fileSize,
    String? locationName,
    String? locationAddress,
    String? contactName,
    String? contactPhone,
    String? contactAvatar,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      isEdited: isEdited ?? this.isEdited,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      attachments: attachments ?? this.attachments,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      locationName: locationName ?? this.locationName,
      locationAddress: locationAddress ?? this.locationAddress,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactAvatar: contactAvatar ?? this.contactAvatar,
      status: status ?? this.status,
    );
  }
}

enum MessageType {
  text,
  image,
  video,
  audio,
  voice,
  file,
  location,
  contact,
  sticker,
  system,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

enum NotificationType {
  like,
  comment,
  follow,
  challenge,
  workout,
  achievement,
  system,
  message,
}

enum TrainingStatus {
  pending,
  planned,
  inProgress,
  completed,
  skipped,
}

class ProfileStats {
  final int totalWorkouts;
  final int totalMinutes;
  final int totalCaloriesBurned;
  final int currentStreak;
  final int maxStreak;
  final double averageWorkoutDuration;
  final double workoutFrequency;
  final int maxWeightLifted;
  final double totalDistanceCovered;

  ProfileStats({
    this.totalWorkouts = 0,
    this.totalMinutes = 0,
    this.totalCaloriesBurned = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.averageWorkoutDuration = 0.0,
    this.workoutFrequency = 0.0,
    this.maxWeightLifted = 0,
    this.totalDistanceCovered = 0.0,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      totalWorkouts: json['total_workouts'] ?? 0,
      totalMinutes: json['total_minutes'] ?? 0,
      totalCaloriesBurned: json['total_calories_burned'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      maxStreak: json['max_streak'] ?? 0,
      averageWorkoutDuration: (json['average_workout_duration'] ?? 0.0).toDouble(),
      workoutFrequency: (json['workout_frequency'] ?? 0.0).toDouble(),
      maxWeightLifted: json['max_weight_lifted'] ?? 0,
      totalDistanceCovered: (json['total_distance_covered'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_workouts': totalWorkouts,
      'total_minutes': totalMinutes,
      'total_calories_burned': totalCaloriesBurned,
      'current_streak': currentStreak,
      'max_streak': maxStreak,
      'average_workout_duration': averageWorkoutDuration,
      'workout_frequency': workoutFrequency,
      'max_weight_lifted': maxWeightLifted,
      'total_distance_covered': totalDistanceCovered,
    };
  }
}

// ==================== 组间休息相关模型 ====================

class RestSession {
  final int id;
  final int userId;
  final int duration;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String notes;
  final String aiHint;
  final DateTime createdAt;
  final DateTime updatedAt;

  RestSession({
    required this.id,
    required this.userId,
    required this.duration,
    required this.startedAt,
    this.completedAt,
    required this.notes,
    required this.aiHint,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RestSession.fromJson(Map<String, dynamic> json) {
    return RestSession(
      id: json['id'],
      userId: json['user_id'],
      duration: json['duration'],
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'])
          : null,
      notes: json['notes'] ?? '',
      aiHint: json['ai_hint'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'duration': duration,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
      'ai_hint': aiHint,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class RestPost {
  final int id;
  final int userId;
  final String content;
  final String? imageUrl;
  final String type;
  final bool isActive;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final bool isLiked;

  RestPost({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.type,
    required this.isActive,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.isLiked = false,
  });

  factory RestPost.fromJson(Map<String, dynamic> json) {
    return RestPost(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      imageUrl: json['image_url'],
      type: json['type'] ?? 'rest',
      isActive: json['is_active'] ?? true,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      isLiked: json['is_liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'image_url': imageUrl,
      'type': type,
      'is_active': isActive,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user?.toJson(),
      'is_liked': isLiked,
    };
  }

  RestPost copyWith({
    int? id,
    int? userId,
    String? content,
    String? imageUrl,
    String? type,
    bool? isActive,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    bool? isLiked,
  }) {
    return RestPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class RestFeed {
  final List<RestPost> posts;
  final List<RestPost> jokes;
  final List<RestPost> knowledge;
  final int total;
  final bool hasMore;

  RestFeed({
    required this.posts,
    required this.jokes,
    required this.knowledge,
    required this.total,
    required this.hasMore,
  });

  factory RestFeed.fromJson(Map<String, dynamic> json) {
    return RestFeed(
      posts: (json['posts'] as List?)
          ?.map((post) => RestPost.fromJson(post))
          .toList() ?? [],
      jokes: (json['jokes'] as List?)
          ?.map((joke) => RestPost.fromJson(joke))
          .toList() ?? [],
      knowledge: (json['knowledge'] as List?)
          ?.map((knowledge) => RestPost.fromJson(knowledge))
          .toList() ?? [],
      total: json['total'] ?? 0,
      hasMore: json['has_more'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posts': posts.map((post) => post.toJson()).toList(),
      'jokes': jokes.map((joke) => joke.toJson()).toList(),
      'knowledge': knowledge.map((knowledge) => knowledge.toJson()).toList(),
      'total': total,
      'has_more': hasMore,
    };
  }
}

// 健身房相关模型
class Gym {
  final String id;
  final String name;
  final String? address;
  final double? lat;
  final double? lng;
  final String? description;
  final String? ownerUserId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? currentBuddiesCount;
  final GymDiscount? applicableDiscount;

  Gym({
    required this.id,
    required this.name,
    this.address,
    this.lat,
    this.lng,
    this.description,
    this.ownerUserId,
    required this.createdAt,
    required this.updatedAt,
    this.currentBuddiesCount,
    this.applicableDiscount,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      id: json['id'].toString(),
      name: json['name'],
      address: json['address'],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      description: json['description'],
      ownerUserId: json['owner_user_id']?.toString(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      currentBuddiesCount: json['current_buddies_count'],
      applicableDiscount: json['applicable_discount'] != null
          ? GymDiscount.fromJson(json['applicable_discount'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'description': description,
      'owner_user_id': ownerUserId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'current_buddies_count': currentBuddiesCount,
      'applicable_discount': applicableDiscount?.toJson(),
    };
  }
}

class GymJoinRequest {
  final String id;
  final String gymId;
  final String userId;
  final String status;
  final String? goal;
  final DateTime? timeSlot;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  GymJoinRequest({
    required this.id,
    required this.gymId,
    required this.userId,
    required this.status,
    this.goal,
    this.timeSlot,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GymJoinRequest.fromJson(Map<String, dynamic> json) {
    return GymJoinRequest(
      id: json['id'].toString(),
      gymId: json['gym_id'].toString(),
      userId: json['user_id'].toString(),
      status: json['status'],
      goal: json['goal'],
      timeSlot: json['time_slot'] != null
          ? DateTime.parse(json['time_slot'])
          : null,
      note: json['note'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gym_id': gymId,
      'user_id': userId,
      'status': status,
      'goal': goal,
      'time_slot': timeSlot?.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class GymDiscount {
  final String id;
  final String gymId;
  final int minGroupSize;
  final int discountPercent;
  final bool active;
  final DateTime createdAt;

  GymDiscount({
    required this.id,
    required this.gymId,
    required this.minGroupSize,
    required this.discountPercent,
    required this.active,
    required this.createdAt,
  });

  factory GymDiscount.fromJson(Map<String, dynamic> json) {
    return GymDiscount(
      id: json['id'].toString(),
      gymId: json['gym_id'].toString(),
      minGroupSize: json['min_group_size'],
      discountPercent: json['discount_percent'],
      active: json['active'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gym_id': gymId,
      'min_group_size': minGroupSize,
      'discount_percent': discountPercent,
      'active': active,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class GymBuddyGroup {
  final String id;
  final String gymId;
  final String name;
  final String? description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  GymBuddyGroup({
    required this.id,
    required this.gymId,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GymBuddyGroup.fromJson(Map<String, dynamic> json) {
    return GymBuddyGroup(
      id: json['id'].toString(),
      gymId: json['gym_id'].toString(),
      name: json['name'],
      description: json['description'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gym_id': gymId,
      'name': name,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class GymBuddyMember {
  final String id;
  final String groupId;
  final String userId;
  final String? userName;
  final String? goal;
  final DateTime? timeSlot;
  final String status;
  final DateTime joinedAt;

  GymBuddyMember({
    required this.id,
    required this.groupId,
    required this.userId,
    this.userName,
    this.goal,
    this.timeSlot,
    required this.status,
    required this.joinedAt,
  });

  factory GymBuddyMember.fromJson(Map<String, dynamic> json) {
    return GymBuddyMember(
      id: json['id'].toString(),
      groupId: json['group_id'].toString(),
      userId: json['user_id'].toString(),
      userName: json['user_name'],
      goal: json['goal'],
      timeSlot: json['time_slot'] != null
          ? DateTime.parse(json['time_slot'])
          : null,
      status: json['status'],
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'user_name': userName,
      'goal': goal,
      'time_slot': timeSlot?.toIso8601String(),
      'status': status,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

class GymReview {
  final String id;
  final String gymId;
  final String userId;
  final String? userName;
  final int rating;
  final String? content;
  final DateTime createdAt;
  final DateTime updatedAt;

  GymReview({
    required this.id,
    required this.gymId,
    required this.userId,
    this.userName,
    required this.rating,
    this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GymReview.fromJson(Map<String, dynamic> json) {
    return GymReview(
      id: json['id'].toString(),
      gymId: json['gym_id'].toString(),
      userId: json['user_id'].toString(),
      userName: json['user_name'],
      rating: json['rating'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gym_id': gymId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

