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
    String? currentUserName,
  }) {
    final senderIdStr = json['sender_id']?.toString() ??
        json['senderId']?.toString() ??
        (json['sender'] is Map
            ? json['sender']['id']?.toString()
            : json['sender']?.toString());

    final rawSenderName = json['sender_name']?.toString() ??
        json['senderName']?.toString() ??
        (json['sender'] is Map
            ? (json['sender']['name'] ??
                    json['sender']['full_name'] ??
                    '${json['sender']['first_name'] ?? ''} ${json['sender']['last_name'] ?? ''}')
                ?.toString()
                .trim()
            : null);

    final isMeFlag = json['is_me'] == true ||
        json['isMe'] == true ||
        (currentUserId != null &&
            senderIdStr != null &&
            currentUserId.trim().isNotEmpty &&
            currentUserId.trim() == senderIdStr.trim()) ||
        (currentUserName != null &&
            rawSenderName != null &&
            currentUserName.trim().isNotEmpty &&
            rawSenderName.trim().isNotEmpty &&
            currentUserName.trim().toLowerCase() ==
                rawSenderName.trim().toLowerCase());

    final rawType = (json['message_type'] ??
            json['messageType'] ??
            json['msg_type'] ??
            json['type'] ??
            'text')
        .toString()
        .toLowerCase();

    final rawSenderRole = json['sender_role']?.toString() ??
        json['senderRole']?.toString() ??
        (json['sender'] is Map ? json['sender']['role']?.toString() : null);

    final mediaUrlStr = (json['media_url'] ??
            json['mediaUrl'] ??
            json['file'] ??
            json['attachment'] ??
            json['media'] ??
            json['audio'] ??
            json['image'] ??
            json['url'])
        ?.toString() ??
        '';

    final voiceDurStr = (json['voice_duration'] ??
            json['voiceDuration'] ??
            json['duration'] ??
            json['audio_duration'] ??
            json['length'])
        ?.toString();

    final rawText = (json['text'] ??
            json['content'] ??
            json['message'] ??
            json['body'] ??
            json['msg'] ??
            '')
        .toString();

    final mediaLower = mediaUrlStr.toLowerCase();

    ChatMessageType msgType = ChatMessageType.text;
    if (rawType.contains('image') ||
        rawType.contains('photo') ||
        mediaLower.contains('.jpg') ||
        mediaLower.contains('.png') ||
        mediaLower.contains('.jpeg') ||
        mediaLower.contains('.webp')) {
      msgType = ChatMessageType.image;
    } else if (rawType.contains('voice') ||
        rawType.contains('audio') ||
        (voiceDurStr != null && voiceDurStr.trim().isNotEmpty) ||
        mediaLower.contains('.m4a') ||
        mediaLower.contains('.mp3') ||
        mediaLower.contains('.wav') ||
        mediaLower.contains('.aac') ||
        mediaLower.contains('.ogg') ||
        rawText.trim().toLowerCase() == 'voice message' ||
        rawText.trim().toLowerCase().contains('voice note')) {
      msgType = ChatMessageType.voice;
    } else if (rawType == 'system' ||
        rawSenderRole?.toLowerCase() == 'system') {
      msgType = ChatMessageType.system;
    }

    final rawAvatar = (json['avatar_type'] ?? json['avatarType'] ?? 'sponsor')
        .toString()
        .toLowerCase();
    ChatAvatarType avatarType = ChatAvatarType.sponsor;
    if (rawAvatar == 'ai') avatarType = ChatAvatarType.ai;
    if (rawAvatar == 'investor') avatarType = ChatAvatarType.investor;

    String timeStr = json['time']?.toString() ?? '';
    if (timeStr.isEmpty &&
        (json['created_at'] != null || json['timestamp'] != null)) {
      final rawDt = (json['created_at'] ?? json['timestamp']).toString();
      final dt = DateTime.tryParse(rawDt)?.toLocal();
      if (dt != null) {
        timeStr =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }

    final sName = isMeFlag
        ? 'You'
        : (rawSenderName ??
            (msgType == ChatMessageType.system ? 'System' : 'User'));

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

    String finalText = rawText;
    if (msgType == ChatMessageType.voice && finalText.trim().isEmpty) {
      finalText = 'Voice message';
    }

    return GroupChatMessage(
      id: json['id']?.toString() ?? '',
      senderName: sName,
      senderRole: rawSenderRole,
      avatarInitials: initials,
      avatarType: avatarType,
      isAi: json['is_ai'] == true || json['isAi'] == true,
      isMe: isMeFlag,
      text: finalText,
      time: timeStr.isNotEmpty ? timeStr : 'Just now',
      type: msgType,
      mediaUrl: mediaUrlStr.isNotEmpty ? mediaUrlStr : null,
      voiceDuration: voiceDurStr,
    );
  }

  GroupChatMessage copyWith({
    String? id,
    String? senderName,
    String? senderRole,
    String? avatarInitials,
    ChatAvatarType? avatarType,
    bool? isAi,
    bool? isMe,
    String? text,
    String? time,
    ChatMessageType? type,
    String? mediaUrl,
    String? voiceDuration,
  }) {
    return GroupChatMessage(
      id: id ?? this.id,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      avatarType: avatarType ?? this.avatarType,
      isAi: isAi ?? this.isAi,
      isMe: isMe ?? this.isMe,
      text: text ?? this.text,
      time: time ?? this.time,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      voiceDuration: voiceDuration ?? this.voiceDuration,
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
