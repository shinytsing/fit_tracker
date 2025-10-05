import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_provider.dart';

class AuthRegisterPage extends ConsumerStatefulWidget {
  const AuthRegisterPage({super.key});

  @override
  ConsumerState<AuthRegisterPage> createState() => _AuthRegisterPageState();
}

class _AuthRegisterPageState extends ConsumerState<AuthRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  
  bool _obscurePassword = true;
  String _registerType = 'email'; // email, phone, username

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 构建注册数据
    String username;
    String email;
    String? phone;

    switch (_registerType) {
      case 'username':
        username = _usernameController.text.trim();
        email = '${username}@gymates.local';
        break;
      case 'phone':
        phone = _emailController.text.trim();
        username = phone;
        email = '${phone}@gymates.local';
        break;
      case 'email':
      default:
        email = _emailController.text.trim();
        username = email.split('@')[0];
        break;
    }

    final success = await ref.read(authProvider.notifier).register(
      username: username,
      email: email,
      phone: phone,
      password: _passwordController.text,
      nickname: _nicknameController.text.trim(),
    );

    if (success && mounted) {
      // 注册成功，自动跳转到首页
      context.go('/');
    } else if (mounted) {
      // 显示错误信息
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? '注册失败'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '注册',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 欢迎标题
              const SizedBox(height: 20),
              const Text(
                '加入 Gymates',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '开始你的健身之旅',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 注册方式选择
              _buildRegisterTypeSelector(),
              const SizedBox(height: 24),

              // 昵称输入
              _buildNicknameField(),
              const SizedBox(height: 16),

              // 根据注册类型显示不同输入框
              if (_registerType == 'email') ...[
                _buildEmailField(),
              ] else if (_registerType == 'phone') ...[
                _buildPhoneField(),
              ] else ...[
                _buildUsernameField(),
              ],
              const SizedBox(height: 16),

              // 密码输入
              _buildPasswordField(),
              const SizedBox(height: 24),

              // 注册按钮
              _buildRegisterButton(authState.isLoading),
              const SizedBox(height: 24),

              // 登录链接
              _buildLoginLink(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建注册方式选择器
  Widget _buildRegisterTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRegisterTypeOption(
              'email',
              '邮箱',
              Icons.email,
            ),
          ),
          Expanded(
            child: _buildRegisterTypeOption(
              'phone',
              '手机',
              Icons.phone,
            ),
          ),
          Expanded(
            child: _buildRegisterTypeOption(
              'username',
              '用户名',
              Icons.person,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterTypeOption(String type, String label, IconData icon) {
    final isSelected = _registerType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _registerType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建昵称输入框
  Widget _buildNicknameField() {
    return _buildInputField(
      controller: _nicknameController,
      label: '昵称',
      hintText: '请输入你的昵称',
      prefixIcon: Icons.person_outline,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入昵称';
        }
        if (value.trim().length < 2) {
          return '昵称至少2个字符';
        }
        return null;
      },
    );
  }

  /// 构建邮箱输入框
  Widget _buildEmailField() {
    return _buildInputField(
      controller: _emailController,
      label: '邮箱',
      hintText: '请输入邮箱地址',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入邮箱地址';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return '请输入有效的邮箱地址';
        }
        return null;
      },
    );
  }

  /// 构建手机号输入框
  Widget _buildPhoneField() {
    return _buildInputField(
      controller: _emailController, // 复用email controller
      label: '手机号',
      hintText: '请输入手机号码',
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入手机号码';
        }
        if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
          return '请输入有效的手机号码';
        }
        return null;
      },
    );
  }

  /// 构建用户名输入框
  Widget _buildUsernameField() {
    return _buildInputField(
      controller: _usernameController,
      label: '用户名',
      hintText: '请输入用户名',
      prefixIcon: Icons.person_outline,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入用户名';
        }
        if (value.trim().length < 3) {
          return '用户名至少3个字符';
        }
        if (value.trim().length > 20) {
          return '用户名最多20个字符';
        }
        return null;
      },
    );
  }

  /// 构建密码输入框
  Widget _buildPasswordField() {
    return _buildInputField(
      controller: _passwordController,
      label: '密码',
      hintText: '请输入密码',
      prefixIcon: Icons.lock_outline,
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入密码';
        }
        if (value.length < 6) {
          return '密码至少6个字符';
        }
        return null;
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(prefixIcon, color: Colors.grey[600]),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建注册按钮
  Widget _buildRegisterButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _handleRegister,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              '注册',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  /// 构建登录链接
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '已有账号？',
          style: TextStyle(color: Colors.grey),
        ),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text(
            '立即登录',
            style: TextStyle(
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
