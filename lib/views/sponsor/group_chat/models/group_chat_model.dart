import '../../chat/models/chat_message_model.dart';

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
  final ChatMessageType type;
  final String? mediaUrl;
  final String? voiceDuration;

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
    this.type = ChatMessageType.text,
    this.mediaUrl,
    this.voiceDuration,
  });

  factory GroupChatMessage.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final senderIdStr =
        json['sender_id']?.toString() ?? json['senderId']?.toString();
    final isMeFlag = json['is_me'] == true ||
        json['isMe'] == true ||
        (currentUserId != null &&
            senderIdStr != null &&
            currentUserId == senderIdStr);

    final rawType = (json['message_type'] ?? json['type'] ?? 'text')
        .toString()
        .toLowerCase();
    ChatMessageType msgType = ChatMessageType.text;
    if (rawType == 'image') msgType = ChatMessageType.image;
    if (rawType == 'voice') msgType = ChatMessageType.voice;

    final rawAvatar = (json['avatar_type'] ?? json['avatarType'] ?? 'sponsor')
        .toString()
        .toLowerCase();
    ChatAvatarType avatarType = ChatAvatarType.sponsor;
    if (rawAvatar == 'ai') avatarType = ChatAvatarType.ai;
    if (rawAvatar == 'investor') avatarType = ChatAvatarType.investor;

    String timeStr = json['time']?.toString() ?? '';
    if (timeStr.isEmpty && json['created_at'] != null) {
      final dt = DateTime.tryParse(json['created_at'].toString())?.toLocal();
      if (dt != null) {
        timeStr =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }

    final sName = json['sender_name']?.toString() ??
        json['senderName']?.toString() ??
        'User';

    String initials = json['avatar_initials']?.toString() ??
        json['avatarInitials']?.toString() ??
        '';
    if (initials.isEmpty && sName.isNotEmpty) {
      final parts = sName.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = sName.substring(0, sName.length >= 2 ? 2 : 1).toUpperCase();
      }
    }

    return GroupChatMessage(
      id: json['id']?.toString() ?? '',
      senderName: sName,
      senderRole:
          json['sender_role']?.toString() ?? json['senderRole']?.toString(),
      avatarInitials: initials,
      avatarType: avatarType,
      isAi: json['is_ai'] == true || json['isAi'] == true,
      isMe: isMeFlag,
      text: json['text']?.toString() ?? '',
      time: timeStr.isNotEmpty ? timeStr : 'Just now',
      type: msgType,
      mediaUrl: json['media_url']?.toString() ?? json['mediaUrl']?.toString(),
      voiceDuration: json['voice_duration']?.toString() ??
          json['voiceDuration']?.toString(),
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

  factory AiSuggestion.fromJson(Map<String, dynamic> json) {
    return AiSuggestion(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '💡',
      isCompleted:
          json['is_completed'] == true || json['isCompleted'] == true,
    );
  }
}
