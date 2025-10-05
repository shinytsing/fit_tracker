import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  
  // Form data
  final _nameController = TextEditingController();
  int? _height;
  int? _weight;
  String? _experience;
  String? _goal;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isIOS = themeProvider.themeType == ThemeType.ios;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / 3,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        ThemeProvider.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_currentStep + 1}/3',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildPersonalInfoStep(context, isIOS),
                  _buildFitnessGoalStep(context, isIOS),
                  _buildCompleteStep(context, isIOS),
                ],
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: CustomButton(
                        text: '上一步',
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        isIOS: isIOS,
                        backgroundColor: Colors.grey[200],
                        textColor: Colors.grey[700],
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: _currentStep == 2 ? '完成' : '下一步',
                      onPressed: () {
                        if (_currentStep == 2) {
                          // Complete onboarding
                          authProvider.completeOnboarding(
                            height: _height ?? 170,
                            weight: _weight ?? 70,
                            experience: _experience ?? '初级',
                            goal: _goal ?? '减脂',
                          );
                          context.go('/main');
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      isIOS: isIOS,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep(BuildContext context, bool isIOS) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '设置个人信息',
            style: TextStyle(
              fontSize: 28,
              fontWeight: isIOS ? FontWeight.w700 : FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '告诉我们一些关于你的基本信息',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Name Input
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '姓名',
              hintText: '请输入您的姓名',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Height and Weight
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '身高 (cm)',
                    hintText: '170',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                    ),
                  ),
                  onChanged: (value) {
                    _height = int.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '体重 (kg)',
                    hintText: '70',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                    ),
                  ),
                  onChanged: (value) {
                    _weight = int.tryParse(value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessGoalStep(BuildContext context, bool isIOS) {
    final experienceOptions = ['初级', '中级', '高级'];
    final goalOptions = ['减脂', '增肌', '塑形', '保持健康'];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择健身目标',
            style: TextStyle(
              fontSize: 28,
              fontWeight: isIOS ? FontWeight.w700 : FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '选择你的健身目标，我们会为你推荐合适的计划',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Experience Level
          Text(
            '健身经验',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: experienceOptions.map((option) {
              final isSelected = _experience == option;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _experience = option;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? ThemeProvider.primaryColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? ThemeProvider.primaryColor : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Goal
          Text(
            '健身目标',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: goalOptions.map((option) {
              final isSelected = _goal == option;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _goal = option;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? ThemeProvider.primaryColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? ThemeProvider.primaryColor : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteStep(BuildContext context, bool isIOS) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 48),
          
          Text(
            '完成设置',
            style: TextStyle(
              fontSize: 28,
              fontWeight: isIOS ? FontWeight.w700 : FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          Text(
            '一切准备就绪！开始你的健身之旅吧',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}