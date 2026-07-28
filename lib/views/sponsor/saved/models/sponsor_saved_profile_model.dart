class SponsorSavedProfileModel {
  final String id;
  final String name;
  final String title;
  final String company;
  final String avatarUrl;
  final String location;
  final String role;
  final bool isSaved;

  const SponsorSavedProfileModel({
    required this.id,
    required this.name,
    required this.title,
    required this.company,
    required this.avatarUrl,
    required this.location,
    required this.role,
    this.isSaved = true,
  });

  static List<SponsorSavedProfileModel> mockList() {
    return const [
      SponsorSavedProfileModel(
        id: "pr1",
        name: "Sarah Jenkins",
        title: "Angel Investor",
        company: "Vanguard Investments",
        avatarUrl:
            "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop",
        location: "San Francisco, CA",
        role: "Investor",
      ),
      SponsorSavedProfileModel(
        id: "pr2",
        name: "Marcus Vance",
        title: "Venture Partner",
        company: "Apex Tech Ventures",
        avatarUrl:
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop",
        location: "Austin, TX",
        role: "Investor",
      ),
    ];
  }
}
