import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart' as models;
import '../providers/message_provider.dart';

/// 聊天消息气泡组件
/// 支持文字、图片、语音、视频、文件等多种消息类型
class ChatBubble extends StatelessWidget {
  final models.Message message;
  final bool showTime;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ChatBubble({
    super.key,
    required this.message,
    this.showTime = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = message.senderId == 'current_user';
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: isCurrentUser 
              ? CrossAxisAlignment.end 
              : CrossAxisAlignment.start,
          children: [
            // 时间显示
            if (showTime) _buildTimeIndicator(),
            
            // 消息内容
            Row(
              mainAxisAlignment: isCurrentUser 
                  ? MainAxisAlignment.end 
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 发送者头像（仅非当前用户显示）
                if (!isCurrentUser) ...[
                  _buildAvatar(),
                  const SizedBox(width: 8),
                ],
                
                // 消息气泡
                Flexible(
                  child: _buildMessageBubble(context, isCurrentUser),
                ),
                
                // 当前用户头像
                if (isCurrentUser) ...[
                  const SizedBox(width: 8),
                  _buildAvatar(),
                ],
              ],
            ),
            
            // 消息状态（仅当前用户消息显示）
            if (isCurrentUser) _buildMessageStatus(),
          ],
        ),
      ),
    );
  }

  /// 构建时间指示器
  Widget _buildTimeIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        _formatTime(message.createdAt),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundImage: message.senderAvatar != null 
          ? NetworkImage(message.senderAvatar!) 
          : null,
      child: message.senderAvatar == null 
          ? Text(
              message.senderName?.isNotEmpty == true ? message.senderName![0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  /// 构建消息气泡
  Widget _buildMessageBubble(BuildContext context, bool isCurrentUser) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppTheme.primary : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
          bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildMessageContent(isCurrentUser),
    );
  }

  /// 构建消息内容
  Widget _buildMessageContent(bool isCurrentUser) {
    switch (message.type) {
      case models.MessageType.text:
        return _buildTextMessage(isCurrentUser);
      case models.MessageType.image:
        return _buildImageMessage();
      case models.MessageType.video:
        return _buildVideoMessage();
      case models.MessageType.voice:
        return _buildVoiceMessage(isCurrentUser);
      case models.MessageType.file:
        return _buildFileMessage(isCurrentUser);
      case models.MessageType.location:
        return _buildLocationMessage(isCurrentUser);
      case models.MessageType.contact:
        return _buildContactMessage(isCurrentUser);
      case models.MessageType.system:
        return _buildSystemMessage();
      default:
        return _buildTextMessage(isCurrentUser);
    }
  }

  /// 构建文字消息
  Widget _buildTextMessage(bool isCurrentUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        message.content,
        style: TextStyle(
          fontSize: 16,
          color: isCurrentUser ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  /// 构建图片消息
  Widget _buildImageMessage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 200,
          maxHeight: 200,
        ),
        child: Image.network(
          message.mediaUrl ?? '',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 100,
              color: Colors.grey[300],
              child: const Icon(Icons.error, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }

  /// 构建视频消息
  Widget _buildVideoMessage() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
        maxHeight: 200,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.black,
              child: Image.network(
                message.thumbnailUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          if (message.duration != null)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(message.duration!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建语音消息
  Widget _buildVoiceMessage(bool isCurrentUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            MdiIcons.play,
            color: isCurrentUser ? Colors.white : AppTheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(message.duration ?? 0),
            style: TextStyle(
              fontSize: 14,
              color: isCurrentUser ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          // 语音波形（简化显示）
          Container(
            width: 60,
            height: 20,
            child: CustomPaint(
              painter: VoiceWavePainter(
                color: isCurrentUser ? Colors.white : AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建文件消息
  Widget _buildFileMessage(bool isCurrentUser) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFileIcon(message.fileName ?? ''),
            color: isCurrentUser ? Colors.white : AppTheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? '未知文件',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (message.fileSize != null)
                  Text(
                    _formatFileSize(message.fileSize!),
                    style: TextStyle(
                      fontSize: 12,
                      color: isCurrentUser ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建位置消息
  Widget _buildLocationMessage(bool isCurrentUser) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            MdiIcons.mapMarker,
            color: isCurrentUser ? Colors.white : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.locationName ?? '位置信息',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? Colors.white : Colors.black87,
                  ),
                ),
                if (message.locationAddress != null)
                  Text(
                    message.locationAddress!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isCurrentUser ? Colors.white70 : Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建联系人消息
  Widget _buildContactMessage(bool isCurrentUser) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: message.contactAvatar != null 
                ? NetworkImage(message.contactAvatar!) 
                : null,
            child: message.contactAvatar == null 
                ? Icon(
                    MdiIcons.account,
                    color: isCurrentUser ? Colors.white : AppTheme.primary,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.contactName ?? '联系人',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? Colors.white : Colors.black87,
                  ),
                ),
                if (message.contactPhone != null)
                  Text(
                    message.contactPhone!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isCurrentUser ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建系统消息
  Widget _buildSystemMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        message.content,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 构建消息状态
  Widget _buildMessageStatus() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.status == models.MessageStatus.sending)
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            )
          else if (message.status == models.MessageStatus.sent)
            Icon(
              MdiIcons.check,
              size: 12,
              color: Colors.grey[600],
            )
          else if (message.status == models.MessageStatus.delivered)
            Icon(
              MdiIcons.checkAll,
              size: 12,
              color: Colors.grey[600],
            )
          else if (message.status == models.MessageStatus.read)
            Icon(
              MdiIcons.checkAll,
              size: 12,
              color: Colors.blue,
            )
          else if (message.status == models.MessageStatus.failed)
            Icon(
              MdiIcons.alertCircle,
              size: 12,
              color: Colors.red,
            ),
          
          const SizedBox(width: 4),
          
          Text(
            _formatTime(message.createdAt),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 辅助方法
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return '昨天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return MdiIcons.fileDocument;
      case 'doc':
      case 'docx':
        return MdiIcons.fileWord;
      case 'xls':
      case 'xlsx':
        return MdiIcons.fileExcel;
      case 'ppt':
      case 'pptx':
        return MdiIcons.filePowerpoint;
      case 'zip':
      case 'rar':
        return MdiIcons.archive;
      default:
        return MdiIcons.file;
    }
  }
}

/// 语音波形绘制器
class VoiceWavePainter extends CustomPainter {
  final Color color;

  VoiceWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    final waveWidth = size.width / 8;

    for (int i = 0; i < 8; i++) {
      final x = i * waveWidth + waveWidth / 2;
      final height = (i % 3 + 1) * 4.0;
      
      canvas.drawLine(
        Offset(x, centerY - height),
        Offset(x, centerY + height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
