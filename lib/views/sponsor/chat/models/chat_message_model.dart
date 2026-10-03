enum ChatMessageType { text, image, voice }

class ChatMessageModel {
  final String id;
  final String chatId;
  final String text;
  final String timestamp;
  final bool isMe;
  final ChatMessageType type;
  final String? mediaUrl;
  final String? voiceDuration;

  const ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.text,
    required this.timestamp,
    required this.isMe,
    this.type = ChatMessageType.text,
    this.mediaUrl,
    this.voiceDuration,
  });

  factory ChatMessageModel.fromJson(
    Map<String, dynamic> json, {
    String? chatId,
    String? currentUserId,
  }) {
    final rawType = (json['message_type'] ?? json['type'] ?? 'text')
        .toString()
        .toLowerCase();
    ChatMessageType msgType = ChatMessageType.text;
    if (rawType == 'image') msgType = ChatMessageType.image;
    if (rawType == 'voice') msgType = ChatMessageType.voice;

    final senderIdStr =
        json['sender_id']?.toString() ?? json['senderId']?.toString();
    final isMeFlag = json['is_me'] == true ||
        json['isMe'] == true ||
        (currentUserId != null &&
            senderIdStr != null &&
            currentUserId == senderIdStr);

    String timeStr = json['time']?.toString() ?? '';
    if (timeStr.isEmpty && json['created_at'] != null) {
      final dt = DateTime.tryParse(json['created_at'].toString())?.toLocal();
      if (dt != null) {
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final minute = dt.minute.toString().padLeft(2, '0');
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        timeStr = '$hour:$minute $ampm';
      }
    }

    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      chatId: chatId ?? json['conversation_id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      timestamp: timeStr.isNotEmpty ? timeStr : 'Just now',
      isMe: isMeFlag,
      type: msgType,
      mediaUrl: json['media_url']?.toString() ?? json['mediaUrl']?.toString(),
      voiceDuration: json['voice_duration']?.toString() ??
          json['voiceDuration']?.toString(),
    );
  }
}

