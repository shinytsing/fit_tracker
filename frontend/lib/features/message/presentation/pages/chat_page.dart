import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/message_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input_bar.dart';
import '../widgets/chat_header.dart';
import '../widgets/media_picker_bottom_sheet.dart';

/// 聊天页面
/// 支持文字、图片、语音、视频、文件等多种消息类型
class ChatPage extends ConsumerStatefulWidget {
  final Chat chat;

  const ChatPage({
    super.key,
    required this.chat,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  bool _isTyping = false;
  String _typingText = '';

  @override
  void initState() {
    super.initState();
    
    // 监听滚动事件
    _scrollController.addListener(_onScroll);
    
    // 监听输入框变化
    _messageController.addListener(_onMessageChanged);
    
    // 加载聊天消息
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messageProvider.notifier).loadChatMessages(widget.chat.id);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 滚动到顶部时加载更多消息
    if (_scrollController.position.pixels <= 0) {
      ref.read(messageProvider.notifier).loadMoreMessages(widget.chat.id);
    }
  }

  void _onMessageChanged() {
    final text = _messageController.text;
    if (text.isNotEmpty && !_isTyping) {
      setState(() {
        _isTyping = true;
      });
      // 发送正在输入状态
      ref.read(messageProvider.notifier).sendTypingStatus(widget.chat.id, true);
    } else if (text.isEmpty && _isTyping) {
      setState(() {
        _isTyping = false;
      });
      // 停止正在输入状态
      ref.read(messageProvider.notifier).sendTypingStatus(widget.chat.id, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageState = ref.watch(messageProvider);
    final messages = messageState.chatMessages[widget.chat.id] ?? [];
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: ChatHeader(
          chat: widget.chat,
          onUserTap: () {
            _navigateToUserProfile();
          },
          onVideoCall: () {
            _startVideoCall();
          },
          onVoiceCall: () {
            _startVoiceCall();
          },
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          // 更多操作
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleMenuAction(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'chat_info',
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16),
                    SizedBox(width: 8),
                    Text('聊天信息'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'search',
                child: Row(
                  children: [
                    Icon(Icons.search, size: 16),
                    SizedBox(width: 8),
                    Text('搜索消息'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_history',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 16),
                    SizedBox(width: 8),
                    Text('清空聊天记录'),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isLastMessage = index == 0;
                      final showTime = isLastMessage || 
                          (index < messages.length - 1 && 
                           _shouldShowTime(message, messages[index + 1]));
                      
                      return ChatBubble(
                        message: message,
                        showTime: showTime,
                        onTap: () {
                          _handleMessageTap(message);
                        },
                        onLongPress: () {
                          _showMessageOptions(message);
                        },
                      );
                    },
                  ),
          ),
          
          // 正在输入指示器
          if (messageState.typingUsers[widget.chat.id]?.isNotEmpty == true)
            _buildTypingIndicator(messageState.typingUsers[widget.chat.id]!),
          
          // 消息输入栏
          MessageInputBar(
            controller: _messageController,
            focusNode: _messageFocusNode,
            onSendMessage: _sendTextMessage,
            onSendMedia: _showMediaPicker,
            onSendVoice: _startVoiceRecording,
            onSendLocation: _sendLocation,
            onSendContact: _sendContact,
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.messageOutline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '开始聊天吧',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '发送消息开始与${widget.chat.name}的对话',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建正在输入指示器
  Widget _buildTypingIndicator(List<String> typingUsers) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            MdiIcons.pencil,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            typingUsers.length == 1 
                ? '${typingUsers[0]}正在输入...'
                : '${typingUsers.length}人正在输入...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// 判断是否显示时间
  bool _shouldShowTime(Message currentMessage, Message nextMessage) {
    final currentTime = currentMessage.createdAt;
    final nextTime = nextMessage.createdAt;
    return currentTime.difference(nextTime).inMinutes >= 5;
  }

  // 事件处理方法
  void _sendTextMessage(String text) {
    if (text.trim().isEmpty) return;
    
    ref.read(messageProvider.notifier).sendMessage(
      widget.chat.id,
      MessageType.text,
      content: text.trim(),
    );
    
    _messageController.clear();
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MediaPickerBottomSheet(
        onImageSelected: (imagePath) {
          _sendImageMessage(imagePath);
        },
        onVideoSelected: (videoPath) {
          _sendVideoMessage(videoPath);
        },
        onFileSelected: (filePath) {
          _sendFileMessage(filePath);
        },
      ),
    );
  }

  void _sendImageMessage(String imagePath) {
    ref.read(messageProvider.notifier).sendMessage(
      widget.chat.id,
      MessageType.image,
      mediaPath: imagePath,
    );
  }

  void _sendVideoMessage(String videoPath) {
    ref.read(messageProvider.notifier).sendMessage(
      widget.chat.id,
      MessageType.video,
      mediaPath: videoPath,
    );
  }

  void _sendFileMessage(String filePath) {
    ref.read(messageProvider.notifier).sendMessage(
      widget.chat.id,
      MessageType.file,
      mediaPath: filePath,
    );
  }

  void _startVoiceRecording() {
    // TODO: 实现语音录制
    Navigator.pushNamed(context, '/messages/voice-recorder');
  }

  void _sendLocation() {
    // TODO: 实现位置发送
    Navigator.pushNamed(context, '/messages/location-picker');
  }

  void _sendContact() {
    // TODO: 实现联系人发送
    Navigator.pushNamed(context, '/messages/contact-picker');
  }

  void _handleMessageTap(Message message) {
    switch (message.type) {
      case MessageType.image:
      case MessageType.video:
        _showMediaViewer(message);
        break;
      case MessageType.file:
        _downloadFile(message);
        break;
      case MessageType.location:
        _showLocationOnMap(message);
        break;
      default:
        break;
    }
  }

  void _showMessageOptions(Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('复制'),
              onTap: () {
                Navigator.pop(context);
                _copyMessage(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('回复'),
              onTap: () {
                Navigator.pop(context);
                _replyToMessage(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.forward),
              title: const Text('转发'),
              onTap: () {
                Navigator.pop(context);
                _forwardMessage(message);
              },
            ),
            if (message.senderId == 'current_user')
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('删除'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(message);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'chat_info':
        Navigator.pushNamed(context, '/messages/chat-info', arguments: widget.chat);
        break;
      case 'search':
        Navigator.pushNamed(context, '/messages/search', arguments: widget.chat);
        break;
      case 'clear_history':
        _showClearHistoryDialog();
        break;
    }
  }

  void _navigateToUserProfile() {
    Navigator.pushNamed(context, '/community/user-profile', arguments: widget.chat.userId);
  }

  void _startVideoCall() {
    Navigator.pushNamed(context, '/messages/video-call', arguments: widget.chat);
  }

  void _startVoiceCall() {
    Navigator.pushNamed(context, '/messages/voice-call', arguments: widget.chat);
  }

  void _showMediaViewer(Message message) {
    Navigator.pushNamed(context, '/messages/media-viewer', arguments: message);
  }

  void _downloadFile(Message message) {
    // TODO: 实现文件下载
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('开始下载文件')),
    );
  }

  void _showLocationOnMap(Message message) {
    Navigator.pushNamed(context, '/messages/location-viewer', arguments: message);
  }

  void _copyMessage(Message message) {
    // TODO: 实现消息复制
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('消息已复制')),
    );
  }

  void _replyToMessage(Message message) {
    // TODO: 实现消息回复
    _messageFocusNode.requestFocus();
  }

  void _forwardMessage(Message message) {
    Navigator.pushNamed(context, '/messages/forward', arguments: message);
  }

  void _deleteMessage(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除消息'),
        content: const Text('确定要删除这条消息吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(messageProvider.notifier).deleteMessage(message.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空聊天记录'),
        content: const Text('确定要清空所有聊天记录吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(messageProvider.notifier).clearChatHistory(widget.chat.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('聊天记录已清空')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }
}
