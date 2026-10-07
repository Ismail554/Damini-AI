import 'dart:convert';

class ProjectDraftModel {
  final String id;
  final String title;
  final String shortDesc;
  final String fullDesc;
  final String minInvestment;
  final String fundingGoal;
  final String targetRoi;
  final String? industry;
  final int? industryId;
  final String? country;
  final String location;
  final String fundingStage;
  final String timeline;
  final String status;
  final String milestones;
  final String useOfFunds;
  final String sponsorInvestment;
  final String minContribution;
  final String expectedRoi;
  final String monthlyRevenue;
  final String holdPeriod;
  final String timelineOps;
  final String teamMembers;
  final String ndaAgreement;
  final String? coverImagePath;
  final int lastEditedMs;
  final String? customLastEdited;

  const ProjectDraftModel({
    required this.id,
    required this.title,
    this.shortDesc = '',
    this.fullDesc = '',
    this.minInvestment = '',
    this.fundingGoal = '5000000',
    this.targetRoi = '18',
    this.industry,
    this.industryId,
    this.country,
    this.location = '',
    this.fundingStage = 'Seed',
    this.timeline = '36 months',
    this.status = '',
    this.milestones = '',
    this.useOfFunds = '',
    this.sponsorInvestment = '',
    this.minContribution = '',
    this.expectedRoi = '',
    this.monthlyRevenue = '',
    this.holdPeriod = '',
    this.timelineOps = '',
    this.teamMembers = '',
    this.ndaAgreement = '',
    this.coverImagePath,
    this.lastEditedMs = 0,
    String? lastEdited,
  }) : customLastEdited = lastEdited;

  /// Human-readable relative time string computed dynamically
  String get lastEdited {
    if (customLastEdited != null && customLastEdited!.isNotEmpty) {
      return customLastEdited!;
    }
    if (lastEditedMs <= 0) return 'Last edited just now';
    final now = DateTime.now();
    final edited = DateTime.fromMillisecondsSinceEpoch(lastEditedMs);
    final diff = now.difference(edited);
    if (diff.inMinutes < 1) return 'Last edited just now';
    if (diff.inMinutes < 60) return 'Last edited ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Last edited ${diff.inHours}h ago';
    if (diff.inDays < 7) return 'Last edited ${diff.inDays}d ago';
    return 'Last edited ${edited.month}/${edited.day}/${edited.year}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'shortDesc': shortDesc,
      'fullDesc': fullDesc,
      'minInvestment': minInvestment,
      'fundingGoal': fundingGoal,
      'targetRoi': targetRoi,
      'industry': industry,
      'industryId': industryId,
      'country': country,
      'location': location,
      'fundingStage': fundingStage,
      'timeline': timeline,
      'status': status,
      'milestones': milestones,
      'useOfFunds': useOfFunds,
      'sponsorInvestment': sponsorInvestment,
      'minContribution': minContribution,
      'expectedRoi': expectedRoi,
      'monthlyRevenue': monthlyRevenue,
      'holdPeriod': holdPeriod,
      'timelineOps': timelineOps,
      'teamMembers': teamMembers,
      'ndaAgreement': ndaAgreement,
      'coverImagePath': coverImagePath,
      'lastEditedMs': lastEditedMs > 0
          ? lastEditedMs
          : DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory ProjectDraftModel.fromMap(Map<String, dynamic> map) {
    int? parsedIndustryId;
    if (map['industryId'] is int) {
      parsedIndustryId = map['industryId'] as int;
    } else if (map['industry_id'] != null) {
      parsedIndustryId = int.tryParse(map['industry_id'].toString());
    }

    String? parsedTimeline = map['timeline']?.toString();
    if ((parsedTimeline == null || parsedTimeline.isEmpty) &&
        map['timeline_months'] != null) {
      parsedTimeline = "${map['timeline_months']} months";
    }

    String? parsedHoldPeriod = map['holdPeriod']?.toString();
    if ((parsedHoldPeriod == null || parsedHoldPeriod.isEmpty) &&
        map['hold_period_months'] != null) {
      parsedHoldPeriod = "${map['hold_period_months']} months";
    }

    String? parsedTimelineOps = map['timelineOps']?.toString();
    if ((parsedTimelineOps == null || parsedTimelineOps.isEmpty) &&
        map['timeline_to_operations_months'] != null) {
      parsedTimelineOps = "${map['timeline_to_operations_months']} months";
    }

    return ProjectDraftModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      shortDesc: map['shortDesc']?.toString() ??
          map['short_description']?.toString() ??
          '',
      fullDesc: map['fullDesc']?.toString() ??
          map['full_description']?.toString() ??
          map['business_description']?.toString() ??
          '',
      minInvestment: map['minInvestment']?.toString() ??
          map['minimum_investment']?.toString() ??
          '',
      fundingGoal: map['fundingGoal']?.toString() ??
          map['funding_goal']?.toString() ??
          '5000000',
      targetRoi: map['targetRoi']?.toString() ??
          map['target_roi']?.toString() ??
          '18',
      industry: (map['industry'] ?? map['industry_name'])?.toString(),
      industryId: parsedIndustryId,
      country: map['country']?.toString(),
      location: map['location']?.toString() ?? '',
      fundingStage: map['fundingStage']?.toString() ??
          map['funding_stage']?.toString() ??
          'Seed',
      timeline: parsedTimeline ?? '36 months',
      status: map['status']?.toString() ??
          map['current_status']?.toString() ??
          '',
      milestones: map['milestones']?.toString() ??
          map['next_milestones']?.toString() ??
          '',
      useOfFunds: map['useOfFunds']?.toString() ??
          map['use_of_funds']?.toString() ??
          '',
      sponsorInvestment: map['sponsorInvestment']?.toString() ??
          map['skin_in_the_game']?.toString() ??
          '',
      minContribution: map['minContribution']?.toString() ??
          map['minimum_contribution']?.toString() ??
          '',
      expectedRoi: map['expectedRoi']?.toString() ??
          map['expected_roi']?.toString() ??
          '',
      monthlyRevenue: map['monthlyRevenue']?.toString() ??
          map['potential_monthly_revenue']?.toString() ??
          '',
      holdPeriod: parsedHoldPeriod ?? '',
      timelineOps: parsedTimelineOps ?? '',
      teamMembers: map['teamMembers']?.toString() ??
          map['team_members_text']?.toString() ??
          '',
      ndaAgreement: map['ndaAgreement']?.toString() ??
          map['confidentiality_agreement_text']?.toString() ??
          '',
      coverImagePath: map['coverImagePath'] as String?,
      lastEditedMs: map['lastEditedMs'] is int
          ? map['lastEditedMs'] as int
          : (int.tryParse(map['lastEditedMs']?.toString() ?? '') ?? 0),
      lastEdited: (map['lastEdited'] ?? map['last_edited']) as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProjectDraftModel.fromJson(String source) =>
      ProjectDraftModel.fromMap(json.decode(source));
}
