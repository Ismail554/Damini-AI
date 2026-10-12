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
  final String? industry;
  final List<int>? categoryIds;
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
    this.industry,
    this.categoryIds,
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

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'title': title.trim(),
      'short_description': shortDescription.trim(),
      'business_description': businessDescription.trim(),
      'funding_goal': fundingGoal.toStringAsFixed(2),
      'minimum_investment': minimumInvestment.toStringAsFixed(2),
      'target_roi': targetRoi.toStringAsFixed(2),
      'target_return': targetRoi.toStringAsFixed(2),
      'country': country.trim(),
      'location': location.trim(),
      'funding_stage': fundingStage.trim(),
      'timeline_months': timelineMonths.toString(),
      'project_duration_months': timelineMonths.toString(),
      'current_status': currentStatus.trim(),
      'next_milestones': nextMilestones.trim(),
      'use_of_funds': useOfFunds.trim(),
      'skin_in_the_game': skinInTheGame.toStringAsFixed(2),
      'potential_monthly_revenue': potentialMonthlyRevenue.toStringAsFixed(2),
      'hold_period_months': holdPeriodMonths.toString(),
      'timeline_to_operations_months': timelineToOperationsMonths.toString(),
      'team_members_text': teamMembersText.trim(),
      'confidentiality_agreement_text': confidentialityAgreementText.trim(),
      'status': status.toUpperCase(),
    };

    if (industry != null && industry!.trim().isNotEmpty) {
      final parsedId = int.tryParse(industry!.trim());
      if (parsedId != null && parsedId > 0) {
        map['industry'] = parsedId.toString();
      }
    }

    if (categoryIds != null && categoryIds!.isNotEmpty) {
      for (var i = 0; i < categoryIds!.length; i++) {
        map['category_ids[$i]'] = categoryIds![i].toString();
      }
    }

    if (coverImagePath != null && coverImagePath!.trim().isNotEmpty) {
      map['cover_image'] = coverImagePath;
    }

    return map;
  }

  Future<FormData> toFormData() async {
    final Map<String, dynamic> map = {
      'title': title.trim(),
      'short_description': shortDescription.trim(),
      'business_description': businessDescription.trim(),
      'funding_goal': fundingGoal.toStringAsFixed(2),
      'minimum_investment': minimumInvestment.toStringAsFixed(2),
      'target_roi': targetRoi.toStringAsFixed(2),
      'target_return': targetRoi.toStringAsFixed(2),
      'country': country.trim(),
      'location': location.trim(),
      'funding_stage': fundingStage.trim(),
      'timeline_months': timelineMonths.toString(),
      'project_duration_months': timelineMonths.toString(),
      'current_status': currentStatus.trim(),
      'next_milestones': nextMilestones.trim(),
      'use_of_funds': useOfFunds.trim(),
      'skin_in_the_game': skinInTheGame.toStringAsFixed(2),
      'potential_monthly_revenue': potentialMonthlyRevenue.toStringAsFixed(2),
      'hold_period_months': holdPeriodMonths.toString(),
      'timeline_to_operations_months': timelineToOperationsMonths.toString(),
      'team_members_text': teamMembersText.trim(),
      'confidentiality_agreement_text': confidentialityAgreementText.trim(),
      'status': status.toUpperCase(),
    };

    // Industry ID as integer (if provided)
    if (industry != null && industry!.trim().isNotEmpty) {
      final parsedId = int.tryParse(industry!.trim());
      if (parsedId != null && parsedId > 0) {
        map['industry'] = parsedId.toString();
      }
    }

    // Category IDs: Only send if provided and non-empty.
    // Spec: "e.g. category_ids[0]: 1, category_ids[1]: 2"
    if (categoryIds != null && categoryIds!.isNotEmpty) {
      for (var i = 0; i < categoryIds!.length; i++) {
        map['category_ids[$i]'] = categoryIds![i].toString();
      }
    }

    final imagePath = coverImagePath?.trim();
    if (imagePath != null && imagePath.isNotEmpty) {
      final fileName = imagePath.split(RegExp(r'[\\/]')).last;
      final ext = fileName.split('.').last.toLowerCase();
      DioMediaType? mediaType;
      if (ext == 'png') {
        mediaType = DioMediaType('image', 'png');
      } else if (ext == 'webp') {
        mediaType = DioMediaType('image', 'webp');
      } else if (ext == 'jpg' || ext == 'jpeg') {
        mediaType = DioMediaType('image', 'jpeg');
      }

      map['cover_image'] = await MultipartFile.fromFile(
        imagePath,
        filename: fileName,
        contentType: mediaType,
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
