import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart' as models;
import '../../../../shared/widgets/custom_widgets.dart';
import '../providers/message_provider.dart';
import '../widgets/message_list_item.dart';
import '../widgets/video_message_widget.dart';
import '../widgets/video_call_widget.dart';
import '../widgets/video_recorder_widget.dart';

/// 小红书风格的消息页面
/// 包含搜索栏、消息分类、消息列表、视频消息、视频通话功能
class XiaohongshuMessagePage extends ConsumerStatefulWidget {
  const XiaohongshuMessagePage({super.key});

  @override
  ConsumerState<XiaohongshuMessagePage> createState() => _XiaohongshuMessagePageState();
}

class _XiaohongshuMessagePageState extends ConsumerState<XiaohongshuMessagePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 加载初始数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messageProvider.notifier).loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messageState = ref.watch(messageProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 顶部状态栏和标题栏
          _buildTopBar(),
          
          // 搜索栏
          _buildSearchBar(),
          
          // 快速分类按钮
          _buildQuickCategories(),
          
          // 消息列表
          Expanded(
            child: _buildMessageList(messageState),
          ),
          
          // 通知横幅
          _buildNotificationBanner(),
        ],
      ),
      // 底部导航栏
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// 构建顶部状态栏和标题栏
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 44, 16, 16), // 包含状态栏高度
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧时间
          Text(
            '08:35',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          
          // 中间标题
          const Text(
            '消息',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          // 右侧图标
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                child: Icon(
                  MdiIcons.magnify,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _showNewMessageDialog,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isSearching ? 50 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _isSearching
          ? TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索用户或消息',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(MdiIcons.magnify, color: Colors.grey[400]),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                  child: Icon(MdiIcons.close, color: Colors.grey[400]),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            )
          : const SizedBox.shrink(),
    );
  }

  /// 构建快速分类按钮
  Widget _buildQuickCategories() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildCategoryButton(
              icon: MdiIcons.heart,
              label: '赞和收藏',
              color: Colors.red,
              onTap: () {
                _tabController.animateTo(0);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildCategoryButton(
              icon: MdiIcons.accountPlus,
              label: '新增关注',
              color: Colors.blue,
              onTap: () {
                _tabController.animateTo(1);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildCategoryButton(
              icon: MdiIcons.commentText,
              label: '评论和@',
              color: Colors.green,
              onTap: () {
                _tabController.animateTo(2);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建消息列表
  Widget _buildMessageList(MessageState messageState) {
    return TabBarView(
      controller: _tabController,
      children: [
        // Tab 1: 聊天消息
        _buildChatMessagesTab(messageState),
        
        // Tab 2: 系统通知
        _buildNotificationsTab(messageState),
        
        // Tab 3: 推荐用户
        _buildRecommendedUsersTab(messageState),
      ],
    );
  }

  /// 构建聊天消息标签页
  Widget _buildChatMessagesTab(MessageState messageState) {
    final chats = messageState.chats;
    
    if (chats.isEmpty) {
      return _buildEmptyState(
        icon: MdiIcons.messageOutline,
        title: '暂无消息',
        subtitle: '开始与朋友聊天吧',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(messageProvider.notifier).loadInitialData();
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return MessageListItem(
            chat: chat,
            onTap: () => _openChat(chat),
            onVideoCall: () => _startVideoCall(chat),
          );
        },
      ),
    );
  }

  /// 构建系统通知标签页
  Widget _buildNotificationsTab(MessageState messageState) {
    final notifications = messageState.notifications;
    
    if (notifications.isEmpty) {
      return _buildEmptyState(
        icon: MdiIcons.bellOutline,
        title: '暂无通知',
        subtitle: '新的通知将在这里显示',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(messageProvider.notifier).loadNotifications();
      },
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  /// 构建推荐用户标签页
  Widget _buildRecommendedUsersTab(MessageState messageState) {
    final recommendedUsers = _getRecommendedUsers();
    
    return Column(
      children: [
        // 推荐用户标题
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '你可能感兴趣的人①',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    MdiIcons.informationOutline,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // 关闭推荐
                },
                child: Text(
                  '关闭',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 推荐用户列表
        Expanded(
          child: ListView.builder(
            itemCount: recommendedUsers.length,
            itemBuilder: (context, index) {
              final user = recommendedUsers[index];
              return _buildRecommendedUserItem(user);
            },
          ),
        ),
      ],
    );
  }

  /// 构建通知横幅
  Widget _buildNotificationBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(
            MdiIcons.bell,
            color: Colors.orange[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '打开通知,不再错过互动消息',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              // 开启通知
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange[600],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '开启',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              // 关闭横幅
            },
            child: Icon(
              MdiIcons.close,
              color: Colors.orange[400],
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部导航栏
  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(MdiIcons.home, '首页', false),
          _buildNavItem(MdiIcons.store, '市集', false),
          _buildNavItem(Icons.add, '', true), // 中间的大按钮
          _buildNavItem(MdiIcons.message, '消息', true),
          _buildNavItem(MdiIcons.account, '我', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    if (label.isEmpty) {
      // 中间的大按钮
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.red : Colors.grey[600],
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.red : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  /// 构建空状态
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建通知项
  Widget _buildNotificationItem(models.Notification notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // 通知图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getNotificationColor(notification.type).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // 通知内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.content,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // 时间
          Text(
            _formatTime(notification.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建推荐用户项
  Widget _buildRecommendedUserItem(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // 用户头像
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: user['avatar'] != null
                    ? NetworkImage(user['avatar'])
                    : null,
                child: user['avatar'] == null
                    ? const Icon(MdiIcons.account, size: 24)
                    : null,
              ),
              if (user['verified'] == true)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 10,
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
                  user['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // 关注按钮
          GestureDetector(
            onTap: () {
              // 关注用户
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '关注',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // 关闭按钮
          GestureDetector(
            onTap: () {
              // 关闭推荐
            },
            child: Icon(
              MdiIcons.close,
              color: Colors.grey[400],
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // 辅助方法
  void _openChat(models.Chat chat) {
    // 打开聊天页面
    Navigator.pushNamed(context, '/chat', arguments: chat);
  }

  void _startVideoCall(models.Chat chat) {
    // 发起视频通话
    Navigator.pushNamed(
      context, 
      '/messages/video-call',
      arguments: {
        'chat': chat,
        'isIncoming': false,
      },
    );
  }

  void _showNewMessageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建消息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(MdiIcons.camera),
              title: const Text('录制视频'),
              onTap: () {
                Navigator.of(context).pop();
                _showVideoRecorder();
              },
            ),
            ListTile(
              leading: const Icon(MdiIcons.video),
              title: const Text('视频通话'),
              onTap: () {
                Navigator.of(context).pop();
                _showVideoCallDialog();
              },
            ),
            ListTile(
              leading: const Icon(MdiIcons.message),
              title: const Text('发送消息'),
              onTap: () {
                Navigator.of(context).pop();
                // 打开选择联系人页面
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoRecorder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoRecorderWidget(
          onVideoRecorded: (videoPath, thumbnailPath, duration) {
            // 处理录制的视频
            Navigator.of(context).pop();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showVideoCallDialog() {
    // 显示视频通话对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发起视频通话'),
        content: const Text('选择要通话的用户'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 跳转到视频通话页面
              Navigator.pushNamed(
                context, 
                '/messages/video-call',
                arguments: {
                  'chat': const Chat(
                    id: 'demo_chat',
                    name: '演示用户',
                    avatar: 'https://via.placeholder.com/40',
                    lastMessage: '',
                    lastMessageTime: DateTime.now(),
                    unreadCount: 0,
                    isOnline: true,
                    isPinned: false,
                    isMuted: false,
                  ),
                  'isIncoming': false,
                },
              );
            },
            child: const Text('开始通话'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getRecommendedUsers() {
    return [
      {
        'name': '大悍娇',
        'description': '时尚内容热门作者',
        'avatar': null,
        'verified': false,
      },
      {
        'name': 'AriaAndBrandon',
        'description': '情感内容热门作者',
        'avatar': null,
        'verified': true,
      },
      {
        'name': 'ling_zi',
        'description': '个人专业号',
        'avatar': null,
        'verified': false,
      },
      {
        'name': '是..四条(在线版)',
        'description': '美食内容热门作者',
        'avatar': null,
        'verified': false,
      },
      {
        'name': '就酱薯薯',
        'description': '兴趣爱好内容热门作者',
        'avatar': null,
        'verified': false,
      },
      {
        'name': '泡芙甜甜的手绘',
        'description': '手绘内容热门作者',
        'avatar': null,
        'verified': true,
      },
    ];
  }

  Color _getNotificationColor(models.NotificationType type) {
    switch (type) {
      case models.NotificationType.like:
        return Colors.red;
      case models.NotificationType.comment:
        return Colors.blue;
      case models.NotificationType.follow:
        return Colors.green;
      case models.NotificationType.message:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(models.NotificationType type) {
    switch (type) {
      case models.NotificationType.like:
        return MdiIcons.heart;
      case models.NotificationType.comment:
        return MdiIcons.comment;
      case models.NotificationType.follow:
        return MdiIcons.accountPlus;
      case models.NotificationType.message:
        return MdiIcons.message;
      default:
        return MdiIcons.bell;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
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
