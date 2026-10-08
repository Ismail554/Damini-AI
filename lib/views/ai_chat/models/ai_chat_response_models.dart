import 'ai_chat_message_model.dart';

class AiChatInitialData {
  final String conversationId;
  final AiChatMessageModel? welcomeMessage;
  final List<String> quickPrompts;

  const AiChatInitialData({
    required this.conversationId,
    this.welcomeMessage,
    this.quickPrompts = const [
      "Analyze high-yield real estate projects",
      "How do I create a new funding request?",
      "Calculate estimated ROI for Tech Hub",
      "What are current market trends?",
    ],
  });

  factory AiChatInitialData.fromJson(Map<String, dynamic> json) {
    // Check nested 'data' if present
    final map = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final convId = map['conversation_id']?.toString() ??
        map['conversationId']?.toString() ??
        map['id']?.toString() ??
        '';

    AiChatMessageModel? welcome;
    if (map['welcome_message'] is Map) {
      welcome = AiChatMessageModel.fromJson(
        Map<String, dynamic>.from(map['welcome_message'] as Map),
      );
    } else if (map['welcomeMessage'] is Map) {
      welcome = AiChatMessageModel.fromJson(
        Map<String, dynamic>.from(map['welcomeMessage'] as Map),
      );
    }

    List<String> prompts = [];
    final rawPrompts = map['quick_prompts'] ?? map['quickPrompts'];
    if (rawPrompts is List) {
      prompts = rawPrompts
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return AiChatInitialData(
      conversationId: convId,
      welcomeMessage: welcome,
      quickPrompts: prompts.isNotEmpty
          ? prompts
          : const [
              "Analyze high-yield real estate projects",
              "How do I create a new funding request?",
              "Calculate estimated ROI for Tech Hub",
              "What are current market trends?",
            ],
    );
  }
}

class AiSendMessageResult {
  final AiChatMessageModel? userMessage;
  final AiChatMessageModel? aiReply;
  final List<String>? updatedQuickPrompts;

  const AiSendMessageResult({
    this.userMessage,
    this.aiReply,
    this.updatedQuickPrompts,
  });

  factory AiSendMessageResult.fromJson(Map<String, dynamic> json) {
    final map = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    AiChatMessageModel? userMsg;
    if (map['user_message'] is Map) {
      userMsg = AiChatMessageModel.fromJson(
        Map<String, dynamic>.from(map['user_message'] as Map),
      );
    } else if (map['userMessage'] is Map) {
      userMsg = AiChatMessageModel.fromJson(
        Map<String, dynamic>.from(map['userMessage'] as Map),
      );
    }

    AiChatMessageModel? reply;
    if (map['ai_reply'] is Map) {
      reply = AiChatMessageModel.fromJson(
        Map<String, dynamic>.from(map['ai_reply'] as Map),
      );
    } else if (map['aiReply'] is Map) {
      reply = AiChatMessageModel.fromJson(
        Map<String, dynamic>.from(map['aiReply'] as Map),
      );
    } else if (map['message'] is Map) {
      reply = AiChatMessageModel.fromJson(
        Map<String, dynamic>.from(map['message'] as Map),
      );
    } else if (map['reply'] is String) {
      reply = AiChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: map['reply'].toString(),
        isUser: false,
        timestamp: DateTime.now(),
      );
    }

    List<String>? updatedPrompts;
    final rawPrompts = map['updated_quick_prompts'] ?? map['quick_prompts'];
    if (rawPrompts is List) {
      updatedPrompts = rawPrompts
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return AiSendMessageResult(
      userMessage: userMsg,
      aiReply: reply,
      updatedQuickPrompts: updatedPrompts,
    );
  }
}
