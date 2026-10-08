import '../../../../core/constants/api_endpoints.dart';

class InvestmentPortfolioSummary {
  final String totalInvested;
  final String totalCurrentValue;
  final String totalProfitLoss;
  final int activeDealsCount;

  const InvestmentPortfolioSummary({
    this.totalInvested = "\$560,000",
    this.totalCurrentValue = "\$644,200",
    this.totalProfitLoss = "+\$84,200 (+15.0%)",
    this.activeDealsCount = 4,
  });

  factory InvestmentPortfolioSummary.fromJson(Map<String, dynamic> json) {
    final invested = json['total_invested']?.toString() ??
        json['totalInvested']?.toString() ??
        "\$560,000";
    final currentVal = json['total_current_value']?.toString() ??
        json['totalCurrentValue']?.toString() ??
        "\$644,200";
    final profit = json['total_profit_loss']?.toString() ??
        json['totalProfitLoss']?.toString() ??
        json['overall_roi']?.toString() ??
        "+\$84,200 (+15.0%)";
    final count = json['active_deals_count'] is int
        ? json['active_deals_count'] as int
        : (int.tryParse(json['active_investments_count']?.toString() ?? '') ?? 4);

    return InvestmentPortfolioSummary(
      totalInvested: invested,
      totalCurrentValue: currentVal,
      totalProfitLoss: profit,
      activeDealsCount: count,
    );
  }
}

class InvestmentRecordModel {
  final String id;
  final String projectId;
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
    this.projectId = '',
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

  factory InvestmentRecordModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['cover_image']?.toString() ??
        json['image_url']?.toString() ??
        json['image']?.toString() ??
        json['imageUrl']?.toString();

    String imageUrl =
        "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=300&auto=format&fit=crop";
    if (rawImage != null && rawImage != 'null' && rawImage.isNotEmpty) {
      if (rawImage.startsWith('http://') || rawImage.startsWith('https://')) {
        imageUrl = rawImage;
      } else {
        final base = ApiEndpoints.baseUrl.endsWith('/')
            ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
            : ApiEndpoints.baseUrl;
        final path = rawImage.startsWith('/') ? rawImage : '/$rawImage';
        imageUrl = '$base$path';
      }
    }

    final dateStr = json['formatted_date']?.toString() ??
        json['date']?.toString() ??
        json['investment_date']?.toString() ??
        'Mar 14, 2026';

    final investedStr = json['formatted_invested']?.toString() ??
        json['invested']?.toString() ??
        (json['invested_amount'] != null ? "\$${json['invested_amount']}" : "\$250,000");

    final currentValStr = json['formatted_current_value']?.toString() ??
        json['currentValue']?.toString() ??
        json['current_value']?.toString() ??
        "\$288,000";

    final roiStr = json['roi']?.toString() ??
        json['target_roi']?.toString() ??
        "+15.2%";

    return InvestmentRecordModel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: json['project_id']?.toString() ?? json['projectId']?.toString() ?? '',
      title: json['title']?.toString() ?? json['project_title']?.toString() ?? 'Investment Deal',
      category: json['category']?.toString() ?? 'Real Estate',
      sponsor: json['sponsor_name']?.toString() ?? json['sponsor']?.toString() ?? 'Sponsor',
      date: dateStr,
      status: json['status']?.toString() ?? 'Active',
      invested: investedStr,
      currentValue: currentValStr,
      roi: roiStr,
      imageUrl: imageUrl,
    );
  }
}
