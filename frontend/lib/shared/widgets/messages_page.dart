import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/theme/app_theme.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  String activeTab = 'messages';

  final tabs = [
    _TabItem(id: 'messages', label: '消息'),
    _TabItem(id: 'notifications', label: '通知'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // 头部区域
            Container(
              color: AppTheme.card,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 标题和操作按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '消息',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.foreground,
                        ),
                      ),
                      Row(
                        children: [
                          _buildActionButton(MdiIcons.magnify),
                          const SizedBox(width: 12),
                          _buildActionButton(MdiIcons.dotsHorizontal),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 标签页
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.inputBackground,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: tabs.map((tab) {
                        final isActive = activeTab == tab.id;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                activeTab = tab.id;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive ? AppTheme.card : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                boxShadow: isActive ? AppTheme.cardShadow : null,
                              ),
                              child: Text(
                                tab.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                                  color: isActive ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            
            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: activeTab == 'messages' ? _buildMessagesList() : _buildNotificationsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.inputBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        color: AppTheme.textSecondaryColor,
        size: 20,
      ),
    );
  }

  Widget _buildMessagesList() {
    final messages = [
      _MessageData(
        id: 1,
        user: _UserData(
          name: '健身教练Mike',
          avatar: 'https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
          online: true,
        ),
        lastMessage: '今天的训练计划我已经发给你了，记得按时完成哦',
        time: '10:30',
        unread: 2,
        type: 'text',
      ),
      _MessageData(
        id: 2,
        user: _UserData(
          name: '跑步小组',
          avatar: 'https://images.unsplash.com/photo-1738523686534-7055df5858d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwZW9wbGUlMjB3b3Jrb3V0JTIwdG9nZXRoZXIlMjBzb2NpYWx8ZW58MXx8fHwxNzU5NTMyOTgwfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
          online: false,
        ),
        lastMessage: '明天早上7点公园见，准时出发！',
        time: '昨天',
        unread: 0,
        type: 'group',
      ),
      _MessageData(
        id: 3,
        user: _UserData(
          name: '瑜伽小姐姐',
          avatar: 'https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
          online: true,
        ),
        lastMessage: '感谢你的瑜伽指导，进步很大！',
        time: '周一',
        unread: 0,
        type: 'text',
      ),
    ];

    return Column(
      children: messages.map((message) => _buildMessageCard(message)).toList(),
    );
  }

  Widget _buildMessageCard(_MessageData message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 头像
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(message.user.avatar),
              ),
              if (message.user.online)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 12),
          
          // 消息内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      message.user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.foreground,
                      ),
                    ),
                    Text(
                      message.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message.lastMessage,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 未读消息数和操作按钮
          Column(
            children: [
              if (message.unread > 0)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      message.unread.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildMessageActionButton(MdiIcons.phone),
                  const SizedBox(width: 4),
                  _buildMessageActionButton(MdiIcons.video),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageActionButton(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: AppTheme.textSecondaryColor,
        size: 16,
      ),
    );
  }

  Widget _buildNotificationsList() {
    final notifications = [
      _NotificationData(
        id: 1,
        title: '训练提醒',
        content: '距离今日训练计划还有30分钟',
        time: '1小时前',
        type: 'reminder',
        unread: true,
      ),
      _NotificationData(
        id: 2,
        title: '挑战更新',
        content: '你参与的"30天俯卧撑挑战"有新进展',
        time: '3小时前',
        type: 'challenge',
        unread: true,
      ),
      _NotificationData(
        id: 3,
        title: '点赞通知',
        content: '用户"健身达人小王"点赞了你的动态',
        time: '1天前',
        type: 'like',
        unread: false,
      ),
    ];

    return Column(
      children: notifications.map((notification) => _buildNotificationCard(notification)).toList(),
    );
  }

  Widget _buildNotificationCard(_NotificationData notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: notification.unread ? AppTheme.primaryColor : AppTheme.border,
          width: notification.unread ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                notification.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.foreground,
                ),
              ),
              Text(
                notification.time,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notification.content,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          if (notification.unread) ...[
            const SizedBox(height: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabItem {
  final String id;
  final String label;

  _TabItem({required this.id, required this.label});
}

class _MessageData {
  final int id;
  final _UserData user;
  final String lastMessage;
  final String time;
  final int unread;
  final String type;

  _MessageData({
    required this.id,
    required this.user,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.type,
  });
}

class _UserData {
  final String name;
  final String avatar;
  final bool online;

  _UserData({
    required this.name,
    required this.avatar,
    required this.online,
  });
}

class _NotificationData {
  final int id;
  final String title;
  final String content;
  final String time;
  final String type;
  final bool unread;

  _NotificationData({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
    required this.type,
    required this.unread,
  });
}
