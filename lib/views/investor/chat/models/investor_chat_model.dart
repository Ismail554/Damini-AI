class InvestorChatItemModel {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String avatarUrl;
  final bool isGroupChat;

  const InvestorChatItemModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    required this.avatarUrl,
    this.isGroupChat = false,
  });
}
