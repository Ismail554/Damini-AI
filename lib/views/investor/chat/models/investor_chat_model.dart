import '../../../../core/constants/api_endpoints.dart';

class InvestorChatItemModel {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String avatarUrl;
  final bool isGroupChat;
  final String? projectId;

  const InvestorChatItemModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    required this.avatarUrl,
    this.isGroupChat = false,
    this.projectId,
  });

  factory InvestorChatItemModel.fromJson(Map<String, dynamic> json) {
    final rawAvatar = json['avatar_url']?.toString() ??
        json['avatar']?.toString() ??
        json['image_url']?.toString() ??
        json['image']?.toString();

    String avatarUrl =
        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop";
    if (rawAvatar != null && rawAvatar != 'null' && rawAvatar.isNotEmpty) {
      if (rawAvatar.startsWith('http://') || rawAvatar.startsWith('https://')) {
        avatarUrl = rawAvatar;
      } else {
        final base = ApiEndpoints.baseUrl.endsWith('/')
            ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
            : ApiEndpoints.baseUrl;
        final path = rawAvatar.startsWith('/') ? rawAvatar : '/$rawAvatar';
        avatarUrl = '$base$path';
      }
    }

    final timeStr = json['time']?.toString() ??
        json['last_message_time']?.toString() ??
        'Just now';

    final unread = json['unread_count'] is int
        ? json['unread_count'] as int
        : (int.tryParse(json['unread_count']?.toString() ?? '') ?? 0);

    return InvestorChatItemModel(
      id: json['id']?.toString() ??
          json['conversation_id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name']?.toString() ??
          json['title']?.toString() ??
          json['project_title']?.toString() ??
          'Chat',
      lastMessage: json['last_message']?.toString() ??
          json['message']?.toString() ??
          'No messages yet',
      time: timeStr,
      unreadCount: unread,
      avatarUrl: avatarUrl,
      isGroupChat: json['is_group_chat'] == true || json['is_group'] == true,
      projectId: json['project_id']?.toString() ?? json['project']?.toString(),
    );
  }
}
