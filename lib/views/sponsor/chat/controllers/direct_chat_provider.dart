import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_item_model.dart';
import '../models/chat_message_model.dart';
import '../repositories/chat_repository.dart';

class DirectChatState {
  final ChatItemModel chatItem;
  final List<ChatMessageModel> messages;
  final bool isLoading;

  const DirectChatState({
    required this.chatItem,
    this.messages = const [],
    this.isLoading = false,
  });

  DirectChatState copyWith({
    ChatItemModel? chatItem,
    List<ChatMessageModel>? messages,
    bool? isLoading,
  }) {
    return DirectChatState(
      chatItem: chatItem ?? this.chatItem,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DirectChatNotifier extends Notifier<DirectChatState> {
  final ChatItemModel chatItem;
  DirectChatNotifier(this.chatItem);

  final ChatRepository _repository = ChatRepository();
  late final TextEditingController textController;
  late final ScrollController scrollController;

  @override
  DirectChatState build() {
    textController = TextEditingController();
    scrollController = ScrollController();
    ref.onDispose(() {
      textController.dispose();
      scrollController.dispose();
    });

    final messages = _repository.fetchMessagesForChat(chatItem.id);
    return DirectChatState(
      chatItem: chatItem,
      messages: messages,
      isLoading: false,
    );
  }

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final timeStr =
        "${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    final newMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: state.chatItem.id,
      text: text,
      timestamp: timeStr,
      isMe: true,
      type: ChatMessageType.text,
    );

    state = state.copyWith(messages: [...state.messages, newMessage]);
    textController.clear();
    _scrollToBottom();
  }

  void sendImageMessage(String imagePath) {
    if (imagePath.isEmpty) return;

    final now = DateTime.now();
    final timeStr =
        "${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    final newMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: state.chatItem.id,
      text: "Photo",
      timestamp: timeStr,
      isMe: true,
      type: ChatMessageType.image,
      mediaUrl: imagePath,
    );

    state = state.copyWith(messages: [...state.messages, newMessage]);
    _scrollToBottom();
  }

  void sendVoiceMessage(String duration) {
    final now = DateTime.now();
    final timeStr =
        "${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    final newMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: state.chatItem.id,
      text: "Voice message",
      timestamp: timeStr,
      isMe: true,
      type: ChatMessageType.voice,
      voiceDuration: duration,
    );

    state = state.copyWith(messages: [...state.messages, newMessage]);
    _scrollToBottom();
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
