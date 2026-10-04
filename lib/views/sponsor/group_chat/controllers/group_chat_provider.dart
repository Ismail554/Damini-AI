import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/chat_websocket_service.dart';
import '../../chat/models/chat_message_model.dart';
import '../../chat/repositories/chat_repository.dart';
import '../models/group_chat_model.dart';
import '../repositories/group_chat_repository.dart';

class GroupChatState {
  final String? conversationId;
  final int? projectId;
  final String? projectTitle;
  final List<GroupChatMessage> messages;
  final List<AiSuggestion> suggestions;
  final List<String> participants;
  final bool isLoading;
  final bool isConnected;
  final String? typingUser;

  const GroupChatState({
    this.conversationId,
    this.projectId,
    this.projectTitle,
    this.messages = const [],
    this.suggestions = const [],
    this.participants = const [],
    this.isLoading = false,
    this.isConnected = false,
    this.typingUser,
  });

  GroupChatState copyWith({
    String? conversationId,
    int? projectId,
    String? projectTitle,
    List<GroupChatMessage>? messages,
    List<AiSuggestion>? suggestions,
    List<String>? participants,
    bool? isLoading,
    bool? isConnected,
    String? typingUser,
    bool clearTypingUser = false,
  }) {
    return GroupChatState(
      conversationId: conversationId ?? this.conversationId,
      projectId: projectId ?? this.projectId,
      projectTitle: projectTitle ?? this.projectTitle,
      messages: messages ?? this.messages,
      suggestions: suggestions ?? this.suggestions,
      participants: participants ?? this.participants,
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      typingUser: clearTypingUser ? null : (typingUser ?? this.typingUser),
    );
  }
}

class GroupChatNotifier extends Notifier<GroupChatState> {
  late final GroupChatRepository _fallbackRepo;
  late final ChatRepository _chatRepo;
  late final TextEditingController messageController;
  late final ScrollController scrollController;

  StreamSubscription<Map<String, dynamic>>? _wsSubscription;

  @override
  GroupChatState build() {
    _fallbackRepo = GroupChatRepositoryImpl();
    _chatRepo = ref.watch(chatRepositoryProvider);
    messageController = TextEditingController();
    scrollController = ScrollController();

    ref.onDispose(() {
      _wsSubscription?.cancel();
      messageController.dispose();
      scrollController.dispose();
    });

    return const GroupChatState(isLoading: true);
  }

  Future<void> init({
    String? conversationId,
    int? projectId,
    String? projectTitle,
  }) async {
    state = state.copyWith(
      conversationId: conversationId,
      projectId: projectId,
      projectTitle: projectTitle,
      isLoading: true,
    );

    String? targetConvId = conversationId;

    if ((targetConvId == null || targetConvId.isEmpty) &&
        projectId != null &&
        projectId > 0) {
      try {
        final conv = await _chatRepo.startConversation(
          targetUserId: 0,
          projectId: projectId,
        );
        targetConvId = conv.id.toString();
        state = state.copyWith(conversationId: targetConvId);
      } catch (_) {}
    }

    if (targetConvId != null && targetConvId.isNotEmpty) {
      await _connectWebSocket(targetConvId);
      await _fetchMessages(targetConvId);
    } else {
      state = state.copyWith(
        isLoading: false,
        messages: const [],
        suggestions: const [],
      );
    }
  }

  Future<void> _fetchMessages(String convId) async {
    try {
      final fetchedMessages = await _chatRepo.fetchMessages(convId);

      // Collect active participants from message history
      final participantSet = <String>{};
      for (final m in fetchedMessages) {
        if (!m.isMe &&
            !m.isAi &&
            m.senderName.trim().isNotEmpty &&
            m.senderName.trim().toLowerCase() != 'user' &&
            m.senderName.trim().toLowerCase() != 'you') {
          participantSet.add(m.senderName.trim());
        }
      }

      state = state.copyWith(
        messages: List.from(fetchedMessages),
        participants: participantSet.isNotEmpty
            ? participantSet.toList()
            : state.participants,
        suggestions: const [],
        isLoading: false,
      );

      _chatRepo.markConversationAsRead(convId);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        messages: const [],
        suggestions: const [],
      );
    } finally {
      _scrollToBottom();
    }
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
          final newMsg = GroupChatMessage.fromJson(msgData);
          if (!state.messages.any((m) => m.id == newMsg.id)) {
            final updatedParticipants = List<String>.from(state.participants);
            if (!newMsg.isMe &&
                !newMsg.isAi &&
                newMsg.senderName.trim().isNotEmpty &&
                newMsg.senderName.trim().toLowerCase() != 'user' &&
                newMsg.senderName.trim().toLowerCase() != 'you') {
              if (!updatedParticipants.contains(newMsg.senderName.trim())) {
                updatedParticipants.add(newMsg.senderName.trim());
              }
            }

            state = state.copyWith(
              messages: [...state.messages, newMsg],
              participants: updatedParticipants,
            );
            _scrollToBottom();

            if (!newMsg.isMe) {
              final ws = ref.read(chatWebSocketServiceProvider);
              final msgId = int.tryParse(newMsg.id);
              if (msgId != null) ws.markRead(msgId);
            }
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

      case 'ai_suggestion':
        final rawSuggs = event['suggestions'] as List?;
        if (rawSuggs != null) {
          final suggs = rawSuggs
              .whereType<Map>()
              .map((m) => AiSuggestion.fromJson(Map<String, dynamic>.from(m)))
              .toList();
          state = state.copyWith(suggestions: suggs);
        }
        break;

      case 'participant_removed':
      case 'participant_left':
        final userName = event['user_name']?.toString();
        final sysMsg = event['system_message']?.toString() ??
            '⚠️ ${userName ?? "A member"} left the group.';
        if (userName != null) {
          final updated = List<String>.from(state.participants)..remove(userName);
          state = state.copyWith(participants: updated);
        }
        addSystemMessage(sysMsg);
        break;
    }
  }

  void onTyping(bool isTyping) {
    final ws = ref.read(chatWebSocketServiceProvider);
    ws.sendTyping(isTyping);
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messageController.clear();
    onTyping(false);

    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final optimisticMsg = GroupChatMessage(
      id: tempId,
      senderName: 'You',
      senderRole: 'Sponsor',
      avatarInitials: 'YO',
      avatarType: ChatAvatarType.sponsor,
      isAi: false,
      isMe: true,
      text: text,
      time: timeStr,
    );

    state = state.copyWith(messages: [...state.messages, optimisticMsg]);
    _scrollToBottom();

    final ws = ref.read(chatWebSocketServiceProvider);
    final sent = ws.sendMessage(text: text);
    if (!sent && state.conversationId == null) {
      await _fallbackRepo.sendMessage(text);
    }
  }

  Future<void> sendImageMessage(String imagePath) async {
    if (imagePath.isEmpty) return;

    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final optimisticMsg = GroupChatMessage(
      id: tempId,
      senderName: 'You',
      senderRole: 'Sponsor',
      avatarInitials: 'YO',
      avatarType: ChatAvatarType.sponsor,
      isAi: false,
      isMe: true,
      text: 'Photo',
      time: timeStr,
      type: ChatMessageType.image,
      mediaUrl: imagePath,
    );

    state = state.copyWith(messages: [...state.messages, optimisticMsg]);
    _scrollToBottom();

    try {
      final uploadRes = await _chatRepo.uploadMedia(
        filePath: imagePath,
        type: 'image',
      );
      final uploadedUrl = uploadRes['media_url'] as String? ?? imagePath;

      final ws = ref.read(chatWebSocketServiceProvider);
      ws.sendMessage(
        text: 'Photo',
        messageType: 'image',
        mediaUrl: uploadedUrl,
      );
    } catch (_) {}
  }

  Future<void> sendVoiceMessage(String duration, {String? filePath}) async {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final optimisticMsg = GroupChatMessage(
      id: tempId,
      senderName: 'You',
      senderRole: 'Sponsor',
      avatarInitials: 'YO',
      avatarType: ChatAvatarType.sponsor,
      isAi: false,
      isMe: true,
      text: 'Voice message',
      time: timeStr,
      type: ChatMessageType.voice,
      voiceDuration: duration,
      mediaUrl: filePath,
    );

    state = state.copyWith(messages: [...state.messages, optimisticMsg]);
    _scrollToBottom();

    if (filePath != null && filePath.isNotEmpty) {
      try {
        final uploadRes = await _chatRepo.uploadMedia(
          filePath: filePath,
          type: 'voice',
          voiceDuration: duration,
        );
        final uploadedUrl = uploadRes['media_url'] as String?;

        final ws = ref.read(chatWebSocketServiceProvider);
        ws.sendMessage(
          text: 'Voice message',
          messageType: 'voice',
          mediaUrl: uploadedUrl,
          voiceDuration: duration,
        );
      } catch (_) {}
    }
  }

  void addSystemMessage(String text) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final sysMsg = GroupChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderName: 'Damani AI',
      avatarInitials: 'AI',
      avatarType: ChatAvatarType.ai,
      isAi: true,
      isMe: false,
      text: text,
      time: timeStr,
    );
    state = state.copyWith(messages: [...state.messages, sysMsg]);
    _scrollToBottom();
  }

  Future<void> removeParticipant(String name, {String? userId}) async {
    final updatedParticipants = List<String>.from(state.participants)..remove(name);
    state = state.copyWith(participants: updatedParticipants);
    addSystemMessage('⚠️ $name was removed from the group by the owner.');

    if (state.conversationId != null && userId != null) {
      try {
        await _chatRepo.removeParticipant(
          conversationId: state.conversationId!,
          userId: userId,
        );
      } catch (_) {}
    }
  }

  void onSuggestionTap(AiSuggestion suggestion) {
    messageController.text = suggestion.title;
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

final groupChatProvider =
    NotifierProvider.autoDispose<GroupChatNotifier, GroupChatState>(
  GroupChatNotifier.new,
);
