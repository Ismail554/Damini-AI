import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/chat_websocket_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/chat_item_model.dart';
import '../models/chat_message_model.dart';
import '../repositories/chat_repository.dart';

class DirectChatState {
  final ChatItemModel chatItem;
  final List<ChatMessageModel> messages;
  final bool isLoading;
  final bool isConnected;
  final String? typingUser;

  const DirectChatState({
    required this.chatItem,
    this.messages = const [],
    this.isLoading = false,
    this.isConnected = false,
    this.typingUser,
  });

  DirectChatState copyWith({
    ChatItemModel? chatItem,
    List<ChatMessageModel>? messages,
    bool? isLoading,
    bool? isConnected,
    String? typingUser,
    bool clearTypingUser = false,
  }) {
    return DirectChatState(
      chatItem: chatItem ?? this.chatItem,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      typingUser: clearTypingUser ? null : (typingUser ?? this.typingUser),
    );
  }
}

class DirectChatNotifier extends Notifier<DirectChatState> {
  final ChatItemModel chatItem;
  DirectChatNotifier(this.chatItem);

  late final ChatRepository _chatRepo;
  late final TextEditingController textController;
  late final ScrollController scrollController;
  String? _currentUserId;
  String? _currentUserName;

  StreamSubscription<Map<String, dynamic>>? _wsSubscription;

  @override
  DirectChatState build() {
    _chatRepo = ref.watch(chatRepositoryProvider);
    textController = TextEditingController();
    scrollController = ScrollController();

    ref.onDispose(() {
      _wsSubscription?.cancel();
      textController.dispose();
      scrollController.dispose();
    });

    _init();

    return DirectChatState(
      chatItem: chatItem,
      isLoading: true,
    );
  }

  Future<void> _init() async {
    _currentUserId = await StorageService.getUuid();
    _currentUserName = await StorageService.getUserName();
    final isBackendId = int.tryParse(chatItem.id) != null;

    if (isBackendId) {
      await _connectWebSocket(chatItem.id);
      await _fetchMessages(chatItem.id);
    } else {
      _loadFallback();
    }
  }

  Future<void> _fetchMessages(String convId) async {
    try {
      final fetched = await _chatRepo.fetchMessages(
        convId,
        currentUserId: _currentUserId,
        currentUserName: _currentUserName,
      );
      if (fetched.isNotEmpty) {
        final mapped = fetched
            .map((g) => ChatMessageModel(
                  id: g.id,
                  chatId: convId,
                  text: g.text,
                  timestamp: g.time,
                  isMe: g.isMe,
                  type: g.type,
                  mediaUrl: g.mediaUrl,
                  voiceDuration: g.voiceDuration,
                ))
            .toList();

        state = state.copyWith(messages: mapped, isLoading: false);
      } else {
        _loadFallback();
      }
      _chatRepo.markConversationAsRead(convId);
    } catch (_) {
      _loadFallback();
    } finally {
      _scrollToBottom();
    }
  }

  void _loadFallback() {
    final fallback = _chatRepo.fetchMessagesForChat(chatItem.id);
    state = state.copyWith(
      messages: List.from(fallback),
      isLoading: false,
    );
    _scrollToBottom();
  }

  Future<void> _connectWebSocket(String convId) async {
    final ws = ref.read(chatWebSocketServiceProvider);
    await ws.connect(convId);

    _wsSubscription?.cancel();
    _wsSubscription = ws.stream.listen(
      _handleSocketEvent,
      onError: (_) {
        state = state.copyWith(isConnected: false);
      },
    );

    state = state.copyWith(isConnected: ws.isConnected);
  }

  void _handleSocketEvent(Map<String, dynamic> event) {
    final type = event['type']?.toString();

    switch (type) {
      case 'new_message':
        final msgData = event['message'] is Map<String, dynamic>
            ? event['message'] as Map<String, dynamic>
            : (event['data'] is Map<String, dynamic>
                ? event['data'] as Map<String, dynamic>
                : null);

        if (msgData != null) {
          final newMsg = ChatMessageModel.fromJson(
            msgData,
            chatId: chatItem.id,
            currentUserId: _currentUserId,
            currentUserName: _currentUserName,
          );

          // 1. Avoid duplicate if message already exists with real ID
          if (state.messages.any((m) => m.id == newMsg.id && !m.id.startsWith('temp_'))) {
            break;
          }

          // 2. If it's my message, reconcile with pending optimistic message
          if (newMsg.isMe) {
            final tempIndex = state.messages.lastIndexWhere(
              (m) =>
                  m.id.startsWith('temp_') &&
                  m.type == newMsg.type &&
                  (newMsg.type != ChatMessageType.text ||
                      m.text.trim() == newMsg.text.trim()),
            );
            if (tempIndex != -1) {
              final existing = state.messages[tempIndex];
              final hasLocalFile = existing.mediaUrl != null &&
                  File(existing.mediaUrl!).existsSync() &&
                  File(existing.mediaUrl!).lengthSync() > 10;
              final merged = newMsg.copyWith(
                mediaUrl: hasLocalFile
                    ? existing.mediaUrl
                    : (newMsg.mediaUrl ?? existing.mediaUrl),
                voiceDuration: newMsg.voiceDuration ?? existing.voiceDuration,
              );
              final updated = List<ChatMessageModel>.from(state.messages);
              updated[tempIndex] = merged;
              state = state.copyWith(messages: updated);
              _scrollToBottom();
              break;
            }
          }

          state = state.copyWith(messages: [...state.messages, newMsg]);
          _scrollToBottom();

          if (!newMsg.isMe) {
            final ws = ref.read(chatWebSocketServiceProvider);
            final msgId = int.tryParse(newMsg.id);
            if (msgId != null) ws.markRead(msgId);
          }
        }
        break;

      case 'user_typing':
        final isTyping = event['is_typing'] == true;
        final userName = event['user_name']?.toString();
        state = state.copyWith(
          typingUser: isTyping ? userName : null,
          clearTypingUser: !isTyping,
        );
        break;
    }
  }

  void onTyping(bool isTyping) {
    final ws = ref.read(chatWebSocketServiceProvider);
    ws.sendTyping(isTyping);
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    textController.clear();
    onTyping(false);

    final now = DateTime.now();
    final timeStr =
        "${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final newMessage = ChatMessageModel(
      id: tempId,
      chatId: state.chatItem.id,
      text: text,
      timestamp: timeStr,
      isMe: true,
      type: ChatMessageType.text,
    );

    state = state.copyWith(messages: [...state.messages, newMessage]);
    _scrollToBottom();

    final ws = ref.read(chatWebSocketServiceProvider);
    final sent = ws.sendMessage(text: text);
    if (!sent && int.tryParse(chatItem.id) != null) {
      await ws.connect(chatItem.id);
      ws.sendMessage(text: text);
    }
  }

  Future<void> sendImageMessage(String imagePath) async {
    if (imagePath.isEmpty) return;

    final now = DateTime.now();
    final timeStr =
        "${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final newMessage = ChatMessageModel(
      id: tempId,
      chatId: state.chatItem.id,
      text: "Photo",
      timestamp: timeStr,
      isMe: true,
      type: ChatMessageType.image,
      mediaUrl: imagePath,
    );

    state = state.copyWith(messages: [...state.messages, newMessage]);
    _scrollToBottom();

    try {
      final uploadRes = await _chatRepo.uploadMedia(
        filePath: imagePath,
        type: 'image',
      );
      final uploadedUrl = uploadRes['media_url'] as String? ?? imagePath;

      final ws = ref.read(chatWebSocketServiceProvider);
      final sent = ws.sendMessage(
        text: 'Photo',
        messageType: 'image',
        mediaUrl: uploadedUrl,
      );
      if (!sent && int.tryParse(chatItem.id) != null) {
        await ws.connect(chatItem.id);
        ws.sendMessage(
          text: 'Photo',
          messageType: 'image',
          mediaUrl: uploadedUrl,
        );
      }
    } catch (_) {}
  }

  Future<void> sendVoiceMessage(String duration, {String? filePath}) async {
    final now = DateTime.now();
    final timeStr =
        "${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final newMessage = ChatMessageModel(
      id: tempId,
      chatId: state.chatItem.id,
      text: "Voice message",
      timestamp: timeStr,
      isMe: true,
      type: ChatMessageType.voice,
      voiceDuration: duration,
      mediaUrl: filePath,
    );

    state = state.copyWith(messages: [...state.messages, newMessage]);
    _scrollToBottom();

    String? uploadedUrl;
    if (filePath != null && filePath.isNotEmpty && File(filePath).existsSync()) {
      try {
        final uploadRes = await _chatRepo.uploadMedia(
          filePath: filePath,
          type: 'voice',
          voiceDuration: duration,
        );
        debugPrint("Direct chat voice upload response: $uploadRes");
        uploadedUrl = (uploadRes['media_url'] ??
                uploadRes['file'] ??
                uploadRes['url'] ??
                uploadRes['media'])
            ?.toString();
      } catch (e) {
        debugPrint("Error uploading voice file in direct chat: $e");
      }
    }

    final ws = ref.read(chatWebSocketServiceProvider);
    final sent = ws.sendMessage(
      text: 'Voice message',
      messageType: 'voice',
      mediaUrl: uploadedUrl,
      voiceDuration: duration,
    );
    if (!sent && int.tryParse(chatItem.id) != null) {
      await ws.connect(chatItem.id);
      ws.sendMessage(
        text: 'Voice message',
        messageType: 'voice',
        mediaUrl: uploadedUrl,
        voiceDuration: duration,
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

final directChatProvider = NotifierProvider.autoDispose
    .family<DirectChatNotifier, DirectChatState, ChatItemModel>(
  DirectChatNotifier.new,
);
