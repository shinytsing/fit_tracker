import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userInfoKey = 'user_info';
  static const String _isLoggedInKey = 'is_logged_in';

  // 保存JWT token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_isLoggedInKey, true);
  }

  // 获取JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // 保存用户信息
  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userInfoKey, jsonEncode(userInfo));
  }

  // 获取用户信息
  Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoString = prefs.getString(_userInfoKey);
    if (userInfoString != null) {
      return jsonDecode(userInfoString) as Map<String, dynamic>;
    }
    return null;
  }

  // 检查是否已登录
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // 清除所有存储的数据（登出）
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userInfoKey);
    await prefs.remove(_isLoggedInKey);
  }

  // 获取用户UID
  Future<int?> getUserUID() async {
    final userInfo = await getUserInfo();
    return userInfo?['uid'];
  }

  // 获取用户名
  Future<String?> getUsername() async {
    final userInfo = await getUserInfo();
    return userInfo?['username'];
  }

  // 获取用户昵称
  Future<String?> getNickname() async {
    final userInfo = await getUserInfo();
    return userInfo?['nickname'];
  }
}

// Provider for dependency injection
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
