import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../core/theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/common/limited_scroll_controller.dart';

/// 基于Figma设计的消息页面
/// 实现聊天、通知等消息功能
class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  final bool isIOS = Platform.isIOS;
  final ApiService _apiService = ApiService();
  int _selectedTabIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _apiService.init();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isIOS ? const Color(0xFFF9FAFB) : AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 头部区域
            _buildHeader(),
            
            // 标签栏
            _buildTabBar(),
            
            // 内容区域
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                children: const [
                  ChatsTab(),
                  NotificationsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建头部区域
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '消息',
                      style: TextStyle(
                        fontSize: isIOS ? 28 : 24,
                        fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '与健身伙伴保持联系',
                      style: TextStyle(
                        fontSize: isIOS ? 16 : 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildHeaderButton(
                    icon: Icons.search_rounded,
                    onTap: () => _showSearchDialog(),
                  ),
                  const SizedBox(width: 12),
                  _buildHeaderButton(
                    icon: Icons.add_rounded,
                    onTap: () => _showNewChatDialog(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建头部按钮
  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF6B7280),
          size: 20,
        ),
      ),
    );
  }

  /// 构建标签栏
  Widget _buildTabBar() {
    final tabs = ['聊天', '通知'];
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _selectedTabIndex == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      tab,
                      style: TextStyle(
                        fontSize: isIOS ? 16 : 14,
                        fontWeight: isSelected 
                            ? (isIOS ? FontWeight.w600 : FontWeight.w500)
                            : FontWeight.w400,
                        color: isSelected 
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF6366F1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('搜索消息'),
        content: const Text('搜索功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showNewChatDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewChatBottomSheet(),
    );
  }
}

/// 聊天标签页
class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    
    // 模拟聊天数据
    final chats = [
      {
        'id': '1',
        'user': {
          'id': '1',
          'nickname': '健身达人小李',
          'avatar': '👨‍💼',
          'isOnline': true,
        },
        'lastMessage': '今天一起训练吗？',
        'lastMessageTime': '10:30',
        'unreadCount': 2,
        'isPinned': true,
      },
      {
        'id': '2',
        'user': {
          'id': '2',
          'nickname': '瑜伽小仙女',
          'avatar': '👩‍🦰',
          'isOnline': false,
        },
        'lastMessage': '瑜伽课的时间改到明天了',
        'lastMessageTime': '昨天',
        'unreadCount': 0,
        'isPinned': false,
      },
      {
        'id': '3',
        'user': {
          'id': '3',
          'nickname': '跑步爱好者',
          'avatar': '👨‍🏃',
          'isOnline': true,
        },
        'lastMessage': '明天早上6点公园见',
        'lastMessageTime': '2天前',
        'unreadCount': 1,
        'isPinned': false,
      },
    ];

    return LimitedListViewBuilder(
      padding: const EdgeInsets.all(16),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        return ChatItem(
          chat: chats[index],
        );
      },
    );
  }
}

/// 通知标签页
class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    
    // 模拟通知数据
    final notifications = [
      {
        'id': '1',
        'type': 'buddy_request',
        'title': '新的搭子申请',
        'content': '健身达人小李想和你一起训练',
        'time': '5分钟前',
        'isRead': false,
        'avatar': '👨‍💼',
      },
      {
        'id': '2',
        'type': 'workout_reminder',
        'title': '训练提醒',
        'content': '你今天的训练计划：上肢力量训练',
        'time': '1小时前',
        'isRead': true,
        'avatar': '💪',
      },
      {
        'id': '3',
        'type': 'achievement',
        'title': '成就解锁',
        'content': '恭喜！你已连续训练7天',
        'time': '3小时前',
        'isRead': true,
        'avatar': '🏆',
      },
      {
        'id': '4',
        'type': 'community',
        'title': '社区动态',
        'content': '你的动态收到了5个点赞',
        'time': '昨天',
        'isRead': true,
        'avatar': '❤️',
      },
    ];

    return LimitedListViewBuilder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return NotificationItem(
          notification: notifications[index],
        );
      },
    );
  }
}

/// 聊天项组件
class ChatItem extends StatelessWidget {
  final Map<String, dynamic> chat;
  
  const ChatItem({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    final user = chat['user'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isIOS ? 0.1 : 0.12),
            blurRadius: isIOS ? 20 : 4,
            offset: Offset(0, isIOS ? 10 : 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    user['avatar'],
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              if (user['isOnline'] == true)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(7),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user['nickname'],
                        style: TextStyle(
                          fontSize: isIOS ? 16 : 14,
                          fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    if (chat['isPinned'] == true)
                      Icon(
                        Icons.push_pin,
                        size: 16,
                        color: const Color(0xFF6366F1),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      chat['lastMessageTime'],
                      style: TextStyle(
                        fontSize: isIOS ? 12 : 10,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        chat['lastMessage'],
                        style: TextStyle(
                          fontSize: isIOS ? 14 : 12,
                          color: const Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (chat['unreadCount'] > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          chat['unreadCount'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 通知项组件
class NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notification;
  
  const NotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification['isRead'] ? Colors.white : const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
        border: notification['isRead'] ? null : Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isIOS ? 0.1 : 0.12),
            blurRadius: isIOS ? 20 : 4,
            offset: Offset(0, isIOS ? 10 : 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                notification['avatar'],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification['title'],
                        style: TextStyle(
                          fontSize: isIOS ? 16 : 14,
                          fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    Text(
                      notification['time'],
                      style: TextStyle(
                        fontSize: isIOS ? 12 : 10,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification['content'],
                  style: TextStyle(
                    fontSize: isIOS ? 14 : 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          if (!notification['isRead'])
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

/// 新建聊天底部弹窗
class NewChatBottomSheet extends StatefulWidget {
  const NewChatBottomSheet({super.key});

  @override
  State<NewChatBottomSheet> createState() => _NewChatBottomSheetState();
}

class _NewChatBottomSheetState extends State<NewChatBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _contacts = [];
  final List<Map<String, dynamic>> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() {
    // 模拟联系人数据
    setState(() {
      _contacts.addAll([
        {
          'id': '1',
          'nickname': '健身达人小李',
          'avatar': '👨‍💼',
          'isOnline': true,
          'isBuddy': true,
        },
        {
          'id': '2',
          'nickname': '瑜伽小仙女',
          'avatar': '👩‍🦰',
          'isOnline': false,
          'isBuddy': true,
        },
        {
          'id': '3',
          'nickname': '跑步爱好者',
          'avatar': '👨‍🏃',
          'isOnline': true,
          'isBuddy': false,
        },
        {
          'id': '4',
          'nickname': '健身教练',
          'avatar': '👨‍🏋️',
          'isOnline': false,
          'isBuddy': false,
        },
      ]);
      _filteredContacts.addAll(_contacts);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isIOS ? 20 : 16),
          topRight: Radius.circular(isIOS ? 20 : 16),
        ),
      ),
      child: Column(
        children: [
          // 头部
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '新建聊天',
                  style: TextStyle(
                    fontSize: isIOS ? 18 : 16,
                    fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // 搜索框
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索联系人...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                  borderSide: const BorderSide(color: Color(0xFF6366F1)),
                ),
              ),
              onChanged: _filterContacts,
            ),
          ),
          
          // 联系人列表
          Expanded(
            child: LimitedListViewBuilder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                return ContactItem(
                  contact: _filteredContacts[index],
                  onTap: () => _startChat(_filteredContacts[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts.clear();
        _filteredContacts.addAll(_contacts);
      } else {
        _filteredContacts.clear();
        _filteredContacts.addAll(
          _contacts.where((contact) =>
            contact['nickname'].toLowerCase().contains(query.toLowerCase())
          ).toList()
        );
      }
    });
  }

  void _startChat(Map<String, dynamic> contact) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('开始与${contact['nickname']}聊天'),
        backgroundColor: const Color(0xFF6366F1),
      ),
    );
  }
}

/// 联系人项组件
class ContactItem extends StatelessWidget {
  final Map<String, dynamic> contact;
  final VoidCallback onTap;
  
  const ContactItem({super.key, required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      contact['avatar'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                if (contact['isOnline'] == true)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(6),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        contact['nickname'],
                        style: TextStyle(
                          fontSize: isIOS ? 16 : 14,
                          fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      if (contact['isBuddy'] == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '搭子',
                            style: TextStyle(
                              fontSize: isIOS ? 10 : 8,
                              color: const Color(0xFF6366F1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    contact['isOnline'] ? '在线' : '离线',
                    style: TextStyle(
                      fontSize: isIOS ? 12 : 10,
                      color: contact['isOnline'] 
                          ? const Color(0xFF10B981)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
