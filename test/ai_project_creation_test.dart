import 'package:flutter_test/flutter_test.dart';
import 'package:Braintech/views/sponsor/create_project/models/ai_project_creation_models.dart';

void main() {
  group('AI Project Creation Deserialization Tests', () {
    test('Step 1 (start conversation) parses correctly', () {
      final json = {
        "conversation_id": "conv_abc123",
        "step": "industry",
        "step_index": 1,
        "total_steps": 4,
        "step_title": "Select Industry",
        "message": {
          "id": "msg_001",
          "role": "assistant",
          "content": "Hi, I'm Damini Advisor. I can help you create a new project. To get started, what industry is your project in?",
          "timestamp": "2026-10-07T09:00:00Z",
          "suggestions": ["Technology", "Clean Energy", "Real Estate", "Healthcare", "Fintech"]
        }
      };

      final data = AiProjectConversationData.fromJson(json);

      expect(data.conversationId, "conv_abc123");
      expect(data.step, "industry");
      expect(data.stepIndex, 1);
      expect(data.totalSteps, 4);
      expect(data.stepTitle, "Select Industry");
      expect(data.message, isNotNull);
      expect(data.message!.text, contains("Damini Advisor"));
      expect(data.message!.isUser, isFalse);
      expect(data.message!.suggestions, contains("Technology"));
      expect(data.draft, isNull);
    });

    test('Step 4 (done step with blueprint draft) parses snake_case draft accurately', () {
      final json = {
        "conversation_id": "conv_abc123",
        "step": "done",
        "step_index": 4,
        "total_steps": 4,
        "step_title": "Blueprint Ready!",
        "message": {
          "id": "msg_007",
          "role": "assistant",
          "content": "I've generated a complete project blueprint based on our conversation. Review it below!",
          "timestamp": "2026-10-07T09:03:00Z",
          "suggestions": ["Apply to Project"]
        },
        "extracted_data": {
          "industry": "Technology",
          "description": "AI-powered supply chain platform",
          "funding_goal": "5000000"
        },
        "draft": {
          "id": "draft_xyz789",
          "title": "AI Project: Technology Innovation",
          "short_description": "AI-assisted business opportunity...",
          "full_description": "Comprehensive operational blueprint...",
          "funding_goal": "5000000",
          "minimum_investment": "1000",
          "target_roi": "15",
          "industry_id": 3,
          "industry_name": "Technology",
          "country": "United States",
          "location": "Austin, TX",
          "funding_stage": "Seed",
          "timeline_months": 36,
          "current_status": "Ready for investment pipeline",
          "next_milestones": "Q1: Prototype & MVP\nQ2: Pilot Customers",
          "use_of_funds": "40% R&D, 30% Sales & Marketing",
          "skin_in_the_game": "250000",
          "minimum_contribution": "1000",
          "expected_roi": "15",
          "potential_monthly_revenue": "45000",
          "hold_period_months": 36,
          "timeline_to_operations_months": 1,
          "team_members_text": "Alex Vance (CEO), Maria Santos (CTO)",
          "confidentiality_agreement_text": "Standard NDA required"
        }
      };

      final data = AiProjectConversationData.fromJson(json);

      expect(data.step, "done");
      expect(data.stepIndex, 4);
      expect(data.draft, isNotNull);

      final draft = data.draft!;
      expect(draft.id, "draft_xyz789");
      expect(draft.title, "AI Project: Technology Innovation");
      expect(draft.shortDesc, "AI-assisted business opportunity...");
      expect(draft.fullDesc, "Comprehensive operational blueprint...");
      expect(draft.fundingGoal, "5000000");
      expect(draft.targetRoi, "15");
      expect(draft.industryId, 3);
      expect(draft.industry, "Technology");
      expect(draft.timeline, "36 months");
      expect(draft.holdPeriod, "36 months");
      expect(draft.timelineOps, "1 months");
      expect(draft.status, "Ready for investment pipeline");
      expect(draft.sponsorInvestment, "250000");
      expect(draft.teamMembers, "Alex Vance (CEO), Maria Santos (CTO)");
    });

    test('Conversation history GET endpoint parses list of messages', () {
      final json = {
        "conversation_id": "conv_abc123",
        "step": "description",
        "step_index": 2,
        "total_steps": 4,
        "step_title": "Project Concept",
        "messages": [
          {
            "id": "msg_001",
            "role": "assistant",
            "content": "Hi, I'm Damini...",
            "timestamp": "2026-10-07T09:00:00Z",
            "suggestions": ["Technology"]
          },
          {
            "id": "msg_002",
            "role": "user",
            "content": "Technology",
            "timestamp": "2026-10-07T09:01:00Z"
          }
        ]
      };

      final data = AiProjectConversationData.fromJson(json);

      expect(data.messages.length, 2);
      expect(data.messages[0].isUser, isFalse);
      expect(data.messages[1].isUser, isTrue);
      expect(data.messages[1].text, "Technology");
    });
  });
}
