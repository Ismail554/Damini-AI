import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/collaboration_request_model.dart';

final collaborationRequestsRepositoryProvider =
    Provider<CollaborationRequestsRepository>((ref) {
  return CollaborationRequestsRepository();
});

class CollaborationRequestsRepository {
  Future<List<CollaborationRequestModel>> fetchPendingRequests() async {
    return CollaborationRequestModel.mockPendingList();
  }

  Future<List<CollaborationRequestModel>> fetchApprovedRequests() async {
    return CollaborationRequestModel.mockHistoryList();
  }

  Future<List<CollaborationRequestModel>> fetchConfirmationRequests() async {
    return CollaborationRequestModel.mockConfirmationList();
  }
}
