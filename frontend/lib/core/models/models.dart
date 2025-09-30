class User {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final String? bio;
  final int totalWorkouts;
  final int totalCheckins;
  final int currentStreak;
  final int longestStreak;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatar,
    this.bio,
    required this.totalWorkouts,
    required this.totalCheckins,
    required this.currentStreak,
    required this.longestStreak,
    required this.createdAt,
    required this.updatedAt,
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
      totalWorkouts: json['total_workouts'] ?? 0,
      totalCheckins: json['total_checkins'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
      'total_workouts': totalWorkouts,
      'total_checkins': totalCheckins,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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
  final int id;
  final int userId;
  final int? planId;
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
  final int id;
  final String name;
  final String? description;
  final String type;
  final String difficulty;
  final int duration;
  final bool isPublic;
  final bool isAi;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    );
  }
}

class Exercise {
  final int id;
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
    );
  }
}

class Checkin {
  final int id;
  final int userId;
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

class Post {
  final int id;
  final int userId;
  final String content;
  final String? images;
  final String? type;
  final bool isPublic;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final User? user;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    this.images,
    this.type,
    required this.isPublic,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      images: json['images'],
      type: json['type'],
      isPublic: json['is_public'] ?? true,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class Challenge {
  final int id;
  final String name;
  final String? description;
  final String type;
  final String difficulty;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int participantsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Challenge({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.difficulty,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.participantsCount,
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
      isActive: json['is_active'] ?? true,
      participantsCount: json['participants_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
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
