import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_error_handler.dart';
import '../../../../core/services/api_service.dart';
import '../models/create_project_models.dart';

final createProjectRepositoryProvider =
    Provider<CreateProjectRepository>((ref) {
  return CreateProjectRepository(ref.watch(apiServiceProvider));
});

class CreateProjectRepository {
  final ApiService _apiService;

  CreateProjectRepository(this._apiService);

  Future<CreateProjectResponseModel> createProject(
    CreateProjectRequestModel request,
  ) async {
    try {
      final formData = await request.toFormData();
      final response = await _apiService.post(
        ApiEndpoints.sponsorProjects,
        data: formData,
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map) {
        final status = data['status']?.toString().toLowerCase();
        if (status == 'error' || status == 'failed') {
          final errorMsg = _extractErrorMessage(data);
          return CreateProjectResponseModel(
            success: false,
            message: errorMsg ?? "Could not create project",
            data: data,
          );
        }
      }

      return CreateProjectResponseModel.fromJson(data);
    } catch (e) {
      String message = "Could not create project. Please try again.";
      if (e is ApiException) {
        message = e.message;
        final extracted = _extractErrorMessage(e.data);
        if (extracted != null && extracted.isNotEmpty) {
          message = extracted;
        }
      } else if (e is AppException) {
        message = e.message;
      } else {
        message = e.toString();
      }
      return CreateProjectResponseModel(
        success: false,
        message: message,
      );
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {
        return data;
      }
    }
    if (data is Map) {
      if (data['errors'] is Map && (data['errors'] as Map).isNotEmpty) {
        final msgs = <String>[];
        (data['errors'] as Map).forEach((k, v) {
          if (v is List && v.isNotEmpty) {
            msgs.add('$k: ${v.join(", ")}');
          } else if (v != null) {
            msgs.add('$k: $v');
          }
        });
        if (msgs.isNotEmpty) return msgs.join('\n');
      }
      if (data['message'] != null &&
          data['message'].toString().toLowerCase() != 'validation failed.') {
        return data['message'].toString();
      }
      if (data['detail'] != null) {
        return data['detail'].toString();
      }
      // Non-field errors or first value
      for (final entry in data.entries) {
        if (entry.value is List && (entry.value as List).isNotEmpty) {
          return '${entry.key}: ${(entry.value as List).join(", ")}';
        } else if (entry.value is String && (entry.value as String).isNotEmpty) {
          return '${entry.key}: ${entry.value}';
        }
      }
    }
    return null;
  }
}
