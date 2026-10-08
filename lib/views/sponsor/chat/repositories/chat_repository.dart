import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../../group_chat/models/group_chat_header_model.dart';
import '../../group_chat/models/group_chat_model.dart';
import '../models/chat_item_model.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(apiServiceProvider));
});

class ChatRepository {
  final ApiService? _apiService;

  ChatRepository([this._apiService]);

  ApiService get _api => _apiService ?? ApiService();

  /// POST /api/v1/notifications/chat/conversations/start/
  Future<ConversationModel> startConversation({
    int? targetUserId,
    int? projectId,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.startConversation,
        data: {
          'target_user_id': targetUserId ?? 0,
          'project_id': projectId ?? 0,
        },
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      Map<String, dynamic> payload = {};
      if (data is Map && data['data'] is Map) {
        payload = Map<String, dynamic>.from(data['data'] as Map);
      } else if (data is Map) {
        payload = Map<String, dynamic>.from(data);
      }

      return ConversationModel.fromJson(payload);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch all active conversations: GET /api/v1/notifications/chat/conversations/
  Future<List<ConversationModel>> fetchConversations() async {
    try {
      final response = await _api.get(
        ApiEndpoints.conversations,
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      List rawList = [];
      if (data is Map && data['data'] is List) {
        rawList = data['data'] as List;
      } else if (data is List) {
        rawList = data;
      } else if (data is Map && data['results'] is List) {
        rawList = data['results'] as List;
      }

      final conversations = <ConversationModel>[];
      for (final item in rawList.whereType<Map>()) {
        try {
          conversations.add(
            ConversationModel.fromJson(Map<String, dynamic>.from(item)),
          );
        } catch (_) {
          continue;
        }
      }

      conversations.sort((a, b) {
        final aDate = a.updatedAt ?? DateTime(0);
        final bDate = b.updatedAt ?? DateTime(0);
        return bDate.compareTo(aDate);
      });

      return conversations;
    } catch (e) {
      rethrow;
    }
  }

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

  /// GET /api/v1/notifications/chat/conversations/{conversation_id}/messages/
  Future<List<GroupChatMessage>> fetchMessages(
    String conversationId, {
    int? beforeId,
    int limit = 30,
    String? currentUserId,
    String? currentUserName,
  }) async {
    try {
      final query = <String, dynamic>{
        'limit': limit,
        'before_id': ?beforeId,
      };

      final response = await _api.get(
        ApiEndpoints.conversationMessages(conversationId),
        queryParameters: query,
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      List rawList = [];
      if (data is Map) {
        if (data['data'] is List) {
          rawList = data['data'] as List;
        } else if (data['data'] is Map && data['data']['messages'] is List) {
          rawList = data['data']['messages'] as List;
        } else if (data['data'] is Map && data['data']['results'] is List) {
          rawList = data['data']['results'] as List;
        } else if (data['results'] is List) {
          rawList = data['results'] as List;
        } else if (data['messages'] is List) {
          rawList = data['messages'] as List;
        }
      } else if (data is List) {
        rawList = data;
      }

      final messages = <GroupChatMessage>[];
      for (final item in rawList.whereType<Map>()) {
        try {
          messages.add(
            GroupChatMessage.fromJson(
              Map<String, dynamic>.from(item),
              currentUserId: currentUserId,
              currentUserName: currentUserName,
            ),
          );
        } catch (_) {}
      }

      return messages;
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/v1/notifications/chat/upload/
  Future<Map<String, dynamic>> uploadMedia({
    required String filePath,
    required String type,
    String? voiceDuration,
  }) async {
    try {
      final file = File(filePath);
      final fileName = filePath.split(Platform.pathSeparator).last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'type': type,
        'voice_duration': ?voiceDuration,
      });

      final response = await _api.post(
        ApiEndpoints.chatUpload,
        data: formData,
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      } else if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/v1/notifications/chat/conversations/{conversation_id}/read/
  Future<bool> markConversationAsRead(String conversationId) async {
    try {
      await _api.post(
        ApiEndpoints.markConversationRead(conversationId),
        data: {},
        requireAuth: true,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// DELETE /api/v1/notifications/chat/conversations/{conversation_id}/participants/{user_id}/
  Future<bool> removeParticipant({
    required String conversationId,
    required String userId,
  }) async {
    try {
      await _api.delete(
        ApiEndpoints.removeParticipant(conversationId, userId),
        requireAuth: true,
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/v1/notifications/chat/conversations/{id}/header/
  Future<GroupChatHeaderModel> fetchConversationHeader(
      String conversationId) async {
    try {
      final response = await _api.get(
        ApiEndpoints.conversationHeader(conversationId),
        requireAuth: true,
      );
      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      return GroupChatHeaderModel.fromJson(
          data is Map ? Map<String, dynamic>.from(data) : {});
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/v1/notifications/chat/conversations/{id}/confirm-investors/
  /// (with fallback to /api/v1/projects/{project_id}/confirm-investors/)
  Future<Map<String, dynamic>> confirmInvestors({
    required int projectId,
    required int conversationId,
    required List<Map<String, dynamic>> investors,
  }) async {
    final payload = {
      if (conversationId > 0) 'conversation_id': conversationId,
      if (projectId > 0) 'project_id': projectId,
      'investors': investors,
    };

    final primaryEndpoint = conversationId > 0
        ? ApiEndpoints.conversationConfirmInvestors(conversationId.toString())
        : ApiEndpoints.confirmInvestors(projectId.toString());

    try {
      final response = await _api.post(
        primaryEndpoint,
        data: payload,
        requireAuth: true,
      );
      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      return data is Map ? Map<String, dynamic>.from(data) : {};
    } on DioException catch (dioErr) {
      if (dioErr.response?.statusCode == 404 && projectId > 0 && conversationId > 0) {
        final fallbackEndpoint = ApiEndpoints.confirmInvestors(projectId.toString());
        final fallbackRes = await _api.post(
          fallbackEndpoint,
          data: payload,
          requireAuth: true,
        );
        dynamic data = fallbackRes.data;
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (_) {}
        }
        return data is Map ? Map<String, dynamic>.from(data) : {};
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/v1/notifications/chat/conversations/{id}/leave/
  Future<Map<String, dynamic>> leaveConversation(String conversationId) async {
    try {
      final response = await _api.post(
        ApiEndpoints.leaveConversation(conversationId),
        data: {},
        requireAuth: true,
      );
      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      return data is Map ? Map<String, dynamic>.from(data) : {};
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/v1/notifications/chat/conversations/{id}/report/
  Future<Map<String, dynamic>> reportConversation({
    required String conversationId,
    required String reason,
    String? description,
    List<int>? flaggedMessageIds,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.reportConversation(conversationId),
        data: {
          'reason': reason,
          if (description != null && description.isNotEmpty)
            'description': description,
          if (flaggedMessageIds != null && flaggedMessageIds.isNotEmpty)
            'flagged_message_ids': flaggedMessageIds,
        },
        requireAuth: true,
      );
      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      return data is Map ? Map<String, dynamic>.from(data) : {};
    } catch (e) {
      rethrow;
    }
  }
}
