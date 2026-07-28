import 'package:flutter/material.dart';
import '../models/chat_item_model.dart';
import '../models/chat_message_model.dart';
import '../repositories/chat_repository.dart';

class DirectChatProvider extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  late ChatItemModel _chatItem;
  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;

  ChatItemModel get chatItem => _chatItem;
  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  void init(ChatItemModel chatItem) {
    _chatItem = chatItem;
    _isLoading = true;
    notifyListeners();

    _messages = _repository.fetchMessagesForChat(chatItem.id);
    _isLoading = false;
    notifyListeners();

    _scrollToBottom();
  }

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final timeStr =
        "${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    final newMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: _chatItem.id,
      text: text,
      timestamp: timeStr,
      isMe: true,
    );

    _messages.add(newMessage);
    textController.clear();
    notifyListeners();
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

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
