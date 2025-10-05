import 'package:flutter/material.dart';

enum AuthState { login, register, onboarding, authenticated }

class User {
  final String id;
  final String name;
  final String phone;
  final String? avatar;
  final int? height;
  final int? weight;
  final String? experience;
  final String? goal;
  final double? bmi;

  User({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
    this.height,
    this.weight,
    this.experience,
    this.goal,
    this.bmi,
  });

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? avatar,
    int? height,
    int? weight,
    String? experience,
    String? goal,
    double? bmi,
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
    );
  }
}

class AuthProvider extends ChangeNotifier {
  AuthState _authState = AuthState.login;
  User? _user;

  AuthState get authState => _authState;
  User? get user => _user;
  bool get isAuthenticated => _authState == AuthState.authenticated;

  void setAuthState(AuthState state) {
    _authState = state;
    notifyListeners();
  }

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void login(String phone, String password) {
    // Simulate login process
    _user = User(
      id: '1',
      name: '用户',
      phone: phone,
      avatar: 'https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    );
    _authState = AuthState.authenticated;
    notifyListeners();
  }

  void register(String phone, String password, String name) {
    // Simulate registration process
    _user = User(
      id: '1',
      name: name,
      phone: phone,
      avatar: 'https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    );
    _authState = AuthState.onboarding;
    notifyListeners();
  }

  void completeOnboarding({
    required int height,
    required int weight,
    required String experience,
    required String goal,
  }) {
    if (_user != null) {
      _user = _user!.copyWith(
        height: height,
        weight: weight,
        experience: experience,
        goal: goal,
        bmi: weight / ((height / 100) * (height / 100)),
      );
      _authState = AuthState.authenticated;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    _authState = AuthState.login;
    notifyListeners();
  }
}
