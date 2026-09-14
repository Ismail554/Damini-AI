import 'package:flutter/material.dart';

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
}

class InvestorBannerModel {
  final String title;
  final String subtitle;
  final String tag;
  final List<Color> bgGradient;
  final String actionText;

  const InvestorBannerModel({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.bgGradient,
    required this.actionText,
  });
}
