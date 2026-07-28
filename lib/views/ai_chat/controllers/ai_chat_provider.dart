import 'package:flutter/material.dart';
import '../models/ai_chat_message_model.dart';

class AiChatProvider extends ChangeNotifier {
  final List<AiChatMessageModel> _messages = [];
  bool _isTyping = false;

  List<AiChatMessageModel> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  final List<String> quickPrompts = [
    "Analyze high-yield real estate projects",
    "How do I create a new funding request?",
    "Calculate estimated ROI for Tech Hub",
    "What are current market trends?",
  ];

  AiChatProvider() {
    _initGreeting();
  }

  void _initGreeting() {
    _messages.add(
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

    _messages.add(userMsg);
    _isTyping = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    final aiReplyText = _generateAiReply(trimmed);
    final aiMsg = AiChatMessageModel(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: aiReplyText,
      isUser: false,
      timestamp: DateTime.now(),
      suggestions: _getFollowUpSuggestions(trimmed),
    );

    _isTyping = false;
    _messages.add(aiMsg);
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _initGreeting();
    notifyListeners();
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
