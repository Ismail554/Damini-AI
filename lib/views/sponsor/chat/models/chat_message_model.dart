enum ChatMessageType { text, image, voice, system }

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

    String timeStr = json['time']?.toString() ?? '';
    if (timeStr.isEmpty &&
        (json['created_at'] != null || json['timestamp'] != null)) {
      final rawDt = (json['created_at'] ?? json['timestamp']).toString();
      final dt = DateTime.tryParse(rawDt)?.toLocal();
      if (dt != null) {
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final minute = dt.minute.toString().padLeft(2, '0');
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        timeStr = '$hour:$minute $ampm';
      }
    }

    String finalText = rawText;
    if (msgType == ChatMessageType.voice && finalText.trim().isEmpty) {
      finalText = 'Voice message';
    }

    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      chatId: chatId ?? json['conversation_id']?.toString() ?? '',
      text: finalText,
      timestamp: timeStr.isNotEmpty ? timeStr : 'Just now',
      isMe: isMeFlag,
      type: msgType,
      mediaUrl: mediaUrlStr.isNotEmpty ? mediaUrlStr : null,
      voiceDuration: voiceDurStr,
    );
  }

  ChatMessageModel copyWith({
    String? id,
    String? chatId,
    String? text,
    String? timestamp,
    bool? isMe,
    ChatMessageType? type,
    String? mediaUrl,
    String? voiceDuration,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      voiceDuration: voiceDuration ?? this.voiceDuration,
    );
  }
}

