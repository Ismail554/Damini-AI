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
  /// or project-specific GET /api/v1/projects/sponsor/{id}/requests/
  Future<List<CollaborationRequestModel>> fetchCollaborationRequests({
    String? projectId,
    String? status,
  }) async {
    try {
      final endpoint = (projectId != null && projectId.isNotEmpty)
          ? ApiEndpoints.sponsorProjectRequests(projectId)
          : ApiEndpoints.sponsorCollaborationRequests;

      final queryParams = <String, dynamic>{};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _apiService.get(
        endpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
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
    final all = await fetchCollaborationRequests();
    return all.where((r) => r.isInterested).toList();
  }

  Future<List<CollaborationRequestModel>> fetchApprovedRequests() async {
    final all = await fetchCollaborationRequests();
    return all.where((r) => r.isAgreedToProceed || r.isRoadmapSent).toList();
  }

  Future<List<CollaborationRequestModel>> fetchConfirmationRequests() async {
    final all = await fetchCollaborationRequests();
    return all.where((r) => r.isClosedOffPlatform).toList();
  }

  /// POST /api/v1/projects/{projectId}/confirm-investors/
  /// Confirms / approves investor requests for a project syndicate.
  Future<bool> confirmInvestors({
    required String projectId,
    required List<int> requestIds,
    List<String>? confirmedInvestorIds,
    String? closingDate,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.confirmInvestors(projectId),
        data: {
          'request_ids': requestIds,
          'confirmed_investor_ids': ?confirmedInvestorIds,
          'closing_date': ?closingDate,
        },
        requireAuth: true,
      );
      final data = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      if (data is Map &&
          (data['status'] == 'success' || data['success'] == true)) {
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/v1/projects/sponsor/requests/{id}/approve/
  Future<Map<String, dynamic>?> approveRequest(String id) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.approveCollaborationRequest(id),
        requireAuth: true,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map) {
          return Map<String, dynamic>.from(response.data as Map);
        }
        return {'success': true};
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/v1/projects/sponsor/requests/{id}/reject/
  /// Rejects an investor collaboration request with optional reason.
  Future<bool> rejectRequest(String id, {String? reason}) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.rejectCollaborationRequest(id),
        data: {
          'reason': ?reason,
        },
        requireAuth: true,
      );
      final data = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      if (data is Map &&
          (data['status'] == 'success' || data['success'] == true)) {
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/v1/projects/sponsor/requests/{id}/fund-received/
  Future<bool> fundReceivedRequest(
    String id, {
    num? receivedAmount,
    String? paymentReference,
    DateTime? receivedAt,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.fundReceivedCollaborationRequest(id),
        data: {
          'received_amount': ?receivedAmount,
          'payment_reference': ?paymentReference,
          'received_at': receivedAt != null ? receivedAt.toIso8601String() : DateTime.now().toIso8601String(),
        },
        requireAuth: true,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      rethrow;
    }
  }
}
