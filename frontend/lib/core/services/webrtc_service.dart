import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

/// WebRTC服务
/// 处理视频通话的信令交换和媒体流管理
class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  factory WebRTCService() => _instance;
  WebRTCService._internal();

  RTCPeerConnection? _peerConnection;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  
  WebSocketChannel? _channel;
  String? _currentUserId;
  String? _otherUserId;
  String? _roomId;
  
  bool _isInitialized = false;
  bool _isConnected = false;
  
  // 事件流
  final StreamController<WebRTCEvent> _eventController = StreamController.broadcast();
  Stream<WebRTCEvent> get events => _eventController.stream;
  
  // 本地媒体流
  MediaStream? _localStream;
  
  // ICE服务器配置
  final List<Map<String, String>> _iceServers = [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
  ];

  /// 初始化WebRTC服务
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      _isInitialized = true;
      
      _eventController.add(WebRTCEvent.initialized());
      debugPrint('WebRTC服务初始化成功');
    } catch (e) {
      debugPrint('WebRTC服务初始化失败: $e');
      _eventController.add(WebRTCEvent.error('初始化失败: $e'));
    }
  }

  /// 连接到信令服务器
  Future<void> connectToSignalingServer(String wsUrl, String userId) async {
    try {
      _currentUserId = userId;
      _channel = WebSocketChannel.connect(Uri.parse('$wsUrl?user_id=$userId'));
      
      _channel!.stream.listen(
        _handleSignalingMessage,
        onError: (error) {
          debugPrint('WebSocket错误: $error');
          _eventController.add(WebRTCEvent.error('连接错误: $error'));
        },
        onDone: () {
          debugPrint('WebSocket连接关闭');
          _eventController.add(WebRTCEvent.disconnected());
        },
      );
      
      _eventController.add(WebRTCEvent.connected());
      debugPrint('连接到信令服务器成功');
    } catch (e) {
      debugPrint('连接信令服务器失败: $e');
      _eventController.add(WebRTCEvent.error('连接失败: $e'));
    }
  }

  /// 处理信令消息
  void _handleSignalingMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'] as String;
      
      debugPrint('收到信令消息: $type');
      
      switch (type) {
        case 'video_call_invite':
          _handleVideoCallInvite(data);
          break;
        case 'video_call_accept':
          _handleVideoCallAccept(data);
          break;
        case 'video_call_reject':
          _handleVideoCallReject(data);
          break;
        case 'video_call_end':
          _handleVideoCallEnd(data);
          break;
        case 'sdp_offer':
          _handleSdpOffer(data);
          break;
        case 'sdp_answer':
          _handleSdpAnswer(data);
          break;
        case 'ice_candidate':
          _handleIceCandidate(data);
          break;
        default:
          debugPrint('未知的信令消息类型: $type');
      }
    } catch (e) {
      debugPrint('处理信令消息失败: $e');
    }
  }

  /// 发起视频通话
  Future<void> startVideoCall(String otherUserId, String roomId) async {
    try {
      _otherUserId = otherUserId;
      _roomId = roomId;
      
      // 获取本地媒体流
      await _getUserMedia();
      
      // 创建PeerConnection
      await _createPeerConnection();
      
      // 添加本地流
      if (_localStream != null) {
        await _peerConnection!.addStream(_localStream!);
      }
      
      // 创建Offer
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      
      // 发送邀请和Offer
      _sendSignalingMessage({
        'type': 'video_call_invite',
        'data': {
          'callee_id': otherUserId,
          'room_id': roomId,
          'sdp': offer.sdp,
          'type': offer.type,
        },
      });
      
      _eventController.add(WebRTCEvent.callStarted());
      debugPrint('视频通话邀请已发送');
    } catch (e) {
      debugPrint('发起视频通话失败: $e');
      _eventController.add(WebRTCEvent.error('发起通话失败: $e'));
    }
  }

  /// 接受视频通话
  Future<void> acceptVideoCall(String callerId, String roomId, Map<String, dynamic> offerData) async {
    try {
      _otherUserId = callerId;
      _roomId = roomId;
      
      // 获取本地媒体流
      await _getUserMedia();
      
      // 创建PeerConnection
      await _createPeerConnection();
      
      // 添加本地流
      if (_localStream != null) {
        await _peerConnection!.addStream(_localStream!);
      }
      
      // 设置远程Offer
      final offer = RTCSessionDescription(
        offerData['sdp'] as String,
        offerData['type'] as String,
      );
      await _peerConnection!.setRemoteDescription(offer);
      
      // 创建Answer
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      
      // 发送接受和Answer
      _sendSignalingMessage({
        'type': 'video_call_accept',
        'data': {
          'caller_id': callerId,
          'room_id': roomId,
          'sdp': answer.sdp,
          'type': answer.type,
        },
      });
      
      _eventController.add(WebRTCEvent.callAccepted());
      debugPrint('视频通话已接受');
    } catch (e) {
      debugPrint('接受视频通话失败: $e');
      _eventController.add(WebRTCEvent.error('接受通话失败: $e'));
    }
  }

  /// 拒绝视频通话
  void rejectVideoCall(String callerId) {
    _sendSignalingMessage({
      'type': 'video_call_reject',
      'data': {
        'caller_id': callerId,
      },
    });
    
    _eventController.add(WebRTCEvent.callRejected());
    debugPrint('视频通话已拒绝');
  }

  /// 结束视频通话
  void endVideoCall() {
    _sendSignalingMessage({
      'type': 'video_call_end',
      'data': {
        'other_user_id': _otherUserId,
        'room_id': _roomId,
      },
    });
    
    _cleanup();
    _eventController.add(WebRTCEvent.callEnded());
    debugPrint('视频通话已结束');
  }

  /// 获取用户媒体
  Future<void> _getUserMedia() async {
    try {
      final constraints = {
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
      
      _localStream = await navigator.mediaDevices.getUserMedia(constraints);
      _localRenderer.srcObject = _localStream;
      
      _eventController.add(WebRTCEvent.localStreamReady(_localStream!));
      debugPrint('本地媒体流获取成功');
    } catch (e) {
      debugPrint('获取用户媒体失败: $e');
      _eventController.add(WebRTCEvent.error('获取媒体失败: $e'));
    }
  }

  /// 创建PeerConnection
  Future<void> _createPeerConnection() async {
    try {
      _peerConnection = await createPeerConnection({
        'iceServers': _iceServers,
      });
      
      // 设置事件监听
      _peerConnection!.onIceCandidate = (candidate) {
        _sendSignalingMessage({
          'type': 'ice_candidate',
          'data': {
            'other_user_id': _otherUserId,
            'candidate': candidate.toMap(),
          },
        });
      };
      
      _peerConnection!.onAddStream = (stream) {
        _remoteRenderer.srcObject = stream;
        _isConnected = true;
        _eventController.add(WebRTCEvent.remoteStreamReady(stream));
        debugPrint('远程媒体流已接收');
      };
      
      _peerConnection!.onRemoveStream = (stream) {
        _eventController.add(WebRTCEvent.remoteStreamRemoved(stream));
        debugPrint('远程媒体流已移除');
      };
      
      _peerConnection!.onIceConnectionState = (state) {
        debugPrint('ICE连接状态: $state');
        _eventController.add(WebRTCEvent.iceConnectionStateChanged(state));
      };
      
      _peerConnection!.onConnectionState = (state) {
        debugPrint('连接状态: $state');
        _eventController.add(WebRTCEvent.connectionStateChanged(state));
      };
      
      debugPrint('PeerConnection创建成功');
    } catch (e) {
      debugPrint('创建PeerConnection失败: $e');
      _eventController.add(WebRTCEvent.error('创建连接失败: $e'));
    }
  }

  /// 处理视频通话邀请
  void _handleVideoCallInvite(Map<String, dynamic> data) {
    final callData = data['data'] as Map<String, dynamic>;
    _eventController.add(WebRTCEvent.incomingCall(
      callData['caller_id'] as String,
      callData['room_id'] as String,
      callData,
    ));
  }

  /// 处理视频通话接受
  void _handleVideoCallAccept(Map<String, dynamic> data) {
    final callData = data['data'] as Map<String, dynamic>;
    _eventController.add(WebRTCEvent.callAccepted());
    
    // 设置远程Answer
    if (callData['sdp'] != null) {
      final answer = RTCSessionDescription(
        callData['sdp'] as String,
        callData['type'] as String,
      );
      _peerConnection?.setRemoteDescription(answer);
    }
  }

  /// 处理视频通话拒绝
  void _handleVideoCallReject(Map<String, dynamic> data) {
    _eventController.add(WebRTCEvent.callRejected());
    _cleanup();
  }

  /// 处理视频通话结束
  void _handleVideoCallEnd(Map<String, dynamic> data) {
    _eventController.add(WebRTCEvent.callEnded());
    _cleanup();
  }

  /// 处理SDP Offer
  void _handleSdpOffer(Map<String, dynamic> data) {
    final offerData = data['data'] as Map<String, dynamic>;
    final offer = RTCSessionDescription(
      offerData['sdp'] as String,
      offerData['type'] as String,
    );
    
    _peerConnection?.setRemoteDescription(offer).then((_) async {
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      
      _sendSignalingMessage({
        'type': 'sdp_answer',
        'data': {
          'other_user_id': _otherUserId,
          'sdp': answer.sdp,
          'type': answer.type,
        },
      });
    });
  }

  /// 处理SDP Answer
  void _handleSdpAnswer(Map<String, dynamic> data) {
    final answerData = data['data'] as Map<String, dynamic>;
    final answer = RTCSessionDescription(
      answerData['sdp'] as String,
      answerData['type'] as String,
    );
    
    _peerConnection?.setRemoteDescription(answer);
  }

  /// 处理ICE候选
  void _handleIceCandidate(Map<String, dynamic> data) {
    final candidateData = data['data'] as Map<String, dynamic>;
    final candidateMap = candidateData['candidate'] as Map<String, dynamic>;
    
    final candidate = RTCIceCandidate(
      candidateMap['candidate'] as String,
      candidateMap['sdpMid'] as String,
      candidateMap['sdpMLineIndex'] as int,
    );
    
    _peerConnection?.addCandidate(candidate);
  }

  /// 发送信令消息
  void _sendSignalingMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
      debugPrint('发送信令消息: ${message['type']}');
    }
  }

  /// 切换摄像头
  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
    }
  }

  /// 切换麦克风
  void toggleMicrophone() {
    if (_localStream != null) {
      final audioTrack = _localStream!.getAudioTracks().first;
      audioTrack.enabled = !audioTrack.enabled;
    }
  }

  /// 切换摄像头
  void toggleCamera() {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      videoTrack.enabled = !videoTrack.enabled;
    }
  }

  /// 清理资源
  void _cleanup() {
    _peerConnection?.close();
    _peerConnection = null;
    
    _localStream?.dispose();
    _localStream = null;
    
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    
    _isConnected = false;
    _otherUserId = null;
    _roomId = null;
  }

  /// 断开连接
  void disconnect() {
    _channel?.sink.close(status.normalClosure);
    _channel = null;
    _cleanup();
    _eventController.add(WebRTCEvent.disconnected());
  }

  /// 销毁服务
  void dispose() {
    disconnect();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _eventController.close();
  }

  // Getters
  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;
  bool get isInitialized => _isInitialized;
  bool get isConnected => _isConnected;
  String? get currentUserId => _currentUserId;
  String? get otherUserId => _otherUserId;
  String? get roomId => _roomId;
}

/// WebRTC事件
class WebRTCEvent {
  final WebRTCEventType type;
  final String? message;
  final String? callerId;
  final String? roomId;
  final Map<String, dynamic>? data;
  final MediaStream? stream;
  final RTCIceConnectionState? iceState;
  final RTCPeerConnectionState? connectionState;

  WebRTCEvent._({
    required this.type,
    this.message,
    this.callerId,
    this.roomId,
    this.data,
    this.stream,
    this.iceState,
    this.connectionState,
  });

  factory WebRTCEvent.initialized() => WebRTCEvent._(type: WebRTCEventType.initialized);
  factory WebRTCEvent.connected() => WebRTCEvent._(type: WebRTCEventType.connected);
  factory WebRTCEvent.disconnected() => WebRTCEvent._(type: WebRTCEventType.disconnected);
  factory WebRTCEvent.error(String message) => WebRTCEvent._(type: WebRTCEventType.error, message: message);
  factory WebRTCEvent.callStarted() => WebRTCEvent._(type: WebRTCEventType.callStarted);
  factory WebRTCEvent.callAccepted() => WebRTCEvent._(type: WebRTCEventType.callAccepted);
  factory WebRTCEvent.callRejected() => WebRTCEvent._(type: WebRTCEventType.callRejected);
  factory WebRTCEvent.callEnded() => WebRTCEvent._(type: WebRTCEventType.callEnded);
  factory WebRTCEvent.incomingCall(String callerId, String roomId, Map<String, dynamic> data) => 
      WebRTCEvent._(type: WebRTCEventType.incomingCall, callerId: callerId, roomId: roomId, data: data);
  factory WebRTCEvent.localStreamReady(MediaStream stream) => 
      WebRTCEvent._(type: WebRTCEventType.localStreamReady, stream: stream);
  factory WebRTCEvent.remoteStreamReady(MediaStream stream) => 
      WebRTCEvent._(type: WebRTCEventType.remoteStreamReady, stream: stream);
  factory WebRTCEvent.remoteStreamRemoved(MediaStream stream) => 
      WebRTCEvent._(type: WebRTCEventType.remoteStreamRemoved, stream: stream);
  factory WebRTCEvent.iceConnectionStateChanged(RTCIceConnectionState state) => 
      WebRTCEvent._(type: WebRTCEventType.iceConnectionStateChanged, iceState: state);
  factory WebRTCEvent.connectionStateChanged(RTCPeerConnectionState state) => 
      WebRTCEvent._(type: WebRTCEventType.connectionStateChanged, connectionState: state);
}

/// WebRTC事件类型
enum WebRTCEventType {
  initialized,
  connected,
  disconnected,
  error,
  callStarted,
  callAccepted,
  callRejected,
  callEnded,
  incomingCall,
  localStreamReady,
  remoteStreamReady,
  remoteStreamRemoved,
  iceConnectionStateChanged,
  connectionStateChanged,
}
