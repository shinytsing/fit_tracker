import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/post_provider.dart';

class PostTypeSelector extends StatelessWidget {
  final PostType selectedType;
  final Function(PostType) onTypeChanged;

  const PostTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择类型',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTypeButton(
                context,
                PostType.text,
                MdiIcons.text,
                '文字',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTypeButton(
                context,
                PostType.image,
                MdiIcons.image,
                '图片',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTypeButton(
                context,
                PostType.video,
                MdiIcons.video,
                '视频',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTypeButton(
                context,
                PostType.workout,
                MdiIcons.dumbbell,
                '训练',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton(
    BuildContext context,
    PostType type,
    IconData icon,
    String label,
  ) {
    final isSelected = selectedType == type;
    
    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
            ? AppTheme.primaryColor.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
              ? AppTheme.primaryColor
              : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                ? AppTheme.primaryColor
                : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                  ? AppTheme.primaryColor
                  : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
