import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/ai_chat_message_model.dart';
import '../models/ai_chat_response_models.dart';

final aiChatRepositoryProvider = Provider<AiChatRepository>((ref) {
  return AiChatRepository(ref.watch(apiServiceProvider));
});

class AiChatRepository {
  final ApiService _apiService;

  AiChatRepository(this._apiService);

  /// GET /api/v1/ai/chat/initial/
  /// Fetches initial welcome message, conversation ID, and quick prompt chips.
  Future<AiChatInitialData> fetchInitialState() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.aiChatInitial,
        requireAuth: true,
      );

      final Map<String, dynamic> data = _normalizeResponseData(response.data);
      return AiChatInitialData.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/v1/ai/chat/conversations/{conversation_id}/messages/
  /// Sends user message to AI Copilot and receives AI reply with suggestions.
  Future<AiSendMessageResult> sendMessage({
    required String conversationId,
    required String content,
    Map<String, dynamic>? context,
  }) async {
    try {
      final payload = <String, dynamic>{
        'content': content.trim(),
        'context': ?context,
      };

      final response = await _apiService.post(
        ApiEndpoints.aiChatMessages(conversationId),
        data: payload,
        requireAuth: true,
      );

      final Map<String, dynamic> data = _normalizeResponseData(response.data);
      return AiSendMessageResult.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/v1/ai/chat/conversations/{conversation_id}/messages/
  /// Fetches paginated history for an existing conversation session.
  Future<List<AiChatMessageModel>> fetchHistory({
    required String conversationId,
    int page = 1,
    int pageSize = 30,
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.aiChatMessages(conversationId),
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
        requireAuth: true,
      );

      final Map<String, dynamic> data = _normalizeResponseData(response.data);
      final list = data['data'] is Map && (data['data']['messages'] is List)
          ? data['data']['messages'] as List
          : (data['messages'] is List
              ? data['messages'] as List
              : (data['data'] is List
                  ? data['data'] as List
                  : (data['results'] is List ? data['results'] as List : [])));

      return list
          .whereType<Map>()
          .map((m) => AiChatMessageModel.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Clear Copilot Memory: POST (or DELETE) /api/v1/ai/chat/conversations/{conversation_id}/clear/
  Future<AiChatInitialData?> clearChat({
    required String conversationId,
  }) async {
    try {
      dynamic response;
      try {
        response = await _apiService.post(
          ApiEndpoints.aiChatClear(conversationId),
          data: {},
          requireAuth: true,
        );
      } catch (_) {
        response = await _apiService.delete(
          ApiEndpoints.aiChatClear(conversationId),
          requireAuth: true,
        );
      }

      final Map<String, dynamic> data = _normalizeResponseData(response.data);
      if (data.isNotEmpty) {
        return AiChatInitialData.fromJson(data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> _normalizeResponseData(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return <String, dynamic>{};
  }
}
