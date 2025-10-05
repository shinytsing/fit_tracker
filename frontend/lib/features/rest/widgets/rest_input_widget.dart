import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class RestInputWidget extends StatefulWidget {
  final Function(String content, String? imageUrl, String type) onPost;
  final bool isLoading;

  const RestInputWidget({
    super.key,
    required this.onPost,
    required this.isLoading,
  });

  @override
  State<RestInputWidget> createState() => _RestInputWidgetState();
}

class _RestInputWidgetState extends State<RestInputWidget> {
  final TextEditingController _controller = TextEditingController();
  String _selectedType = 'rest';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '快速发帖',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // 类型选择
          Row(
            children: [
              _buildTypeChip('rest', '动态', Icons.fitness_center),
              const SizedBox(width: 8),
              _buildTypeChip('joke', '段子', Icons.sentiment_very_satisfied),
              const SizedBox(width: 8),
              _buildTypeChip('knowledge', '知识', Icons.lightbulb_outline),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 输入框
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: _getHintText(),
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
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 3,
            maxLength: 50,
          ),
          
          const SizedBox(height: 16),
          
          // 发布按钮
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: widget.isLoading || _controller.text.trim().isEmpty
                  ? null
                  : () => _publishPost(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '发布',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHintText() {
    switch (_selectedType) {
      case 'joke':
        return '分享一个健身段子...';
      case 'knowledge':
        return '分享健身小知识...';
      default:
        return '分享你的训练感受...';
    }
  }

  void _publishPost() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    widget.onPost(content, null, _selectedType);
    _controller.clear();
  }
}
