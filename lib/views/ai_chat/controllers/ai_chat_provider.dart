import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_chat_message_model.dart';

class AiChatState {
  final List<AiChatMessageModel> messages;
  final bool isTyping;
  final List<String> quickPrompts;

  const AiChatState({
    required this.messages,
    this.isTyping = false,
    this.quickPrompts = const [
      "Analyze high-yield real estate projects",
      "How do I create a new funding request?",
      "Calculate estimated ROI for Tech Hub",
      "What are current market trends?",
    ],
  });

  AiChatState copyWith({
    List<AiChatMessageModel>? messages,
    bool? isTyping,
    List<String>? quickPrompts,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      quickPrompts: quickPrompts ?? this.quickPrompts,
    );
  }
}

class AiChatNotifier extends Notifier<AiChatState> {
  @override
  AiChatState build() {
    return AiChatState(
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
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMsg = AiChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    await Future.delayed(const Duration(milliseconds: 1200));

    final aiReplyText = _generateAiReply(trimmed);
    final aiMsg = AiChatMessageModel(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: aiReplyText,
      isUser: false,
      timestamp: DateTime.now(),
      suggestions: _getFollowUpSuggestions(trimmed),
    );

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isTyping: false,
    );
  }

  void clearChat() {
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
    );
  }

  String _generateAiReply(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains("real estate") || lower.contains("project")) {
      return "Downtown Tech Hub currently offers a 18% target ROI with a minimum investment of \$1,000. It is located in the Prime Tech District with 75% funded status.";
    } else if (lower.contains("create") || lower.contains("proposal")) {
      return "To create a new project draft:\n1. Tap the '+' button on the home dashboard\n2. Fill in project details & budget targets\n3. Submit for sponsor review.";
    } else if (lower.contains("roi") || lower.contains("calculate")) {
      return "Based on historical performance, average returns across tech & energy portfolios range from 12% to 25% annually.";
    }
    return "I have processed your query regarding '$prompt'. Would you like me to generate a detailed summary or check related opportunity metrics?";
  }

  List<String> _getFollowUpSuggestions(String prompt) {
    return const [
      "Show Financial Breakdown",
      "Connect with Sponsor",
      "View Documents",
    ];
  }
}

final aiChatProvider =
    NotifierProvider.autoDispose<AiChatNotifier, AiChatState>(
  AiChatNotifier.new,
);
