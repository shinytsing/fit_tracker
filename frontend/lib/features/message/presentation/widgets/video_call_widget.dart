import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:async';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart' as models;
import '../../../../core/services/websocket_service.dart';
import '../providers/message_provider.dart';

/// 视频通话组件
/// 支持发起、接听、拒绝、结束视频通话
class VideoCallWidget extends StatefulWidget {
  final models.VideoCallSession? session;
  final String? callerName;
  final String? callerAvatar;
  final bool isIncoming;
  final String? targetUserId;
  final String? chatId;
  final String? roomId;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onEnd;
  final Function(RTCPeerConnection)? onPeerConnectionReady;

  const VideoCallWidget({
    super.key,
    this.session,
    this.callerName,
    this.callerAvatar,
    this.isIncoming = false,
    this.targetUserId,
    this.chatId,
    this.roomId,
    this.onAccept,
    this.onReject,
    this.onEnd,
    this.onPeerConnectionReady,
  });

  @override
  State<VideoCallWidget> createState() => _VideoCallWidgetState();
}

class _VideoCallWidgetState extends State<VideoCallWidget> {
  RTCPeerConnection? _peerConnection;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  
  bool _isConnected = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerEnabled = false;
  Duration _callDuration = Duration.zero;
  Timer? _callTimer;
  
  MediaStream? _localStream;
  bool _isInitialized = false;
  
  final WebSocketService _websocketService = WebSocketService();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _setupWebSocketHandlers();
    if (!widget.isIncoming) {
      _initializeCall();
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _localStream?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
    _websocketService.dispose();
    super.dispose();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _setupWebSocketHandlers() {
    _websocketService.onVideoCallAccept = _handleVideoCallAccept;
    _websocketService.onVideoCallReject = _handleVideoCallReject;
    _websocketService.onVideoCallEnd = _handleVideoCallEnd;
    _websocketService.onIceCandidate = _handleIceCandidate;
    _websocketService.onSdpOffer = _handleSdpOffer;
    _websocketService.onSdpAnswer = _handleSdpAnswer;
  }

  Future<void> _initializeCall() async {
    try {
      // 获取本地媒体流
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': {
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
          'optional': [],
        }
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;

      // 创建PeerConnection
      final Map<String, dynamic> configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      };

      _peerConnection = await createPeerConnection(configuration);

      // 添加本地流
      await _peerConnection!.addStream(_localStream!);

      // 设置事件监听
      _peerConnection!.onIceCandidate = (candidate) {
        // 发送ICE候选给对方
        _sendIceCandidate(candidate);
      };

      _peerConnection!.onAddStream = (stream) {
        _remoteRenderer.srcObject = stream;
        setState(() {
          _isConnected = true;
        });
        _startCallTimer();
      };

      // 创建Offer
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      
      // 发送Offer给对方
      _sendOffer(offer);

      widget.onPeerConnectionReady?.call(_peerConnection!);
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('初始化通话失败: $e');
      _showErrorDialog('初始化通话失败');
    }
  }

  Future<void> _acceptCall() async {
    try {
      // 获取本地媒体流
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': {
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
          'optional': [],
        }
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;

      // 创建PeerConnection
      final Map<String, dynamic> configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      };

      _peerConnection = await createPeerConnection(configuration);

      // 添加本地流
      await _peerConnection!.addStream(_localStream!);

      // 设置事件监听
      _peerConnection!.onIceCandidate = (candidate) {
        _sendIceCandidate(candidate);
      };

      _peerConnection!.onAddStream = (stream) {
        _remoteRenderer.srcObject = stream;
        setState(() {
          _isConnected = true;
        });
        _startCallTimer();
      };

      // 处理接收到的Offer
      // 这里应该从WebSocket接收到的数据中获取
      // final offer = RTCSessionDescription(offerData['sdp'], offerData['type']);
      // await _peerConnection!.setRemoteDescription(offer);

      // 创建Answer
      // final answer = await _peerConnection!.createAnswer();
      // await _peerConnection!.setLocalDescription(answer);
      
      // 发送Answer给对方
      // _sendAnswer(answer);

      widget.onAccept?.call();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('接听通话失败: $e');
      _showErrorDialog('接听通话失败');
    }
  }

  void _sendOffer(RTCSessionDescription offer) {
    if (widget.targetUserId != null && widget.chatId != null) {
      _websocketService.sendSdpOffer(
        targetUserId: widget.targetUserId!,
        chatId: widget.chatId!,
        offer: offer,
      );
      debugPrint('发送Offer: ${offer.sdp}');
    }
  }

  void _sendAnswer(RTCSessionDescription answer) {
    if (widget.targetUserId != null && widget.chatId != null) {
      _websocketService.sendSdpAnswer(
        targetUserId: widget.targetUserId!,
        chatId: widget.chatId!,
        answer: answer,
      );
      debugPrint('发送Answer: ${answer.sdp}');
    }
  }

  void _sendIceCandidate(RTCIceCandidate candidate) {
    if (widget.targetUserId != null && widget.chatId != null) {
      _websocketService.sendIceCandidate(
        targetUserId: widget.targetUserId!,
        chatId: widget.chatId!,
        candidate: candidate,
      );
      debugPrint('发送ICE候选: ${candidate.candidate}');
    }
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
      });
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    // 切换麦克风状态
    if (_localStream != null) {
      _localStream!.getAudioTracks().forEach((track) {
        track.enabled = !_isMuted;
      });
    }
  }

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    // 切换摄像头状态
    if (_localStream != null) {
      _localStream!.getVideoTracks().forEach((track) {
        track.enabled = _isVideoEnabled;
      });
    }
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerEnabled = !_isSpeakerEnabled;
    });
    // 切换扬声器状态
  }

  void _endCall() {
    _callTimer?.cancel();
    _localStream?.dispose();
    _peerConnection?.close();
    widget.onEnd?.call();
  }

  void _rejectCall() {
    _callTimer?.cancel();
    _localStream?.dispose();
    _peerConnection?.close();
    widget.onReject?.call();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 远程视频（全屏）
            if (_isConnected)
              Positioned.fill(
                child: RTCVideoView(
                  _remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            
            // 本地视频（小窗口）
            if (_isConnected && _isInitialized)
              Positioned(
                top: 50,
                right: 20,
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: RTCVideoView(
                      _localRenderer,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      mirror: true,
                    ),
                  ),
                ),
              ),
            
            // 通话状态信息
            if (!_isConnected)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 头像
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: widget.callerAvatar != null
                          ? NetworkImage(widget.callerAvatar!)
                          : null,
                      child: widget.callerAvatar == null
                          ? const Icon(
                              MdiIcons.account,
                              size: 60,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(height: 20),
                    
                    // 用户名
                    Text(
                      widget.callerName ?? '未知用户',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // 通话状态
                    Text(
                      widget.isIncoming ? '来电中...' : '呼叫中...',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            
            // 顶部状态栏
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 通话时长
                    if (_isConnected)
                      Text(
                        _formatDuration(_callDuration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    
                    // 网络状态
                    Icon(
                      MdiIcons.wifi,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            
            // 底部控制栏
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(30),
                child: widget.isIncoming && !_isConnected
                    ? _buildIncomingCallControls()
                    : _buildActiveCallControls(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 拒绝按钮
        _buildControlButton(
          icon: MdiIcons.phoneHangup,
          backgroundColor: Colors.red,
          onPressed: _rejectCall,
        ),
        
        // 接听按钮
        _buildControlButton(
          icon: MdiIcons.phone,
          backgroundColor: Colors.green,
          onPressed: _acceptCall,
        ),
      ],
    );
  }

  Widget _buildActiveCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 静音按钮
        _buildControlButton(
          icon: _isMuted ? MdiIcons.microphoneOff : MdiIcons.microphone,
          backgroundColor: _isMuted ? Colors.red : Colors.grey[700]!,
          onPressed: _toggleMute,
        ),
        
        // 摄像头按钮
        _buildControlButton(
          icon: _isVideoEnabled ? MdiIcons.video : MdiIcons.videoOff,
          backgroundColor: _isVideoEnabled ? Colors.grey[700]! : Colors.red,
          onPressed: _toggleVideo,
        ),
        
        // 扬声器按钮
        _buildControlButton(
          icon: _isSpeakerEnabled ? MdiIcons.volumeHigh : MdiIcons.volumeOff,
          backgroundColor: _isSpeakerEnabled ? AppTheme.primary : Colors.grey[700]!,
          onPressed: _toggleSpeaker,
        ),
        
        // 挂断按钮
        _buildControlButton(
          icon: MdiIcons.phoneHangup,
          backgroundColor: Colors.red,
          onPressed: _endCall,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // WebSocket事件处理方法
  void _handleVideoCallAccept(Map<String, dynamic> data) {
    debugPrint('收到视频通话接受: $data');
    // 处理对方接受通话
  }

  void _handleVideoCallReject(Map<String, dynamic> data) {
    debugPrint('收到视频通话拒绝: $data');
    // 处理对方拒绝通话
    widget.onReject?.call();
  }

  void _handleVideoCallEnd(Map<String, dynamic> data) {
    debugPrint('收到视频通话结束: $data');
    // 处理通话结束
    widget.onEnd?.call();
  }

  void _handleIceCandidate(Map<String, dynamic> data) {
    debugPrint('收到ICE候选: $data');
    if (_peerConnection != null) {
      final candidateData = data['candidate'] as Map<String, dynamic>;
      final candidate = RTCIceCandidate(
        candidateData['candidate'] as String,
        candidateData['sdpMid'] as String?,
        candidateData['sdpMLineIndex'] as int?,
      );
      _peerConnection!.addCandidate(candidate);
    }
  }

  void _handleSdpOffer(Map<String, dynamic> data) {
    debugPrint('收到SDP Offer: $data');
    if (_peerConnection != null) {
      final sdpData = data['sdp'] as Map<String, dynamic>;
      final offer = RTCSessionDescription(
        sdpData['sdp'] as String,
        sdpData['type'] as String,
      );
      _peerConnection!.setRemoteDescription(offer);
      
      // 创建Answer
      _peerConnection!.createAnswer().then((answer) {
        _peerConnection!.setLocalDescription(answer);
        _sendAnswer(answer);
      });
    }
  }

  void _handleSdpAnswer(Map<String, dynamic> data) {
    debugPrint('收到SDP Answer: $data');
    if (_peerConnection != null) {
      final sdpData = data['sdp'] as Map<String, dynamic>;
      final answer = RTCSessionDescription(
        sdpData['sdp'] as String,
        sdpData['type'] as String,
      );
      _peerConnection!.setRemoteDescription(answer);
    }
  }
}
