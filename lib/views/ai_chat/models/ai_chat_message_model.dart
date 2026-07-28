class AiChatMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestions;
  final bool isThinking;

  const AiChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
    this.isThinking = false,
  });

  AiChatMessageModel copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    List<String>? suggestions,
    bool? isThinking,
  }) {
    return AiChatMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      suggestions: suggestions ?? this.suggestions,
      isThinking: isThinking ?? this.isThinking,
    );
  }
}
