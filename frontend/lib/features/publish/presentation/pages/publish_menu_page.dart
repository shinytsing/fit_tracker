import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/publish_option_card.dart';

/// 发布菜单页面 - 底部弹窗形式
/// 包含发布动态、快速打卡、分享心情/饮食等功能
/// 按照功能重排表实现：发布动态、快速打卡、分享心情/饮食、保存草稿
class PublishMenuPage extends ConsumerWidget {
  const PublishMenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 标题
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  '发布内容',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // 发布选项网格
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                // 发布动态 - 文字、图片、视频、训练成果
                PublishOptionCard(
                  icon: MdiIcons.text,
                  title: '发布动态',
                  subtitle: '文字、图片、视频、训练成果',
                  color: Colors.blue,
                  onTap: () => _navigateToCreatePost(context, 'dynamic'),
                ),
                PublishOptionCard(
                  icon: MdiIcons.camera,
                  title: '拍照打卡',
                  subtitle: '记录美好瞬间',
                  color: Colors.green,
                  onTap: () => _navigateToCreatePost(context, 'photo'),
                ),
                PublishOptionCard(
                  icon: MdiIcons.video,
                  title: '视频分享',
                  subtitle: '分享精彩视频',
                  color: Colors.red,
                  onTap: () => _navigateToCreatePost(context, 'video'),
                ),
                PublishOptionCard(
                  icon: MdiIcons.dumbbell,
                  title: '训练成果',
                  subtitle: '记录训练成果',
                  color: Colors.orange,
                  onTap: () => _navigateToCreatePost(context, 'workout'),
                ),
                // 快速打卡 - 一键记录训练完成情况
                PublishOptionCard(
                  icon: MdiIcons.checkCircle,
                  title: '快速打卡',
                  subtitle: '一键记录训练完成情况',
                  color: Colors.purple,
                  onTap: () => _quickCheckin(context),
                ),
                // 分享心情/饮食 - 轻量化内容
                PublishOptionCard(
                  icon: MdiIcons.food,
                  title: '分享心情/饮食',
                  subtitle: '轻量化内容分享',
                  color: Colors.teal,
                  onTap: () => _navigateToCreatePost(context, 'mood_nutrition'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 快速操作区域
          _buildQuickActions(context),
          
          const SizedBox(height: 20),
          
          // 草稿箱入口
          _buildDraftSection(context),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// 构建快速操作区域
  Widget _buildQuickActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '快速操作',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionItem(
                  icon: MdiIcons.heart,
                  label: '分享心情',
                  color: Colors.pink,
                  onTap: () => _shareMood(context),
                ),
              ),
              Expanded(
                child: _buildQuickActionItem(
                  icon: MdiIcons.food,
                  label: '饮食记录',
                  color: Colors.green,
                  onTap: () => _recordNutrition(context),
                ),
              ),
              Expanded(
                child: _buildQuickActionItem(
                  icon: MdiIcons.chartLine,
                  label: '训练数据',
                  color: Colors.cyan,
                  onTap: () => _shareTrainingData(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建快速操作项
  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建草稿箱区域 - 支持编辑、修改、再次发布
  Widget _buildDraftSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(
            MdiIcons.fileDocumentOutline,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '草稿箱',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _openDrafts(context),
            child: const Text('查看草稿'),
          ),
        ],
      ),
    );
  }

  // 导航方法
  void _navigateToCreatePost(BuildContext context, String type) {
    Navigator.pop(context); // 关闭弹窗
    Navigator.pushNamed(context, '/publish/create', arguments: type);
  }

  void _quickCheckin(BuildContext context) {
    Navigator.pop(context); // 关闭弹窗
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('快速打卡'),
        content: const Text('确定要完成今日训练打卡吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现快速打卡API调用
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('打卡成功！')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _shareMood(BuildContext context) {
    Navigator.pop(context); // 关闭弹窗
    Navigator.pushNamed(context, '/publish/create', arguments: 'mood');
  }

  void _recordNutrition(BuildContext context) {
    Navigator.pop(context); // 关闭弹窗
    Navigator.pushNamed(context, '/publish/create', arguments: 'nutrition');
  }

  void _shareTrainingData(BuildContext context) {
    Navigator.pop(context); // 关闭弹窗
    Navigator.pushNamed(context, '/publish/create', arguments: 'training_data');
  }

  void _openDrafts(BuildContext context) {
    Navigator.pop(context); // 关闭弹窗
    Navigator.pushNamed(context, '/publish/drafts');
  }
}
