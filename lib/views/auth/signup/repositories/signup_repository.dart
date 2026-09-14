import '../models/signup_request_model.dart';

abstract class SignupRepository {
  Future<SignupResponseModel> signUp(SignupRequestModel request);
}

class SignupRepositoryImpl implements SignupRepository {
  @override
  Future<SignupResponseModel> signUp(SignupRequestModel request) async {
    // Mock API Delay (Ready for DioService.client.post)
    await Future.delayed(const Duration(seconds: 1));
    return const SignupResponseModel(success: true);
  }
}
