import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';

/// 设置列表组件
/// 显示用户的各种设置选项
class SettingsList extends StatelessWidget {
  final List<Setting> settings;
  final Function(Setting) onSettingTap;

  const SettingsList({
    super.key,
    required this.settings,
    required this.onSettingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '设置',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // 按类别分组设置
        ..._groupSettingsByCategory().entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.key.isNotEmpty) ...[
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: entry.value.asMap().entries.map((item) {
                    final setting = item.value;
                    final isLast = item.key == entry.value.length - 1;
                    
                    return Column(
                      children: [
                        _buildSettingItem(setting),
                        if (!isLast) const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ],
    );
  }

  /// 按类别分组设置
  Map<String, List<Setting>> _groupSettingsByCategory() {
    final Map<String, List<Setting>> grouped = {};
    
    for (final setting in settings) {
      if (!grouped.containsKey(setting.category)) {
        grouped[setting.category] = [];
      }
      grouped[setting.category]!.add(setting);
    }
    
    return grouped;
  }

  /// 构建设置项
  Widget _buildSettingItem(Setting setting) {
    return ListTile(
      leading: Icon(
        _getIconFromString(setting.icon ?? 'settings'),
        color: _getColorFromString(setting.color ?? AppTheme.primary.toString()),
        size: 20,
      ),
      title: Text(
        setting.title ?? setting.name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: (setting.subtitle?.isNotEmpty ?? false)
          ? Text(
              setting.subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: _buildSettingTrailing(setting),
      onTap: () => onSettingTap(setting),
    );
  }

  /// 构建设置项尾部
  Widget _buildSettingTrailing(Setting setting) {
    switch (setting.type) {
      case SettingType.switchSetting:
        return Switch(
          value: setting.switchValue ?? false,
          onChanged: (value) {
            // TODO: 处理开关状态变化
          },
          activeColor: AppTheme.primary,
        );
      
      case SettingType.badgeSetting:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (setting.badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getColorFromString(setting.badgeColor ?? AppTheme.primary.toString()),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  setting.badge!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 16,
            ),
          ],
        );
      
      case SettingType.valueSetting:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              setting.value ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 16,
            ),
          ],
        );
      
      case SettingType.dangerousSetting:
        return const Icon(
          Icons.chevron_right,
          color: Colors.red,
          size: 16,
        );
      
      default:
        return const Icon(
          Icons.chevron_right,
          color: Colors.grey,
          size: 16,
        );
    }
  }

  /// 从字符串获取图标
  IconData _getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'account':
        return Icons.person;
      case 'notification':
        return Icons.notifications;
      case 'privacy':
        return Icons.privacy_tip;
      case 'security':
        return Icons.security;
      case 'language':
        return Icons.language;
      case 'theme':
        return Icons.palette;
      case 'about':
        return Icons.info;
      case 'help':
        return Icons.help;
      case 'feedback':
        return Icons.feedback;
      case 'logout':
        return Icons.logout;
      default:
        return Icons.settings;
    }
  }

  /// 从字符串获取颜色
  Color _getColorFromString(String colorString) {
    // 简单的颜色解析，可以根据需要扩展
    if (colorString.contains('primary')) {
      return AppTheme.primary;
    } else if (colorString.contains('red')) {
      return Colors.red;
    } else if (colorString.contains('green')) {
      return Colors.green;
    } else if (colorString.contains('blue')) {
      return Colors.blue;
    } else if (colorString.contains('orange')) {
      return Colors.orange;
    }
    return AppTheme.primary;
  }
}
