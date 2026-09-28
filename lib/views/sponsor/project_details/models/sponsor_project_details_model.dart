import '../../../../core/constants/api_endpoints.dart';

class ProjectDocumentModel {
  final int id;
  final String title;
  final String fileUrl;
  final bool isConfidential;
  final DateTime? createdAt;

  const ProjectDocumentModel({
    required this.id,
    required this.title,
    required this.fileUrl,
    this.isConfidential = false,
    this.createdAt,
  });

  factory ProjectDocumentModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    final title = json['title']?.toString() ?? 'Untitled Document';
    final rawFile =
        json['file']?.toString() ?? json['file_url']?.toString() ?? '';

    String fileUrl = rawFile;
    if (fileUrl.isNotEmpty &&
        !fileUrl.startsWith('http://') &&
        !fileUrl.startsWith('https://')) {
      final base = ApiEndpoints.baseUrl.endsWith('/')
          ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
          : ApiEndpoints.baseUrl;
      final path = fileUrl.startsWith('/') ? fileUrl : '/$fileUrl';
      fileUrl = '$base$path';
    }

    final isConfidential = json['is_confidential'] == true;
    final createdAtStr = json['created_at']?.toString();
    final createdAt =
        createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;

    return ProjectDocumentModel(
      id: id,
      title: title,
      fileUrl: fileUrl,
      isConfidential: isConfidential,
      createdAt: createdAt,
    );
  }
}

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

  factory InvestorContributionModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final investor = json['investor'] is Map ? json['investor'] as Map : json;
    final name = investor['name']?.toString() ??
        json['name']?.toString() ??
        'Investor';
    final type = _formatInvestorType(
      investor['investor_type']?.toString() ?? json['type']?.toString(),
    );
    final rawPhoto = investor['photo']?.toString() ??
        json['avatarUrl']?.toString() ??
        json['photo']?.toString();

    String avatarUrl = '';
    if (rawPhoto != null && rawPhoto.isNotEmpty && rawPhoto != 'null') {
      if (rawPhoto.startsWith('http://') || rawPhoto.startsWith('https://')) {
        avatarUrl = rawPhoto;
      } else {
        final base = ApiEndpoints.baseUrl.endsWith('/')
            ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
            : ApiEndpoints.baseUrl;
        final path = rawPhoto.startsWith('/') ? rawPhoto : '/$rawPhoto';
        avatarUrl = '$base$path';
      }
    }

    final rawBudget = json['proposed_budget'] ?? json['amount'] ?? 0;
    final amount = _formatCurrency(rawBudget);

    final createdAtStr =
        json['created_at']?.toString() ?? json['date']?.toString();
    final date = _formatDate(createdAtStr);

    final status = json['status']?.toString().toUpperCase() ?? '';
    final isFunded = json['is_funded'] == true ||
        status == 'APPROVED' ||
        status == 'RECEIVED' ||
        status == 'CONFIRMED';

    return InvestorContributionModel(
      id: id,
      name: name,
      type: type,
      avatarUrl: avatarUrl,
      amount: amount,
      date: date,
      isFunded: isFunded,
    );
  }
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

  // Additional backend metadata
  final String shortDescription;
  final String businessDescription;
  final String industry;
  final String? category;
  final String minimumInvestment;
  final int timelineMonths;
  final String? coverImageUrl;
  final String? sponsorCompanyName;
  final bool isSponsorVerified;
  final List<ProjectDocumentModel> documents;
  final DateTime? createdAt;

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
    this.shortDescription = '',
    this.businessDescription = '',
    this.industry = '',
    this.category,
    this.minimumInvestment = '\$0.00',
    this.timelineMonths = 24,
    this.coverImageUrl,
    this.sponsorCompanyName,
    this.isSponsorVerified = false,
    this.documents = const [],
    this.createdAt,
  });

  factory SponsorProjectDetailsModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final title = json['title']?.toString() ?? 'Untitled Project';

    final locRaw = json['location']?.toString().trim();
    final countryRaw = json['country']?.toString().trim();
    final location = (locRaw != null && locRaw.isNotEmpty)
        ? locRaw
        : ((countryRaw != null && countryRaw.isNotEmpty)
            ? countryRaw
            : 'Austin, TX');

    final rawStatus = json['status']?.toString() ?? 'ACTIVE';
    final badgeText = _formatStatusBadge(rawStatus);

    final rawGoal = _parseNumber(
      json['funding_goal'] ??
          json['target_funding'] ??
          json['goal_amount'] ??
          0,
    );
    final rawRaised = _parseNumber(
      json['raised_amount'] ??
          json['current_funding'] ??
          json['funded_amount'] ??
          0,
    );

    final double progress = json['progress'] != null
        ? _parseNumber(json['progress']).clamp(0.0, 1.0)
        : (rawGoal > 0 ? (rawRaised / rawGoal).clamp(0.0, 1.0) : 0.0);

    final percentage = '${(progress * 100).toInt()}%';
    final raisedAmount = _formatCurrency(rawRaised);
    final goalAmount = _formatCurrency(rawGoal);
    final remainingAmount = rawGoal > rawRaised
        ? _formatCurrency(rawGoal - rawRaised)
        : '\$0.00';

    final rawRoi = _parseNumber(json['target_roi'] ?? 0);
    final targetRoi = '${rawRoi.toStringAsFixed(1)}%';

    final pendingReviewAmount = _formatCurrency(
      json['pending_review_amount'] ?? json['proposed_budget'] ?? 0,
    );

    // Sponsor info
    final sponsor = json['sponsor'] is Map
        ? Map<String, dynamic>.from(json['sponsor'] as Map)
        : const <String, dynamic>{};
    final sponsorCompanyName = sponsor['legal_company_name']?.toString();
    final isSponsorVerified = sponsor['is_verified'] == true;

    final rawCount = json['investors_count'] ?? sponsor['projects_count'] ?? 0;
    final investorsCount = _parseInt(rawCount);

    // Categories
    String? category;
    if (json['category'] != null) {
      if (json['category'] is Map) {
        category = json['category']['name']?.toString();
      } else {
        category = json['category'].toString();
      }
    } else if (json['categories'] is List &&
        (json['categories'] as List).isNotEmpty) {
      final firstCat = (json['categories'] as List).first;
      if (firstCat is Map) {
        category = firstCat['name']?.toString();
      } else {
        category = firstCat?.toString();
      }
    }

    // Cover image
    final rawCover = json['cover_image']?.toString();
    String? coverImageUrl;
    if (rawCover != null && rawCover.isNotEmpty && rawCover != 'null') {
      if (rawCover.startsWith('http://') || rawCover.startsWith('https://')) {
        coverImageUrl = rawCover;
      } else {
        final base = ApiEndpoints.baseUrl.endsWith('/')
            ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
            : ApiEndpoints.baseUrl;
        final path = rawCover.startsWith('/') ? rawCover : '/$rawCover';
        coverImageUrl = '$base$path';
      }
    }

    // Documents
    final documents = <ProjectDocumentModel>[];
    if (json['documents'] is List) {
      for (final doc in (json['documents'] as List).whereType<Map>()) {
        try {
          documents.add(
            ProjectDocumentModel.fromJson(Map<String, dynamic>.from(doc)),
          );
        } catch (_) {}
      }
    }

    // Contributions / Investors
    final contributions = <InvestorContributionModel>[];
    List rawContribList = [];
    if (json['contributions'] is List) {
      rawContribList = json['contributions'] as List;
    } else if (json['investors'] is List) {
      rawContribList = json['investors'] as List;
    } else if (json['team_members'] is List) {
      rawContribList = json['team_members'] as List;
    }
    for (final c in rawContribList.whereType<Map>()) {
      try {
        contributions.add(
          InvestorContributionModel.fromJson(Map<String, dynamic>.from(c)),
        );
      } catch (_) {}
    }

    final createdAtStr = json['created_at']?.toString();
    final createdAt =
        createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;

    return SponsorProjectDetailsModel(
      id: id,
      title: title,
      location: location,
      badgeText: badgeText,
      raisedAmount: raisedAmount,
      goalAmount: goalAmount,
      percentage: percentage,
      progress: progress,
      remainingAmount: remainingAmount,
      investorsCount: investorsCount > 0 ? investorsCount : contributions.length,
      targetRoi: targetRoi,
      pendingReviewAmount: pendingReviewAmount,
      contributions: contributions,
      shortDescription: json['short_description']?.toString() ?? '',
      businessDescription: json['business_description']?.toString() ?? '',
      industry: json['industry']?.toString() ?? '',
      category: category,
      minimumInvestment: _formatCurrency(json['minimum_investment']),
      timelineMonths: _parseInt(json['timeline_months'] ?? 24),
      coverImageUrl: coverImageUrl,
      sponsorCompanyName: sponsorCompanyName,
      isSponsorVerified: isSponsorVerified,
      documents: documents,
      createdAt: createdAt,
    );
  }

  static SponsorProjectDetailsModel mockData() {
    return const SponsorProjectDetailsModel(
      id: "3",
      title: "Downtown Tech Hub",
      location: "Austin, TX",
      badgeText: "Funding Active",
      raisedAmount: "\$1.00M",
      goalAmount: "\$5.00M",
      percentage: "20%",
      progress: 0.20,
      remainingAmount: "\$4.00M",
      investorsCount: 3,
      targetRoi: "18.0%",
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
      documents: [
        ProjectDocumentModel(
          id: 1,
          title: "Q3 Financial Report",
          fileUrl:
              "https://clubby-andy-irksomely.ngrok-free.dev/media/projects/docs/report.pdf",
          isConfidential: true,
        ),
      ],
    );
  }
}

// ── Formatting Helpers ──────────────────────────────────────────

String _formatCurrency(dynamic value) {
  if (value == null) return '\$0.00';
  if (value is String) {
    final str = value.trim();
    if (str.startsWith('\$') ||
        str.endsWith('M') ||
        str.endsWith('K') ||
        str.endsWith('k')) {
      return str;
    }
  }
  final num? number =
      num.tryParse(value.toString().replaceAll(RegExp(r'[^0-9.]'), ''));
  if (number == null || number == 0) return '\$0.00';

  if (number >= 1000000) {
    final double inMillions = number / 1000000;
    final formatted = inMillions % 1 == 0
        ? inMillions.toInt().toString()
        : inMillions.toStringAsFixed(2);
    return '\$${formatted}M';
  }
  if (number >= 1000) {
    final double inThousands = number / 1000;
    final formatted = inThousands % 1 == 0
        ? inThousands.toInt().toString()
        : inThousands.toStringAsFixed(1);
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

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
}

String _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return 'Recent';
  final dt = DateTime.tryParse(raw);
  if (dt == null) return raw;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

String _formatStatusBadge(String status) {
  final clean = status.trim().toUpperCase();
  if (clean == 'ACTIVE' || clean == 'FUNDING_ACTIVE') return 'Funding Active';
  if (clean == 'COMPLETED') return 'Completed';
  if (clean == 'TERMINATED') return 'Terminated';
  if (clean == 'DRAFT') return 'Draft';
  if (clean.isEmpty) return 'Funding Active';
  return status.split(RegExp(r'[_\s]+')).map((w) {
    if (w.isEmpty) return '';
    return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
  }).join(' ');
}

String _formatInvestorType(String? type) {
  if (type == null || type.isEmpty) return 'Individual Investor';
  final clean = type.trim().toUpperCase();
  if (clean == 'INDIVIDUAL') return 'Individual Investor';
  if (clean == 'VENTURE_CAPITAL' || clean == 'VC') return 'Venture Capital';
  if (clean == 'PRIVATE_EQUITY' || clean == 'PE') return 'Private Equity';
  if (clean == 'ANGEL') return 'Angel Investor';
  return type
      .split(RegExp(r'[_\s]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');
}
