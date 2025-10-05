import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../training/training_screen.dart';
import '../community/community_screen.dart';
import '../mates/mates_screen.dart';
import '../messages/messages_screen.dart';
import '../profile/profile_screen.dart';

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
    final isIOS = themeProvider.themeType == ThemeType.ios;

    // Check authentication state
    if (authProvider.authState == AuthState.login) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (authProvider.authState == AuthState.onboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/onboarding');
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                          Flexible(
                            child: Text(
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
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
