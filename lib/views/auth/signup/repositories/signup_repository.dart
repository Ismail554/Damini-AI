import 'package:Braintech/core/constants/api_endpoints.dart';
import 'package:Braintech/core/services/api_service.dart';

import '../models/signup_request_model.dart';

abstract class SignupRepository {
  Future<SignupResponseModel> signUp(SignupRequestModel request);
}

class SignupRepositoryImpl implements SignupRepository {
  final ApiService apiService;

  SignupRepositoryImpl(this.apiService);

  @override
  Future<SignupResponseModel> signUp(SignupRequestModel request) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.register,
        data: request.toJson(),
        requireAuth: false,
      );
      final data = response.data;
      final msg = data is Map ? data['message'] : null;
      return SignupResponseModel(
        success: true,
        message: msg ?? "Registration successful",
      );
    } catch (e) {
      return SignupResponseModel(success: false, message: e.toString());
    }
  }
}
