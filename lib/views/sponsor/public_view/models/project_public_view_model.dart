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
  });

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
    );
  }
}
