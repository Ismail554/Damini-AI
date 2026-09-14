import 'package:flutter/material.dart';

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

  const SponsorActiveProjectData({
    required this.id,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.raisedAmount,
    required this.goalAmount,
    required this.progress,
    this.imageUrl,
  });
}

class SponsorCollaborationRequestPreview {
  final String id;
  final String name;
  final String subtitle;
  final String avatarUrl;

  const SponsorCollaborationRequestPreview({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.avatarUrl,
  });
}
