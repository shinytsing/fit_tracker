import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_service.dart';
import '../network/api_service.dart';

// 认证状态
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? userInfo;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.userInfo,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? userInfo,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userInfo: userInfo ?? this.userInfo,
    );
  }
}

// 认证控制器
class AuthController extends StateNotifier<AuthState> {
  final StorageService _storageService;
  final ApiService _apiService;

  AuthController(this._storageService, this._apiService) : super(const AuthState()) {
    _checkAuthStatus();
  }

  // 检查认证状态
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final token = await _storageService.getToken();
      if (token != null && _isTokenValid(token)) {
        // 验证token是否有效
        final userInfo = await _storageService.getUserInfo();
        if (userInfo != null) {
          // 可选：验证token是否仍然有效（调用API）
          try {
            final response = await _apiService.getProfile();
            if (response != null) {
              state = state.copyWith(
                isAuthenticated: true,
                isLoading: false,
                userInfo: response,
              );
              return;
            }
          } catch (e) {
            // API验证失败，清除本地token
            await _storageService.clearAll();
          }
        }
      }
      
      // token无效或不存在
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 检查token是否有效（基本格式检查）
  bool _isTokenValid(String token) {
    if (token.isEmpty) return false;
    
    // 检查token格式（JWT通常有三部分，用.分隔）
    final parts = token.split('.');
    if (parts.length != 3) return false;
    
    // 这里可以添加更复杂的token验证逻辑
    // 比如检查过期时间等
    
    return true;
  }

  // 登录
  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.login(
        username: username,
        password: password,
      );

      if (response['token'] != null) {
        // 保存token和用户信息
        await _storageService.saveToken(response['token']);
        if (response['user'] != null) {
          await _storageService.saveUserInfo(response['user']);
        }

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userInfo: response['user'],
        );
        return true;
      }
      
      state = state.copyWith(
        isLoading: false,
        error: '登录失败',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // 第三方登录
  Future<bool> thirdPartyLogin(Map<String, dynamic> loginData) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      print('🔍 开始第三方登录: $loginData');
      final response = await _apiService.post('/users/third-party-login', data: loginData);
      print('📡 后端响应: $response');

      if (response != null && response.data != null && response.data['data'] != null) {
        final token = response.data['data']['token'] as String;
        final userInfo = response.data['data']['user'] as Map<String, dynamic>;

        await _storageService.saveToken(token);
        await _storageService.saveUserInfo(userInfo);

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userInfo: userInfo,
        );
        print('✅ 第三方登录成功');
        return true;
      }
      
      print('❌ 第三方登录失败: 响应数据为空');
      state = state.copyWith(
        isLoading: false,
        error: '第三方登录失败',
      );
      return false;
    } catch (e) {
      print('❌ 第三方登录异常: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // 注册
  Future<bool> register({
    required String username,
    required String email,
    String? phone,
    required String password,
    required String nickname,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.register(
        username: username,
        email: email,
        phone: phone,
        password: password,
        nickname: nickname,
      );

      if (response['token'] != null) {
        // 保存token和用户信息
        await _storageService.saveToken(response['token']);
        if (response['user'] != null) {
          await _storageService.saveUserInfo(response['user']);
        }

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userInfo: response['user'],
        );
        return true;
      }
      
      state = state.copyWith(
        isLoading: false,
        error: '注册失败',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // 注销
  Future<void> logout() async {
    await _storageService.clearAll();
    state = state.copyWith(
      isAuthenticated: false,
      userInfo: null,
      error: null,
    );
  }

  // 获取当前用户信息
  Map<String, dynamic>? get currentUser => state.userInfo;

  // 获取当前用户UID
  int? get currentUserUID => state.userInfo?['uid'];

  // 获取当前用户名
  String? get currentUsername => state.userInfo?['username'];

  // 获取当前用户昵称
  String? get currentNickname => state.userInfo?['nickname'];
}

// Provider
final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final storageService = ref.read(storageServiceProvider);
  final apiService = ref.read(apiServiceProvider);
  return AuthController(storageService, apiService);
});

// 便捷访问器
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(authProvider).userInfo;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});
