import 'dart:convert';
import 'package:Braintech/core/constants/api_endpoints.dart';
import 'package:Braintech/core/services/api_error_handler.dart';
import 'package:Braintech/core/services/api_service.dart';

import '../models/signup_request_model.dart';

abstract class SignupRepository {
  Future<SignupResponseModel> signUp(SignupRequestModel request);
}

class SignupRepositoryImpl implements SignupRepository {
  final ApiService apiService;

  SignupRepositoryImpl(this.apiService);

  Map<String, String> _parseErrors(dynamic data) {
    final Map<String, String> errors = {};
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }
    if (data is Map) {
      final rawErrors = data['errors'] ?? (data.containsKey('status') ? null : data);
      if (rawErrors is Map) {
        rawErrors.forEach((key, val) {
          final k = key.toString();
          if (val is List && val.isNotEmpty) {
            errors[k] = val.map((e) => e.toString()).join('\n');
          } else if (val != null) {
            errors[k] = val.toString();
          }
        });
      }
    }
    return errors;
  }

  @override
  Future<SignupResponseModel> signUp(SignupRequestModel request) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.register,
        data: request.toJson(),
        requireAuth: false,
      );
      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map) {
        final status = data['status']?.toString().toLowerCase();
        final errors = _parseErrors(data);
        if (status == 'error' || status == 'failed' || errors.isNotEmpty) {
          final msg = data['message']?.toString();
          final resolvedMessage = (msg != null && msg.toLowerCase() != 'validation failed.')
              ? msg
              : (errors.isNotEmpty ? errors.values.join('\n') : (msg ?? "Validation failed."));
          return SignupResponseModel(
            success: false,
            message: resolvedMessage,
            errors: errors.isNotEmpty ? errors : null,
          );
        }
      }

      final msg = data is Map ? data['message']?.toString() : null;
      return SignupResponseModel(
        success: true,
        message: msg ?? "Registration successful",
      );
    } catch (e) {
      String message = "Registration failed. Please try again.";
      Map<String, String>? errors;
      if (e is ApiException) {
        message = e.message;
        final parsed = _parseErrors(e.data);
        if (parsed.isNotEmpty) {
          errors = parsed;
          if (message.toLowerCase() == 'validation failed.' || message.isEmpty) {
            message = parsed.values.join('\n');
          }
        }
      } else {
        message = e.toString();
      }
      return SignupResponseModel(
        success: false,
        message: message,
        errors: errors,
      );
    }
  }
}
