class User {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final String? bio;
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class AuthResponse {
  final User user;
  final String token;
  final String refreshToken;

  AuthResponse({
    required this.user,
    required this.token,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      token: json['token'],
      refreshToken: json['refresh_token'],
    );
  }
}

class Workout {
  final int id;
  final String name;
  final String type;
  final int duration;
  final int calories;
  final String difficulty;
  final String? notes;
  final double rating;
  final DateTime createdAt;
  final List<Exercise> exercises;

  Workout({
    required this.id,
    required this.name,
    required this.type,
    required this.duration,
    required this.calories,
    required this.difficulty,
    this.notes,
    required this.rating,
    required this.createdAt,
    required this.exercises,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      duration: json['duration'],
      calories: json['calories'],
      difficulty: json['difficulty'],
      notes: json['notes'],
      rating: json['rating']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      exercises: (json['exercises'] as List?)
          ?.map((e) => Exercise.fromJson(e))
          .toList() ?? [],
    );
  }
}

class Exercise {
  final int id;
  final String name;
  final String category;
  final String difficulty;
  final String? description;
  final String? imageUrl;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    this.description,
    this.imageUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      difficulty: json['difficulty'],
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }
}

class TrainingPlan {
  final int id;
  final String name;
  final String description;
  final String difficulty;
  final String type;
  final int duration;
  final List<Exercise> exercises;

  TrainingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.type,
    required this.duration,
    required this.exercises,
  });

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    return TrainingPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      difficulty: json['difficulty'],
      type: json['type'],
      duration: json['duration'],
      exercises: (json['exercises'] as List?)
          ?.map((e) => Exercise.fromJson(e))
          .toList() ?? [],
    );
  }
}

class Post {
  final int id;
  final User user;
  final String content;
  final List<String> images;
  final String? type;
  final bool isPublic;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;
  final List<String> tags;

  Post({
    required this.id,
    required this.user,
    required this.content,
    required this.images,
    this.type,
    required this.isPublic,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.createdAt,
    required this.tags,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      user: User.fromJson(json['user']),
      content: json['content'],
      images: List<String>.from(json['images'] ?? []),
      type: json['type'],
      isPublic: json['is_public'] ?? true,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}

class Challenge {
  final int id;
  final String name;
  final String description;
  final String difficulty;
  final String type;
  final int duration;
  final int participantsCount;
  final bool isJoined;
  final DateTime startDate;
  final DateTime endDate;

  Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.type,
    required this.duration,
    required this.participantsCount,
    required this.isJoined,
    required this.startDate,
    required this.endDate,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      difficulty: json['difficulty'],
      type: json['type'],
      duration: json['duration'],
      participantsCount: json['participants_count'] ?? 0,
      isJoined: json['is_joined'] ?? false,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }
}

class Checkin {
  final int id;
  final String type;
  final String? notes;
  final String? mood;
  final int energy;
  final int motivation;
  final DateTime createdAt;

  Checkin({
    required this.id,
    required this.type,
    this.notes,
    this.mood,
    required this.energy,
    required this.motivation,
    required this.createdAt,
  });

  factory Checkin.fromJson(Map<String, dynamic> json) {
    return Checkin(
      id: json['id'],
      type: json['type'],
      notes: json['notes'],
      mood: json['mood'],
      energy: json['energy'] ?? 5,
      motivation: json['motivation'] ?? 5,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class BMICalculation {
  final double bmi;
  final String category;
  final String recommendation;
  final double idealWeightMin;
  final double idealWeightMax;

  BMICalculation({
    required this.bmi,
    required this.category,
    required this.recommendation,
    required this.idealWeightMin,
    required this.idealWeightMax,
  });

  factory BMICalculation.fromJson(Map<String, dynamic> json) {
    return BMICalculation(
      bmi: json['bmi']?.toDouble() ?? 0.0,
      category: json['category'],
      recommendation: json['recommendation'],
      idealWeightMin: json['ideal_weight_min']?.toDouble() ?? 0.0,
      idealWeightMax: json['ideal_weight_max']?.toDouble() ?? 0.0,
    );
  }
}

class BMIRecord {
  final int id;
  final double height;
  final double weight;
  final int age;
  final String gender;
  final double bmi;
  final String category;
  final String? notes;
  final DateTime createdAt;

  BMIRecord({
    required this.id,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.bmi,
    required this.category,
    this.notes,
    required this.createdAt,
  });

  factory BMIRecord.fromJson(Map<String, dynamic> json) {
    return BMIRecord(
      id: json['id'],
      height: json['height']?.toDouble() ?? 0.0,
      weight: json['weight']?.toDouble() ?? 0.0,
      age: json['age'],
      gender: json['gender'],
      bmi: json['bmi']?.toDouble() ?? 0.0,
      category: json['category'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class NutritionRecord {
  final int id;
  final String date;
  final String mealType;
  final String foodName;
  final double quantity;
  final String unit;
  final String? notes;
  final DateTime createdAt;

  NutritionRecord({
    required this.id,
    required this.date,
    required this.mealType,
    required this.foodName,
    required this.quantity,
    required this.unit,
    this.notes,
    required this.createdAt,
  });

  factory NutritionRecord.fromJson(Map<String, dynamic> json) {
    return NutritionRecord(
      id: json['id'],
      date: json['date'],
      mealType: json['meal_type'],
      foodName: json['food_name'],
      quantity: json['quantity']?.toDouble() ?? 0.0,
      unit: json['unit'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ApiResponse<T> {
  final T data;
  final Map<String, dynamic>? pagination;

  ApiResponse({
    required this.data,
    this.pagination,
  });
}
