import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chat/models/chat_message_model.dart';
import '../models/group_chat_model.dart';
import '../repositories/group_chat_repository.dart';

class GroupChatState {
  final List<GroupChatMessage> messages;
  final List<AiSuggestion> suggestions;
  final List<String> participants;
  final bool isLoading;

  const GroupChatState({
    this.messages = const [],
    this.suggestions = const [],
    this.participants = const [
      'Ahmad Al-Rashid',
      'Marcus Webb',
      'Priya Mehta',
    ],
    this.isLoading = false,
  });

  GroupChatState copyWith({
    List<GroupChatMessage>? messages,
    List<AiSuggestion>? suggestions,
    List<String>? participants,
    bool? isLoading,
  }) {
    return GroupChatState(
      messages: messages ?? this.messages,
      suggestions: suggestions ?? this.suggestions,
      participants: participants ?? this.participants,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class GroupChatNotifier extends Notifier<GroupChatState> {
  late final GroupChatRepository _repository;
  late final TextEditingController messageController;
  late final ScrollController scrollController;

  @override
  GroupChatState build() {
    _repository = GroupChatRepositoryImpl();
    messageController = TextEditingController();
    scrollController = ScrollController();
    ref.onDispose(() {
      messageController.dispose();
      scrollController.dispose();
    });

    _init();

    return const GroupChatState(isLoading: true);
  }

  Future<void> _init() async {
    try {
      final fetchedMessages = await _repository.fetchInitialMessages();
      final fetchedSuggestions = await _repository.fetchSuggestions();
      state = state.copyWith(
        messages: List.from(fetchedMessages),
        suggestions: List.from(fetchedSuggestions),
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    } finally {
      _scrollToBottom();
    }
  }

  void removeParticipant(String name) {
    final updatedParticipants = List<String>.from(state.participants)..remove(name);
    state = state.copyWith(participants: updatedParticipants);
    addSystemMessage('⚠️ $name was removed from the group by the owner.');
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messageController.clear();
    final newMsg = await _repository.sendMessage(text);
    state = state.copyWith(messages: [...state.messages, newMsg]);
    _scrollToBottom();
  }

  void sendImageMessage(String imagePath) {
    if (imagePath.isEmpty) return;

    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final newMsg = GroupChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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

    state = state.copyWith(messages: [...state.messages, newMsg]);
    _scrollToBottom();
  }

  void sendVoiceMessage(String duration) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final newMsg = GroupChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
    );

    state = state.copyWith(messages: [...state.messages, newMsg]);
    _scrollToBottom();
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
