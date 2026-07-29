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
}

