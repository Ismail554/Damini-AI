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
  Future<LoginResponseModel> loginWithGoogle(String idToken);
  Future<LoginResponseModel> loginWithApple({
    required String idToken,
    String? firstName,
    String? lastName,
  });
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
      return await _processAuthResponse(
        response.data,
        fallbackErrorMessage: "Login failed",
      );
    } catch (e) {
      return _handleError(e, "Login failed. Please check your credentials.");
    }
  }

  @override
  Future<LoginResponseModel> loginWithGoogle(String idToken) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.googleLogin,
        data: {'id_token': idToken},
        requireAuth: false,
      );
      return await _processAuthResponse(
        response.data,
        fallbackErrorMessage: "Google sign-in failed",
      );
    } catch (e) {
      return _handleError(e, "Google sign-in failed. Please try again.");
    }
  }

  @override
  Future<LoginResponseModel> loginWithApple({
    required String idToken,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final hasFirstName = firstName != null && firstName.trim().isNotEmpty;
      final hasLastName = lastName != null && lastName.trim().isNotEmpty;
      final Map<String, dynamic> body = {
        'id_token': idToken,
        if (hasFirstName || hasLastName)
          'user': {
            'name': {
              if (hasFirstName) 'firstName': firstName.trim(),
              if (hasLastName) 'lastName': lastName.trim(),
            }
          }
      };

      final response = await apiService.post(
        ApiEndpoints.appleLogin,
        data: body,
        requireAuth: false,
      );
      return await _processAuthResponse(
        response.data,
        fallbackErrorMessage: "Apple sign-in failed",
      );
    } catch (e) {
      return _handleError(e, "Apple sign-in failed. Please try again.");
    }
  }

  Future<LoginResponseModel> _processAuthResponse(
    dynamic data, {
    required String fallbackErrorMessage,
  }) async {
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
        final errorMsg = data['message']?.toString() ??
            (data['data'] is Map
                ? (data['data'] as Map)['message']?.toString()
                : null) ??
            fallbackErrorMessage;
        return LoginResponseModel(
          success: false,
          message: errorMsg,
        );
      }

      // Check whether auth tokens and user data are nested under 'data' or present at root
      final Map payload = (data['data'] is Map) ? data['data'] as Map : data;

      token = payload['access']?.toString() ??
          payload['token']?.toString() ??
          payload['access_token']?.toString() ??
          data['access']?.toString() ??
          data['token']?.toString() ??
          data['access_token']?.toString();

      refreshToken = payload['refresh']?.toString() ??
          payload['refresh_token']?.toString() ??
          data['refresh']?.toString() ??
          data['refresh_token']?.toString();

      message = data['message']?.toString() ?? payload['message']?.toString();

      final rawRole = payload['role'] ?? data['role'];
      if (rawRole != null && rawRole.toString().trim().isNotEmpty) {
        role = rawRole.toString().trim();
      }

      final rawUser = payload['user'] ?? data['user'];
      if (rawUser is Map) {
        user = UserModel.fromJson(Map<String, dynamic>.from(rawUser));
        if (role == null || role.isEmpty || role.toUpperCase() == 'NONE') {
          final userRole = user.role.trim();
          if (userRole.isNotEmpty && userRole.toUpperCase() != 'NONE') {
            role = userRole;
          }
        }
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
    } else {
      final jwtUid = StorageService.extractUserIdFromJwt(token);
      if (jwtUid != null && jwtUid.isNotEmpty) {
        await StorageService.saveUuid(jwtUid);
      }
    }
    final resolvedName = (user?.fullName != null && user!.fullName!.trim().isNotEmpty)
        ? user.fullName!.trim()
        : [user?.firstName, user?.lastName]
            .where((s) => s != null && s.trim().isNotEmpty)
            .join(' ')
            .trim();
    if (resolvedName.isNotEmpty) {
      await StorageService.saveUserName(resolvedName);
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
  }

  LoginResponseModel _handleError(dynamic e, String defaultMessage) {
    String message = defaultMessage;
    if (e is ApiException) {
      message = e.message;
    } else {
      message = e.toString();
    }
    return LoginResponseModel(success: false, message: message);
  }
}
