import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthService {
  static Future<void> init() async {
    // 初始化认证服务
  }
}

final authProvider = StateProvider<bool>((ref) => false);
