import '../../../../core/constants/api_endpoints.dart';

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

  factory InvestorSavedItemModel.fromJson(Map<String, dynamic> json) {
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
        json['saved_date']?.toString() ??
        json['date']?.toString() ??
        'Feb 22, 2026';

    final investedStr = json['invested']?.toString() ??
        (json['invested_amount'] != null ? "\$${json['invested_amount']}" : "\$250k");

    final valueStr = json['value']?.toString() ??
        json['current_value']?.toString() ??
        "\$288k";

    final roiStr = json['target_roi']?.toString() ??
        json['roi']?.toString() ??
        "+15.0%";

    final double progress = json['funding_progress'] is num
        ? (json['funding_progress'] as num).toDouble()
        : (double.tryParse(json['funding_progress']?.toString() ?? '') ?? 0.5);

    return InvestorSavedItemModel(
      id: json['id']?.toString() ?? json['project_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? json['project_title']?.toString() ?? 'Saved Deal',
      category: json['category']?.toString() ?? 'Real Estate',
      date: dateStr,
      status: json['status']?.toString() ?? 'Active',
      invested: investedStr,
      value: valueStr,
      targetRoi: roiStr,
      fundingProgress: progress,
      imageUrl: imageUrl,
    );
  }
}
