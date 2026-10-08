import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';

class InvestorUserProfile {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? profilePhoto;
  final bool pushNotificationsEnabled;
  final String subscriptionTier;
  final String? verificationStatus;

  const InvestorUserProfile({
    this.id,
    required this.firstName,
    required this.lastName,
    this.email = '',
    this.role = 'INVESTOR',
    this.profilePhoto,
    this.pushNotificationsEnabled = true,
    this.subscriptionTier = 'FREE',
    this.verificationStatus,
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
    return 'Investor';
  }

  factory InvestorUserProfile.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final id = data['id'] is int
        ? data['id'] as int
        : int.tryParse(data['id']?.toString() ?? '');
    final email = data['email']?.toString() ?? '';
    final role = data['role']?.toString() ?? 'INVESTOR';

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

    final verificationStatus = profile['verification_status']?.toString();
    final notifications = data['push_notifications_enabled'] == true;
    final subTier = data['subscription_tier']?.toString() ?? 'FREE';

    return InvestorUserProfile(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: role,
      profilePhoto: profilePhoto,
      pushNotificationsEnabled: notifications,
      subscriptionTier: subTier,
      verificationStatus: verificationStatus,
    );
  }
}

class DashboardCategoryModel {
  final String label;
  final IconData icon;

  const DashboardCategoryModel({
    required this.label,
    required this.icon,
  });
}

class FeaturedOpportunityModel {
  final String title;
  final String location;
  final String category;
  final String imageUrl;
  final String targetRaise;
  final String targetRoi;

  const FeaturedOpportunityModel({
    required this.title,
    required this.location,
    required this.category,
    required this.imageUrl,
    required this.targetRaise,
    required this.targetRoi,
  });

  factory FeaturedOpportunityModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['cover_image']?.toString() ??
        json['image']?.toString() ??
        json['imageUrl']?.toString() ??
        json['image_url']?.toString();

    String imageUrl =
        "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=400&auto=format&fit=crop";
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
    final goalStr = _formatCurrency(rawGoal);

    final rawRoi =
        json['target_irr'] ?? json['target_roi'] ?? json['roi'] ?? '~ 18%';

    return FeaturedOpportunityModel(
      title: json['title']?.toString() ?? 'Untitled Project',
      location: json['location']?.toString() ?? 'Global',
      category: json['category']?.toString() ?? 'Tech',
      imageUrl: imageUrl,
      targetRaise: goalStr,
      targetRoi: rawRoi.toString(),
    );
  }
}

class TrendingProjectModel {
  final String title;
  final String location;
  final String category;
  final String imageUrl;
  final double fundedPercent;
  final String minInvestment;
  final int daysLeft;

  const TrendingProjectModel({
    required this.title,
    required this.location,
    required this.category,
    required this.imageUrl,
    required this.fundedPercent,
    required this.minInvestment,
    required this.daysLeft,
  });

  factory TrendingProjectModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['cover_image']?.toString() ??
        json['image']?.toString() ??
        json['imageUrl']?.toString() ??
        json['image_url']?.toString();

    String imageUrl =
        "https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?q=80&w=400&auto=format&fit=crop";
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

    final rawRaised = _parseNumber(
      json['raised_amount'] ?? json['current_funding'] ?? json['funded'] ?? 0,
    );
    final rawGoal = _parseNumber(
      json['funding_goal'] ?? json['target_funding'] ?? json['goal'] ?? 0,
    );
    final double percent =
        rawGoal > 0 ? (rawRaised / rawGoal).clamp(0.0, 1.0) : 0.75;

    final rawMin =
        json['min_investment'] ?? json['min_ticket'] ?? json['minimum'] ?? 10000;
    final minInv = _formatCurrency(rawMin);

    final rawDays = json['days_left'] is int
        ? json['days_left'] as int
        : int.tryParse(json['days_left']?.toString() ?? '') ?? 15;

    return TrendingProjectModel(
      title: json['title']?.toString() ?? 'Trending Opportunity',
      location: json['location']?.toString() ?? 'Global',
      category: json['category']?.toString() ?? 'Tech',
      imageUrl: imageUrl,
      fundedPercent: percent,
      minInvestment: minInv,
      daysLeft: rawDays,
    );
  }
}

class InvestorBannerModel {
  final String id;
  final String title;
  final String location;
  final String targetRaise;
  final String subtitle;
  final String tag;
  final List<Color> bgGradient;
  final String imageUrl;
  final String actionText;
  final String? actionUrl;
  final String? targetProjectId;

  const InvestorBannerModel({
    this.id = '',
    required this.title,
    this.location = 'Global',
    this.targetRaise = 'Target Raise: \$5.0M',
    required this.subtitle,
    required this.tag,
    required this.bgGradient,
    this.imageUrl = 'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=400&auto=format&fit=crop',
    required this.actionText,
    this.actionUrl,
    this.targetProjectId,
  });

  factory InvestorBannerModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image_url'] ?? json['imageUrl'] ?? json['image'];
    String imageUrl =
        "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=400&auto=format&fit=crop";
    if (rawImage != null && rawImage.toString().isNotEmpty) {
      imageUrl = rawImage.toString();
    }

    List<Color> gradient = const [Color(0xFF0F1E2E), Color(0xFF162A3D)];
    final rawGradient = json['bg_gradient'] ?? json['bgGradient'];
    if (rawGradient is List && rawGradient.isNotEmpty) {
      gradient = rawGradient.map((c) {
        if (c is String && c.startsWith('#')) {
          final hex = c.replaceFirst('#', '');
          return Color(int.parse('0xFF$hex'));
        }
        return const Color(0xFF0F1E2E);
      }).toList();
    }

    return InvestorBannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Featured Opportunity',
      location: json['location']?.toString() ?? 'Global',
      targetRaise: json['target_raise']?.toString() ??
          (json['targetRaise']?.toString() ?? 'Target Raise: \$5.0M'),
      subtitle: json['subtitle']?.toString() ?? '',
      tag: json['tag']?.toString() ?? 'Featured',
      bgGradient: gradient,
      imageUrl: imageUrl,
      actionText: json['action_text']?.toString() ??
          (json['actionText']?.toString() ?? 'Explore'),
      actionUrl: json['action_url']?.toString() ?? json['actionUrl']?.toString(),
      targetProjectId: json['target_project_id']?.toString() ??
          json['targetProjectId']?.toString(),
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
  return '\$${number.toStringAsFixed(2)}';
}

double _parseNumber(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  final parsed =
      double.tryParse(value.toString().replaceAll(RegExp(r'[^0-9.]'), ''));
  return parsed ?? 0.0;
}
