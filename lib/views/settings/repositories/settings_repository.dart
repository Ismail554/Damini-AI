import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/settings_model.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(apiServiceProvider));
});

abstract class SettingsRepository {
  Future<UserSettingsModel> getUserSettings();
  Future<bool> updateNotificationPreference(bool enabled);
  Future<bool> deleteAccount([String? password]);
}

class SettingsRepositoryImpl implements SettingsRepository {
  final ApiService _apiService;

  SettingsRepositoryImpl(this._apiService);

  @override
  Future<UserSettingsModel> getUserSettings() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.currentUser,
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        return UserSettingsModel.fromJson(data);
      } else if (data is Map) {
        return UserSettingsModel.fromJson(Map<String, dynamic>.from(data));
      }
      return const UserSettingsModel();
    } catch (_) {
      return const UserSettingsModel();
    }
  }

  @override
  Future<bool> updateNotificationPreference(bool enabled) async {
    try {
      final response = await _apiService.patch(
        ApiEndpoints.currentUser,
        data: {'push_notifications_enabled': enabled},
        requireAuth: true,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteAccount([String? password]) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.deleteAccount,
        data: {
          if (password != null && password.isNotEmpty) 'password': password,
          'confirmation': 'DELETE',
        },
        requireAuth: true,
      );
      return response.statusCode == 200 ||
          response.statusCode == 204 ||
          (response.data is Map &&
              (response.data['status'] == 'success' ||
                  response.data['success'] == true));
    } catch (e) {
      try {
        final fallback = await _apiService.delete(
          ApiEndpoints.currentUser,
          requireAuth: true,
        );
        return fallback.statusCode == 200 || fallback.statusCode == 204;
      } catch (_) {
        rethrow;
      }
    }
  }
}
