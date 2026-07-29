class InvestorSavedItemModel {
  final String id;
  final String title;
  final String category;
  final String date;
  final String status;
  final String invested;
  final String value;
  final String targetRoi;
  final double fundingProgress;
  final String imageUrl;

  const InvestorSavedItemModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.status,
    required this.invested,
    required this.value,
    required this.targetRoi,
    required this.fundingProgress,
    required this.imageUrl,
  });

  bool get isActive => status.toLowerCase() == 'active';
}
