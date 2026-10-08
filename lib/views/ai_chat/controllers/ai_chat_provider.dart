import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_error_handler.dart';
import '../../auth/session/controllers/session_provider.dart';
import '../models/ai_chat_message_model.dart';
import '../repositories/ai_chat_repository.dart';

class AiChatState {
  final String? conversationId;
  final List<AiChatMessageModel> messages;
  final bool isTyping;
  final bool isLoadingInitial;
  final String? errorMessage;
  final List<String> quickPrompts;

  const AiChatState({
    this.conversationId,
    required this.messages,
    this.isTyping = false,
    this.isLoadingInitial = false,
    this.errorMessage,
    this.quickPrompts = const [
      "Analyze high-yield real estate projects",
      "How do I create a new funding request?",
      "Calculate estimated ROI for Tech Hub",
      "What are current market trends?",
    ],
  });

  AiChatState copyWith({
    String? conversationId,
    List<AiChatMessageModel>? messages,
    bool? isTyping,
    bool? isLoadingInitial,
    String? errorMessage,
    bool clearError = false,
    List<String>? quickPrompts,
  }) {
    return AiChatState(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      quickPrompts: quickPrompts ?? this.quickPrompts,
    );
  }
}

class AiChatNotifier extends Notifier<AiChatState> {
  AiChatRepository get _repository => ref.read(aiChatRepositoryProvider);

  @override
  AiChatState build() {
    // Initial default state before network resolves
    final defaultState = AiChatState(
      messages: [
        AiChatMessageModel(
          id: "msg_welcome",
          text:
              "Hello! I am your AI Investment Copilot. How can I help you optimize your portfolio or projects today?",
          isUser: false,
          timestamp: DateTime.now(),
          suggestions: const [
            "Explore Top Projects",
            "Draft New Proposal",
            "Market Analytics",
          ],
        ),
      ],
    );

    // Fetch initial state asynchronously on load
    Future.microtask(() => loadInitialState());

    return defaultState;
  }

  /// Loads initial state (conversation ID, backend welcome message & quick prompts).
  Future<void> loadInitialState() async {
    state = state.copyWith(isLoadingInitial: true, clearError: true);
    try {
      final initialData = await _repository.fetchInitialState();

      final welcome = initialData.welcomeMessage ??
          AiChatMessageModel(
            id: "msg_welcome",
            text:
                "Hello! I am your AI Investment Copilot. How can I help you optimize your portfolio or projects today?",
            isUser: false,
            timestamp: DateTime.now(),
            suggestions: const [
              "Explore Top Projects",
              "Draft New Proposal",
              "Market Analytics",
            ],
          );

      state = state.copyWith(
        conversationId: initialData.conversationId.isNotEmpty
            ? initialData.conversationId
            : state.conversationId,
        messages: [welcome],
        quickPrompts: initialData.quickPrompts.isNotEmpty
            ? initialData.quickPrompts
            : state.quickPrompts,
        isLoadingInitial: false,
        clearError: true,
      );
    } catch (e) {
      debugPrint("AiChatNotifier: loadInitialState error: $e");
      state = state.copyWith(isLoadingInitial: false);
    }
  }

  /// Sends a message to the AI Copilot.
  Future<void> sendMessage(
    String text, {
    Map<String, dynamic>? context,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isTyping) return;

    final userMsg = AiChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
      clearError: true,
    );

    final convId = state.conversationId ?? "default_conv";
    final activeRole = ref.read(sessionProvider).userRole ?? 'investor';
    final requestContext = context ?? {
      'current_screen': 'ai_chat',
      'role': activeRole,
    };

    try {
      final result = await _repository.sendMessage(
        conversationId: convId,
        content: trimmed,
        context: requestContext,
      );

      final List<AiChatMessageModel> updatedMessages = [...state.messages];

      if (result.aiReply != null) {
        updatedMessages.add(result.aiReply!);
      } else {
        // Fallback default reply if response lacked payload
        updatedMessages.add(
          AiChatMessageModel(
            id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
            text: "I have processed your query. Let me know if you need more details.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      }

      state = state.copyWith(
        messages: updatedMessages,
        quickPrompts: result.updatedQuickPrompts != null &&
                result.updatedQuickPrompts!.isNotEmpty
            ? result.updatedQuickPrompts!
            : state.quickPrompts,
        isTyping: false,
        clearError: true,
      );
    } catch (e) {
      debugPrint("AiChatNotifier: sendMessage error: $e");
      String errorText = "Failed to get AI response. Please try again.";
      if (e is ApiException) {
        errorText = e.message;
      } else if (e is AppException) {
        errorText = e.message;
      }

      state = state.copyWith(
        isTyping: false,
        errorMessage: errorText,
      );
    }
  }

  /// Clears the chat history on backend and resets session.
  Future<void> clearChat() async {
    final convId = state.conversationId;
    state = state.copyWith(isTyping: false, clearError: true);

    if (convId != null && convId.isNotEmpty) {
      try {
        final resetData = await _repository.clearChat(conversationId: convId);
        if (resetData != null) {
          final welcome = resetData.welcomeMessage ??
              AiChatMessageModel(
                id: "msg_welcome",
                text:
                    "Hello! I am your AI Investment Copilot. How can I help you optimize your portfolio or projects today?",
                isUser: false,
                timestamp: DateTime.now(),
                suggestions: const [
                  "Explore Top Projects",
                  "Draft New Proposal",
                  "Market Analytics",
                ],
              );

          state = state.copyWith(
            conversationId: resetData.conversationId.isNotEmpty
                ? resetData.conversationId
                : convId,
            messages: [welcome],
            quickPrompts: resetData.quickPrompts.isNotEmpty
                ? resetData.quickPrompts
                : state.quickPrompts,
            isTyping: false,
            clearError: true,
          );
          return;
        }
      } catch (e) {
        debugPrint("AiChatNotifier: clearChat error: $e");
      }
    }

    // Default fallback reset
    state = state.copyWith(
      messages: [
        AiChatMessageModel(
          id: "msg_welcome",
          text:
              "Hello! I am your AI Investment Copilot. How can I help you optimize your portfolio or projects today?",
          isUser: false,
          timestamp: DateTime.now(),
          suggestions: const [
            "Explore Top Projects",
            "Draft New Proposal",
            "Market Analytics",
          ],
        ),
      ],
      isTyping: false,
      clearError: true,
    );
  }
}

final aiChatProvider =
    NotifierProvider.autoDispose<AiChatNotifier, AiChatState>(
  AiChatNotifier.new,
);
