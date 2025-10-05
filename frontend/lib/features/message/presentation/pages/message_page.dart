import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';
import '../../../../shared/widgets/custom_widgets.dart';
import '../providers/message_provider.dart';
import '../widgets/message_list_item.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input_bar.dart';
import '../widgets/system_notification_item.dart';
import '../widgets/chat_header.dart';

/// Tab3 - 消息页面
/// 按照功能重排表实现：
/// - 私信聊天：一对一聊天（文字、图片、语音）
/// - 系统通知：点赞、评论、关注提醒、平台公告
/// - 实时通信：WebSocket 推送
/// - 消息管理：搜索、分类、删除、置顶
class MessagePage extends ConsumerStatefulWidget {
  const MessagePage({super.key});

  @override
  ConsumerState<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends ConsumerState<MessagePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    
    // 加载初始数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messageProvider.notifier).loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messageState = ref.watch(messageProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '消息',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          // 搜索按钮
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
          // 更多操作
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleMenuAction(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read, size: 16),
                    SizedBox(width: 8),
                    Text('全部标记为已读'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 16),
                    SizedBox(width: 8),
                    Text('消息设置'),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '聊天', icon: Icon(Icons.chat)),
            Tab(text: '通知', icon: Icon(Icons.notifications)),
            Tab(text: '群聊', icon: Icon(Icons.group)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 顶部统计区域
          _buildStatsSection(messageState),
          
          // Tab内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: 聊天列表
                _buildChatsTab(messageState),
                
                // Tab 2: 系统通知
                _buildNotificationsTab(messageState),
                
                // Tab 3: 群聊列表
                _buildGroupsTab(messageState),
              ],
            ),
          ),
        ],
      ),
      // 浮动操作按钮 - 新建聊天
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewChatDialog(context);
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 构建统计区域
  Widget _buildStatsSection(MessageState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: MdiIcons.message,
              label: '未读消息',
              value: '${state.unreadMessagesCount}',
              color: Colors.red,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              icon: MdiIcons.bell,
              label: '未读通知',
              value: '${state.unreadNotificationsCount}',
              color: Colors.orange,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              icon: MdiIcons.accountGroup,
              label: '群聊数量',
              value: '${state.groupsCount}',
              color: Colors.blue,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              icon: MdiIcons.video,
              label: '视频通话',
              value: '${state.videoCallsCount}',
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建聊天Tab
  Widget _buildChatsTab(MessageState state) {
    if (state.isLoading && state.chats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.chats.isEmpty) {
      return _buildErrorWidget(state.error!);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(messageProvider.notifier).refreshChats();
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: state.chats.length,
        itemBuilder: (context, index) {
          final chat = state.chats[index];
          return MessageListItem(
            chat: chat,
            onTap: () {
              _navigateToChat(chat);
            },
            onLongPress: () {
              _showChatOptions(chat);
            },
          );
        },
      ),
    );
  }

  /// 构建通知Tab
  Widget _buildNotificationsTab(MessageState state) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.notifications.isEmpty) {
      return _buildErrorWidget(state.error!);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(messageProvider.notifier).refreshNotifications();
      },
      child: ListView.builder(
        itemCount: state.notifications.length,
        itemBuilder: (context, index) {
          final notification = state.notifications[index];
          return SystemNotificationItem(
            notification: notification,
            onTap: () {
              _handleNotificationTap(notification);
            },
            onMarkRead: () {
              ref.read(messageProvider.notifier).markNotificationRead(notification.id);
            },
          );
        },
      ),
    );
  }

  /// 构建群聊Tab
  Widget _buildGroupsTab(MessageState state) {
    if (state.isLoading && state.groups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.groups.isEmpty) {
      return _buildErrorWidget(state.error!);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(messageProvider.notifier).refreshGroups();
      },
      child: ListView.builder(
        itemCount: state.groups.length,
        itemBuilder: (context, index) {
          final group = state.groups[index];
          return MessageListItem(
            chat: group.toChat(),
            onTap: () {
              _navigateToGroupChat(group);
            },
            onLongPress: () {
              _showGroupOptions(group);
            },
          );
        },
      ),
    );
  }

  /// 构建错误组件
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('加载失败: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(messageProvider.notifier).loadInitialData();
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  // 事件处理方法
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索消息'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: '搜索聊天记录、联系人...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现搜索功能
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'mark_all_read':
        ref.read(messageProvider.notifier).markAllAsRead();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('全部标记为已读')),
        );
        break;
      case 'settings':
        Navigator.pushNamed(context, '/messages/settings');
        break;
    }
  }

  void _showNewChatDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '新建聊天',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('添加联系人'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/messages/add-contact');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('创建群聊'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/messages/create-group');
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('扫一扫'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/messages/scan-qr');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToChat(Chat chat) {
    Navigator.pushNamed(context, '/messages/chat', arguments: chat);
  }

  void _navigateToGroupChat(Group group) {
    Navigator.pushNamed(context, '/messages/group-chat', arguments: group);
  }

  void _showChatOptions(Chat chat) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mark_email_read),
              title: const Text('标记为已读'),
              onTap: () {
                Navigator.pop(context);
                ref.read(messageProvider.notifier).markChatRead(chat.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off),
              title: const Text('关闭通知'),
              onTap: () {
                Navigator.pop(context);
                ref.read(messageProvider.notifier).toggleChatNotification(chat.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('删除聊天'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteChatDialog(chat);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupOptions(Group group) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('群信息'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/messages/group-info', arguments: group);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off),
              title: const Text('关闭通知'),
              onTap: () {
                Navigator.pop(context);
                ref.read(messageProvider.notifier).toggleGroupNotification(group.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('退出群聊'),
              onTap: () {
                Navigator.pop(context);
                _showLeaveGroupDialog(group);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    ref.read(messageProvider.notifier).markNotificationRead(notification.id);
    
    // 根据通知类型跳转到相应页面
    switch (notification.type) {
      case 'like':
      case 'comment':
        Navigator.pushNamed(context, '/community/post-detail', arguments: notification.data?['post_id']);
        break;
      case 'follow':
        Navigator.pushNamed(context, '/community/user-profile', arguments: notification.data?['user_id']);
        break;
      case 'challenge':
        Navigator.pushNamed(context, '/community/challenge-detail', arguments: notification.data?['challenge_id']);
        break;
      default:
        break;
    }
  }

  void _showDeleteChatDialog(Chat chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除聊天'),
        content: const Text('确定要删除这个聊天吗？删除后将无法恢复聊天记录。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(messageProvider.notifier).deleteChat(chat.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('聊天已删除')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showLeaveGroupDialog(Group group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出群聊'),
        content: Text('确定要退出 "${group.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(messageProvider.notifier).leaveGroup(group.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已退出群聊')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}