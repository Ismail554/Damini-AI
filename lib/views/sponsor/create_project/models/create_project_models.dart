import 'package:dio/dio.dart';

class CreateProjectRequestModel {
  final String title;
  final String shortDescription;
  final String businessDescription;
  final double fundingGoal;
  final double minimumInvestment;
  final double targetRoi;
  final String country;
  final String location;
  final String industry;
  final String categoryIds;
  final String fundingStage;
  final int timelineMonths;
  final String currentStatus;
  final String nextMilestones;
  final String useOfFunds;
  final double skinInTheGame;
  final double potentialMonthlyRevenue;
  final int holdPeriodMonths;
  final int timelineToOperationsMonths;
  final String teamMembersText;
  final String confidentialityAgreementText;
  final String? coverImagePath;
  final String status; // 'ACTIVE', 'DRAFT', 'COMPLETED'

  const CreateProjectRequestModel({
    required this.title,
    required this.shortDescription,
    required this.businessDescription,
    required this.fundingGoal,
    required this.minimumInvestment,
    required this.targetRoi,
    required this.country,
    required this.location,
    required this.industry,
    required this.categoryIds,
    required this.fundingStage,
    required this.timelineMonths,
    required this.currentStatus,
    required this.nextMilestones,
    required this.useOfFunds,
    required this.skinInTheGame,
    required this.potentialMonthlyRevenue,
    required this.holdPeriodMonths,
    required this.timelineToOperationsMonths,
    required this.teamMembersText,
    required this.confidentialityAgreementText,
    this.coverImagePath,
    this.status = 'ACTIVE',
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> map = {
      'title': title.trim(),
      'short_description': shortDescription.trim(),
      'business_description': businessDescription.trim(),
      'funding_goal': fundingGoal.toString(),
      'minimum_investment': minimumInvestment.toString(),
      'target_roi': targetRoi.toString(),
      'country': country.trim(),
      'location': location.trim(),
      'industry': industry.trim(),
      'category_ids': categoryIds.trim(),
      'funding_stage': fundingStage.trim(),
      'timeline_months': timelineMonths.toString(),
      'current_status': currentStatus.trim(),
      'next_milestones': nextMilestones.trim(),
      'use_of_funds': useOfFunds.trim(),
      'skin_in_the_game': skinInTheGame.toString(),
      'potential_monthly_revenue': potentialMonthlyRevenue.toString(),
      'hold_period_months': holdPeriodMonths.toString(),
      'timeline_to_operations_months': timelineToOperationsMonths.toString(),
      'team_members_text': teamMembersText.trim(),
      'confidentiality_agreement_text': confidentialityAgreementText.trim(),
      'status': status.toUpperCase(),
    };

    final imagePath = coverImagePath?.trim();
    if (imagePath != null && imagePath.isNotEmpty) {
      final fileName = imagePath.split(RegExp(r'[\\/]')).last;
      map['cover_image'] = await MultipartFile.fromFile(
        imagePath,
        filename: fileName,
      );
    }

    return FormData.fromMap(map);
  }
}

class CreateProjectResponseModel {
  final bool success;
  final String message;
  final String? projectId;
  final dynamic data;

  const CreateProjectResponseModel({
    required this.success,
    required this.message,
    this.projectId,
    this.data,
  });

  factory CreateProjectResponseModel.fromJson(dynamic json) {
    if (json is Map) {
      final dataObj = json['data'] is Map ? json['data'] as Map : json;
      final id = dataObj['id']?.toString() ?? json['id']?.toString();
      final status = json['status']?.toString().toLowerCase();
      final msg = json['message']?.toString() ??
          (status == 'success'
              ? 'Project created successfully'
              : 'Operation completed');

      return CreateProjectResponseModel(
        success: status != 'error' && status != 'failed',
        message: msg,
        projectId: id,
        data: json,
      );
    }
    return const CreateProjectResponseModel(
      success: true,
      message: 'Project created successfully',
    );
  }
}
