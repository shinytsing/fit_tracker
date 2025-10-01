#!/bin/bash

# FitTracker 模块生成器 - Tab5: 消息中心
# 自动生成消息中心相关的前端和后端代码

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 项目路径
PROJECT_ROOT="/Users/gaojie/Desktop/fittraker"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKEND_DIR="$PROJECT_ROOT/backend-go"

log_info() {
    echo -e "${BLUE}[Tab5 Generator]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[Tab5 Generator]${NC} $1"
}

log_error() {
    echo -e "${RED}[Tab5 Generator]${NC} $1"
}

# 生成前端消息页面
generate_frontend_message_page() {
    log_info "生成前端消息页面..."
    
    mkdir -p "$FRONTEND_DIR/lib/features/message/presentation/pages"
    mkdir -p "$FRONTEND_DIR/lib/features/message/presentation/widgets"
    mkdir -p "$FRONTEND_DIR/lib/features/message/domain/models"
    mkdir -p "$FRONTEND_DIR/lib/features/message/data/repositories"
    
    # 消息模型
    cat > "$FRONTEND_DIR/lib/features/message/domain/models/message_models.dart" << 'EOF'
import 'package:json_annotation/json_annotation.dart';

part 'message_models.g.dart';

@JsonSerializable()
class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String receiverId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? readAt;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.status,
    this.metadata,
    required this.createdAt,
    this.readAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class Conversation {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String lastMessage;
  final MessageType lastMessageType;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final ConversationType type;

  Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.lastMessage,
    required this.lastMessageType,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
    required this.type,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationToJson(this);
}

@JsonSerializable()
class Notification {
  final String id;
  final String userId;
  final String title;
  final String content;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}

@JsonSerializable()
class CallSession {
  final String id;
  final String callerId;
  final String callerName;
  final String? callerAvatar;
  final String receiverId;
  final CallType type;
  final CallStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration; // 秒

  CallSession({
    required this.id,
    required this.callerId,
    required this.callerName,
    this.callerAvatar,
    required this.receiverId,
    required this.type,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.duration,
  });

  factory CallSession.fromJson(Map<String, dynamic> json) =>
      _$CallSessionFromJson(json);
  Map<String, dynamic> toJson() => _$CallSessionToJson(this);
}

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('video')
  video,
  @JsonValue('audio')
  audio,
  @JsonValue('file')
  file,
  @JsonValue('location')
  location,
  @JsonValue('system')
  system,
}

enum MessageStatus {
  @JsonValue('sending')
  sending,
  @JsonValue('sent')
  sent,
  @JsonValue('delivered')
  delivered,
  @JsonValue('read')
  read,
  @JsonValue('failed')
  failed,
}

enum ConversationType {
  @JsonValue('private')
  private,
  @JsonValue('group')
  group,
  @JsonValue('system')
  system,
}

enum NotificationType {
  @JsonValue('like')
  like,
  @JsonValue('comment')
  comment,
  @JsonValue('follow')
  follow,
  @JsonValue('mention')
  mention,
  @JsonValue('system')
  system,
  @JsonValue('training')
  training,
  @JsonValue('achievement')
  achievement,
}

enum CallType {
  @JsonValue('voice')
  voice,
  @JsonValue('video')
  video,
}

enum CallStatus {
  @JsonValue('calling')
  calling,
  @JsonValue('ringing')
  ringing,
  @JsonValue('connected')
  connected,
  @JsonValue('ended')
  ended,
  @JsonValue('missed')
  missed,
  @JsonValue('rejected')
  rejected,
}
EOF

    # 消息页面
    cat > "$FRONTEND_DIR/lib/features/message/presentation/pages/message_page.dart" << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/message_provider.dart';
import '../widgets/conversation_list.dart';
import '../widgets/chat_page.dart';
import '../widgets/notification_list.dart';
import '../widgets/call_page.dart';

class MessagePage extends ConsumerStatefulWidget {
  const MessagePage({super.key});

  @override
  ConsumerState<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends ConsumerState<MessagePage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息中心'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(conversationsProvider);
              ref.refresh(notificationsProvider);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '聊天', icon: Icon(Icons.chat)),
            Tab(text: '通知', icon: Icon(Icons.notifications)),
            Tab(text: '通话', icon: Icon(Icons.call)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          _buildNotificationTab(),
          _buildCallTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildChatTab() {
    final conversations = ref.watch(conversationsProvider);
    
    return conversations.when(
      data: (conversations) {
        if (conversations.isEmpty) {
          return _buildEmptyChatState();
        }
        
        return ConversationList(
          conversations: conversations,
          onConversationTap: (conversation) {
            _openChat(conversation);
          },
          onUserTap: (userId) {
            _showUserProfile(userId);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败: $error',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.refresh(conversationsProvider);
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTab() {
    final notifications = ref.watch(notificationsProvider);
    
    return notifications.when(
      data: (notifications) {
        if (notifications.isEmpty) {
          return _buildEmptyNotificationState();
        }
        
        return NotificationList(
          notifications: notifications,
          onNotificationTap: (notification) {
            _handleNotificationTap(notification);
          },
          onMarkAsRead: (notificationId) {
            ref.read(messageProvider.notifier).markNotificationAsRead(notificationId);
          },
          onMarkAllAsRead: () {
            ref.read(messageProvider.notifier).markAllNotificationsAsRead();
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('加载失败: $error'),
      ),
    );
  }

  Widget _buildCallTab() {
    final callHistory = ref.watch(callHistoryProvider);
    
    return callHistory.when(
      data: (calls) {
        if (calls.isEmpty) {
          return _buildEmptyCallState();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: calls.length,
          itemBuilder: (context, index) {
            final call = calls[index];
            return Card(
              margin: const EdgeInsets.all(4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: call.callerAvatar != null
                      ? NetworkImage(call.callerAvatar!)
                      : null,
                  child: call.callerAvatar == null
                      ? Text(call.callerName[0])
                      : null,
                ),
                title: Text(call.callerName),
                subtitle: Text(
                  '${call.type == CallType.voice ? '语音' : '视频'}通话 - '
                  '${_formatCallDuration(call.duration)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        call.type == CallType.voice ? Icons.call : Icons.videocam,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        _makeCall(call.callerId, call.type);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        _showCallDetail(call);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  _makeCall(call.callerId, call.type);
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('加载失败: $error'),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _showNewChatDialog();
      },
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    );
  }

  Widget _buildEmptyChatState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '暂无聊天记录',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '开始与朋友聊天吧！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNotificationState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '暂无通知',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '有新消息时会在这里显示',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCallState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.call_end,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '暂无通话记录',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '与朋友进行语音或视频通话',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          conversation: conversation,
          onSendMessage: (content, type) {
            ref.read(messageProvider.notifier).sendMessage(
              conversation.otherUserId,
              content,
              type,
            );
          },
        ),
      ),
    );
  }

  void _showUserProfile(String userId) {
    Navigator.pushNamed(context, '/user_profile', arguments: userId);
  }

  void _handleNotificationTap(notification) {
    // 标记为已读
    ref.read(messageProvider.notifier).markNotificationAsRead(notification.id);
    
    // 根据通知类型处理点击事件
    switch (notification.type) {
      case NotificationType.like:
      case NotificationType.comment:
        // 跳转到相关动态
        break;
      case NotificationType.follow:
        // 跳转到用户资料
        _showUserProfile(notification.data?['userId']);
        break;
      case NotificationType.mention:
        // 跳转到相关动态
        break;
      case NotificationType.training:
        // 跳转到训练页面
        Navigator.pushNamed(context, '/training');
        break;
      case NotificationType.achievement:
        // 跳转到成就页面
        break;
      case NotificationType.system:
        // 显示系统消息详情
        break;
    }
  }

  void _makeCall(String userId, CallType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(
          userId: userId,
          callType: type,
          onCallEnd: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showCallDetail(call) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('通话详情'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('通话类型: ${call.type == CallType.voice ? '语音' : '视频'}'),
            Text('通话状态: ${call.status}'),
            Text('开始时间: ${call.startTime}'),
            if (call.endTime != null)
              Text('结束时间: ${call.endTime}'),
            Text('通话时长: ${_formatCallDuration(call.duration)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索消息'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: '输入关键词搜索...',
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
              // 执行搜索
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  void _showNewChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建聊天'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: '输入用户名或ID',
            prefixIcon: Icon(Icons.person),
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
              // 创建新聊天
            },
            child: const Text('开始聊天'),
          ),
        ],
      ),
    );
  }

  String _formatCallDuration(int duration) {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
EOF

    log_success "前端消息页面生成完成"
}

# 生成后端消息 API
generate_backend_message_api() {
    log_info "生成后端消息 API..."
    
    # 消息模型
    cat > "$BACKEND_DIR/internal/models/message.go" << 'EOF'
package models

import (
	"time"
	"gorm.io/gorm"
)

// Message 消息
type Message struct {
	ID         string    `json:"id" gorm:"primaryKey"`
	SenderID   string    `json:"sender_id" gorm:"not null"`
	ReceiverID string    `json:"receiver_id" gorm:"not null"`
	Content    string    `json:"content" gorm:"not null"`
	Type       string    `json:"type" gorm:"not null"` // text, image, video, audio, file, location, system
	Status     string    `json:"status" gorm:"default:'sent'"` // sending, sent, delivered, read, failed
	Metadata   string    `json:"metadata"` // JSON
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `json:"-" gorm:"index"`
}

// Conversation 会话
type Conversation struct {
	ID               string    `json:"id" gorm:"primaryKey"`
	UserID           string    `json:"user_id" gorm:"not null"`
	OtherUserID      string    `json:"other_user_id" gorm:"not null"`
	LastMessageID    string    `json:"last_message_id"`
	LastMessage      string    `json:"last_message"`
	LastMessageType  string    `json:"last_message_type"`
	LastMessageTime  time.Time `json:"last_message_time"`
	UnreadCount      int       `json:"unread_count" gorm:"default:0"`
	CreatedAt        time.Time `json:"created_at"`
	UpdatedAt        time.Time `json:"updated_at"`
}

// Notification 通知
type Notification struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	UserID    string    `json:"user_id" gorm:"not null"`
	Title     string    `json:"title" gorm:"not null"`
	Content   string    `json:"content" gorm:"not null"`
	Type      string    `json:"type" gorm:"not null"` // like, comment, follow, mention, system, training, achievement
	Data      string    `json:"data"` // JSON
	IsRead    bool      `json:"is_read" gorm:"default:false"`
	CreatedAt time.Time `json:"created_at"`
	ReadAt    *time.Time `json:"read_at"`
}

// CallSession 通话会话
type CallSession struct {
	ID         string     `json:"id" gorm:"primaryKey"`
	CallerID   string     `json:"caller_id" gorm:"not null"`
	ReceiverID string     `json:"receiver_id" gorm:"not null"`
	Type       string     `json:"type" gorm:"not null"` // voice, video
	Status     string     `json:"status" gorm:"not null"` // calling, ringing, connected, ended, missed, rejected
	StartTime  time.Time  `json:"start_time"`
	EndTime    *time.Time `json:"end_time"`
	Duration   int        `json:"duration" gorm:"default:0"` // 秒
	CreatedAt  time.Time  `json:"created_at"`
	UpdatedAt  time.Time  `json:"updated_at"`
}

// OnlineUser 在线用户
type OnlineUser struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	UserID    string    `json:"user_id" gorm:"not null"`
	LastSeen  time.Time `json:"last_seen"`
	IsOnline  bool      `json:"is_online" gorm:"default:true"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
EOF

    # 消息处理器
    cat > "$BACKEND_DIR/internal/handlers/message_handler.go" << 'EOF'
package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"fittracker/backend/internal/services"
)

type MessageHandler struct {
	messageService *services.MessageService
}

func NewMessageHandler(messageService *services.MessageService) *MessageHandler {
	return &MessageHandler{
		messageService: messageService,
	}
}

// GetConversations 获取会话列表
func (h *MessageHandler) GetConversations(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	conversations, err := h.messageService.GetConversations(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": conversations})
}

// GetMessages 获取消息列表
func (h *MessageHandler) GetMessages(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	otherUserID := c.Param("user_id")
	if otherUserID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "用户ID不能为空"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	messages, total, err := h.messageService.GetMessages(userID, otherUserID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": messages,
		"total": total,
		"page": page,
		"limit": limit,
	})
}

// SendMessage 发送消息
func (h *MessageHandler) SendMessage(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var req struct {
		ReceiverID string `json:"receiver_id" binding:"required"`
		Content    string `json:"content" binding:"required"`
		Type       string `json:"type" binding:"required"`
		Metadata   string `json:"metadata"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	message, err := h.messageService.SendMessage(userID, req.ReceiverID, req.Content, req.Type, req.Metadata)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": message})
}

// MarkMessageAsRead 标记消息为已读
func (h *MessageHandler) MarkMessageAsRead(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	messageID := c.Param("id")
	if messageID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "消息ID不能为空"})
		return
	}

	err := h.messageService.MarkMessageAsRead(userID, messageID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "消息已标记为已读"})
}

// MarkConversationAsRead 标记会话为已读
func (h *MessageHandler) MarkConversationAsRead(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	otherUserID := c.Param("user_id")
	if otherUserID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "用户ID不能为空"})
		return
	}

	err := h.messageService.MarkConversationAsRead(userID, otherUserID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "会话已标记为已读"})
}

// GetNotifications 获取通知列表
func (h *MessageHandler) GetNotifications(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	notifications, total, err := h.messageService.GetNotifications(userID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": notifications,
		"total": total,
		"page": page,
		"limit": limit,
	})
}

// MarkNotificationAsRead 标记通知为已读
func (h *MessageHandler) MarkNotificationAsRead(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	notificationID := c.Param("id")
	if notificationID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "通知ID不能为空"})
		return
	}

	err := h.messageService.MarkNotificationAsRead(userID, notificationID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "通知已标记为已读"})
}

// MarkAllNotificationsAsRead 标记所有通知为已读
func (h *MessageHandler) MarkAllNotificationsAsRead(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	err := h.messageService.MarkAllNotificationsAsRead(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "所有通知已标记为已读"})
}

// GetCallHistory 获取通话记录
func (h *MessageHandler) GetCallHistory(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	calls, total, err := h.messageService.GetCallHistory(userID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": calls,
		"total": total,
		"page": page,
		"limit": limit,
	})
}

// StartCall 开始通话
func (h *MessageHandler) StartCall(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var req struct {
		ReceiverID string `json:"receiver_id" binding:"required"`
		Type       string `json:"type" binding:"required"` // voice, video
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	call, err := h.messageService.StartCall(userID, req.ReceiverID, req.Type)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": call})
}

// EndCall 结束通话
func (h *MessageHandler) EndCall(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	callID := c.Param("id")
	if callID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "通话ID不能为空"})
		return
	}

	err := h.messageService.EndCall(userID, callID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "通话已结束"})
}

// GetOnlineUsers 获取在线用户
func (h *MessageHandler) GetOnlineUsers(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	users, err := h.messageService.GetOnlineUsers(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": users})
}
EOF

    log_success "后端消息 API 生成完成"
}

# 生成 WebSocket 服务
generate_websocket_service() {
    log_info "生成 WebSocket 服务..."
    
    cat > "$BACKEND_DIR/internal/services/websocket_service.go" << 'EOF'
package services

import (
	"encoding/json"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"fittracker/backend/internal/models"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // 在生产环境中应该检查来源
	},
}

type Client struct {
	ID     string
	UserID string
	Conn   *websocket.Conn
	Send   chan []byte
	Hub    *Hub
}

type Hub struct {
	clients    map[*Client]bool
	register   chan *Client
	unregister chan *Client
	broadcast  chan []byte
	mutex      sync.RWMutex
}

type WebSocketService struct {
	hub *Hub
	db  *gorm.DB
}

func NewWebSocketService(db *gorm.DB) *WebSocketService {
	hub := &Hub{
		clients:    make(map[*Client]bool),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		broadcast:  make(chan []byte),
	}
	
	ws := &WebSocketService{
		hub: hub,
		db:  db,
	}
	
	go hub.run()
	return ws
}

func (h *Hub) run() {
	for {
		select {
		case client := <-h.register:
			h.mutex.Lock()
			h.clients[client] = true
			h.mutex.Unlock()
			log.Printf("客户端 %s 已连接", client.ID)

		case client := <-h.unregister:
			h.mutex.Lock()
			if _, ok := h.clients[client]; ok {
				delete(h.clients, client)
				close(client.Send)
			}
			h.mutex.Unlock()
			log.Printf("客户端 %s 已断开", client.ID)

		case message := <-h.broadcast:
			h.mutex.RLock()
			for client := range h.clients {
				select {
				case client.Send <- message:
				default:
					close(client.Send)
					delete(h.clients, client)
				}
			}
			h.mutex.RUnlock()
		}
	}
}

func (c *Client) readPump() {
	defer func() {
		c.Hub.unregister <- c
		c.Conn.Close()
	}()

	c.Conn.SetReadLimit(512)
	c.Conn.SetReadDeadline(time.Now().Add(60 * time.Second))
	c.Conn.SetPongHandler(func(string) error {
		c.Conn.SetReadDeadline(time.Now().Add(60 * time.Second))
		return nil
	})

	for {
		_, message, err := c.Conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("WebSocket错误: %v", err)
			}
			break
		}

		// 处理接收到的消息
		var msg map[string]interface{}
		if err := json.Unmarshal(message, &msg); err != nil {
			log.Printf("解析消息错误: %v", err)
			continue
		}

		// 根据消息类型处理
		switch msg["type"] {
		case "message":
			c.handleMessage(msg)
		case "call":
			c.handleCall(msg)
		case "notification":
			c.handleNotification(msg)
		default:
			log.Printf("未知消息类型: %v", msg["type"])
		}
	}
}

func (c *Client) writePump() {
	ticker := time.NewTicker(54 * time.Second)
	defer func() {
		ticker.Stop()
		c.Conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.Send:
			c.Conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if !ok {
				c.Conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			w, err := c.Conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}
			w.Write(message)

			n := len(c.Send)
			for i := 0; i < n; i++ {
				w.Write([]byte{'\n'})
				w.Write(<-c.Send)
			}

			if err := w.Close(); err != nil {
				return
			}

		case <-ticker.C:
			c.Conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if err := c.Conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

func (c *Client) handleMessage(msg map[string]interface{}) {
	// 处理消息逻辑
	log.Printf("用户 %s 发送消息: %v", c.UserID, msg)
}

func (c *Client) handleCall(msg map[string]interface{}) {
	// 处理通话逻辑
	log.Printf("用户 %s 发起通话: %v", c.UserID, msg)
}

func (c *Client) handleNotification(msg map[string]interface{}) {
	// 处理通知逻辑
	log.Printf("用户 %s 收到通知: %v", c.UserID, msg)
}

func (ws *WebSocketService) HandleWebSocket(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Printf("WebSocket升级失败: %v", err)
		return
	}

	client := &Client{
		ID:     generateClientID(),
		UserID: userID,
		Conn:   conn,
		Send:   make(chan []byte, 256),
		Hub:    ws.hub,
	}

	client.Hub.register <- client

	go client.writePump()
	go client.readPump()
}

func (ws *WebSocketService) BroadcastToUser(userID string, message []byte) {
	ws.hub.mutex.RLock()
	defer ws.hub.mutex.RUnlock()

	for client := range ws.hub.clients {
		if client.UserID == userID {
			select {
			case client.Send <- message:
			default:
				close(client.Send)
				delete(ws.hub.clients, client)
			}
		}
	}
}

func (ws *WebSocketService) BroadcastToAll(message []byte) {
	ws.hub.broadcast <- message
}

func generateClientID() string {
	return fmt.Sprintf("client_%d", time.Now().UnixNano())
}
EOF

    log_success "WebSocket 服务生成完成"
}

# 主执行函数
main() {
    log_info "开始生成 Tab5: 消息中心模块..."
    
    generate_frontend_message_page
    generate_backend_message_api
    generate_websocket_service
    
    log_success "Tab5: 消息中心模块生成完成！"
}

# 执行主函数
main "$@"
