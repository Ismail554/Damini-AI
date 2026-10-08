import 'package:flutter_test/flutter_test.dart';
import 'package:Braintech/views/sponsor/collaboration_requests/models/collaboration_request_model.dart';

void main() {
  group('Collaboration Requests Model & Next Flow Serialization Tests', () {
    test('CollaborationRequestModel deserializes pending request correctly', () {
      final json = {
        "id": "req_8812",
        "project": {
          "id": 9876,
          "title": "Downtown Tech Hub"
        },
        "investor": {
          "id": 44,
          "name": "Sarah Connor",
          "investor_type": "VENTURE_CAPITAL",
          "photo": "https://example.com/avatar.png"
        },
        "proposed_budget": "250000",
        "proposal_text": "We would like to join this seed round as a strategic investor.",
        "status": "PENDING",
        "nda_signed": true,
        "created_at": "2026-10-08T10:30:00.000Z"
      };

      final request = CollaborationRequestModel.fromJson(json);

      expect(request.id, "req_8812");
      expect(request.projectName, "Downtown Tech Hub");
      expect(request.investorName, "Sarah Connor");
      expect(request.investorType, "Venture Capital");
      expect(request.proposedBudget, "\$250K");
      expect(request.status, "PENDING");
      expect(request.badgeText, "NDA Signed");
      expect(request.ndaSigned, isTrue);
    });

    test('CollaborationRequestModel deserializes approved/confirmed request correctly', () {
      final json = {
        "id": "req_8812",
        "project": {
          "id": 9876,
          "title": "Downtown Tech Hub"
        },
        "investor": {
          "id": 44,
          "name": "Sarah Connor",
          "investor_type": "ANGEL"
        },
        "proposed_budget": "250000",
        "status": "APPROVED",
        "created_at": "2026-10-08T10:45:00.000Z"
      };

      final request = CollaborationRequestModel.fromJson(json);

      expect(request.id, "req_8812");
      expect(request.status, "APPROVED");
      expect(request.badgeText, "Approved");
      expect(request.isApprovedBadge, isTrue);
      expect(request.hasFundReceivedButton, isTrue);
    });
  });
}
