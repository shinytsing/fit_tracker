import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class User {
  final String id;
  final String name;
  final String phone;
  final String? avatar;
  final double? height;
  final double? weight;
  final String? experience;
  final String? goal;
  final double? bmi;
  final bool isOnboardingCompleted;
  
  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
    this.height,
    this.weight,
    this.experience,
    this.goal,
    this.bmi,
    this.isOnboardingCompleted = false,
  });
  
  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? avatar,
    double? height,
    double? weight,
    String? experience,
    String? goal,
    double? bmi,
    bool? isOnboardingCompleted,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      experience: experience ?? this.experience,
      goal: goal ?? this.goal,
      bmi: bmi ?? this.bmi,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'height': height,
      'weight': weight,
      'experience': experience,
      'goal': goal,
      'bmi': bmi,
      'isOnboardingCompleted': isOnboardingCompleted,
    };
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      experience: json['experience'],
      goal: json['goal'],
      bmi: json['bmi']?.toDouble(),
      isOnboardingCompleted: json['isOnboardingCompleted'] ?? false,
    );
  }
}

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isOnboardingCompleted => _user?.isOnboardingCompleted ?? false;
  
  UserProvider() {
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConstants.userDataKey);
    
    if (userData != null) {
      try {
        _user = User.fromJson(userData as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Error loading user data: $e');
      }
    }
    notifyListeners();
  }
  
  Future<void> setUser(User user) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userDataKey, user.toJson().toString());
      
      _user = user;
    } catch (e) {
      debugPrint('Error saving user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateUser(User user) async {
    await setUser(user);
  }
  
  Future<void> completeOnboarding() async {
    if (_user != null) {
      final updatedUser = _user!.copyWith(isOnboardingCompleted: true);
      await setUser(updatedUser);
    }
  }
  
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userDataKey);
    _user = null;
    notifyListeners();
  }
}
