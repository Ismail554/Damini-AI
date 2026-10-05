import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_error_handler.dart';
import '../../../../core/services/api_service.dart';
import '../models/switch_role_response_model.dart';

final switchRoleRepositoryProvider = Provider<SwitchRoleRepository>((ref) {
  return SwitchRoleRepositoryImpl(ref.watch(apiServiceProvider));
});

abstract class SwitchRoleRepository {
  Future<SwitchRoleResult> switchRole(String role);
}

class SwitchRoleRepositoryImpl implements SwitchRoleRepository {
  final ApiService _apiService;
  SwitchRoleRepositoryImpl(this._apiService);

  @override
  Future<SwitchRoleResult> switchRole(String role) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.switchRole,
        data: {'role': role.toUpperCase()},
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        return SwitchRoleResult.fromSuccessJson(data);
      }
      return SwitchRoleResult.failure('Unexpected response format.');
    } on ApiException catch (e) {
      if (e.statusCode == 400) {
        Map<String, dynamic>? map;
        if (e.data is Map) {
          map = Map<String, dynamic>.from(e.data as Map);
        } else if (e.data is String) {
          try {
            final decoded = jsonDecode(e.data as String);
            if (decoded is Map) {
              map = Map<String, dynamic>.from(decoded);
            }
          } catch (_) {}
        }

        String? errorCode;
        if (map != null) {
          if (map['errors'] is Map) {
            errorCode = (map['errors'] as Map)['error_code']?.toString();
          }
          if (errorCode == null && map['data'] is Map) {
            errorCode = (map['data'] as Map)['error_code']?.toString();
          }
          errorCode ??= map['error_code']?.toString();
        }

        final rawMsg = map?['message']?.toString() ?? e.message;
        final isMissing = errorCode == 'PROFILE_MISSING' ||
            e.message.trim() == 'PROFILE_MISSING' ||
            rawMsg.toLowerCase().contains('profile does not exist');

        if (isMissing) {
          return SwitchRoleResult(
            success: false,
            errorCode: 'PROFILE_MISSING',
            message: rawMsg,
          );
        }
      }
      return SwitchRoleResult.failure(e.message);
    } catch (e) {
      return SwitchRoleResult.failure(e.toString());
    }
  }
}
