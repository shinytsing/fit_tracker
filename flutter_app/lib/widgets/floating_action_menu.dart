import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class FloatingActionMenu extends ConsumerWidget {
  final bool isOpen;
  final VoidCallback onClose;

  const FloatingActionMenu({
    super.key,
    required this.isOpen,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedOpacity(
      opacity: isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: isOpen
          ? Stack(
              children: [
                // 背景遮罩
                Positioned.fill(
                  child: GestureDetector(
                    onTap: onClose,
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
                // 菜单内容
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '发布内容',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              GestureDetector(
                                onTap: onClose,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Color(0xFF6B7280),
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildMenuItem(
                            icon: Icons.fitness_center,
                            title: '发布训练',
                            subtitle: '记录你的训练成果',
                            color: const Color(0xFF3B82F6),
                            onTap: () {
                              onClose();
                              _showCreatePostDialog(context, ref, 'workout');
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildMenuItem(
                            icon: Icons.restaurant,
                            title: '发布饮食',
                            subtitle: '分享健康饮食',
                            color: const Color(0xFF10B981),
                            onTap: () {
                              onClose();
                              _showCreatePostDialog(context, ref, 'nutrition');
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildMenuItem(
                            icon: Icons.edit,
                            title: '发布动态',
                            subtitle: '分享你的生活',
                            color: const Color(0xFF8B5CF6),
                            onTap: () {
                              onClose();
                              _showCreatePostDialog(context, ref, 'general');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
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

  void _showCreatePostDialog(BuildContext context, WidgetRef ref, String type) {
    final TextEditingController contentController = TextEditingController();
    final communityNotifier = ref.read(communityProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getPostTypeTitle(type)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: _getPostTypeHint(type),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (contentController.text.trim().isNotEmpty) {
                try {
                  await communityNotifier.createPost(
                    content: contentController.text.trim(),
                    type: type,
                    tags: _getPostTypeTags(type),
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('发布成功！'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('发布失败: $e'),
                        backgroundColor: const Color(0xFFEF4444),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('发布'),
          ),
        ],
      ),
    );
  }

  String _getPostTypeTitle(String type) {
    switch (type) {
      case 'workout':
        return '发布训练动态';
      case 'nutrition':
        return '发布饮食动态';
      case 'general':
        return '发布动态';
      default:
        return '发布动态';
    }
  }

  String _getPostTypeHint(String type) {
    switch (type) {
      case 'workout':
        return '分享你的训练心得...';
      case 'nutrition':
        return '分享你的健康饮食...';
      case 'general':
        return '分享你的生活动态...';
      default:
        return '分享你的动态...';
    }
  }

  List<String> _getPostTypeTags(String type) {
    switch (type) {
      case 'workout':
        return ['#训练', '#健身'];
      case 'nutrition':
        return ['#饮食', '#健康'];
      case 'general':
        return ['#生活', '#分享'];
      default:
        return [];
    }
  }
}
