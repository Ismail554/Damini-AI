class CollaborationRequestModel {
  final String id;
  final String investorName;
  final String investorType;
  final String avatarUrl;
  final String? badgeText;
  final bool isApprovedBadge;
  final String projectName;
  final String proposedBudget;
  final String proposalText;
  final bool isHistory;
  final String? confirmedDate;
  final String? projectStatusText;
  final bool hasFundReceivedButton;

  const CollaborationRequestModel({
    required this.id,
    required this.investorName,
    required this.investorType,
    required this.avatarUrl,
    this.badgeText,
    this.isApprovedBadge = false,
    required this.projectName,
    required this.proposedBudget,
    this.proposalText = '',
    this.isHistory = false,
    this.confirmedDate,
    this.projectStatusText,
    this.hasFundReceivedButton = false,
  });

  static List<CollaborationRequestModel> mockPendingList() {
    return const [
      CollaborationRequestModel(
        id: "req_1",
        investorName: "Venture Partners LLC",
        investorType: "Venture Capital",
        avatarUrl:
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150&auto=format&fit=crop",
        badgeText: "NDA Sign",
        isApprovedBadge: false,
        projectName: "Downtown Tech Hub",
        proposedBudget: "\$500k",
        proposalText:
            "\"Interested in acting as lead investor for the seed round. We have extensive experience in commercial real estate tech.\"",
        isHistory: false,
      ),
      CollaborationRequestModel(
        id: "req_2",
        investorName: "Sarah Jenkins",
        investorType: "Angel Investor",
        avatarUrl:
            "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop",
        badgeText: "NDA Sign",
        isApprovedBadge: false,
        projectName: "EcoTech Solar Farm",
        proposedBudget: "\$50k",
        proposalText:
            "\"Looking to diversify my portfolio with sustainable energy projects.\"",
        isHistory: false,
      ),
    ];
  }

  static List<CollaborationRequestModel> mockHistoryList() {
    return const [
      CollaborationRequestModel(
        id: "req_3",
        investorName: "Global Horizons Fund",
        investorType: "Private Equity",
        avatarUrl:
            "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150&auto=format&fit=crop",
        badgeText: "Approved",
        isApprovedBadge: true,
        projectName: "Downtown Tech Hub",
        proposedBudget: "\$1M - \$5M",
        proposalText:
            "\"We are prepared to fund the entire remaining balance pending due diligence.\"",
        isHistory: true,
      ),
    ];
  }

  static List<CollaborationRequestModel> mockConfirmationList() {
    return const [
      CollaborationRequestModel(
        id: "conf_1",
        investorName: "Global Horizons Fund",
        investorType: "Private Equity",
        avatarUrl:
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150&auto=format&fit=crop",
        badgeText: "Received",
        isApprovedBadge: true,
        projectName: "Downtown Tech Hub",
        proposedBudget: "\$5M",
        confirmedDate: "Confirmed Apr 10, 2026",
        projectStatusText: "Project in progress",
        hasFundReceivedButton: false,
      ),
      CollaborationRequestModel(
        id: "conf_2",
        investorName: "Sarah Jenkins",
        investorType: "Private Equity",
        avatarUrl:
            "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150&auto=format&fit=crop",
        badgeText: null,
        isApprovedBadge: false,
        projectName: "Downtown Tech Hub",
        proposedBudget: "\$5M",
        confirmedDate: "Confirmed Apr 10, 2026",
        projectStatusText: "Project in progress",
        hasFundReceivedButton: true,
      ),
    ];
  }
}
