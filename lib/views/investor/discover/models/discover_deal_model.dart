import '../../../../core/constants/api_endpoints.dart';

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
  final double fundedPercent;
  final int daysLeft;
  final bool isTrending;
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
    this.fundedPercent = 0.75,
    this.daysLeft = 15,
    this.isTrending = false,
    required this.createdAt,
  });

  factory DiscoverDealItem.fromJson(Map<String, dynamic> json) {
    final rawImage = json['cover_image']?.toString() ??
        json['image']?.toString() ??
        json['imageUrl']?.toString() ??
        json['image_url']?.toString();

    String imageUrl =
        "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop";
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

    final rawGoal = json['funding_goal'] ??
        json['target_funding'] ??
        json['target_raise'] ??
        json['goal'] ??
        1000000;
    final raiseVal = _parseNumber(rawGoal);
    final goalStr = _formatCurrency(rawGoal);

    final rawRaised = _parseNumber(
      json['raised_amount'] ?? json['current_funding'] ?? json['funded'] ?? 0,
    );
    final double percent =
        raiseVal > 0 ? (rawRaised / raiseVal).clamp(0.0, 1.0) : 0.75;

    final rawMin =
        json['min_investment'] ?? json['min_ticket'] ?? json['minimum'] ?? 1000;
    final minInvStr = _formatCurrency(rawMin);

    final rawRoi =
        json['target_irr'] ?? json['target_roi'] ?? json['roi'] ?? '~ 18%';
    final roiVal = _parseNumber(rawRoi);

    final rawDays = json['days_left'] is int
        ? json['days_left'] as int
        : int.tryParse(json['days_left']?.toString() ?? '') ?? 15;

    final createdAtStr = json['created_at']?.toString();
    final createdAt = createdAtStr != null
        ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
        : DateTime.now();

    final isTrendingVal = json['is_trending'] == true || percent >= 0.7;

    return DiscoverDealItem(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? 'Investment Opportunity',
      location: json['location']?.toString() ?? 'Global',
      category: json['category']?.toString() ??
          json['industry']?.toString() ??
          'Tech',
      imageUrl: imageUrl,
      targetRaise: goalStr,
      minInvestment: minInvStr,
      targetRoi: rawRoi.toString().startsWith('~') ? rawRoi.toString() : '~ $rawRoi',
      roiValue: roiVal > 0 ? roiVal : 18.0,
      raiseValue: raiseVal > 0 ? raiseVal : 1000000.0,
      fundedPercent: percent,
      daysLeft: rawDays,
      isTrending: isTrendingVal,
      createdAt: createdAt,
    );
  }

  static String _formatCurrency(dynamic value) {
    if (value == null) return '\$0.00';
    if (value is String) {
      final str = value.trim();
      if (str.startsWith('\$') || str.endsWith('M') || str.endsWith('K')) {
        return str;
      }
    }
    final num? number =
        num.tryParse(value.toString().replaceAll(RegExp(r'[^0-9.]'), ''));
    if (number == null || number == 0) return '\$0.00';

    if (number >= 1000000) {
      final formatted = (number / 1000000).toStringAsFixed(1);
      return '\$${formatted}M';
    }
    if (number >= 1000) {
      final formatted = (number / 1000).toStringAsFixed(0);
      return '\$${formatted}K';
    }
    return '\$${number.toStringAsFixed(0)}';
  }

  static double _parseNumber(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    final parsed =
        double.tryParse(value.toString().replaceAll(RegExp(r'[^0-9.]'), ''));
    return parsed ?? 0.0;
  }
}
