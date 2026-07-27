import 'package:flutter/material.dart';
import '../views/sponsor/project_details/models/sponsor_project_details_model.dart';

class SponsorProjectProvider extends ChangeNotifier {
  SponsorProjectDetailsModel _project = SponsorProjectDetailsModel.mockData();

  SponsorProjectDetailsModel get project => _project;

  void addContribution(InvestorContributionModel contribution) {
    final updatedContributions = List<InvestorContributionModel>.from(_project.contributions)
      ..insert(0, contribution);

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
      investorsCount: _project.investorsCount + 1,
      targetRoi: _project.targetRoi,
      pendingReviewAmount: _project.pendingReviewAmount,
      contributions: updatedContributions,
    );

    notifyListeners();
  }
}
