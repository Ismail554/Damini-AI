import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/reset_password_model.dart';

abstract class ResetPasswordRepository {
  Future<ResetPasswordResponseModel> resetPassword(ResetPasswordRequestModel request);
}

class ResetPasswordRepositoryImpl implements ResetPasswordRepository {
  final ApiService _apiService;

  ResetPasswordRepositoryImpl(this._apiService);

  @override
  Future<ResetPasswordResponseModel> resetPassword(ResetPasswordRequestModel request) async {
    final response = await _apiService.post(
      ApiEndpoints.resetPassword,
      data: request.toJson(),
      requireAuth: false,
    );

    if (response.data is Map<String, dynamic>) {
      return ResetPasswordResponseModel.fromJson(response.data as Map<String, dynamic>);
    } else if (response.data is Map) {
      return ResetPasswordResponseModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    }

    return const ResetPasswordResponseModel(success: true, message: "Password reset successfully.");
  }
}
