import 'package:flutter/material.dart';
import '../views/sponsor/collaboration_requests/models/collaboration_request_model.dart';
import '../views/sponsor/project_details/models/sponsor_project_details_model.dart';

class SponsorProjectProvider extends ChangeNotifier {
  SponsorProjectDetailsModel _project = SponsorProjectDetailsModel.mockData();
  SponsorProjectDetailsModel get project => _project;

  final List<CollaborationRequestModel> _pendingList =
      CollaborationRequestModel.mockPendingList();
  List<CollaborationRequestModel> get pendingList => _pendingList;

  final List<CollaborationRequestModel> _approvedList =
      CollaborationRequestModel.mockHistoryList();
  List<CollaborationRequestModel> get approvedList => _approvedList;

  final List<CollaborationRequestModel> _confirmationList =
      CollaborationRequestModel.mockConfirmationList();
  List<CollaborationRequestModel> get confirmationList => _confirmationList;

  void approvePendingRequest(CollaborationRequestModel item) {
    _pendingList.removeWhere((req) => req.id == item.id);
    _approvedList.insert(
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
    notifyListeners();
  }

  void rejectPendingRequest(String id) {
    _pendingList.removeWhere((req) => req.id == id);
    notifyListeners();
  }

  void addContribution(InvestorContributionModel contribution) {
    final updatedContributions =
        List<InvestorContributionModel>.from(_project.contributions);

    final existingIndex =
        updatedContributions.indexWhere((c) => c.name == contribution.name);

    if (existingIndex != -1) {
      updatedContributions[existingIndex] = contribution;
    } else {
      updatedContributions.insert(0, contribution);
    }

    _project = SponsorProjectDetailsModel(
      id: _project.id,
      title: _project.title,
      location: _project.location,
      badgeText: _project.badgeText,
      raisedAmount: _project.raisedAmount,
      goalAmount: _project.goalAmount,
      percentage: _project.percentage,
      progress: _project.progress,
      remainingAmount: _project.remainingAmount,
      investorsCount: updatedContributions.length,
      targetRoi: _project.targetRoi,
      pendingReviewAmount: _project.pendingReviewAmount,
      contributions: updatedContributions,
    );

    // Add to Confirmation Tab list
    final confId = 'conf_${contribution.id}';
    _confirmationList.removeWhere((item) => item.investorName == contribution.name);
    _confirmationList.insert(
      0,
      CollaborationRequestModel(
        id: confId,
        investorName: contribution.name,
        investorType: contribution.type,
        avatarUrl: contribution.avatarUrl,
        badgeText: contribution.isFunded ? 'Received' : null,
        isApprovedBadge: contribution.isFunded,
        projectName: _project.title,
        proposedBudget: contribution.amount,
        confirmedDate: 'Confirmed ${contribution.date}',
        projectStatusText: 'Project in progress',
        hasFundReceivedButton: !contribution.isFunded,
      ),
    );

    notifyListeners();
  }

  void markFundReceived(String confirmationId) {
    final confIndex =
        _confirmationList.indexWhere((item) => item.id == confirmationId);
    if (confIndex == -1) return;

    final targetItem = _confirmationList[confIndex];
    _confirmationList[confIndex] = CollaborationRequestModel(
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
    final updatedContributions = _project.contributions.map((c) {
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

    _project = SponsorProjectDetailsModel(
      id: _project.id,
      title: _project.title,
      location: _project.location,
      badgeText: _project.badgeText,
      raisedAmount: _project.raisedAmount,
      goalAmount: _project.goalAmount,
      percentage: _project.percentage,
      progress: _project.progress,
      remainingAmount: _project.remainingAmount,
      investorsCount: updatedContributions.length,
      targetRoi: _project.targetRoi,
      pendingReviewAmount: _project.pendingReviewAmount,
      contributions: updatedContributions,
    );

    notifyListeners();
  }
}
