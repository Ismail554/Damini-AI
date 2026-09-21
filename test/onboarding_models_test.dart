import 'package:flutter_test/flutter_test.dart';
import 'package:Braintech/views/role_selection/models/onboarding_models.dart';

void main() {
  group('Onboarding Models Test', () {
    test('IndustryModel parsing', () {
      final json = {'id': 1, 'name': 'Real Estate'};
      final model = IndustryModel.fromJson(json);
      expect(model.id, 1);
      expect(model.name, 'Real Estate');
      expect(model.toJson(), json);
    });

    test('VerificationStatusModel parsing data wrapper', () {
      final json = {
        'status': 'success',
        'data': {
          'verification_status': 'APPROVED',
        },
      };
      final model = VerificationStatusModel.fromJson(json);
      expect(model.status, 'APPROVED');
      expect(model.isApproved, isTrue);
      expect(model.isPending, isFalse);
    });

    test('VerificationStatusModel pending and rejected statuses', () {
      final pendingModel = VerificationStatusModel.fromJson({'verification_status': 'PENDING'});
      expect(pendingModel.isPending, isTrue);

      final rejectedModel = VerificationStatusModel.fromJson({'verification_status': 'REJECTED'});
      expect(rejectedModel.isRejected, isTrue);
    });

    test('OnboardingState copyWith and company check', () {
      const state = OnboardingState();
      expect(state.role, 'investor');
      expect(state.accountType, 'INDIVIDUAL');
      expect(state.isCompany, isFalse);

      final companyState = state.copyWith(accountType: 'COMPANY');
      expect(companyState.isCompany, isTrue);
    });
  });
}
