import 'package:flutter/material.dart';

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
  });

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
    );
  }
}
