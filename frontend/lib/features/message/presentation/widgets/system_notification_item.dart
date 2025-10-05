import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/models.dart';
import '../providers/message_provider.dart';

class SystemNotificationItem extends ConsumerWidget {
  final NotificationItem notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkRead;
  
  const SystemNotificationItem({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: _buildNotificationIcon(context),
        title: _buildTitle(context),
        subtitle: _buildSubtitle(context),
        trailing: _buildTrailing(context),
        onTap: onTap ?? () => _handleNotificationTap(context, ref),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;
    
    switch (notification.type) {
      case 'like':
        iconData = Icons.favorite;
        iconColor = Colors.red;
        break;
      case 'comment':
        iconData = Icons.comment;
        iconColor = Colors.blue;
        break;
      case 'follow':
        iconData = Icons.person_add;
        iconColor = Colors.green;
        break;
      case 'challenge':
        iconData = Icons.emoji_events;
        iconColor = Colors.orange;
        break;
      case 'achievement':
        iconData = Icons.stars;
        iconColor = Colors.amber;
        break;
      case 'system':
        iconData = Icons.notifications;
        iconColor = Colors.grey;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }
    
    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      notification.title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (notification.content?.isNotEmpty == true) ...[
          Text(
            notification.content!,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
        ],
        Text(
          _formatTime(notification.createdAt),
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!notification.isRead)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime time) {
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

  void _handleNotificationTap(BuildContext context, WidgetRef ref) {
    // 标记为已读
    if (!notification.isRead) {
      ref.read(messageProvider.notifier).markNotificationRead(notification.id);
    }
    
    // 根据通知类型导航到相应页面
    switch (notification.type) {
      case NotificationType.like:
      case NotificationType.comment:
        if (notification.data?['post_id'] != null) {
          Navigator.pushNamed(
            context,
            '/community/post-detail',
            arguments: {'postId': notification.data!['post_id']},
          );
        }
        break;
      case NotificationType.follow:
        if (notification.data?['user_id'] != null) {
          Navigator.pushNamed(
            context,
            '/community/user-profile',
            arguments: {'userId': notification.data!['user_id']},
          );
        }
        break;
      case NotificationType.challenge:
        if (notification.data?['challenge_id'] != null) {
          Navigator.pushNamed(
            context,
            '/community/challenge-detail',
            arguments: {'challengeId': notification.data!['challenge_id']},
          );
        }
        break;
      case NotificationType.achievement:
        Navigator.pushNamed(context, '/profile/achievements');
        break;
      case NotificationType.system:
        // 系统通知可能不需要特殊导航
        break;
      case NotificationType.workout:
        Navigator.pushNamed(context, '/training');
        break;
      case NotificationType.message:
        Navigator.pushNamed(context, '/message');
        break;
    }
  }
}
