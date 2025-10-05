import 'package:flutter/material.dart';
import 'dart:io';
import '../core/theme/app_theme.dart';

class CustomBottomNavigation extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChange;

  const CustomBottomNavigation({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: isIOS ? const Color(0xFFE5E7EB) : const Color(0xFFE5E7EB),
            width: isIOS ? 0.5 : 1,
          ),
        ),
        boxShadow: isIOS ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isIOS ? 20 : 16,
        vertical: isIOS ? 8 : 6,
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabButton(
              icon: Icons.fitness_center_rounded,
              label: '训练',
              tabId: 'training',
              isIOS: isIOS,
            ),
            _buildTabButton(
              icon: Icons.people_rounded,
              label: '社区',
              tabId: 'community',
              isIOS: isIOS,
            ),
            _buildTabButton(
              icon: Icons.favorite_rounded,
              label: '搭子',
              tabId: 'mates',
              isIOS: isIOS,
            ),
            _buildTabButton(
              icon: Icons.message_rounded,
              label: '消息',
              tabId: 'messages',
              isIOS: isIOS,
            ),
            _buildTabButton(
              icon: Icons.person_rounded,
              label: '我的',
              tabId: 'profile',
              isIOS: isIOS,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required IconData icon,
    required String label,
    required String tabId,
    required bool isIOS,
  }) {
    final isActive = activeTab == tabId;
    
    return GestureDetector(
      onTap: () => onTabChange(tabId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isIOS ? 12 : 8,
          vertical: isIOS ? 8 : 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
          color: isActive 
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                size: isIOS ? 26 : 24,
                color: isActive 
                    ? AppTheme.primaryColor 
                    : const Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: isIOS ? 4 : 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isIOS ? 12 : 10,
                color: isActive 
                    ? AppTheme.primaryColor 
                    : const Color(0xFF6B7280),
                fontWeight: isActive 
                    ? (isIOS ? FontWeight.w600 : FontWeight.w500)
                    : (isIOS ? FontWeight.w500 : FontWeight.w400),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
