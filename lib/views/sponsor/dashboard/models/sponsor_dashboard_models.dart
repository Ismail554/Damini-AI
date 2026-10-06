import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';

class SponsorUserProfile {
  final int? id;
  final String email;
  final String role;
  final String firstName;
  final String lastName;
  final String? profilePhoto;
  final String totalRaised;
  final String activeInvestors;
  final String? sponsorType;
  final String? verificationStatus;
  final int projectsCount;
  final int requestsCount;

  const SponsorUserProfile({
    this.id,
    this.email = '',
    this.role = 'SPONSOR',
    required this.firstName,
    required this.lastName,
    this.profilePhoto,
    required this.totalRaised,
    required this.activeInvestors,
    this.sponsorType,
    this.verificationStatus,
    this.projectsCount = 0,
    this.requestsCount = 0,
  });

  String get fullName {
    final first = firstName.trim();
    final last = lastName.trim();

    String capitalize(String s) =>
        s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}';

    final capFirst = capitalize(first);
    final capLast = capitalize(last);

    if (capFirst.isNotEmpty && capLast.isNotEmpty) return '$capFirst $capLast';
    if (capFirst.isNotEmpty) return capFirst;
    if (capLast.isNotEmpty) return capLast;
    return 'Member';
  }

  factory SponsorUserProfile.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final id = data['id'] is int
        ? data['id'] as int
        : int.tryParse(data['id']?.toString() ?? '');
    final email = data['email']?.toString() ?? '';
    final role = data['role']?.toString() ?? 'SPONSOR';

    final profile = data['profile'] is Map
        ? Map<String, dynamic>.from(data['profile'] as Map)
        : const <String, dynamic>{};

    final firstName = data['first_name']?.toString() ??
        profile['first_name']?.toString() ??
        '';
    final lastName = data['last_name']?.toString() ??
        profile['last_name']?.toString() ??
        '';

    final rawPhoto = profile['profile_photo']?.toString() ??
        data['profile_photo']?.toString() ??
        data['profile_image']?.toString() ??
        data['avatar']?.toString();

    String? profilePhoto;
    if (rawPhoto != null && rawPhoto != 'null' && rawPhoto.isNotEmpty) {
      if (rawPhoto.startsWith('http://') || rawPhoto.startsWith('https://')) {
        profilePhoto = rawPhoto;
      } else {
        final base = ApiEndpoints.baseUrl.endsWith('/')
            ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
            : ApiEndpoints.baseUrl;
        final path = rawPhoto.startsWith('/') ? rawPhoto : '/$rawPhoto';
        profilePhoto = '$base$path';
      }
    }

    final sponsorType = profile['sponsor_type']?.toString();
    final verificationStatus = profile['verification_status']?.toString();

    // Nested stats object
    final stats = data['stats'] is Map ? data['stats'] as Map : const {};

    // stats.funded for "Total Raised"
    final rawFunded = stats['funded'] ??
        stats['total_funded'] ??
        stats['total_raised'] ??
        stats['raised'] ??
        0;
    final totalRaised = _formatCurrency(rawFunded);

    final rawProjects = stats['projects'] is num
        ? (stats['projects'] as num).toInt()
        : int.tryParse(stats['projects']?.toString() ?? '0') ?? 0;

    final rawRequests = stats['requests'] is num
        ? (stats['requests'] as num).toInt()
        : int.tryParse(stats['requests']?.toString() ?? '0') ?? 0;

    // stats.requests or stats.projects or active_investors for "Active Investors"
    final rawInvestors = stats['active_investors'] ??
        stats['investors'] ??
        stats['requests'] ??
        stats['projects'] ??
        0;
    final activeInvestors = rawInvestors.toString();

    return SponsorUserProfile(
      id: id,
      email: email,
      role: role,
      firstName: firstName,
      lastName: lastName,
      profilePhoto: profilePhoto,
      totalRaised: totalRaised,
      activeInvestors: activeInvestors,
      sponsorType: sponsorType,
      verificationStatus: verificationStatus,
      projectsCount: rawProjects,
      requestsCount: rawRequests,
    );
  }

  List<SponsorDashboardMetric> toMetrics() {
    return [
      SponsorDashboardMetric(
        label: "Total Raised",
        value: totalRaised,
        icon: Icons.monetization_on_outlined,
      ),
      SponsorDashboardMetric(
        label: "Active Investors",
        value: activeInvestors,
        icon: Icons.people_outline_rounded,
      ),
    ];
  }
}

class SponsorDashboardMetric {
  final String label;
  final String value;
  final IconData icon;

  const SponsorDashboardMetric({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class SponsorActiveProjectData {
  final String id;
  final String title;
  final String description;
  final String badgeText;
  final String raisedAmount;
  final String goalAmount;
  final double progress;
  final String? imageUrl;
  final String? status;
  final String? category;
  final DateTime? createdAt;

  const SponsorActiveProjectData({
    required this.id,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.raisedAmount,
    required this.goalAmount,
    required this.progress,
    this.imageUrl,
    this.status,
    this.category,
    this.createdAt,
  });

  factory SponsorActiveProjectData.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final title = json['title']?.toString() ?? 'Untitled Project';
    final description = json['description']?.toString() ??
        json['short_description']?.toString() ??
        json['business_description']?.toString() ??
        '';

    // Status: convert to badgeText
    final rawStatus = json['status']?.toString() ?? 'Funding Active';
    final badgeText = _formatStatusBadge(rawStatus);

    // raised_amount & funding_goal calculation
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

    return SponsorActiveProjectData(
      id: id,
      title: title,
      description: description,
      badgeText: badgeText,
      raisedAmount: raisedAmount,
      goalAmount: goalAmount,
      progress: progress,
      imageUrl: imageUrl,
      status: rawStatus,
      category: category,
      createdAt: createdAt,
    );
  }
}

class SponsorCollaborationRequestPreview {
  final String id;
  final String? userId;
  final String name;
  final String subtitle;
  final String avatarUrl;
  final DateTime? createdAt;

  const SponsorCollaborationRequestPreview({
    required this.id,
    this.userId,
    required this.name,
    required this.subtitle,
    required this.avatarUrl,
    this.createdAt,
  });

  factory SponsorCollaborationRequestPreview.fromJson(
      Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final investor = json['investor'] is Map
        ? Map<String, dynamic>.from(json['investor'] as Map)
        : const <String, dynamic>{};
    final userId = investor['id']?.toString() ??
        investor['user_id']?.toString() ??
        json['investor_id']?.toString();
    final name = investor['name']?.toString() ?? 'Investor';

    final project = json['project'] is Map
        ? Map<String, dynamic>.from(json['project'] as Map)
        : const <String, dynamic>{};
    final projectTitle = project['title']?.toString() ?? 'Project';
    final subtitle = 'Interested in $projectTitle';

    final rawPhoto = investor['photo']?.toString();
    String avatarUrl =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop';
    if (rawPhoto != null && rawPhoto != 'null' && rawPhoto.isNotEmpty) {
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

    final createdAtStr = json['created_at']?.toString();
    final createdAt =
        createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;

    return SponsorCollaborationRequestPreview(
      id: id,
      userId: userId,
      name: name,
      subtitle: subtitle,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
    );
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
  final num? number = num.tryParse(value.toString().replaceAll(RegExp(r'[^0-9.]'), ''));
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
  final parsed = double.tryParse(value.toString().replaceAll(RegExp(r'[^0-9.]'), ''));
  return parsed ?? 0.0;
}

String _formatStatusBadge(String status) {
  final clean = status.trim().toUpperCase();
  if (clean == 'ACTIVE' || clean == 'FUNDING_ACTIVE') return 'Funding Active';
  if (clean == 'COMPLETED') return 'Completed';
  if (clean == 'DRAFT') return 'Draft';
  if (clean == 'TERMINATED') return 'Terminated';
  if (status.isEmpty) return 'Funding Active';
  return status.split(RegExp(r'[_\s]+')).map((w) {
    if (w.isEmpty) return '';
    return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
  }).join(' ');
}
