import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../collaboration_requests/models/collaboration_request_model.dart';
import '../models/sponsor_project_details_model.dart';
import '../models/sponsor_project_state.dart';
import '../repositories/sponsor_project_details_repository.dart';

export '../models/sponsor_project_state.dart';

final sponsorProjectProvider =
    NotifierProvider<SponsorProjectNotifier, SponsorProjectState>(
  SponsorProjectNotifier.new,
);

class SponsorProjectNotifier extends Notifier<SponsorProjectState> {
  late final SponsorProjectDetailsRepository _repository;

  @override
  SponsorProjectState build() {
    _repository = ref.watch(sponsorProjectDetailsRepositoryProvider);
    return SponsorProjectState(
      isLoading: false,
      project: SponsorProjectDetailsModel.mockData(),
      pendingList: CollaborationRequestModel.mockPendingList(),
      approvedList: CollaborationRequestModel.mockHistoryList(),
      confirmationList: CollaborationRequestModel.mockConfirmationList(),
    );
  }

  /// Load project from backend API: GET /api/v1/projects/{id}/
  Future<void> loadProject(String projectId, {bool isRefresh = false}) async {
    if (projectId.isEmpty) return;
    state = state.copyWith(isLoading: !isRefresh, error: null);

    try {
      final project = await _repository.fetchProjectDetails(projectId);
      state = state.copyWith(isLoading: false, error: null, project: project);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load project details: $e');
    }
  }

  /// Terminate project: POST /api/v1/projects/{id}/terminate/
  Future<bool> terminateProject(String projectId, String reason) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.terminateProject(projectId, reason);
      final updated = state.project.copyWith(
        badgeText: 'Terminated',
        currentStatus: 'Terminated',
        terminationReason: reason,
        terminatedAt: DateTime.now(),
      );
      state = state.copyWith(isLoading: false, error: null, project: updated);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to terminate project: $e');
      return false;
    }
  }

  void approvePendingRequest(CollaborationRequestModel item) {
    final pending = List<CollaborationRequestModel>.from(state.pendingList)
      ..removeWhere((req) => req.id == item.id);

    final approved = List<CollaborationRequestModel>.from(state.approvedList)
      ..insert(
        0,
        CollaborationRequestModel(
          id: item.id,
          investorName: item.investorName,
          investorType: item.investorType,
          avatarUrl: item.avatarUrl,
          badgeText: 'Approved',
          isApprovedBadge: true,
          projectName: item.projectName,
          proposedBudget: item.proposedBudget,
          proposalText: item.proposalText,
          isHistory: true,
        ),
      );

    state = state.copyWith(
      pendingList: pending,
      approvedList: approved,
    );
  }

  void rejectPendingRequest(String id) {
    final pending = List<CollaborationRequestModel>.from(state.pendingList)
      ..removeWhere((req) => req.id == id);
    state = state.copyWith(pendingList: pending);
  }

  void addContribution(InvestorContributionModel contribution) {
    final updatedContributions =
        List<InvestorContributionModel>.from(state.project.contributions);

    final existingIndex =
        updatedContributions.indexWhere((c) => c.name == contribution.name);

    if (existingIndex != -1) {
      updatedContributions[existingIndex] = contribution;
    } else {
      updatedContributions.insert(0, contribution);
    }

    final updatedProject = state.project.copyWith(
      contributions: updatedContributions,
      investorsCount: updatedContributions.length,
    );

    // Add to Confirmation Tab list
    final confId = 'conf_${contribution.id}';
    final confirmations =
        List<CollaborationRequestModel>.from(state.confirmationList)
          ..removeWhere((item) => item.investorName == contribution.name)
          ..insert(
            0,
            CollaborationRequestModel(
              id: confId,
              investorName: contribution.name,
              investorType: contribution.type,
              avatarUrl: contribution.avatarUrl,
              badgeText: contribution.isFunded ? 'Received' : null,
              isApprovedBadge: contribution.isFunded,
              projectName: state.project.title,
              proposedBudget: contribution.amount,
              confirmedDate: 'Confirmed ${contribution.date}',
              projectStatusText: 'Project in progress',
              hasFundReceivedButton: !contribution.isFunded,
            ),
          );

    state = state.copyWith(
      project: updatedProject,
      confirmationList: confirmations,
    );
  }

  void markFundReceived(String confirmationId) {
    final confirmations =
        List<CollaborationRequestModel>.from(state.confirmationList);
    final confIndex =
        confirmations.indexWhere((item) => item.id == confirmationId);
    if (confIndex == -1) return;

    final targetItem = confirmations[confIndex];
    confirmations[confIndex] = CollaborationRequestModel(
      id: targetItem.id,
      investorName: targetItem.investorName,
      investorType: targetItem.investorType,
      avatarUrl: targetItem.avatarUrl,
      badgeText: 'Received',
      isApprovedBadge: true,
      projectName: targetItem.projectName,
      proposedBudget: targetItem.proposedBudget,
      confirmedDate: targetItem.confirmedDate,
      projectStatusText: targetItem.projectStatusText,
      hasFundReceivedButton: false,
    );

    // Update isFunded in project contributions
    final updatedContributions = state.project.contributions.map((c) {
      if (c.name == targetItem.investorName) {
        return InvestorContributionModel(
          id: c.id,
          name: c.name,
          type: c.type,
          avatarUrl: c.avatarUrl,
          amount: c.amount,
          date: c.date,
          isFunded: true,
        );
      }
      return c;
    }).toList();

    final updatedProject = state.project.copyWith(
      contributions: updatedContributions,
      investorsCount: updatedContributions.length,
    );

    state = state.copyWith(
      project: updatedProject,
      confirmationList: confirmations,
    );
  }
}
