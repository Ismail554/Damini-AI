import '../../../../core/services/storage_service.dart';
import '../../../../shared/global_key.dart';
import '../models/login_request_model.dart';

abstract class LoginRepository {
  Future<LoginResponseModel> login(LoginRequestModel request);
}

class LoginRepositoryImpl implements LoginRepository {
  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    // Mock API Delay (Ready to replace with DioService.client.post)
    await Future.delayed(const Duration(seconds: 1));

    await StorageService.saveToken("mock_jwt_token");
    await StorageService.saveUuid("mock_uuid");
    await StorageService.saveIsApiConnected(true);
    await StorageService.saveHasSeenOnboarding();

    final cleanEmail = request.email.trim().toLowerCase();
    String? role;
    if (cleanEmail == GlobalKeys.demoInvestorEmail) {
      role = GlobalKeys.investorRole;
      await StorageService.saveRole(GlobalKeys.investorRole);
    } else if (cleanEmail == GlobalKeys.demoSponsorEmail) {
      role = GlobalKeys.sponsorRole;
      await StorageService.saveRole(GlobalKeys.sponsorRole);
    } else {
      role = await StorageService.getRole();
    }

    return LoginResponseModel(
      success: true,
      token: "mock_jwt_token",
      role: role,
    );
  }
}
