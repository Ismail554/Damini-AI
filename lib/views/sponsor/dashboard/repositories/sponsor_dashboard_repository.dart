import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sponsor_dashboard_models.dart';

final sponsorDashboardRepositoryProvider = Provider<SponsorDashboardRepository>((ref) {
  return SponsorDashboardRepository();
});

class SponsorDashboardRepository {
  Future<List<SponsorDashboardMetric>> fetchMetrics() async {
    return const [
      SponsorDashboardMetric(
        label: "Total Raised",
        value: "\$1.00M",
        icon: Icons.monetization_on_outlined,
      ),
      SponsorDashboardMetric(
        label: "Active Investors",
        value: "3",
        icon: Icons.people_outline_rounded,
      ),
    ];
  }

  Future<SponsorActiveProjectData> fetchActiveProject() async {
    return const SponsorActiveProjectData(
      id: "project_downtown_hub",
      title: "Downtown Tech Hub",
      description:
          "A premium tech incubation hub offering modern workspace, labs, and strategic funding.",
      badgeText: "Funding Active",
      raisedAmount: "\$1.00M",
      goalAmount: "\$5.00M",
      progress: 0.20,
      imageUrl:
          "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=600&auto=format&fit=crop",
    );
  }

  Future<List<SponsorCollaborationRequestPreview>> fetchCollaborationRequests() async {
    return const [
      SponsorCollaborationRequestPreview(
        id: "req_sarah_jenkins",
        name: "Sarah Jenkins",
        subtitle: "Interested in EcoTech Solar Farm",
        avatarUrl:
            "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop",
      ),
    ];
  }
}
