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
  final String lastEdited;

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
    required this.lastEdited,
  });

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
      'lastEdited': lastEdited,
    };
  }

  factory ProjectDraftModel.fromMap(Map<String, dynamic> map) {
    return ProjectDraftModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      shortDesc: map['shortDesc'] ?? '',
      fullDesc: map['fullDesc'] ?? '',
      minInvestment: map['minInvestment'] ?? '',
      fundingGoal: map['fundingGoal'] ?? '5000000',
      targetRoi: map['targetRoi'] ?? '18',
      industry: map['industry'],
      country: map['country'],
      fundingStage: map['fundingStage'] ?? 'Seed',
      timeline: map['timeline'] ?? '36 months',
      status: map['status'] ?? '',
      milestones: map['milestones'] ?? '',
      useOfFunds: map['useOfFunds'] ?? '',
      sponsorInvestment: map['sponsorInvestment'] ?? '',
      minContribution: map['minContribution'] ?? '',
      expectedRoi: map['expectedRoi'] ?? '',
      monthlyRevenue: map['monthlyRevenue'] ?? '',
      holdPeriod: map['holdPeriod'] ?? '',
      timelineOps: map['timelineOps'] ?? '',
      teamMembers: map['teamMembers'] ?? '',
      ndaAgreement: map['ndaAgreement'] ?? '',
      lastEdited: map['lastEdited'] ?? 'Just now',
    );
  }

  String toJson() => json.encode(toMap());

  factory ProjectDraftModel.fromJson(String source) =>
      ProjectDraftModel.fromMap(json.decode(source));

  static List<ProjectDraftModel> mockDrafts() {
    return const [
      ProjectDraftModel(
        id: 'draft_1',
        title: 'Urban Logistics Hub',
        shortDesc: 'Next-gen automated fulfillment center in downtown LA',
        fullDesc:
            'Strategic logistics center focusing on last-mile electric delivery automation.',
        minInvestment: '5000',
        fundingGoal: '3500000',
        targetRoi: '16',
        industry: 'Real Estate',
        country: 'United States',
        fundingStage: 'Seed',
        timeline: '24 months',
        lastEdited: 'Last edited 2 days ago',
      ),
    ];
  }
}
