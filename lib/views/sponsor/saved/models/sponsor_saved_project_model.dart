import '../../../../core/constants/api_endpoints.dart';

class ProjectCategoryItem {
  final int id;
  final String name;

  const ProjectCategoryItem({
    required this.id,
    required this.name,
  });

  factory ProjectCategoryItem.fromJson(Map<String, dynamic> json) {
    return ProjectCategoryItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class SponsorSavedProjectModel {
  final String id;
  final String title;
  final String location;
  final String country;
  final String shortDescription;
  final List<ProjectCategoryItem> categories;
  final String category;
  final String industry;
  final String status;
  final String fundingGoal;
  final String fundingStage;
  final String raisedAmount;
  final String progress;
  final String minimumInvestment;
  final String targetRoi;
  final String potentialMonthlyRevenue;
  final int? holdPeriodMonths;
  final int? timelineToOperationsMonths;
  final int? timelineMonths;
  final String imageUrl;
  final String sponsor;
  final bool isSaved;
  final DateTime? createdAt;

  // Display fields for UI compatibility
  final String targetRaise;
  final String minInvestmentAmt;

  const SponsorSavedProjectModel({
    required this.id,
    required this.title,
    required this.location,
    this.country = '',
    this.shortDescription = '',
    this.categories = const [],
    required this.category,
    this.industry = '',
    this.status = 'DRAFT',
    this.fundingGoal = '0',
    this.fundingStage = '',
    this.raisedAmount = '0',
    this.progress = '0',
    this.minimumInvestment = '0',
    required this.targetRoi,
    this.potentialMonthlyRevenue = '',
    this.holdPeriodMonths,
    this.timelineToOperationsMonths,
    this.timelineMonths,
    required this.imageUrl,
    this.sponsor = '',
    this.isSaved = true,
    this.createdAt,
    required this.targetRaise,
    required this.minInvestmentAmt,
  });

  factory SponsorSavedProjectModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final title = json['title']?.toString() ?? 'Untitled Project';
    final locationRaw = json['location']?.toString() ?? '';
    final country = json['country']?.toString() ?? '';

    // Combine location & country nicely
    String displayLocation = locationRaw;
    if (locationRaw.isEmpty) {
      displayLocation = country.isNotEmpty ? country : 'Location not specified';
    } else if (country.isNotEmpty &&
        !locationRaw.toLowerCase().contains(country.toLowerCase())) {
      displayLocation = '$locationRaw, $country';
    }

    final shortDescription = json['short_description']?.toString() ?? '';

    // Categories list parsing
    final categories = <ProjectCategoryItem>[];
    if (json['categories'] is List) {
      for (final cat in (json['categories'] as List).whereType<Map>()) {
        try {
          categories.add(
            ProjectCategoryItem.fromJson(Map<String, dynamic>.from(cat)),
          );
        } catch (_) {}
      }
    }

    final industry = json['industry']?.toString() ?? '';
    String category = json['category']?.toString() ?? '';
    if (category.isEmpty && categories.isNotEmpty) {
      category = categories.first.name;
    }
    if (category.isEmpty && industry.isNotEmpty) {
      category = industry;
    }
    if (category.isEmpty) {
      category = 'General';
    }

    final status = json['status']?.toString() ?? 'DRAFT';
    final fundingGoal = json['funding_goal']?.toString() ?? '0';
    final fundingStage = json['funding_stage']?.toString() ?? '';
    final raisedAmount = json['raised_amount']?.toString() ?? '0';
    final progress = json['progress']?.toString() ?? '0';
    final minimumInvestment = json['minimum_investment']?.toString() ?? '0';

    // Target ROI handling (can be empty string in backend response)
    final rawRoi = json['target_roi']?.toString().trim() ?? '';
    final String targetRoi;
    if (rawRoi.isEmpty) {
      targetRoi = '—';
    } else if (rawRoi.endsWith('%')) {
      targetRoi = rawRoi;
    } else {
      targetRoi = '$rawRoi%';
    }

    final potentialMonthlyRevenue =
        json['potential_monthly_revenue']?.toString() ?? '';
    final holdPeriodMonths = _tryParseInt(json['hold_period_months']);
    final timelineToOperationsMonths =
        _tryParseInt(json['timeline_to_operations_months']);
    final timelineMonths = _tryParseInt(json['timeline_months']);

    // Cover Image resolution
    final rawImage = json['cover_image']?.toString();
    const fallbackImage =
        'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop';
    String imageUrl = fallbackImage;
    if (rawImage != null &&
        rawImage.isNotEmpty &&
        rawImage != 'null' &&
        rawImage != 'string') {
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

    final sponsor = json['sponsor']?.toString() ?? '';

    // is_saved handling (can be bool or string)
    final rawSaved = json['is_saved'];
    final bool isSaved;
    if (rawSaved is bool) {
      isSaved = rawSaved;
    } else if (rawSaved != null) {
      final s = rawSaved.toString().toLowerCase();
      isSaved = s != 'false' && s != '0';
    } else {
      isSaved = true;
    }

    final createdAtStr = json['created_at']?.toString();
    final createdAt =
        createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;

    final targetRaise = _formatCurrency(fundingGoal);
    final minInvestmentAmt = _formatCurrency(minimumInvestment);

    return SponsorSavedProjectModel(
      id: id,
      title: title,
      location: displayLocation,
      country: country,
      shortDescription: shortDescription,
      categories: categories,
      category: category,
      industry: industry,
      status: status,
      fundingGoal: fundingGoal,
      fundingStage: fundingStage,
      raisedAmount: raisedAmount,
      progress: progress,
      minimumInvestment: minimumInvestment,
      targetRoi: targetRoi,
      potentialMonthlyRevenue: potentialMonthlyRevenue,
      holdPeriodMonths: holdPeriodMonths,
      timelineToOperationsMonths: timelineToOperationsMonths,
      timelineMonths: timelineMonths,
      imageUrl: imageUrl,
      sponsor: sponsor,
      isSaved: isSaved,
      createdAt: createdAt,
      targetRaise: targetRaise,
      minInvestmentAmt: minInvestmentAmt,
    );
  }

  static List<SponsorSavedProjectModel> mockList() {
    return const [
      SponsorSavedProjectModel(
        id: "p1",
        title: "Downtown Tech Hub",
        location: "United States",
        country: "United States",
        category: "Real Estate",
        imageUrl:
            "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=400&auto=format&fit=crop",
        targetRaise: "\$5.0M",
        minInvestmentAmt: "\$1,000",
        targetRoi: "18%",
        status: "ACTIVE",
      ),
      SponsorSavedProjectModel(
        id: "p2",
        title: "AI Logistics Platform",
        location: "United Kingdom",
        country: "United Kingdom",
        category: "Tech",
        imageUrl:
            "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=400&auto=format&fit=crop",
        targetRaise: "\$1.2M",
        minInvestmentAmt: "\$1,000",
        targetRoi: "25%",
        status: "ACTIVE",
      ),
      SponsorSavedProjectModel(
        id: "p3",
        title: "EcoTech Solar Farm",
        location: "Australia",
        country: "Australia",
        category: "Energy",
        imageUrl:
            "https://images.unsplash.com/photo-1785990137771-1cb6d4a63637?q=80&w=1632&auto=format&fit=crop",
        targetRaise: "\$2.5M",
        minInvestmentAmt: "\$1,000",
        targetRoi: "12%",
        status: "ACTIVE",
      ),
    ];
  }
}

class SavedProjectsResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<SponsorSavedProjectModel> results;

  const SavedProjectsResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory SavedProjectsResponse.fromJson(Map<String, dynamic> json) {
    final count = int.tryParse(json['count']?.toString() ?? '0') ?? 0;
    final next = json['next']?.toString();
    final previous = json['previous']?.toString();

    final resultsList = <SponsorSavedProjectModel>[];
    if (json['results'] is List) {
      for (final item in (json['results'] as List).whereType<Map>()) {
        try {
          resultsList.add(
            SponsorSavedProjectModel.fromJson(Map<String, dynamic>.from(item)),
          );
        } catch (_) {
          continue;
        }
      }
    }

    return SavedProjectsResponse(
      count: count > 0 ? count : resultsList.length,
      next: next,
      previous: previous,
      results: resultsList,
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────

int? _tryParseInt(dynamic val) {
  if (val == null) return null;
  if (val is int) return val;
  if (val is num) return val.toInt();
  return int.tryParse(val.toString());
}

String _formatCurrency(dynamic value) {
  if (value == null) return '\$0.00';
  if (value is String) {
    final str = value.trim();
    if (str.startsWith('\$') ||
        str.endsWith('M') ||
        str.endsWith('K') ||
        str.endsWith('B')) {
      return str;
    }
  }
  final num? number =
      num.tryParse(value.toString().replaceAll(RegExp(r'[^0-9.]'), ''));
  if (number == null || number == 0) return '\$0.00';

  if (number >= 1000000000) {
    final formatted = (number / 1000000000).toStringAsFixed(1);
    return '\$${formatted}B';
  }
  if (number >= 1000000) {
    final formatted = (number / 1000000).toStringAsFixed(1);
    return '\$${formatted}M';
  }
  if (number >= 1000) {
    final formatted = (number / 1000).toStringAsFixed(1);
    return '\$${formatted}K';
  }
  return '\$${number.toStringAsFixed(0)}';
}
