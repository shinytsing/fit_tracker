import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/models.dart';
import '../providers/message_provider.dart';

class ChatHeader extends ConsumerWidget {
  final Chat chat;
  final VoidCallback? onBackPressed;
  final VoidCallback? onMorePressed;
  
  const ChatHeader({
    super.key,
    required this.chat,
    this.onBackPressed,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 返回按钮
          IconButton(
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          
          // 用户信息
          Expanded(
            child: GestureDetector(
              onTap: () => _showUserProfile(context),
              child: Row(
                children: [
                  // 头像
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: chat.avatar?.isNotEmpty == true
                            ? NetworkImage(chat.avatar!)
                            : null,
                        child: chat.avatar?.isEmpty != false
                            ? Text(
                                chat.name.isNotEmpty ? chat.name[0].toUpperCase() : 'C',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              )
                            : null,
                      ),
                      if (chat.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 用户信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          chat.isOnline ? '在线' : '离线',
                          style: TextStyle(
                            color: chat.isOnline ? Colors.green : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 更多按钮
          IconButton(
            onPressed: onMorePressed ?? () => _showMoreOptions(context),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  void _showUserProfile(BuildContext context) {
    // TODO: 导航到用户详情页面
    Navigator.pushNamed(
      context,
      '/community/user-profile',
      arguments: {'userId': chat.id},
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildMoreOptionsSheet(context),
    );
  }

  Widget _buildMoreOptionsSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '更多选项',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // 选项列表
          _buildOptionItem(
            context,
            Icons.volume_off,
            chat.isMuted ? '取消静音' : '静音',
            () => _toggleMute(context),
          ),
          _buildOptionItem(
            context,
            Icons.push_pin,
            chat.isPinned ? '取消置顶' : '置顶',
            () => _togglePin(context),
          ),
          _buildOptionItem(
            context,
            Icons.block,
            '屏蔽用户',
            () => _blockUser(context),
          ),
          _buildOptionItem(
            context,
            Icons.report,
            '举报',
            () => _reportUser(context),
          ),
          _buildOptionItem(
            context,
            Icons.delete,
            '删除聊天',
            () => _deleteChat(context),
            isDestructive: true,
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }

  void _toggleMute(BuildContext context) {
    // TODO: 切换静音状态
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(chat.isMuted ? '已取消静音' : '已静音'),
      ),
    );
  }

  void _togglePin(BuildContext context) {
    // TODO: 切换置顶状态
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(chat.isPinned ? '已取消置顶' : '已置顶'),
      ),
    );
  }

  void _blockUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('屏蔽用户'),
        content: Text('确定要屏蔽 ${chat.name} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 屏蔽用户
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已屏蔽用户')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _reportUser(BuildContext context) {
    // TODO: 举报用户
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('举报已提交')),
    );
  }

  void _deleteChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除聊天'),
        content: const Text('确定要删除这个聊天吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 删除聊天
              Navigator.of(context).pop(); // 返回上一页
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('聊天已删除')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
