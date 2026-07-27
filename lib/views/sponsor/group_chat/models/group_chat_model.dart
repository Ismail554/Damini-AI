enum ChatAvatarType { ai, investor, sponsor }

class GroupChatMessage {
  final String id;
  final String senderName;
  final String? senderRole;
  final String avatarInitials;
  final ChatAvatarType avatarType;
  final bool isAi;
  final bool isMe;
  final String text;
  final String time;

  const GroupChatMessage({
    required this.id,
    required this.senderName,
    this.senderRole,
    required this.avatarInitials,
    required this.avatarType,
    required this.isAi,
    required this.isMe,
    required this.text,
    required this.time,
  });

  factory GroupChatMessage.fromJson(Map<String, dynamic> json) {
    return GroupChatMessage(
      id: json['id'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      senderRole: json['senderRole'] as String?,
      avatarInitials: json['avatarInitials'] as String? ?? '',
      avatarType: ChatAvatarType.values.firstWhere(
        (e) => e.name == (json['avatarType'] as String? ?? 'user'),
        orElse: () => ChatAvatarType.sponsor,
      ),
      isAi: json['isAi'] as bool? ?? false,
      isMe: json['isMe'] as bool? ?? false,
      text: json['text'] as String? ?? '',
      time: json['time'] as String? ?? '',
    );
  }
}

class AiSuggestion {
  final String id;
  final String title;
  final String icon;
  final bool isCompleted;

  const AiSuggestion({
    required this.id,
    required this.title,
    required this.icon,
    this.isCompleted = true,
  });
}
