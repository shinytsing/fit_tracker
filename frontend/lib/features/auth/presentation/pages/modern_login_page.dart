import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/auth/third_party_auth_service.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_widgets.dart';

/// 现代化登录页面
/// 参考青藤之恋的设计风格，适配Gymates品牌
class ModernLoginPage extends ConsumerStatefulWidget {
  const ModernLoginPage({super.key});

  @override
  ConsumerState<ModernLoginPage> createState() => _ModernLoginPageState();
}

class _ModernLoginPageState extends ConsumerState<ModernLoginPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

          bool _isLoading = false;
          bool _agreedToTerms = false;
          String _detectedPhoneNumber = ''; // 动态检测的手机号

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // 启动动画
            _fadeController.forward();
            _slideController.forward();
            
            // 检测手机号
            _detectPhoneNumber();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// 检测手机号
  Future<void> _detectPhoneNumber() async {
    try {
      // 尝试获取设备信息来模拟检测手机号
      final result = await ThirdPartyAuthService.oneClickLogin();
      if (result != null && result['success'] == true) {
        final phoneNumber = result['phoneNumber'] as String?;
        if (phoneNumber != null && mounted) {
          setState(() {
            _detectedPhoneNumber = phoneNumber;
          });
        }
      }
    } catch (e) {
      // 如果检测失败，使用默认值
      if (mounted) {
        setState(() {
          _detectedPhoneNumber = '166****3484'; // 默认模拟手机号
        });
        print('📱 使用默认模拟手机号: $_detectedPhoneNumber');
      }
    }
  }

  Future<void> _handleOneClickLogin() async {
    if (!_agreedToTerms) {
      _showAgreementDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 调用第三方一键登录服务
      final result = await ThirdPartyAuthService.oneClickLogin();
      
      if (result != null && result['success'] == true) {
        // 调用后端第三方登录API
        final loginData = {
          'provider': 'one_click',
          'phoneNumber': result['phoneNumber'],
          'deviceInfo': result['deviceInfo'],
        };

        final success = await ref.read(authProvider.notifier).thirdPartyLogin(loginData);

        if (mounted) {
          if (success) {
            print('🎉 一键登录成功，跳转到首页');
            context.go('/');
          } else {
            _showErrorSnackBar('一键登录失败，请尝试其他方式');
          }
        }
      } else {
        _showErrorSnackBar('一键登录失败，请尝试其他方式');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('登录失败: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAppleLogin() async {
    if (!_agreedToTerms) {
      _showAgreementDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 调用苹果登录服务
      final result = await ThirdPartyAuthService.signInWithApple();

      if (result != null && result['success'] == true) {
        // 调用后端第三方登录API
        final loginData = {
          'provider': 'apple',
          'userId': result['userId'],
          'email': result['email'],
          'fullName': result['fullName'],
          'identityToken': result['identityToken'],
          'deviceInfo': result['deviceInfo'],
        };

        final success = await ref.read(authProvider.notifier).thirdPartyLogin(loginData);

        if (mounted) {
          if (success) {
            print('🎉 苹果登录成功，跳转到首页');
            context.go('/');
          } else {
            _showErrorSnackBar('苹果登录失败，请重试');
          }
        }
      } else {
        _showErrorSnackBar('苹果登录失败，请重试');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('苹果登录失败: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleWeChatLogin() async {
    if (!_agreedToTerms) {
      _showAgreementDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 调用微信登录服务
      final result = await ThirdPartyAuthService.signInWithWeChat();

      if (result != null && result['success'] == true) {
        // 调用后端第三方登录API
        final loginData = {
          'provider': 'wechat',
          'authCode': result['code'],
          'deviceInfo': result['deviceInfo'],
        };

        final success = await ref.read(authProvider.notifier).thirdPartyLogin(loginData);

        if (mounted) {
          if (success) {
            print('🎉 微信登录成功，跳转到首页');
            context.go('/');
          } else {
            _showErrorSnackBar('微信登录失败，请重试');
          }
        }
      } else {
        _showErrorSnackBar('微信登录失败，请重试');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('微信登录失败: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleOtherPhoneLogin() {
    context.push('/auth/phone-login');
  }

  void _showAgreementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('用户协议'),
        content: const Text('请先阅读并同意用户协议和隐私政策'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _agreedToTerms = true;
              });
            },
            child: const Text('同意'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50), // 绿色渐变
              Color(0xFF2E7D32),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 背景渐变
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF4CAF50).withOpacity(0.9),
                        const Color(0xFF2E7D32).withOpacity(0.9),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 主要内容
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        
                        // Logo 和品牌
                        _buildBrandSection(),
                        
                        const SizedBox(height: 80),
                        
                        // 检测到的手机号
                        _buildPhoneNumberSection(),
                        
                        const SizedBox(height: 40),
                        
                                // 一键登录按钮
                                _buildOneClickLoginButton(),
                                
                                const SizedBox(height: 20),
                                
                                // 直接登录按钮（绕过API）
                                _buildDirectLoginButton(),
                                
                                const SizedBox(height: 20),
                                
                                // 其他登录方式
                                _buildOtherLoginOptions(),
                        
                        const Spacer(),
                        
                        // 用户协议
                        _buildUserAgreement(),
                        
                        const SizedBox(height: 30),
                        
                        // 第三方登录
                        _buildThirdPartyLogin(),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 加载指示器
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSection() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.fitness_center,
            size: 40,
            color: Color(0xFF4CAF50),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // 应用名称
        const Text(
          'Gymates',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 标语
        const Text(
          '专业的健身社交平台',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberSection() {
    return Column(
      children: [
        // 检测到的手机号
        if (_detectedPhoneNumber.isNotEmpty)
          Text(
            _detectedPhoneNumber,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          )
        else
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        
        const SizedBox(height: 8),
        
        // 认证服务说明
        const Text(
          '认证服务由中国联通提供',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildOneClickLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleOneClickLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '一键登录',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildDirectLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleDirectLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3), // 蓝色
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '直接登录 (测试)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _handleDirectLogin() async {
    if (!_agreedToTerms) {
      _showAgreementDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 直接创建模拟用户数据，绕过API调用
      final mockUser = {
        'uid': 999,
        'username': 'test_user',
        'email': 'test@gymates.com',
        'nickname': '测试用户',
        'avatar': '',
        'phone': '166****3484',
        'is_verified': true,
      };

      final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

      // 直接保存到本地存储
      final storageService = ref.read(storageServiceProvider);
      await storageService.saveToken(mockToken);
      await storageService.saveUserInfo(mockUser);

      // 更新认证状态
      final authController = ref.read(authProvider.notifier);
      authController.state = authController.state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        userInfo: mockUser,
      );

      print('🎉 直接登录成功，跳转到首页');

      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      print('❌ 直接登录失败: $e');
      if (mounted) {
        _showErrorSnackBar('直接登录失败: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildOtherLoginOptions() {
    return GestureDetector(
      onTap: _handleOtherPhoneLogin,
      child: const Text(
        '其他手机号登录',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildUserAgreement() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _agreedToTerms = !_agreedToTerms;
            });
          },
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _agreedToTerms ? const Color(0xFF4CAF50) : Colors.transparent,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _agreedToTerms
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
              children: [
                TextSpan(text: '已阅读并同意'),
                TextSpan(
                  text: '《用户协议》',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                  ),
                ),
                TextSpan(text: '和'),
                TextSpan(
                  text: '《隐私政策》',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThirdPartyLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 苹果登录
        GestureDetector(
          onTap: _handleAppleLogin,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.apple,
              color: Colors.black,
              size: 24,
            ),
          ),
        ),
        
        const SizedBox(width: 30),
        
        // 微信登录
        GestureDetector(
          onTap: _handleWeChatLogin,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Color(0xFF4CAF50),
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
