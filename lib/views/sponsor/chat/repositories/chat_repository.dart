import 'package:flutter/material.dart';
import '../models/chat_item_model.dart';
import '../models/chat_message_model.dart';

class ChatRepository {
  List<ChatItemModel> fetchChats() {
    return [
      const ChatItemModel(
        id: 'ahmad_1',
        name: 'Ahmad Al-Rashid',
        initials: 'AA',
        lastMessage: "Great, let's schedule a call Thursday.",
        time: '2m',
        unreadCount: 2,
        isOnline: true,
        avatarColor: Color(0xFFC026D3),
      ),
      const ChatItemModel(
        id: 'dth_1',
        name: 'Downtown Tech Hub || Group Chat',
        initials: 'DTH',
        lastMessage: 'I reviewed the financial projections.',
        time: '1h',
        unreadCount: 0,
        isOnline: true,
        avatarColor: Color(0xFFE11D48),
        isGroupChat: true,
      ),
      const ChatItemModel(
        id: 'marcus_1',
        name: 'Marcus Webb',
        initials: 'MW',
        lastMessage: 'Can you share the updated cap table?',
        time: '3h',
        unreadCount: 1,
        isOnline: true,
        avatarColor: Color(0xFFDB2777),
      ),
      const ChatItemModel(
        id: 'priya_1',
        name: 'Priya Mehta',
        initials: 'PM',
        lastMessage: 'Looking forward to working together!',
        time: '1d',
        unreadCount: 0,
        isOnline: true,
        avatarColor: Color(0xFF7C3AED),
      ),
      const ChatItemModel(
        id: 'vp_1',
        name: 'Venture Partners LLC',
        initials: 'VP',
        lastMessage:
            "I'll review them with my team this afternoon. Can we schedule a call for tomorrow?",
        time: '10:20 AM',
        unreadCount: 0,
        isOnline: true,
        avatarColor: Color(0xFF2563EB),
      ),
    ];
  }

  List<ChatMessageModel> fetchMessagesForChat(String chatId) {
    if (chatId == 'vp_1') {
      return const [
        ChatMessageModel(
          id: 'msg_1',
          chatId: 'vp_1',
          text: 'Hi there! I reviewed your proposal for the Downtown Tech Hub.',
          timestamp: '10:00 AM',
          isMe: false,
        ),
        ChatMessageModel(
          id: 'msg_2',
          chatId: 'vp_1',
          text:
              "Thanks for getting back to me. We're very interested in leading the round.",
          timestamp: '10:05 AM',
          isMe: true,
        ),
        ChatMessageModel(
          id: 'msg_3',
          chatId: 'vp_1',
          text:
              "That's great to hear. I've approved your NDA request so you should have access to the full financials now.",
          timestamp: '10:15 AM',
          isMe: false,
        ),
        ChatMessageModel(
          id: 'msg_4',
          chatId: 'vp_1',
          text:
              "I'll review them with my team this afternoon. Can we schedule a call for tomorrow?",
          timestamp: '10:20 AM',
          isMe: true,
        ),
      ];
    }

    return [
      ChatMessageModel(
        id: 'msg_default_1',
        chatId: chatId,
        text: 'Hello! How can I assist you with this project today?',
        timestamp: '10:00 AM',
        isMe: false,
      ),
    ];
  }
}
