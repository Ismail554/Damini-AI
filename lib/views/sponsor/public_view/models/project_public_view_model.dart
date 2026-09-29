import '../../create_project/models/project_draft_model.dart';

class TeamMemberModel {
  final String name;
  final String role;
  final String initials;
  final String? avatarUrl;

  const TeamMemberModel({
    required this.name,
    required this.role,
    required this.initials,
    this.avatarUrl,
  });
}

class ProjectPublicViewModel {
  final String id;
  final String title;
  final String location;
  final String category;
  final String stage;
  final String targetRaise;
  final String targetRoi;
  final String sponsorName;
  final String sponsorTagline;
  final String? sponsorAvatarUrl;
  final bool isVerifiedSponsor;
  final List<String> imageUrls;
  final String overviewText;
  final String timeline;
  final String teamSize;
  final List<TeamMemberModel> teamMembers;
  final String businessDescription;
  final bool isNdaSigned;
  final String minContribution;
  final String expectedRoi;
  final String monthlyRevenue;
  final String holdPeriod;
  final String timelineToOperations;
  final bool isSaved;

  const ProjectPublicViewModel({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.stage,
    required this.targetRaise,
    required this.targetRoi,
    required this.sponsorName,
    required this.sponsorTagline,
    this.sponsorAvatarUrl,
    this.isVerifiedSponsor = true,
    required this.imageUrls,
    required this.overviewText,
    required this.timeline,
    required this.teamSize,
    required this.teamMembers,
    required this.businessDescription,
    this.isNdaSigned = false,
    this.minContribution = "\$50,000",
    this.expectedRoi = "18%",
    this.monthlyRevenue = "\$18,000",
    this.holdPeriod = "36 months",
    this.timelineToOperations = "6 months",
    this.isSaved = false,
  });

  factory ProjectPublicViewModel.fromDraft(ProjectDraftModel draft) {
    final title = draft.title.trim().isEmpty ? "Untitled Project Preview" : draft.title;
    final category = draft.industry ?? "Technology";
    final country = draft.country ?? "United States";
    final stage = draft.fundingStage.isEmpty ? "Seed" : draft.fundingStage;
    final raise = draft.fundingGoal.isEmpty
        ? "\$5,000,000"
        : (draft.fundingGoal.startsWith('\$') ? draft.fundingGoal : "\$${draft.fundingGoal}");
    final roi = draft.targetRoi.isEmpty
        ? "18%"
        : (draft.targetRoi.endsWith('%') ? draft.targetRoi : "${draft.targetRoi}%");

    final rawTeam = draft.teamMembers.isEmpty ? "Alex Vance, Maria Santos" : draft.teamMembers;
    final teamNames = rawTeam.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final teamList = teamNames.map((name) {
      final parts = name.split(' ');
      final initials = parts.map((p) => p.isNotEmpty ? p[0] : '').take(2).join('').toUpperCase();
      return TeamMemberModel(
        name: name,
        role: "Team Member",
        initials: initials.isEmpty ? "TM" : initials,
      );
    }).toList();

    return ProjectPublicViewModel(
      id: draft.id,
      title: title,
      location: country,
      category: category,
      stage: stage,
      targetRaise: raise,
      targetRoi: roi,
      sponsorName: "Acme Corp",
      sponsorTagline: "Verified Sponsor · Preview Mode",
      imageUrls: const [
        "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1497215728101-856f4ea42174?q=80&w=600&auto=format&fit=crop",
      ],
      overviewText: draft.shortDesc.isEmpty ? "No short description provided." : draft.shortDesc,
      timeline: draft.timeline.isEmpty ? "36 months" : draft.timeline,
      teamSize: "${teamList.length} Member${teamList.length > 1 ? 's' : ''}",
      teamMembers: teamList,
      businessDescription: draft.fullDesc.isEmpty ? "No business description provided." : draft.fullDesc,
      minContribution: draft.minContribution.isEmpty
          ? (draft.minInvestment.isEmpty ? "\$50,000" : "\$${draft.minInvestment}")
          : draft.minContribution,
      expectedRoi: draft.expectedRoi.isEmpty ? roi : draft.expectedRoi,
      monthlyRevenue: draft.monthlyRevenue.isEmpty ? "\$18,000" : draft.monthlyRevenue,
      holdPeriod: draft.holdPeriod.isEmpty ? "36 months" : draft.holdPeriod,
      timelineToOperations: draft.timelineOps.isEmpty ? "6 months" : draft.timelineOps,
    );
  }

  static ProjectPublicViewModel mockData() {
    return const ProjectPublicViewModel(
      id: "pub_1",
      title: "Downtown Tech Hub",
      location: "Austin, TX, United States",
      category: "Real Estate",
      stage: "Seed",
      targetRaise: "\$5,000,000",
      targetRoi: "18%",
      sponsorName: "Acme Corp",
      sponsorTagline: "Verified Sponsor · 3 Projects",
      sponsorAvatarUrl:
          "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop",
      isVerifiedSponsor: true,
      imageUrls: [
        "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1497215728101-856f4ea42174?q=80&w=600&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&w=600&auto=format&fit=crop",
      ],
      overviewText:
          "A state-of-the-art technology hub located in the heart of downtown Austin. The project aims to provide premium collaborative workspaces for growing tech startups and established enterprises.",
      timeline: "24 Months",
      teamSize: "4 Members",
      teamMembers: [
        TeamMemberModel(
          name: "John Anderson",
          role: "CEO & Co-Founder",
          initials: "JA",
        ),
        TeamMemberModel(
          name: "Maria Santos",
          role: "CEO",
          initials: "MS",
        ),
        TeamMemberModel(
          name: "Yusuf Bennani",
          role: "CTO",
          initials: "YB",
        ),
        TeamMemberModel(
          name: "Lina Haddad",
          role: "CFO",
          initials: "LH",
        ),
      ],
      businessDescription:
          "Detailed explanation of the business model, market opportunity, and use of funds. The Austin market has seen a 40% year-over-year increase in demand for premium tech-focused commercial real estate. Our model leverages pre-leasing agreements to secure cash flow prior to completion.",
      isNdaSigned: false,
      minContribution: "\$50,000",
      expectedRoi: "18%",
      monthlyRevenue: "\$18,000",
      holdPeriod: "36 months",
      timelineToOperations: "6 months",
    );
  }
}
