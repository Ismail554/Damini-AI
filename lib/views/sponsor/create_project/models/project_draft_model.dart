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
    return ProjectDraftModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      shortDesc: map['shortDesc']?.toString() ?? '',
      fullDesc: map['fullDesc']?.toString() ?? '',
      minInvestment: map['minInvestment']?.toString() ?? '',
      fundingGoal: map['fundingGoal']?.toString() ?? '5000000',
      targetRoi: map['targetRoi']?.toString() ?? '18',
      industry: map['industry'] as String?,
      country: map['country'] as String?,
      location: map['location']?.toString() ?? '',
      fundingStage: map['fundingStage']?.toString() ?? 'Seed',
      timeline: map['timeline']?.toString() ?? '36 months',
      status: map['status']?.toString() ?? '',
      milestones: map['milestones']?.toString() ?? '',
      useOfFunds: map['useOfFunds']?.toString() ?? '',
      sponsorInvestment: map['sponsorInvestment']?.toString() ?? '',
      minContribution: map['minContribution']?.toString() ?? '',
      expectedRoi: map['expectedRoi']?.toString() ?? '',
      monthlyRevenue: map['monthlyRevenue']?.toString() ?? '',
      holdPeriod: map['holdPeriod']?.toString() ?? '',
      timelineOps: map['timelineOps']?.toString() ?? '',
      teamMembers: map['teamMembers']?.toString() ?? '',
      ndaAgreement: map['ndaAgreement']?.toString() ?? '',
      coverImagePath: map['coverImagePath'] as String?,
      lastEditedMs: map['lastEditedMs'] is int
          ? map['lastEditedMs'] as int
          : (int.tryParse(map['lastEditedMs']?.toString() ?? '') ?? 0),
      lastEdited: map['lastEdited'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProjectDraftModel.fromJson(String source) =>
      ProjectDraftModel.fromMap(json.decode(source));
}
