import '../models/request_collaboration_model.dart';

abstract class RequestCollaborationRepository {
  Future<bool> submitCollaborationRequest(CollaborationSubmissionModel submission);
}

class RequestCollaborationRepositoryImpl implements RequestCollaborationRepository {
  @override
  Future<bool> submitCollaborationRequest(CollaborationSubmissionModel submission) async {
    // Mock API Delay
    await Future.delayed(const Duration(milliseconds: 800));
    return true;
  }
}
