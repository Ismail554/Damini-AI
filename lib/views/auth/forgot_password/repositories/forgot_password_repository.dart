import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/forgot_password_model.dart';

abstract class ForgotPasswordRepository {
  Future<ForgotPasswordResponseModel> forgotPassword(ForgotPasswordRequestModel request);
}

class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  final ApiService _apiService;

  ForgotPasswordRepositoryImpl(this._apiService);

  @override
  Future<ForgotPasswordResponseModel> forgotPassword(ForgotPasswordRequestModel request) async {
    final response = await _apiService.post(
      ApiEndpoints.forgotPassword,
      data: request.toJson(),
      requireAuth: false,
    );

    if (response.data is Map<String, dynamic>) {
      return ForgotPasswordResponseModel.fromJson(response.data as Map<String, dynamic>);
    } else if (response.data is Map) {
      return ForgotPasswordResponseModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    }

    return const ForgotPasswordResponseModel(success: true, message: "Reset code sent.");
  }
}
