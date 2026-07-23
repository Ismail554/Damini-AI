class InvestorContributionModel {
  final String id;
  final String name;
  final String type;
  final String avatarUrl;
  final String amount;
  final String date;
  final bool isFunded;

  const InvestorContributionModel({
    required this.id,
    required this.name,
    required this.type,
    required this.avatarUrl,
    required this.amount,
    required this.date,
    this.isFunded = true,
  });
}

class SponsorProjectDetailsModel {
  final String id;
  final String title;
  final String location;
  final String badgeText;
  final String raisedAmount;
  final String goalAmount;
  final String percentage;
  final double progress;
  final String remainingAmount;
  final int investorsCount;
  final String targetRoi;
  final String pendingReviewAmount;
  final List<InvestorContributionModel> contributions;

  const SponsorProjectDetailsModel({
    required this.id,
    required this.title,
    required this.location,
    required this.badgeText,
    required this.raisedAmount,
    required this.goalAmount,
    required this.percentage,
    required this.progress,
    required this.remainingAmount,
    required this.investorsCount,
    required this.targetRoi,
    required this.pendingReviewAmount,
    required this.contributions,
  });

  static SponsorProjectDetailsModel mockData() {
    return const SponsorProjectDetailsModel(
      id: "project_1",
      title: "Downtown Tech Hub",
      location: "Austin, TX, United States",
      badgeText: "Funding Active",
      raisedAmount: "\$1.00M",
      goalAmount: "\$5.00M",
      percentage: "20%",
      progress: 0.20,
      remainingAmount: "\$4.00M",
      investorsCount: 3,
      targetRoi: "18%",
      pendingReviewAmount: "\$200k",
      contributions: [
        InvestorContributionModel(
          id: "inv_1",
          name: "Venture Partners LLC",
          type: "Venture Capital",
          avatarUrl:
              "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150&auto=format&fit=crop",
          amount: "\$600k",
          date: "Mar 12, 2026",
          isFunded: true,
        ),
        InvestorContributionModel(
          id: "inv_2",
          name: "Horizon Capital",
          type: "Private Equity",
          avatarUrl:
              "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150&auto=format&fit=crop",
          amount: "\$400k",
          date: "Mar 18, 2026",
          isFunded: true,
        ),
        InvestorContributionModel(
          id: "inv_3",
          name: "Sarah Jenkins",
          type: "Angel Investor",
          avatarUrl:
              "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop",
          amount: "\$200k",
          date: "Apr 02, 2026",
          isFunded: true,
        ),
      ],
    );
  }
}
