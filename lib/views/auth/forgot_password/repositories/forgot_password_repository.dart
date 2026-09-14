import '../models/forgot_password_model.dart';

abstract class ForgotPasswordRepository {
  Future<ForgotPasswordResponseModel> forgotPassword(ForgotPasswordRequestModel request);
}

class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  @override
  Future<ForgotPasswordResponseModel> forgotPassword(ForgotPasswordRequestModel request) async {
    // Mock API delay (Ready for DioService.client.post)
    await Future.delayed(const Duration(seconds: 1));
    return const ForgotPasswordResponseModel(success: true);
  }
}
