import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';
import '../widgets/video_call_widget.dart';
import '../providers/message_provider.dart';

/// 视频通话页面
/// 支持发起、接听、拒绝、结束视频通话
class VideoCallPage extends ConsumerStatefulWidget {
  final Chat chat;
  final bool isIncoming;
  final VideoCallSession? session;

  const VideoCallPage({
    super.key,
    required this.chat,
    this.isIncoming = false,
    this.session,
  });

  @override
  ConsumerState<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends ConsumerState<VideoCallPage> {
  bool _isCallEnded = false;

  @override
  void initState() {
    super.initState();
    if (widget.isIncoming) {
      _showIncomingCallDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCallEnded) {
      return _buildCallEndedView();
    }

    return VideoCallWidget(
      session: widget.session,
      callerName: widget.chat.name,
      callerAvatar: widget.chat.avatar,
      isIncoming: widget.isIncoming,
      targetUserId: widget.chat.userId,
      chatId: widget.chat.id,
      roomId: widget.session?.roomId ?? 'room_${widget.chat.id}',
      onAccept: _handleAcceptCall,
      onReject: _handleRejectCall,
      onEnd: _handleEndCall,
      onPeerConnectionReady: _handlePeerConnectionReady,
    );
  }

  Widget _buildCallEndedView() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.phoneHangup,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              '通话已结束',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '与 ${widget.chat.name} 的通话已结束',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                '返回',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIncomingCallDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 头像
              CircleAvatar(
                radius: 40,
                backgroundImage: widget.chat.avatar != null
                    ? NetworkImage(widget.chat.avatar!)
                    : null,
                child: widget.chat.avatar == null
                    ? const Icon(
                        MdiIcons.account,
                        size: 40,
                        color: Colors.grey,
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              
              // 用户名
              Text(
                widget.chat.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // 通话类型
              Text(
                '视频通话',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              
              // 按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 拒绝按钮
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      _handleRejectCall();
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        MdiIcons.phoneHangup,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  
                  // 接听按钮
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      _handleAcceptCall();
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        MdiIcons.phone,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAcceptCall() {
    // TODO: 实现接听通话逻辑
    debugPrint('接听通话');
    // 这里可以调用后端API接受通话
  }

  void _handleRejectCall() {
    // TODO: 实现拒绝通话逻辑
    debugPrint('拒绝通话');
    // 这里可以调用后端API拒绝通话
    _endCall();
  }

  void _handleEndCall() {
    // TODO: 实现结束通话逻辑
    debugPrint('结束通话');
    // 这里可以调用后端API结束通话
    _endCall();
  }

  void _handlePeerConnectionReady(peerConnection) {
    // TODO: 处理PeerConnection就绪事件
    debugPrint('PeerConnection已就绪');
  }

  void _endCall() {
    setState(() {
      _isCallEnded = true;
    });
    
    // 延迟返回上一页
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}
