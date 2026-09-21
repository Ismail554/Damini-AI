import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/otp_model.dart';

abstract class OtpRepository {
  Future<OtpVerificationResponseModel> verifyOtp(
    OtpVerificationRequestModel request,
  );
  Future<OtpVerificationResponseModel> resendOtp(String email);
}

class OtpRepositoryImpl implements OtpRepository {
  final ApiService apiService;

  OtpRepositoryImpl(this.apiService);

  @override
  Future<OtpVerificationResponseModel> verifyOtp(
    OtpVerificationRequestModel request,
  ) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.verifyOtp,
        data: request.toJson(),
        requireAuth: false,
      );

      final data = response.data;
      String? token;
      String? refreshToken;
      String? message;

      if (data is Map) {
        token = data['access']?.toString() ??
            data['token']?.toString() ??
            data['access_token']?.toString() ??
            (data['data'] is Map ? data['data']['access']?.toString() : null);
        refreshToken = data['refresh']?.toString() ??
            data['refresh_token']?.toString() ??
            (data['data'] is Map ? data['data']['refresh']?.toString() : null);
        message = data['message']?.toString();
      }

      if (token != null) {
        await StorageService.saveToken(token);
        if (refreshToken != null) {
          await StorageService.saveRefreshToken(refreshToken);
        }
        await StorageService.saveIsApiConnected(true);
        await StorageService.saveHasSeenOnboarding();
      }

      return OtpVerificationResponseModel(
        success: true,
        token: token,
        message: message ?? "Verification successful",
      );
    } catch (e) {
      return OtpVerificationResponseModel(
        success: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<OtpVerificationResponseModel> resendOtp(String email) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.resendOtp,
        data: {'email': email.trim()},
        requireAuth: false,
      );
      final data = response.data;
      final msg = data is Map ? data['message'] : null;
      return OtpVerificationResponseModel(
        success: true,
        message: msg?.toString() ?? "OTP sent successfully",
      );
    } catch (e) {
      return OtpVerificationResponseModel(
        success: false,
        message: e.toString(),
      );
    }
  }
}
