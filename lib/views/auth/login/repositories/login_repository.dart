import 'package:Braintech/core/constants/api_endpoints.dart';
import 'package:Braintech/core/services/api_service.dart';
import 'package:Braintech/core/services/storage_service.dart';
import 'package:Braintech/views/auth/login/models/login_request_model.dart';

abstract class LoginRepository {
  Future<LoginResponseModel> login(LoginRequestModel request);
}

class LoginRepositoryImpl implements LoginRepository {
  final ApiService apiService;

  LoginRepositoryImpl(this.apiService);

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.login,
        data: request.toJson(),
        requireAuth: false,
      );
      final data = response.data;
      String? token;
      String? refreshToken;
      String? message;
      String? role;

      if (data is Map) {
        token = data['access']?.toString();
        refreshToken = data['refresh']?.toString();
        message = data['message']?.toString();

        final user = data['user'];
        if (user is Map && user['role'] != null) {
          role = user['role'].toString().toLowerCase();
        } else if (data['role'] != null) {
          role = data['role'].toString().toLowerCase();
        }
      }

      if (token == null || token.isEmpty) {
        return LoginResponseModel(
          success: false,
          message: message ?? "Invalid response from server",
        );
      }

      await StorageService.saveToken(token);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await StorageService.saveRefreshToken(refreshToken);
      }
      if (role != null && role.isNotEmpty) {
        await StorageService.saveRole(role);
      }
      await StorageService.saveIsApiConnected(true);
      await StorageService.saveHasSeenOnboarding();

      return LoginResponseModel(
        success: true,
        token: token,
        role: role,
        message: message ?? "Login successful",
      );
    } catch (e) {
      return LoginResponseModel(success: false, message: e.toString());
    }
  }
}
