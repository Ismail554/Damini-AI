import 'package:flutter_test/flutter_test.dart';
import 'package:Braintech/views/ai_chat/models/ai_chat_message_model.dart';
import 'package:Braintech/views/ai_chat/models/ai_chat_response_models.dart';

void main() {
  group('AI Copilot Chat Models & Serialization Tests', () {
    test('AiChatMessageModel deserializes user message correctly', () {
      final json = {
        "id": "msg_usr_1001",
        "content": "Analyze high-yield real estate projects",
        "is_user": true,
        "created_at": "2026-10-08T10:00:00.000Z",
      };

      final msg = AiChatMessageModel.fromJson(json);

      expect(msg.id, "msg_usr_1001");
      expect(msg.text, "Analyze high-yield real estate projects");
      expect(msg.isUser, isTrue);
      expect(msg.timestamp, DateTime.parse("2026-10-08T10:00:00.000Z"));
      expect(msg.suggestions, isNull);
    });

    test('AiChatMessageModel deserializes assistant reply with suggestions', () {
      final json = {
        "id": "msg_ai_1002",
        "text": "Downtown Tech Hub offers 18% target ROI.",
        "is_user": false,
        "created_at": "2026-10-08T10:00:02.000Z",
        "suggestions": [
          "Show Financial Breakdown",
          "Connect with Sponsor",
          "View Documents"
        ]
      };

      final msg = AiChatMessageModel.fromJson(json);

      expect(msg.id, "msg_ai_1002");
      expect(msg.text, "Downtown Tech Hub offers 18% target ROI.");
      expect(msg.isUser, isFalse);
      expect(msg.suggestions?.length, 3);
      expect(msg.suggestions, contains("Show Financial Breakdown"));
    });

    test('AiChatInitialData deserializes backend GET /api/v1/ai/chat/initial/ response', () {
      final json = {
        "success": true,
        "data": {
          "conversation_id": "c9a4b8e2-4f3d-4c8a-9e12-8d7e6f5a4b3c",
          "welcome_message": {
            "id": "msg_welcome",
            "text": "Hello! I am your AI Investment Copilot. How can I help you today?",
            "is_user": false,
            "created_at": "2026-10-08T10:00:00.000Z",
            "suggestions": [
              "Explore Top Projects",
              "Draft New Proposal",
              "Market Analytics"
            ]
          },
          "quick_prompts": [
            "Analyze high-yield real estate projects",
            "How do I create a new funding request?",
            "Calculate estimated ROI for Tech Hub"
          ]
        }
      };

      final initialData = AiChatInitialData.fromJson(json);

      expect(initialData.conversationId, "c9a4b8e2-4f3d-4c8a-9e12-8d7e6f5a4b3c");
      expect(initialData.welcomeMessage?.text, contains("AI Investment Copilot"));
      expect(initialData.welcomeMessage?.suggestions?.length, 3);
      expect(initialData.quickPrompts.length, 3);
    });

    test('AiSendMessageResult deserializes POST /messages/ response payload', () {
      final json = {
        "success": true,
        "data": {
          "user_message": {
            "id": "msg_usr_123",
            "text": "Calculate estimated ROI for Tech Hub",
            "is_user": true,
            "created_at": "2026-10-08T10:05:00.000Z"
          },
          "ai_reply": {
            "id": "msg_ai_124",
            "text": "The projected ROI is 18.5% over 36 months.",
            "is_user": false,
            "created_at": "2026-10-08T10:05:02.000Z",
            "suggestions": [
              "View Financial Model",
              "Sponsor Risk Profile"
            ]
          },
          "updated_quick_prompts": [
            "Compare with Energy deals",
            "Check sponsor verification"
          ]
        }
      };

      final result = AiSendMessageResult.fromJson(json);

      expect(result.userMessage?.text, "Calculate estimated ROI for Tech Hub");
      expect(result.aiReply?.text, contains("18.5%"));
      expect(result.aiReply?.suggestions, contains("View Financial Model"));
      expect(result.updatedQuickPrompts?.length, 2);
    });
  });
}
