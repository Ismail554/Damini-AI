import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/collaboration_request_model.dart';

final collaborationRequestsRepositoryProvider =
    Provider<CollaborationRequestsRepository>((ref) {
  return CollaborationRequestsRepository(ref.watch(apiServiceProvider));
});

class CollaborationRequestsRepository {
  final ApiService _apiService;

  CollaborationRequestsRepository(this._apiService);

  /// Fetch collaboration requests from GET /api/v1/projects/sponsor/requests/
  Future<List<CollaborationRequestModel>> fetchCollaborationRequests() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.sponsorCollaborationRequests,
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      List rawList = [];
      if (data is Map && data['data'] is List) {
        rawList = data['data'] as List;
      } else if (data is List) {
        rawList = data;
      } else if (data is Map && data['results'] is List) {
        rawList = data['results'] as List;
      }

      final requests = <CollaborationRequestModel>[];
      for (final item in rawList.whereType<Map>()) {
        try {
          requests.add(
            CollaborationRequestModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        } catch (_) {
          continue;
        }
      }

      // Sort by most recent (createdAt descending)
      requests.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(0);
        final bDate = b.createdAt ?? DateTime(0);
        return bDate.compareTo(aDate);
      });

      return requests;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CollaborationRequestModel>> fetchPendingRequests() async {
    try {
      final all = await fetchCollaborationRequests();
      return all.where((r) => r.status.toUpperCase() == 'PENDING').toList();
    } catch (_) {
      return CollaborationRequestModel.mockPendingList();
    }
  }

  Future<List<CollaborationRequestModel>> fetchApprovedRequests() async {
    try {
      final all = await fetchCollaborationRequests();
      final approved = all
          .where((r) =>
              r.status.toUpperCase() == 'APPROVED' ||
              r.status.toUpperCase() == 'ACCEPTED')
          .toList();
      return approved.isNotEmpty
          ? approved
          : CollaborationRequestModel.mockHistoryList();
    } catch (_) {
      return CollaborationRequestModel.mockHistoryList();
    }
  }

  Future<List<CollaborationRequestModel>> fetchConfirmationRequests() async {
    try {
      final all = await fetchCollaborationRequests();
      final conf = all
          .where((r) =>
              r.status.toUpperCase() == 'CONFIRMED' ||
              r.status.toUpperCase() == 'RECEIVED')
          .toList();
      return conf.isNotEmpty
          ? conf
          : CollaborationRequestModel.mockConfirmationList();
    } catch (_) {
      return CollaborationRequestModel.mockConfirmationList();
    }
  }
}
