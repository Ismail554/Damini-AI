import 'dart:convert';
import '../../../ai_chat/models/ai_chat_message_model.dart';
import 'project_draft_model.dart';

/// Represents parsed data from `/api/v1/ai/projects/conversations/...` responses.
class AiProjectConversationData {
  final String conversationId;
  final String step;
  final int stepIndex;
  final int totalSteps;
  final String stepTitle;
  final AiChatMessageModel? message;
  final List<AiChatMessageModel> messages;
  final List<String>? suggestions;
  final Map<String, dynamic>? extractedData;
  final ProjectDraftModel? draft;

  const AiProjectConversationData({
    required this.conversationId,
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.stepTitle,
    this.message,
    this.messages = const [],
    this.suggestions,
    this.extractedData,
    this.draft,
  });

  factory AiProjectConversationData.fromJson(
    Map<String, dynamic> json, {
    String fallbackConversationId = '',
  }) {
    final convId = json['conversation_id']?.toString() ?? fallbackConversationId;
    final stepStr = json['step']?.toString() ?? 'intro';
    final stepIdx = json['step_index'] is int
        ? json['step_index'] as int
        : (int.tryParse(json['step_index']?.toString() ?? '') ?? 1);
    final total = json['total_steps'] is int
        ? json['total_steps'] as int
        : (int.tryParse(json['total_steps']?.toString() ?? '') ?? 4);
    final title = json['step_title']?.toString() ?? 'Select Industry';

    // Parse single message (POST endpoints)
    AiChatMessageModel? singleMsg;
    if (json['message'] is Map<String, dynamic>) {
      singleMsg = parseBackendMessage(json['message'] as Map<String, dynamic>);
    }

    // Parse suggestions (at envelope level or message level)
    List<String>? parsedSuggestions;
    if (json['suggestions'] is List) {
      parsedSuggestions = (json['suggestions'] as List)
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    } else if (singleMsg?.suggestions != null) {
      parsedSuggestions = singleMsg?.suggestions;
    }

    // Attach envelope suggestions to singleMsg if missing
    if (singleMsg != null &&
        (singleMsg.suggestions == null || singleMsg.suggestions!.isEmpty) &&
        parsedSuggestions != null) {
      singleMsg = singleMsg.copyWith(suggestions: parsedSuggestions);
    }

    // Parse message list (GET history endpoint)
    final msgList = <AiChatMessageModel>[];
    if (json['messages'] is List) {
      for (final item in (json['messages'] as List)) {
        if (item is Map<String, dynamic>) {
          final m = parseBackendMessage(item);
          if (m != null) msgList.add(m);
        }
      }
    } else if (singleMsg != null) {
      msgList.add(singleMsg);
    }

    // Parse draft if present
    ProjectDraftModel? parsedDraft;
    if (json['draft'] is Map<String, dynamic>) {
      parsedDraft = ProjectDraftModel.fromMap(
        json['draft'] as Map<String, dynamic>,
      );
    } else if (json['draft'] is Map) {
      parsedDraft = ProjectDraftModel.fromMap(
        Map<String, dynamic>.from(json['draft'] as Map),
      );
    } else if (json['draft'] is String &&
        (json['draft'] as String).trim().startsWith('{')) {
      try {
        final decoded = jsonDecode(json['draft'] as String);
        if (decoded is Map<String, dynamic>) {
          parsedDraft = ProjectDraftModel.fromMap(decoded);
        } else if (decoded is Map) {
          parsedDraft = ProjectDraftModel.fromMap(
            Map<String, dynamic>.from(decoded),
          );
        }
      } catch (_) {}
    }

    Map<String, dynamic>? extracted;
    if (json['extracted_data'] is Map<String, dynamic>) {
      extracted = json['extracted_data'] as Map<String, dynamic>;
    }

    return AiProjectConversationData(
      conversationId: convId,
      step: stepStr,
      stepIndex: stepIdx,
      totalSteps: total,
      stepTitle: title,
      message: singleMsg,
      messages: msgList,
      suggestions: parsedSuggestions,
      extractedData: extracted,
      draft: parsedDraft,
    );
  }

  static AiChatMessageModel? parseBackendMessage(Map<String, dynamic> map) {
    final id = map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    final content = (map['content'] ?? map['text'])?.toString() ?? '';
    final role = map['role']?.toString().toLowerCase();
    final isUser = role == 'user';

    DateTime timestamp;
    if (map['timestamp'] != null) {
      timestamp = DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now();
    } else {
      timestamp = DateTime.now();
    }

    List<String>? suggestions;
    if (map['suggestions'] is List) {
      suggestions = (map['suggestions'] as List)
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    return AiChatMessageModel(
      id: id,
      text: content,
      isUser: isUser,
      timestamp: timestamp,
      suggestions: suggestions,
    );
  }
}

/// Standardized result wrapper for repository calls
class AiProjectConversationResult {
  final bool success;
  final String? message;
  final int? statusCode;
  final int? retryAfter;
  final AiProjectConversationData? data;

  const AiProjectConversationResult({
    required this.success,
    this.message,
    this.statusCode,
    this.retryAfter,
    this.data,
  });

  factory AiProjectConversationResult.success(AiProjectConversationData data) {
    return AiProjectConversationResult(
      success: true,
      data: data,
    );
  }

  factory AiProjectConversationResult.failure(
    String message, {
    int? statusCode,
    int? retryAfter,
    AiProjectConversationData? data,
  }) {
    return AiProjectConversationResult(
      success: false,
      message: message,
      statusCode: statusCode,
      retryAfter: retryAfter,
      data: data,
    );
  }
}
