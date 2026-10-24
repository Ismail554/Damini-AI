import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/services/api_service.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(ref.watch(apiServiceProvider));
});

abstract class ReportRepository {
  Future<bool> submitReport({
    int? reportedProjectId,
    int? reportedUserId,
    int? reportedMessageId,
    required String reason,
    String? details,
  });
}

class ReportRepositoryImpl implements ReportRepository {
  final ApiService _apiService;

  ReportRepositoryImpl(this._apiService);

  @override
  Future<bool> submitReport({
    int? reportedProjectId,
    int? reportedUserId,
    int? reportedMessageId,
    required String reason,
    String? details,
  }) async {
    final payload = <String, dynamic>{
      'reason': reason,
      if (details != null && details.trim().isNotEmpty)
        'details': details.trim(),
      'reported_project_id': ?reportedProjectId,
      'reported_user_id': ?reportedUserId,
      'reported_message_id': ?reportedMessageId,
    };

    try {
      final response = await _apiService.post(
        ApiEndpoints.reports,
        data: payload,
        requireAuth: true,
      );

      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          (response.data is Map &&
              (response.data['status'] == 'success' ||
                  response.data['success'] == true));
    } catch (e) {
      // Fallback try to /api/v1/moderation/report/ if /core/reports/ fails
      try {
        final fallback = await _apiService.post(
          '/api/v1/moderation/report/',
          data: payload,
          requireAuth: true,
        );
        return fallback.statusCode == 200 || fallback.statusCode == 201;
      } catch (_) {
        rethrow;
      }
    }
  }
}
