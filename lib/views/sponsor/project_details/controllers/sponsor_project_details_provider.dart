import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../collaboration_requests/models/collaboration_request_model.dart';
import '../models/sponsor_project_details_model.dart';
import '../repositories/sponsor_project_details_repository.dart';

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

    if (isRefresh) {
      state = state.copyWith(isLoading: false, error: null);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final project = await _repository.fetchProjectDetails(projectId);
      state = state.copyWith(
        isLoading: false,
        error: null,
        project: project,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load project details: $e',
      );
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

    final updatedProject = SponsorProjectDetailsModel(
      id: state.project.id,
      title: state.project.title,
      location: state.project.location,
      badgeText: state.project.badgeText,
      raisedAmount: state.project.raisedAmount,
      goalAmount: state.project.goalAmount,
      percentage: state.project.percentage,
      progress: state.project.progress,
      remainingAmount: state.project.remainingAmount,
      investorsCount: updatedContributions.length,
      targetRoi: state.project.targetRoi,
      pendingReviewAmount: state.project.pendingReviewAmount,
      contributions: updatedContributions,
      shortDescription: state.project.shortDescription,
      businessDescription: state.project.businessDescription,
      industry: state.project.industry,
      category: state.project.category,
      minimumInvestment: state.project.minimumInvestment,
      timelineMonths: state.project.timelineMonths,
      coverImageUrl: state.project.coverImageUrl,
      sponsorCompanyName: state.project.sponsorCompanyName,
      isSponsorVerified: state.project.isSponsorVerified,
      documents: state.project.documents,
      createdAt: state.project.createdAt,
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

    final updatedProject = SponsorProjectDetailsModel(
      id: state.project.id,
      title: state.project.title,
      location: state.project.location,
      badgeText: state.project.badgeText,
      raisedAmount: state.project.raisedAmount,
      goalAmount: state.project.goalAmount,
      percentage: state.project.percentage,
      progress: state.project.progress,
      remainingAmount: state.project.remainingAmount,
      investorsCount: updatedContributions.length,
      targetRoi: state.project.targetRoi,
      pendingReviewAmount: state.project.pendingReviewAmount,
      contributions: updatedContributions,
      shortDescription: state.project.shortDescription,
      businessDescription: state.project.businessDescription,
      industry: state.project.industry,
      category: state.project.category,
      minimumInvestment: state.project.minimumInvestment,
      timelineMonths: state.project.timelineMonths,
      coverImageUrl: state.project.coverImageUrl,
      sponsorCompanyName: state.project.sponsorCompanyName,
      isSponsorVerified: state.project.isSponsorVerified,
      documents: state.project.documents,
      createdAt: state.project.createdAt,
    );

    state = state.copyWith(
      project: updatedProject,
      confirmationList: confirmations,
    );
  }
}
