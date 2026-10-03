import 'package:flutter/material.dart';
import 'conversation_model.dart';

class ChatItemModel {
  final String id;
  final String name;
  final String initials;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final Color avatarColor;
  final String? avatarUrl;
  final bool isGroupChat;
  final int? projectId;

  const ChatItemModel({
    required this.id,
    required this.name,
    required this.initials,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.avatarColor = const Color(0xFF006EDB),
    this.avatarUrl,
    this.isGroupChat = false,
    this.projectId,
  });

  factory ChatItemModel.fromConversation(ConversationModel conv) {
    String initials = '';
    final parts = conv.name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials = parts[0]
          .substring(0, parts[0].length >= 2 ? 2 : 1)
          .toUpperCase();
    } else {
      initials = 'CH';
    }

    String formattedTime = '';
    if (conv.updatedAt != null) {
      final now = DateTime.now();
      final diff = now.difference(conv.updatedAt!);
      if (diff.inMinutes < 60) {
        formattedTime = '${diff.inMinutes}m';
      } else if (diff.inHours < 24) {
        formattedTime = '${diff.inHours}h';
      } else if (diff.inDays < 7) {
        formattedTime = '${diff.inDays}d';
      } else {
        formattedTime = '${conv.updatedAt!.month}/${conv.updatedAt!.day}';
      }
    }

    final colors = [
      const Color(0xFF006EDB),
      const Color(0xFFC026D3),
      const Color(0xFFE11D48),
      const Color(0xFFDB2777),
      const Color(0xFF7C3AED),
      const Color(0xFF2563EB),
      const Color(0xFF10B981),
    ];
    final color = colors[conv.id.abs() % colors.length];

    return ChatItemModel(
      id: conv.id.toString(),
      name: conv.name,
      initials: initials,
      lastMessage: conv.lastMessage ??
          (conv.isGroup
              ? "Group conversation started"
              : "Conversation started"),
      time: formattedTime.isNotEmpty ? formattedTime : "Just now",
      unreadCount: conv.unreadCount,
      isOnline: false,
      avatarColor: color,
      isGroupChat: conv.isGroup,
      projectId: conv.project,
    );
  }

  ChatItemModel copyWith({
    String? id,
    String? name,
    String? initials,
    String? lastMessage,
    String? time,
    int? unreadCount,
    bool? isOnline,
    Color? avatarColor,
    String? avatarUrl,
    bool? isGroupChat,
    int? projectId,
  }) {
    return ChatItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      lastMessage: lastMessage ?? this.lastMessage,
      time: time ?? this.time,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      avatarColor: avatarColor ?? this.avatarColor,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGroupChat: isGroupChat ?? this.isGroupChat,
      projectId: projectId ?? this.projectId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatItemModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
