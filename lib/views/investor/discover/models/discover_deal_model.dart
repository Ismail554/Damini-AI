class DiscoverDealItem {
  final String id;
  final String title;
  final String location;
  final String category;
  final String imageUrl;
  final String targetRaise;
  final String minInvestment;
  final String targetRoi;
  final double roiValue;
  final double raiseValue;
  final DateTime createdAt;

  const DiscoverDealItem({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.imageUrl,
    required this.targetRaise,
    required this.minInvestment,
    required this.targetRoi,
    required this.roiValue,
    required this.raiseValue,
    required this.createdAt,
  });
}
