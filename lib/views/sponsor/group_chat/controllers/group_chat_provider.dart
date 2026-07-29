import 'package:flutter/material.dart';
import '../../chat/models/chat_message_model.dart';
import '../models/group_chat_model.dart';
import '../repositories/group_chat_repository.dart';

class GroupChatProvider extends ChangeNotifier {
  final GroupChatRepository _repository;

  GroupChatProvider({GroupChatRepository? repository})
      : _repository = repository ?? GroupChatRepositoryImpl();

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<GroupChatMessage> _messages = [];
  List<GroupChatMessage> get messages => _messages;

  List<AiSuggestion> _suggestions = [];
  List<AiSuggestion> get suggestions => _suggestions;

  final List<String> _participants = [
    'Ahmad Al-Rashid',
    'Marcus Webb',
    'Priya Mehta',
  ];
  List<String> get participants => _participants;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void removeParticipant(String name) {
    _participants.remove(name);
    addSystemMessage('⚠️ $name was removed from the group by the owner.');
    notifyListeners();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedMessages = await _repository.fetchInitialMessages();
      final fetchedSuggestions = await _repository.fetchSuggestions();
      _messages = List.from(fetchedMessages);
      _suggestions = List.from(fetchedSuggestions);
    } catch (_) {
      // Empty/Error state handling
    } finally {
      _isLoading = false;
      notifyListeners();
      _scrollToBottom();
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messageController.clear();
    final newMsg = await _repository.sendMessage(text);
    _messages.add(newMsg);
    notifyListeners();
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

    _messages.add(newMsg);
    notifyListeners();
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

    _messages.add(newMsg);
    notifyListeners();
    _scrollToBottom();
  }

  void addSystemMessage(String text) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _messages.add(
      GroupChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderName: 'Damani AI',
        avatarInitials: 'AI',
        avatarType: ChatAvatarType.ai,
        isAi: true,
        isMe: false,
        text: text,
        time: timeStr,
      ),
    );
    notifyListeners();
    _scrollToBottom();
  }

  void onSuggestionTap(AiSuggestion suggestion) {
    messageController.text = suggestion.title;
    notifyListeners();
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
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
