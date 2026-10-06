import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/request_collaboration_model.dart';

abstract class RequestCollaborationRepository {
  Future<bool> submitCollaborationRequest(
    CollaborationSubmissionModel submission,
  );
}

class RequestCollaborationRepositoryImpl
    implements RequestCollaborationRepository {
  final ApiService _apiService;

  RequestCollaborationRepositoryImpl(this._apiService);

  @override
  Future<bool> submitCollaborationRequest(
    CollaborationSubmissionModel submission,
  ) async {
    final cleanBudget = submission.amount.replaceAll(RegExp(r'[^0-9.]'), '');
    final payload = {
      'proposed_budget': cleanBudget.isNotEmpty
          ? cleanBudget
          : submission.amount,
      'message': submission.note.trim().isNotEmpty
          ? submission.note.trim()
          : 'I am interested in collaborating on this project.',
    };

    final response = await _apiService.post(
      ApiEndpoints.createCollaborationRequest(submission.projectId),
      data: payload,
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
