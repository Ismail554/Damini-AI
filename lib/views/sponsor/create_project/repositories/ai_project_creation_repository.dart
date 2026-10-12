import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_error_handler.dart';
import '../../../../core/services/api_service.dart';
import '../models/ai_project_creation_models.dart';

final aiProjectCreationRepositoryProvider =
    Provider<AiProjectCreationRepository>((ref) {
  return AiProjectCreationRepository(ref.watch(apiServiceProvider));
});

class AiProjectCreationRepository {
  final ApiService _apiService;

  AiProjectCreationRepository(this._apiService);

  /// POST /api/v1/ai/projects/conversations/
  /// Starts a new AI guided project creation conversation.
  Future<AiProjectConversationResult> startConversation({
    String? initialContext,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (initialContext != null && initialContext.trim().isNotEmpty) {
        payload['initial_context'] = initialContext.trim();
      }

      final response = await _apiService.post(
        ApiEndpoints.aiProjectConversations,
        data: payload,
        requireAuth: true,
      );

      final Map<String, dynamic> data = _normalizeResponseData(response.data);
      final conversationPayload = _extractPayload(data);

      final parsed = AiProjectConversationData.fromJson(conversationPayload);
      return AiProjectConversationResult.success(parsed);
    } catch (e) {
      return _handleError(e, "Failed to start AI conversation.");
    }
  }

  /// POST /api/v1/ai/projects/conversations/{conversation_id}/messages/
  /// Sends user answer/message and receives the next step prompt or blueprint.
  Future<AiProjectConversationResult> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.aiProjectMessages(conversationId),
        data: {'content': content.trim()},
        requireAuth: true,
      );

      final Map<String, dynamic> data = _normalizeResponseData(response.data);
      final conversationPayload = _extractPayload(data);

      final parsed = AiProjectConversationData.fromJson(
        conversationPayload,
        fallbackConversationId: conversationId,
      );
      return AiProjectConversationResult.success(parsed);
    } catch (e) {
      return _handleError(e, "Failed to send message to AI.");
    }
  }

  /// GET /api/v1/ai/projects/conversations/{conversation_id}/
  /// Retrieves conversation history and state.
  Future<AiProjectConversationResult> getConversation({
    required String conversationId,
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.aiProjectConversation(conversationId),
        requireAuth: true,
      );

      final Map<String, dynamic> data = _normalizeResponseData(response.data);
      final conversationPayload = _extractPayload(data);

      final parsed = AiProjectConversationData.fromJson(
        conversationPayload,
        fallbackConversationId: conversationId,
      );
      return AiProjectConversationResult.success(parsed);
    } catch (e) {
      return _handleError(e, "Failed to retrieve conversation history.");
    }
  }

  /// DELETE /api/v1/ai/projects/conversations/{conversation_id}/
  /// Resets or deletes the conversation session on the backend.
  Future<bool> resetConversation({
    required String conversationId,
  }) async {
    try {
      final response = await _apiService.delete(
        ApiEndpoints.aiProjectConversation(conversationId),
        requireAuth: true,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
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

  Map<String, dynamic> _extractPayload(Map<String, dynamic> data) {
    final Map<String, dynamic> payload = Map<String, dynamic>.from(data);
    if (data['data'] is Map<String, dynamic>) {
      payload.addAll(data['data'] as Map<String, dynamic>);
    } else if (data['data'] is Map) {
      payload.addAll(Map<String, dynamic>.from(data['data'] as Map));
    }
    return payload;
  }

  AiProjectConversationResult _handleError(dynamic e, String defaultMessage) {
    String msg = defaultMessage;
    int? code;
    int? retry;

    if (e is ApiException) {
      msg = e.message;
      code = e.statusCode;
      if (e.data is Map) {
        final map = e.data as Map;
        if (map['retry_after'] != null) {
          retry = int.tryParse(map['retry_after'].toString());
        }
        if (map['message'] != null &&
            map['message'].toString().toLowerCase() != 'validation failed.') {
          msg = map['message'].toString();
        }
      }
    } else if (e is AppException) {
      msg = e.message;
    } else {
      msg = e.toString();
    }

    return AiProjectConversationResult.failure(
      msg,
      statusCode: code,
      retryAfter: retry,
    );
  }
}
