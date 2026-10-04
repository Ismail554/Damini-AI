import 'dart:async';
import 'dart:convert';
import 'package:Braintech/core/constants/api_endpoints.dart';
import 'package:Braintech/core/services/api_error_handler.dart';
import 'package:Braintech/core/services/api_service.dart';
import 'package:Braintech/core/services/notification_service.dart';
import 'package:Braintech/core/services/storage_service.dart';
import 'package:Braintech/shared/global_key.dart';
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
      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      String? token;
      String? refreshToken;
      String? message;
      UserModel? user;
      String? role;

      if (data is Map) {
        final status = data['status']?.toString().toLowerCase();
        if (status == 'error' || status == 'failed') {
          return LoginResponseModel(
            success: false,
            message: data['message']?.toString() ?? "Login failed",
          );
        }

        token = data['access']?.toString();
        refreshToken = data['refresh']?.toString();
        message = data['message']?.toString();

        final rawUser = data['user'];
        if (rawUser is Map) {
          user = UserModel.fromJson(Map<String, dynamic>.from(rawUser));
          role = user.role;
        } else if (data['role'] != null) {
          role = data['role']?.toString();
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
      final userId = user?.id;
      if (userId != null) {
        await StorageService.saveUuid(userId.toString());
      }
      await StorageService.saveIsApiConnected(true);
      await StorageService.saveHasSeenOnboarding();

      final normalizedRole = role?.trim().toLowerCase() ?? 'none';
      if (GlobalKeys.isValidRole(normalizedRole)) {
        await StorageService.saveRole(normalizedRole);
      } else {
        await StorageService.clearRole();
      }

      // Validate and register FCM device token with backend
      unawaited(
        NotificationService.validateAndRegisterDeviceToken(force: true),
      );

      return LoginResponseModel(
        success: true,
        token: token,
        refreshToken: refreshToken,
        user: user,
        role: role ?? 'NONE',
        message: message ?? "Login successful",
      );
    } catch (e) {
      String message = "Login failed. Please check your credentials.";
      if (e is ApiException) {
        message = e.message;
      } else {
        message = e.toString();
      }
      return LoginResponseModel(success: false, message: message);
    }
  }
}
