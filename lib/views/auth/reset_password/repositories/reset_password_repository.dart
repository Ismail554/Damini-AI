import '../models/reset_password_model.dart';

abstract class ResetPasswordRepository {
  Future<ResetPasswordResponseModel> resetPassword(ResetPasswordRequestModel request);
}

class ResetPasswordRepositoryImpl implements ResetPasswordRepository {
  @override
  Future<ResetPasswordResponseModel> resetPassword(ResetPasswordRequestModel request) async {
    // Mock API delay (Ready for DioService.client.post)
    await Future.delayed(const Duration(seconds: 1));
    return const ResetPasswordResponseModel(success: true);
  }
}
