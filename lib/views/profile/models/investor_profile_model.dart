class InvestorProfileModel {
  final String name;
  final String title;
  final String avatarUrl;
  final String investedAmount;
  final String projectsCount;

  const InvestorProfileModel({
    this.name = "John Doe",
    this.title = "CEO at Acme Corp",
    this.avatarUrl =
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=250&auto=format&fit=crop",
    this.investedAmount = "\$450K",
    this.projectsCount = "3",
  });

  InvestorProfileModel copyWith({
    String? name,
    String? title,
    String? avatarUrl,
    String? investedAmount,
    String? projectsCount,
  }) {
    return InvestorProfileModel(
      name: name ?? this.name,
      title: title ?? this.title,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      investedAmount: investedAmount ?? this.investedAmount,
      projectsCount: projectsCount ?? this.projectsCount,
    );
  }
}
