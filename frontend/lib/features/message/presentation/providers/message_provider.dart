import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/models/models.dart';

part 'message_provider.freezed.dart';

@freezed
class MessageState with _$MessageState {
  const factory MessageState({
    @Default(false) bool isLoading,
    @Default([]) List<Chat> chats,
    @Default([]) List<Group> groups,
    @Default([]) List<NotificationItem> notifications,
    @Default([]) List<NotificationItem> systemMessages,
    @Default(false) bool isConnected,
    @Default(0) int unreadMessagesCount,
    @Default(0) int unreadNotificationsCount,
    @Default(0) int groupsCount,
    @Default(0) int videoCallsCount,
    String? error,
  }) = _MessageState;
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

// Provider
final messageProvider = StateNotifierProvider<MessageNotifier, MessageState>(
  (ref) => MessageNotifier(),
);

class MessageNotifier extends StateNotifier<MessageState> {
  MessageNotifier() : super(const MessageState()) {
    _initializeWebSocket();
    _loadInitialData();
  }

  void _initializeWebSocket() {
    // TODO: 初始化WebSocket连接
    state = state.copyWith(isConnected: true);
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      refreshChats(),
      refreshNotifications(),
      refreshSystemMessages(),
    ]);
  }

  Future<void> refreshChats() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // TODO: 从API加载聊天列表
      await Future.delayed(const Duration(seconds: 1));
      
      final chats = _generateMockChats();
      state = state.copyWith(
        isLoading: false,
        chats: chats,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshNotifications() async {
    try {
      // TODO: 从API加载通知
      await Future.delayed(const Duration(milliseconds: 500));
      
      final notifications = _generateMockNotifications();
      state = state.copyWith(notifications: notifications);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refreshSystemMessages() async {
    try {
      // TODO: 从API加载系统消息
      await Future.delayed(const Duration(milliseconds: 500));
      
      final systemMessages = _generateMockSystemMessages();
      state = state.copyWith(systemMessages: systemMessages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final updatedNotifications = state.notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();

    state = state.copyWith(notifications: updatedNotifications);
    
    // TODO: 调用API标记为已读
  }

  Future<void> clearAllNotifications() async {
    state = state.copyWith(notifications: []);
    // TODO: 调用API清空通知
  }

  Future<void> clearAllSystemMessages() async {
    state = state.copyWith(systemMessages: []);
    // TODO: 调用API清空系统消息
  }

  Future<void> refreshGroups() async {
    // TODO: 实现群组刷新
  }

  Future<void> markAllAsRead() async {
    final updatedNotifications = state.notifications.map((notification) {
      return notification.copyWith(isRead: true);
    }).toList();
    state = state.copyWith(notifications: updatedNotifications);
  }

  Future<void> markChatRead(String chatId) async {
    // TODO: 实现标记聊天为已读
  }

  Future<void> toggleChatNotification(String chatId) async {
    // TODO: 实现切换聊天通知
  }

  Future<void> toggleGroupNotification(String groupId) async {
    // TODO: 实现切换群组通知
  }

  Future<void> markNotificationRead(String notificationId) async {
    final updatedNotifications = state.notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
    state = state.copyWith(notifications: updatedNotifications);
  }

  Future<void> leaveGroup(String groupId) async {
    try {
      // TODO: Call API to leave group
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updatedGroups = state.groups.where((g) => g.id != groupId).toList();
      state = state.copyWith(
        groups: updatedGroups,
        groupsCount: updatedGroups.length,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addMessage(Message message) async {
    try {
      // TODO: Send message to backend
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Update local state
      final updatedChats = state.chats.map((chat) {
        if (chat.id == message.chatId) {
          return chat.copyWith(
            lastMessage: message.content,
            lastMessageTime: message.timestamp,
            unreadCount: chat.unreadCount + 1,
          );
        }
        return chat;
      }).toList();
      
      state = state.copyWith(
        chats: updatedChats,
        unreadMessagesCount: state.unreadMessagesCount + 1,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteChat(String chatId) async {
    // TODO: 实现删除聊天
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true);
    // TODO: 实现数据加载
  }

  List<Chat> _generateMockChats() {
    return List.generate(8, (index) {
      return Chat(
        id: 'chat_$index',
        name: '用户${index + 1}',
        avatar: 'https://via.placeholder.com/40',
        lastMessage: index % 3 == 0 
          ? '今天训练怎么样？' 
          : index % 3 == 1 
            ? '一起健身吧！' 
            : '加油！💪',
        lastMessageTime: DateTime.now().subtract(Duration(hours: index)),
        unreadCount: index % 4 == 0 ? 0 : index % 3,
        isOnline: index % 2 == 0,
        isPinned: index == 0,
        isMuted: index == 1,
      );
    });
  }

  List<NotificationItem> _generateMockNotifications() {
    return List.generate(10, (index) {
      final types = [
        'like',
        'comment',
        'follow',
        'workout',
        'achievement',
      ];
      
      return NotificationItem(
        id: 'notification_$index',
        title: _getNotificationTitle(types[index % types.length]),
        content: _getNotificationContent(types[index % types.length]),
        type: types[index % types.length],
        createdAt: DateTime.now().subtract(Duration(hours: index)),
        isRead: index % 3 == 0,
      );
    });
  }

  List<NotificationItem> _generateMockSystemMessages() {
    return List.generate(5, (index) {
      return NotificationItem(
        id: 'system_$index',
        title: '系统通知',
        content: '欢迎使用FitTracker！完成个人资料设置可获得更多个性化推荐。',
        type: 'system',
        createdAt: DateTime.now().subtract(Duration(days: index)),
        isRead: index % 2 == 0,
      );
    });
  }

  String _getNotificationTitle(String type) {
    switch (type) {
      case 'like':
        return '点赞通知';
      case 'comment':
        return '评论通知';
      case 'follow':
        return '关注通知';
      case 'workout':
        return '训练提醒';
      case 'achievement':
        return '成就解锁';
      case 'system':
        return '系统通知';
      case 'promotion':
        return '活动通知';
      default:
        return '通知';
    }
  }

  String _getNotificationContent(String type) {
    switch (type) {
      case 'like':
        return '用户点赞了您的训练记录';
      case 'comment':
        return '用户评论了您的动态';
      case 'follow':
        return '用户关注了您';
      case 'workout':
        return '该进行今天的训练了！';
      case 'achievement':
        return '恭喜！您解锁了新成就';
      case 'system':
        return '系统维护通知';
      case 'promotion':
        return '限时活动开始啦！';
      default:
        return '您有一条新通知';
    }
  }
}
