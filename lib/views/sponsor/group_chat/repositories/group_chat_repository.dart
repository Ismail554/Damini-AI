import '../models/group_chat_model.dart';

abstract class GroupChatRepository {
  Future<List<GroupChatMessage>> fetchInitialMessages();
  Future<List<AiSuggestion>> fetchSuggestions();
  Future<GroupChatMessage> sendMessage(String text);
}

class GroupChatRepositoryImpl implements GroupChatRepository {
  @override
  Future<List<GroupChatMessage>> fetchInitialMessages() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return const [
      GroupChatMessage(
        id: '1',
        senderName: 'Damani AI',
        avatarInitials: 'AI',
        avatarType: ChatAvatarType.ai,
        isAi: true,
        isMe: false,
        text:
            'Welcome! This is a group chat with Arif (Sponsor), David (Investor), and me — VentureAI. I am here to keep the conversation on track and suggest next steps.',
        time: '10:05',
      ),
      GroupChatMessage(
        id: '2',
        senderName: 'David Chen',
        senderRole: 'Investor',
        avatarInitials: 'DC',
        avatarType: ChatAvatarType.investor,
        isAi: false,
        isMe: false,
        text:
            'Hello Arif! Very interested to hear about your EdTech project. How many active users do you currently have?',
        time: '10:06',
      ),
      GroupChatMessage(
        id: '3',
        senderName: 'You',
        senderRole: 'Sponsor',
        avatarInitials: 'A',
        avatarType: ChatAvatarType.sponsor,
        isAi: false,
        isMe: true,
        text:
            'We have 2,400 beta users so far, growing at 34% month over month.',
        time: '10:07',
      ),
      GroupChatMessage(
        id: '4',
        senderName: 'Damani AI',
        avatarInitials: 'AI',
        avatarType: ChatAvatarType.ai,
        isAi: true,
        isMe: false,
        text:
            '💡 Tip: Share your retention rate and monthly active users (MAU) with David — these are the most important metrics for investors at the seed stage.',
        time: '10:07',
      ),
    ];
  }

  @override
  Future<List<AiSuggestion>> fetchSuggestions() async {
    return const [
      AiSuggestion(
        id: 's1',
        title: 'Prepare pitch deck',
        icon: '\$',
        isCompleted: true,
      ),
      AiSuggestion(
        id: 's2',
        title: 'Define MVP roadmap',
        icon: '⚡',
        isCompleted: true,
      ),
      AiSuggestion(
        id: 's3',
        title: 'Set financial targets',
        icon: '📈',
        isCompleted: false,
      ),
    ];
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
      avatarInitials: 'A',
      avatarType: ChatAvatarType.sponsor,
      isAi: false,
      isMe: true,
      text: text,
      time: timeStr,
    );
  }
}
