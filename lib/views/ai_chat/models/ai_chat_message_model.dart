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

  factory AiChatMessageModel.fromJson(Map<String, dynamic> json) {
    // Parse sender / isUser
    bool user = false;
    if (json.containsKey('is_user')) {
      user = json['is_user'] == true;
    } else if (json.containsKey('isUser')) {
      user = json['isUser'] == true;
    } else if (json['sender'] != null) {
      user = json['sender'].toString().toLowerCase() == 'user';
    }

    // Parse timestamp
    DateTime time = DateTime.now();
    final rawTime = json['created_at'] ?? json['timestamp'] ?? json['date'];
    if (rawTime != null) {
      try {
        time = DateTime.parse(rawTime.toString());
      } catch (_) {}
    }

    // Parse suggestions
    List<String>? parsedSuggestions;
    final rawSuggestions = json['suggestions'];
    if (rawSuggestions is List) {
      parsedSuggestions = rawSuggestions
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return AiChatMessageModel(
      id: json['id']?.toString() ??
          json['pk']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['text']?.toString() ??
          json['content']?.toString() ??
          json['message']?.toString() ??
          '',
      isUser: user,
      timestamp: time,
      suggestions: parsedSuggestions,
      isThinking: json['is_thinking'] == true || json['isThinking'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'is_user': isUser,
      'created_at': timestamp.toIso8601String(),
      if (suggestions != null) 'suggestions': suggestions,
      'is_thinking': isThinking,
    };
  }

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
