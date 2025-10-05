import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/theme_provider.dart';
import '../core/providers/auth_provider.dart';
import '../widgets/figma/custom_button.dart';
import '../widgets/figma/stats_card.dart';
import '../widgets/figma/today_plan_card.dart';
import '../widgets/figma/ai_plan_generator.dart';
import '../widgets/figma/training_history_list.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TrainingScreen(),
    const CommunityScreen(),
    const MatesScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavigationItem> _navigationItems = [
    BottomNavigationItem(
      icon: Icons.fitness_center,
      label: '训练',
      route: '/main/training',
    ),
    BottomNavigationItem(
      icon: Icons.people,
      label: '社区',
      route: '/main/community',
    ),
    BottomNavigationItem(
      icon: Icons.favorite,
      label: '搭子',
      route: '/main/mates',
    ),
    BottomNavigationItem(
      icon: Icons.message,
      label: '消息',
      route: '/main/messages',
    ),
    BottomNavigationItem(
      icon: Icons.person,
      label: '我的',
      route: '/main/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isIOS = themeProvider.isIOS;

    // Check authentication state
    if (authProvider.authState != AuthState.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color: isSelected
                              ? ThemeProvider.primaryColor
                              : Colors.grey[600],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isIOS && isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? ThemeProvider.primaryColor
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavigationItem {
  final IconData icon;
  final String label;
  final String route;

  BottomNavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

// 训练屏幕 - 基于Figma设计
class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isIOS = themeProvider.isIOS;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '训练',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '让我们开始今天的训练吧！',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CustomIconButton(
                            icon: Icons.search,
                            onPressed: () {},
                            isIOS: isIOS,
                          ),
                          const SizedBox(width: 12),
                          Stack(
                            children: [
                              CustomIconButton(
                                icon: Icons.notifications_outlined,
                                onPressed: () {},
                                isIOS: isIOS,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Progress Stats
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          value: '12',
                          label: '本周训练',
                          isIOS: isIOS,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          value: '2.3k',
                          label: '消耗卡路里',
                          isIOS: isIOS,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          value: '85%',
                          label: '目标完成',
                          isIOS: isIOS,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Today's Plan
                    const TodayPlanCard(),
                    
                    const SizedBox(height: 16),
                    
                    // AI Plan Generator
                    const AIPlanGenerator(),
                    
                    const SizedBox(height: 16),
                    
                    // Training History
                    const TrainingHistoryList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 其他屏幕的占位符
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '社区页面',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

class MatesScreen extends StatelessWidget {
  const MatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '搭子页面',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '消息页面',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '个人页面',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}