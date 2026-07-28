class ChatMessageModel {
  final String id;
  final String chatId;
  final String text;
  final String timestamp;
  final bool isMe;

  const ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });
}
