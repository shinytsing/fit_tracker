import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/theme/app_theme.dart';

class BottomNavigation extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChange;
  final VoidCallback onFloatingButtonClick;

  const BottomNavigation({
    super.key,
    required this.activeTab,
    required this.onTabChange,
    required this.onFloatingButtonClick,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _TabItem(id: 'training', icon: MdiIcons.dumbbell, label: '训练'),
      _TabItem(id: 'community', icon: MdiIcons.accountGroup, label: '社区'),
      _TabItem(id: 'center', icon: MdiIcons.plus, label: '', isFloating: true),
      _TabItem(id: 'messages', icon: MdiIcons.messageText, label: '消息'),
      _TabItem(id: 'profile', icon: MdiIcons.account, label: '我的'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: tabs.map((tab) {
            if (tab.isFloating) {
              return GestureDetector(
                onTap: onFloatingButtonClick,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: AppTheme.floatingShadow,
                  ),
                  child: Icon(
                    tab.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            }

            final isActive = activeTab == tab.id;
            return GestureDetector(
              onTap: () => onTabChange(tab.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab.icon,
                      color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary,
                      size: 24,
                    ),
                    if (tab.label.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TabItem {
  final String id;
  final IconData icon;
  final String label;
  final bool isFloating;

  _TabItem({
    required this.id,
    required this.icon,
    required this.label,
    this.isFloating = false,
  });
}
