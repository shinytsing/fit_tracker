import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/models.dart';
import '../providers/message_provider.dart';

class MessageListItem extends ConsumerWidget {
  final Chat chat;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onVideoCall;
  
  const MessageListItem({
    super.key,
    required this.chat,
    this.onTap,
    this.onLongPress,
    this.onVideoCall,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: _buildAvatar(context),
      title: _buildTitle(context),
      subtitle: _buildSubtitle(context),
      trailing: _buildTrailing(context),
      onTap: onTap ?? () {
        // TODO: 导航到聊天页面
        Navigator.pushNamed(
          context,
          '/message/chat',
          arguments: {'chatId': chat.id},
        );
      },
      onLongPress: onLongPress,
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: chat.avatar?.isNotEmpty == true
              ? NetworkImage(chat.avatar!)
              : null,
          child: chat.avatar?.isEmpty != false
              ? Text(
                  chat.name.isNotEmpty ? chat.name[0].toUpperCase() : 'C',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            chat.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (chat.unreadCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${chat.unreadCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            chat.lastMessage ?? '暂无消息',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatTime(chat.lastMessageTime),
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 视频通话按钮
        if (onVideoCall != null)
          IconButton(
            icon: const Icon(Icons.videocam),
            iconSize: 20,
            color: Theme.of(context).primaryColor,
            onPressed: onVideoCall,
          ),
        
        // 状态图标
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (chat.isPinned)
              Icon(
                Icons.push_pin,
                size: 16,
                color: Colors.grey[400],
              ),
            if (chat.isMuted)
              Icon(
                Icons.volume_off,
                size: 16,
                color: Colors.grey[400],
              ),
          ],
        ),
      ],
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}
