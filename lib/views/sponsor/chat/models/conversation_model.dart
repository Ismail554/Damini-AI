class ConversationModel {
  final int id;
  final int? project;
  final bool isGroup;
  final String name;
  final String? lastMessage;
  final int unreadCount;
  final DateTime? updatedAt;

  const ConversationModel({
    required this.id,
    this.project,
    this.isGroup = false,
    required this.name,
    this.lastMessage,
    this.unreadCount = 0,
    this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '') ?? 0;
    final project = json['project'] is int
        ? json['project'] as int
        : int.tryParse(json['project']?.toString() ?? '');
    final isGroup = json['is_group'] == true;
    final name = json['name']?.toString() ?? 'Conversation';
    final lastMsg = json['last_message']?.toString();
    final unreadCount = json['unread_count'] is int
        ? json['unread_count'] as int
        : int.tryParse(json['unread_count']?.toString() ?? '') ?? 0;
    final updatedAtStr = json['updated_at']?.toString();
    final updatedAt =
        updatedAtStr != null ? DateTime.tryParse(updatedAtStr) : null;

    return ConversationModel(
      id: id,
      project: project,
      isGroup: isGroup,
      name: name,
      lastMessage: lastMsg,
      unreadCount: unreadCount,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'project': project,
        'is_group': isGroup,
        'name': name,
        'last_message': lastMessage,
        'unread_count': unreadCount,
        'updated_at': updatedAt?.toIso8601String(),
      };
}
