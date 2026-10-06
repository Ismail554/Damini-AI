import '../../collaboration_requests/models/collaboration_request_model.dart';
import 'sponsor_project_details_model.dart';

class SponsorProjectState {
  final bool isLoading;
  final String? error;
  final SponsorProjectDetailsModel project;
  final List<CollaborationRequestModel> pendingList;
  final List<CollaborationRequestModel> approvedList;
  final List<CollaborationRequestModel> confirmationList;

  const SponsorProjectState({
    this.isLoading = false,
    this.error,
    required this.project,
    required this.pendingList,
    required this.approvedList,
    required this.confirmationList,
  });

  SponsorProjectState copyWith({
    bool? isLoading,
    String? error,
    SponsorProjectDetailsModel? project,
    List<CollaborationRequestModel>? pendingList,
    List<CollaborationRequestModel>? approvedList,
    List<CollaborationRequestModel>? confirmationList,
  }) {
    return SponsorProjectState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      project: project ?? this.project,
      pendingList: pendingList ?? this.pendingList,
      approvedList: approvedList ?? this.approvedList,
      confirmationList: confirmationList ?? this.confirmationList,
    );
  }
}
