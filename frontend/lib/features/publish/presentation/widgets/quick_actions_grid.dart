import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';

/// 快速操作网格组件
/// 提供常用的快速发布操作入口
class QuickActionsGrid extends StatelessWidget {
  final Function(String action) onActionTap;

  const QuickActionsGrid({
    super.key,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            icon: MdiIcons.camera,
            label: '拍照',
            color: Colors.green,
            onTap: () => onActionTap('camera'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            icon: MdiIcons.video,
            label: '视频',
            color: Colors.red,
            onTap: () => onActionTap('video'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            icon: MdiIcons.dumbbell,
            label: '训练',
            color: Colors.orange,
            onTap: () => onActionTap('workout'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            icon: MdiIcons.checkCircle,
            label: '打卡',
            color: Colors.purple,
            onTap: () => onActionTap('checkin'),
          ),
        ),
      ],
    );
  }

  /// 构建快速操作按钮
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
