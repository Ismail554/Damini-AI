import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_endpoints.dart';
import 'storage_service.dart';

final chatWebSocketServiceProvider = Provider<ChatWebSocketService>((ref) {
  final service = ChatWebSocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

class ChatWebSocketService {
  WebSocket? _socket;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  String? _activeConversationId;
  bool _isManualClose = false;
  int _reconnectAttempts = 0;

  final _eventController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _eventController.stream;

  bool get isConnected =>
      _socket != null && _socket!.readyState == WebSocket.open;

  /// Connect to the WebSocket for a given conversation ID
  Future<void> connect(String conversationId) async {
    if (_activeConversationId == conversationId && isConnected) return;

    await disconnect();
    _isManualClose = false;
    _activeConversationId = conversationId;

    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) return;

    final wsUrl = ApiEndpoints.chatWebSocket(conversationId, token);

    try {
      _socket = await WebSocket.connect(wsUrl).timeout(
        const Duration(seconds: 10),
      );

      _reconnectAttempts = 0;
      _startHeartbeat();

      _socket!.listen(
        (data) {
          try {
            if (data is String) {
              final json = jsonDecode(data);
              if (json is Map<String, dynamic>) {
                if (json['type'] == 'pong') return; // Heartbeat response
                _eventController.add(json);
              }
            }
          } catch (_) {}
        },
        onError: (err) {
          _scheduleReconnect();
        },
        onDone: () {
          if (!_isManualClose) {
            _scheduleReconnect();
          }
        },
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  /// Sends a text, image, or voice message over WebSocket
  bool sendMessage({
    required String text,
    String messageType = 'text',
    String? mediaUrl,
    String? voiceDuration,
  }) {
    if (!isConnected) return false;

    final payload = {
      'action': 'send_message',
      'type': 'send_message',
      'message_type': messageType,
      'text': text,
      'content': text,
      'message': text,
      'media_url': ?mediaUrl,
      'file': ?mediaUrl,
      'voice_duration': ?voiceDuration,
      'duration': ?voiceDuration,
    };

    try {
      _socket?.add(jsonEncode(payload));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Send typing indicator
  void sendTyping(bool isTyping) {
    if (!isConnected) return;
    try {
      _socket?.add(jsonEncode({
        'action': 'typing',
        'type': 'typing',
        'is_typing': isTyping,
      }));
    } catch (_) {}
  }

  /// Mark messages read up to lastMessageId
  void markRead(int lastMessageId) {
    if (!isConnected) return;
    try {
      _socket?.add(jsonEncode({
        'type': 'mark_read',
        'last_message_id': lastMessageId,
      }));
    } catch (_) {}
  }

  void _startHeartbeat() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (timer) {
      if (isConnected) {
        try {
          _socket?.add(jsonEncode({'type': 'ping'}));
        } catch (_) {}
      }
    });
  }

  void _scheduleReconnect() {
    _pingTimer?.cancel();
    _socket = null;

    if (_isManualClose || _activeConversationId == null) return;

    _reconnectTimer?.cancel();
    final delaySeconds = (_reconnectAttempts < 5) ? (2 * (_reconnectAttempts + 1)) : 10;
    _reconnectAttempts++;

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_isManualClose && _activeConversationId != null) {
        connect(_activeConversationId!);
      }
    });
  }

  Future<void> disconnect() async {
    _isManualClose = true;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    try {
      await _socket?.close();
    } catch (_) {}
    _socket = null;
    _activeConversationId = null;
  }

  void dispose() {
    disconnect();
    _eventController.close();
  }
}
