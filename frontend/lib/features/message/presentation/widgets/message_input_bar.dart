import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/models.dart';
import '../providers/message_provider.dart';

class MessageInputBar extends ConsumerStatefulWidget {
  final String chatId;
  final Function(String)? onMessageSent;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function(String)? onSendMessage;
  final Function(String)? onSendMedia;
  final Function(String)? onSendVoice;
  final Function(String)? onSendLocation;
  final Function(String)? onSendContact;
  
  const MessageInputBar({
    super.key,
    required this.chatId,
    this.onMessageSent,
    this.controller,
    this.focusNode,
    this.onSendMessage,
    this.onSendMedia,
    this.onSendVoice,
    this.onSendLocation,
    this.onSendContact,
  });

  @override
  ConsumerState<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends ConsumerState<MessageInputBar> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _isTyping) {
      setState(() {
        _isTyping = hasText;
      });
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      // TODO: 发送消息到后端
      await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟
      
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: widget.chatId,
        senderId: 'current_user', // TODO: 获取当前用户ID
        content: messageText,
        type: MessageType.text,
        timestamp: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isRead: false,
        isDelivered: true,
        isEdited: false,
        replyToMessageId: null,
        attachments: null,
        senderName: '当前用户', // TODO: 获取当前用户名
        senderAvatar: null, // TODO: 获取当前用户头像
      );

      // 更新本地状态
      ref.read(messageProvider.notifier).addMessage(message);
      
      // 清空输入框
      _messageController.clear();
      
      // 通知父组件
      widget.onMessageSent?.call(messageText);
      
      // 隐藏键盘
      _focusNode.unfocus();
      
    } catch (e) {
      // 显示错误消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('发送失败: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildAttachmentBottomSheet(),
    );
  }

  Widget _buildAttachmentBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '选择附件',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAttachmentOption(
                context,
                '照片',
                Icons.photo_camera,
                Colors.blue,
                () => _selectImage(),
              ),
              _buildAttachmentOption(
                context,
                '视频',
                Icons.videocam,
                Colors.red,
                () => _selectVideo(),
              ),
              _buildAttachmentOption(
                context,
                '文件',
                Icons.attach_file,
                Colors.green,
                () => _selectFile(),
              ),
              _buildAttachmentOption(
                context,
                '位置',
                Icons.location_on,
                Colors.orange,
                () => _selectLocation(),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _selectImage() {
    // TODO: 选择图片
  }

  void _selectVideo() {
    // TODO: 选择视频
  }

  void _selectFile() {
    // TODO: 选择文件
  }

  void _selectLocation() {
    // TODO: 选择位置
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 附件按钮
            IconButton(
              onPressed: _showAttachmentOptions,
              icon: Icon(
                Icons.add,
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            // 输入框
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: '输入消息...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // 发送按钮
            Container(
              decoration: BoxDecoration(
                color: _isTyping && !_isSending
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isTyping && !_isSending ? _sendMessage : null,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: _isTyping && !_isSending
                            ? Colors.white
                            : Colors.grey[600],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
