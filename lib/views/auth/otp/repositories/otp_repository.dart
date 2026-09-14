import '../../../../core/services/storage_service.dart';
import '../models/otp_model.dart';

abstract class OtpRepository {
  Future<OtpVerificationResponseModel> verifyOtp(OtpVerificationRequestModel request);
  Future<bool> resendOtp(String email);
}

class OtpRepositoryImpl implements OtpRepository {
  @override
  Future<OtpVerificationResponseModel> verifyOtp(OtpVerificationRequestModel request) async {
    // Mock API Delay (Ready for DioService.client.post)
    await Future.delayed(const Duration(seconds: 1));

    await StorageService.saveToken("mock_jwt_token");
    await StorageService.saveUuid("mock_uuid");
    await StorageService.saveHasSeenOnboarding();

    return const OtpVerificationResponseModel(
      success: true,
      token: "mock_jwt_token",
    );
  }

  @override
  Future<bool> resendOtp(String email) async {
    // Mock API Delay
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
