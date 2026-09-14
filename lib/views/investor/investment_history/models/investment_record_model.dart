class InvestmentRecordModel {
  final String id;
  final String title;
  final String category;
  final String sponsor;
  final String date;
  final String status;
  final String invested;
  final String currentValue;
  final String roi;
  final String imageUrl;

  const InvestmentRecordModel({
    required this.id,
    required this.title,
    required this.category,
    required this.sponsor,
    required this.date,
    required this.status,
    required this.invested,
    required this.currentValue,
    required this.roi,
    required this.imageUrl,
  });
}
