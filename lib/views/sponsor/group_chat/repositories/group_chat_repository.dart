import '../models/group_chat_model.dart';

abstract class GroupChatRepository {
  Future<List<GroupChatMessage>> fetchInitialMessages();
  Future<List<AiSuggestion>> fetchSuggestions();
  Future<GroupChatMessage> sendMessage(String text);
}

class GroupChatRepositoryImpl implements GroupChatRepository {
  @override
  Future<List<GroupChatMessage>> fetchInitialMessages() async {
    return const [];
  }

  @override
  Future<List<AiSuggestion>> fetchSuggestions() async {
    return const [];
  }

  @override
  Future<GroupChatMessage> sendMessage(String text) async {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return GroupChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderName: 'You',
      senderRole: 'Sponsor',
      avatarInitials: 'YO',
      avatarType: ChatAvatarType.sponsor,
      isAi: false,
      isMe: true,
      text: text,
      time: timeStr,
    );
  }
}
