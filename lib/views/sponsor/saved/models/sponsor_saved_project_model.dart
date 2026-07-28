class SponsorSavedProjectModel {
  final String id;
  final String title;
  final String location;
  final String category;
  final String imageUrl;
  final String targetRaise;
  final String minInvestmentAmt;
  final String targetRoi;
  final bool isSaved;

  const SponsorSavedProjectModel({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.imageUrl,
    required this.targetRaise,
    required this.minInvestmentAmt,
    required this.targetRoi,
    this.isSaved = true,
  });

  static List<SponsorSavedProjectModel> mockList() {
    return const [
      SponsorSavedProjectModel(
        id: "p1",
        title: "Downtown Tech Hub",
        location: "United States",
        category: "Real Estate",
        imageUrl:
            "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=400&auto=format&fit=crop",
        targetRaise: "\$5.0M",
        minInvestmentAmt: "\$1000",
        targetRoi: "18%",
      ),
      SponsorSavedProjectModel(
        id: "p2",
        title: "AI Logistics Platform",
        location: "United Kingdom",
        category: "Tech",
        imageUrl:
            "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=400&auto=format&fit=crop",
        targetRaise: "\$1.2M",
        minInvestmentAmt: "\$1000",
        targetRoi: "25%",
      ),
      SponsorSavedProjectModel(
        id: "p3",
        title: "EcoTech Solar Farm",
        location: "Australia",
        category: "Energy",
        imageUrl:
            "https://images.unsplash.com/photo-1509391365360-2e959784a276?q=80&w=400&auto=format&fit=crop",
        targetRaise: "\$2.5M",
        minInvestmentAmt: "\$1000",
        targetRoi: "12%",
      ),
    ];
  }
}
