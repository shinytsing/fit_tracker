import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isIOS = themeProvider.themeType == ThemeType.ios;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isIOS ? Colors.black : Colors.grey[600],
          ),
          onPressed: () {
            authProvider.setAuthState(AuthState.login);
          },
        ),
        title: Text(
          '注册',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              
              Text(
                '创建账户',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: isIOS ? FontWeight.w700 : FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                '输入您的手机号码和密码',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),

              // Phone Number Input
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: '手机号码',
                  hintText: '请输入手机号码',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Password Input
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '密码',
                  hintText: '请输入密码',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Register Button
              CustomButton(
                text: '注册',
                onPressed: () {
                  // Mock register - set user and navigate to onboarding
                  authProvider.register(_phoneController.text, _passwordController.text, '用户');
                  context.go('/onboarding');
                },
                isIOS: isIOS,
              ),
              const SizedBox(height: 24),

              // Terms Agreement
              Row(
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
                        color: _agreedToTerms ? ThemeProvider.primaryColor : Colors.transparent,
                        border: Border.all(
                          color: _agreedToTerms ? ThemeProvider.primaryColor : Colors.grey[400]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _agreedToTerms
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        children: const [
                          TextSpan(text: '我已阅读并同意'),
                          TextSpan(
                            text: '《用户协议》',
                            style: TextStyle(
                              color: ThemeProvider.primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: '和'),
                          TextSpan(
                            text: '《隐私政策》',
                            style: TextStyle(
                              color: ThemeProvider.primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Login Link
              Center(
                child: GestureDetector(
                  onTap: () {
                    authProvider.setAuthState(AuthState.login);
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      children: const [
                        TextSpan(text: '已有账户？'),
                        TextSpan(
                          text: '立即登录',
                          style: TextStyle(
                            color: ThemeProvider.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}