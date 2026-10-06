import '../../../../core/constants/api_endpoints.dart';

enum SponsorProjectStatus { active, completed, terminated }

class SponsorProjectModel {
  final String id;
  final String title;
  final String description;
  final String badgeText;
  final String raisedAmount;
  final String goalAmount;
  final double progress;
  final String? imageUrl;
  final SponsorProjectStatus status;
  final String? category;
  final DateTime? createdAt;
  final String? terminationReason;
  final DateTime? terminatedAt;

  const SponsorProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.raisedAmount,
    required this.goalAmount,
    required this.progress,
    this.imageUrl,
    required this.status,
    this.category,
    this.createdAt,
    this.terminationReason,
    this.terminatedAt,
  });

  factory SponsorProjectModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final title = json['title']?.toString() ?? 'Untitled Project';
    final description = json['short_description']?.toString() ??
        json['description']?.toString() ??
        json['business_description']?.toString() ??
        '';

    final rawStatus = json['status']?.toString().toUpperCase() ?? 'ACTIVE';
    final SponsorProjectStatus status;
    final String badgeText;
    if (rawStatus.contains('COMPLETED') || rawStatus.contains('FUNDED')) {
      status = SponsorProjectStatus.completed;
      badgeText = 'Completed';
    } else if (rawStatus.contains('TERMINATED') ||
        rawStatus.contains('CANCELLED') ||
        rawStatus.contains('REJECTED')) {
      status = SponsorProjectStatus.terminated;
      badgeText = 'Terminated';
    } else {
      status = SponsorProjectStatus.active;
      badgeText = 'Funding Active';
    }

    final rawRaised = _parseNumber(
      json['raised_amount'] ??
          json['current_funding'] ??
          json['funded_amount'] ??
          json['raised'] ??
          0,
    );
    final rawGoal = _parseNumber(
      json['funding_goal'] ??
          json['target_funding'] ??
          json['goal_amount'] ??
          json['goal'] ??
          0,
    );

    final double progress = json['progress'] != null
        ? _parseNumber(json['progress']).clamp(0.0, 1.0)
        : (rawGoal > 0 ? (rawRaised / rawGoal).clamp(0.0, 1.0) : 0.0);
    final raisedAmount = _formatCurrency(rawRaised);
    final goalAmount = _formatCurrency(rawGoal);

    // Image URL resolution
    final rawImage = json['cover_image']?.toString() ??
        json['image']?.toString() ??
        json['imageUrl']?.toString() ??
        json['image_url']?.toString();
    String? imageUrl;
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

    // Category / Industry
    String? category;
    if (json['industry'] != null && json['industry'].toString().isNotEmpty) {
      category = json['industry'].toString();
    } else if (json['category'] != null) {
      if (json['category'] is Map) {
        category = json['category']['name']?.toString() ??
            json['category']['title']?.toString();
      } else {
        category = json['category'].toString();
      }
    } else if (json['category_name'] != null) {
      category = json['category_name'].toString();
    }

    final createdAtStr = json['created_at']?.toString();
    final createdAt =
        createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;
    final terminationReason = json['termination_reason']?.toString();
    final terminatedAtStr = json['terminated_at']?.toString();
    final terminatedAt =
        terminatedAtStr != null ? DateTime.tryParse(terminatedAtStr) : null;

    return SponsorProjectModel(
      id: id,
      title: title,
      description: description,
      badgeText: badgeText,
      raisedAmount: raisedAmount,
      goalAmount: goalAmount,
      progress: progress,
      imageUrl: imageUrl,
      status: status,
      category: category,
      createdAt: createdAt,
      terminationReason: terminationReason,
      terminatedAt: terminatedAt,
    );
  }

  static List<SponsorProjectModel> mockActiveList() {
    const defaultSolarImage =
        'https://images.unsplash.com/photo-1509391365360-2e959784a276?q=80&w=800&auto=format&fit=crop';

    return const [
      SponsorProjectModel(
        id: '1',
        title: 'Downtown Tech Hub',
        description:
            'A state-of-the-art technology hub located in the heart of downtown Austin.',
        badgeText: 'Funding Active',
        raisedAmount: '1.2M',
        goalAmount: '5.0M',
        progress: 0.24,
        imageUrl: defaultSolarImage,
        status: SponsorProjectStatus.active,
        category: 'Technology',
      ),
      SponsorProjectModel(
        id: '2',
        title: 'Downtown Tech Hub',
        description:
            'A state-of-the-art technology hub located in the heart of downtown Austin.',
        badgeText: 'Funding Active',
        raisedAmount: '1.2M',
        goalAmount: '5.0M',
        progress: 0.24,
        imageUrl: defaultSolarImage,
        status: SponsorProjectStatus.active,
        category: 'Commercial',
      ),
      SponsorProjectModel(
        id: '3',
        title: 'Downtown Tech Hub',
        description:
            'A state-of-the-art technology hub located in the heart of downtown Austin.',
        badgeText: 'Funding Active',
        raisedAmount: '1.2M',
        goalAmount: '5.0M',
        progress: 0.24,
        imageUrl: defaultSolarImage,
        status: SponsorProjectStatus.active,
        category: 'Technology',
      ),
    ];
  }

  static List<SponsorProjectModel> mockCompletedList() {
    return const [
      SponsorProjectModel(
        id: '4',
        title: 'EcoTech Solar Farm Phase 1',
        description:
            'Successfully funded 50MW solar panel installation project in West Texas.',
        badgeText: 'Completed',
        raisedAmount: '8.5M',
        goalAmount: '8.5M',
        progress: 1.0,
        imageUrl:
            'https://images.unsplash.com/photo-1466611653911-95081537e5b7?q=80&w=800&auto=format&fit=crop',
        status: SponsorProjectStatus.completed,
        category: 'Clean Energy',
      ),
      SponsorProjectModel(
        id: '5',
        title: 'Green Grid Storage Initiative',
        description:
            'High-capacity energy storage battery grid project fully capitalized.',
        badgeText: 'Completed',
        raisedAmount: '3.0M',
        goalAmount: '3.0M',
        progress: 1.0,
        imageUrl:
            'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?q=80&w=800&auto=format&fit=crop',
        status: SponsorProjectStatus.completed,
        category: 'Infrastructure',
      ),
    ];
  }

  static List<SponsorProjectModel> mockTerminatedList() {
    return const [
      SponsorProjectModel(
        id: '6',
        title: 'Old Wind Turbine Retrofit',
        description:
            'Project terminated due to municipal permit regulations and land reassignment.',
        badgeText: 'Terminated',
        raisedAmount: '400K',
        goalAmount: '2.0M',
        progress: 0.20,
        imageUrl:
            'https://images.unsplash.com/photo-1548337138-e87d889cc369?q=80&w=800&auto=format&fit=crop',
        status: SponsorProjectStatus.terminated,
        category: 'Energy',
      ),
    ];
  }
}

// ── Formatting Helpers ──────────────────────────────────────────

String _formatCurrency(dynamic value) {
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
    final formatted = (number / 1000000).toStringAsFixed(2);
    return '\$${formatted}M';
  }
  if (number >= 1000) {
    final formatted = (number / 1000).toStringAsFixed(1);
    return '\$${formatted}K';
  }
  return '\$${number.toStringAsFixed(2)}';
}

double _parseNumber(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  final parsed =
      double.tryParse(value.toString().replaceAll(RegExp(r'[^0-9.]'), ''));
  return parsed ?? 0.0;
}
