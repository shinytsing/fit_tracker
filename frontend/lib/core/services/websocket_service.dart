import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// WebSocket信令服务
/// 处理视频通话的信令交换
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocket? _socket;
  String? _userId;
  String? _token;
  bool _isConnected = false;
  final StreamController<Map<String, dynamic>> _messageController = 
      StreamController<Map<String, dynamic>>.broadcast();

  // 事件回调
  Function(Map<String, dynamic>)? onVideoCallInvite;
  Function(Map<String, dynamic>)? onVideoCallAccept;
  Function(Map<String, dynamic>)? onVideoCallReject;
  Function(Map<String, dynamic>)? onVideoCallEnd;
  Function(Map<String, dynamic>)? onIceCandidate;
  Function(Map<String, dynamic>)? onSdpOffer;
  Function(Map<String, dynamic>)? onSdpAnswer;

  /// 连接WebSocket
  Future<bool> connect(String userId, String token, {String? serverUrl}) async {
    try {
      _userId = userId;
      _token = token;
      
      final url = serverUrl ?? 'ws://localhost:8080/ws';
      final uri = Uri.parse('$url?user_id=$userId&token=$token');
      
      _socket = await WebSocket.connect(uri.toString());
      _isConnected = true;
      
      _socket!.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      debugPrint('WebSocket连接成功');
      return true;
    } catch (e) {
      debugPrint('WebSocket连接失败: $e');
      _isConnected = false;
      return false;
    }
  }

  /// 断开连接
  void disconnect() {
    _socket?.close();
    _socket = null;
    _isConnected = false;
    debugPrint('WebSocket连接已断开');
  }

  /// 发送消息
  void sendMessage(Map<String, dynamic> message) {
    if (_socket != null && _isConnected) {
      final jsonMessage = json.encode(message);
      _socket!.add(jsonMessage);
      debugPrint('发送WebSocket消息: $jsonMessage');
    } else {
      debugPrint('WebSocket未连接，无法发送消息');
    }
  }

  /// 发起视频通话邀请
  void sendVideoCallInvite({
    required String calleeId,
    required String chatId,
    required String roomId,
  }) {
    final message = {
      'type': 'video_call_invite',
      'data': {
        'caller_id': _userId,
        'callee_id': calleeId,
        'chat_id': chatId,
        'room_id': roomId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    };
    sendMessage(message);
  }

  /// 接受视频通话
  void sendVideoCallAccept({
    required String callerId,
    required String chatId,
    required String roomId,
  }) {
    final message = {
      'type': 'video_call_accept',
      'data': {
        'caller_id': callerId,
        'callee_id': _userId,
        'chat_id': chatId,
        'room_id': roomId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    };
    sendMessage(message);
  }

  /// 拒绝视频通话
  void sendVideoCallReject({
    required String callerId,
    required String chatId,
    required String roomId,
  }) {
    final message = {
      'type': 'video_call_reject',
      'data': {
        'caller_id': callerId,
        'callee_id': _userId,
        'chat_id': chatId,
        'room_id': roomId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    };
    sendMessage(message);
  }

  /// 结束视频通话
  void sendVideoCallEnd({
    required String callerId,
    required String calleeId,
    required String chatId,
    required String roomId,
  }) {
    final message = {
      'type': 'video_call_end',
      'data': {
        'caller_id': callerId,
        'callee_id': calleeId,
        'chat_id': chatId,
        'room_id': roomId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    };
    sendMessage(message);
  }

  /// 发送ICE候选
  void sendIceCandidate({
    required String targetUserId,
    required String chatId,
    required RTCIceCandidate candidate,
  }) {
    final message = {
      'type': 'ice_candidate',
      'data': {
        'target_user_id': targetUserId,
        'chat_id': chatId,
        'candidate': {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        },
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    };
    sendMessage(message);
  }

  /// 发送SDP Offer
  void sendSdpOffer({
    required String targetUserId,
    required String chatId,
    required RTCSessionDescription offer,
  }) {
    final message = {
      'type': 'sdp_offer',
      'data': {
        'target_user_id': targetUserId,
        'chat_id': chatId,
        'sdp': {
          'type': offer.type,
          'sdp': offer.sdp,
        },
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    };
    sendMessage(message);
  }

  /// 发送SDP Answer
  void sendSdpAnswer({
    required String targetUserId,
    required String chatId,
    required RTCSessionDescription answer,
  }) {
    final message = {
      'type': 'sdp_answer',
      'data': {
        'target_user_id': targetUserId,
        'chat_id': chatId,
        'sdp': {
          'type': answer.type,
          'sdp': answer.sdp,
        },
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    };
    sendMessage(message);
  }

  /// 处理接收到的消息
  void _onMessage(dynamic data) {
    try {
      final message = json.decode(data) as Map<String, dynamic>;
      debugPrint('接收WebSocket消息: $message');
      
      _messageController.add(message);
      
      // 根据消息类型调用相应的回调
      final type = message['type'] as String;
      final messageData = message['data'] as Map<String, dynamic>;
      
      switch (type) {
        case 'video_call_invite':
          onVideoCallInvite?.call(messageData);
          break;
        case 'video_call_accept':
          onVideoCallAccept?.call(messageData);
          break;
        case 'video_call_reject':
          onVideoCallReject?.call(messageData);
          break;
        case 'video_call_end':
          onVideoCallEnd?.call(messageData);
          break;
        case 'ice_candidate':
          onIceCandidate?.call(messageData);
          break;
        case 'sdp_offer':
          onSdpOffer?.call(messageData);
          break;
        case 'sdp_answer':
          onSdpAnswer?.call(messageData);
          break;
        default:
          debugPrint('未知消息类型: $type');
      }
    } catch (e) {
      debugPrint('解析WebSocket消息失败: $e');
    }
  }

  /// 处理错误
  void _onError(dynamic error) {
    debugPrint('WebSocket错误: $error');
    _isConnected = false;
  }

  /// 处理连接关闭
  void _onDone() {
    debugPrint('WebSocket连接已关闭');
    _isConnected = false;
  }

  /// 获取消息流
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  /// 是否已连接
  bool get isConnected => _isConnected;

  /// 用户ID
  String? get userId => _userId;

  /// 清理资源
  void dispose() {
    disconnect();
    _messageController.close();
  }
}
