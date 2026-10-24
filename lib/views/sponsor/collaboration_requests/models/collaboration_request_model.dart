import '../../../../core/constants/api_endpoints.dart';

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

  // Additional backend metadata & deal pipeline
  final int? projectId;
  final int? investorId;
  final String status;
  final String committedAmount;
  final String currency;
  final DateTime? roadmapSentAt;
  final bool ndaSigned;
  final String ndaDigitalSignature;
  final String? ndaSignatureImage;
  final DateTime? createdAt;

  const CollaborationRequestModel({
    required this.id,
    required this.investorName,
    required this.investorType,
    required this.avatarUrl,
    this.badgeText,
    this.isApprovedBadge = false,
    required this.projectName,
    required this.proposedBudget,
    this.committedAmount = '\$0.00',
    this.currency = 'USD',
    this.roadmapSentAt,
    this.proposalText = '',
    this.isHistory = false,
    this.confirmedDate,
    this.projectStatusText,
    this.hasFundReceivedButton = false,
    this.projectId,
    this.investorId,
    this.status = 'PENDING',
    this.ndaSigned = false,
    this.ndaDigitalSignature = '',
    this.ndaSignatureImage,
    this.createdAt,
  });

  bool get isInterested => status == 'INTERESTED' || status == 'PENDING';
  bool get isAgreedToProceed =>
      status == 'AGREED_TO_PROCEED' || status == 'APPROVED' || status == 'ACCEPTED';
  bool get isRoadmapSent => status == 'ROADMAP_SENT';
  bool get isClosedOffPlatform =>
      status == 'CLOSED_OFF_PLATFORM' || status == 'CONFIRMED' || status == 'RECEIVED';
  bool get isDeclined =>
      status == 'DECLINED' || status == 'REJECTED' || status == 'WITHDRAWN';

  CollaborationRequestModel copyWith({
    String? id,
    String? investorName,
    String? investorType,
    String? avatarUrl,
    String? badgeText,
    bool? isApprovedBadge,
    String? projectName,
    String? proposedBudget,
    String? committedAmount,
    String? currency,
    DateTime? roadmapSentAt,
    String? proposalText,
    bool? isHistory,
    String? confirmedDate,
    String? projectStatusText,
    bool? hasFundReceivedButton,
    int? projectId,
    int? investorId,
    String? status,
    bool? ndaSigned,
    String? ndaDigitalSignature,
    String? ndaSignatureImage,
    DateTime? createdAt,
  }) {
    return CollaborationRequestModel(
      id: id ?? this.id,
      investorName: investorName ?? this.investorName,
      investorType: investorType ?? this.investorType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      badgeText: badgeText ?? this.badgeText,
      isApprovedBadge: isApprovedBadge ?? this.isApprovedBadge,
      projectName: projectName ?? this.projectName,
      proposedBudget: proposedBudget ?? this.proposedBudget,
      committedAmount: committedAmount ?? this.committedAmount,
      currency: currency ?? this.currency,
      roadmapSentAt: roadmapSentAt ?? this.roadmapSentAt,
      proposalText: proposalText ?? this.proposalText,
      isHistory: isHistory ?? this.isHistory,
      confirmedDate: confirmedDate ?? this.confirmedDate,
      projectStatusText: projectStatusText ?? this.projectStatusText,
      hasFundReceivedButton:
          hasFundReceivedButton ?? this.hasFundReceivedButton,
      projectId: projectId ?? this.projectId,
      investorId: investorId ?? this.investorId,
      status: status ?? this.status,
      ndaSigned: ndaSigned ?? this.ndaSigned,
      ndaDigitalSignature: ndaDigitalSignature ?? this.ndaDigitalSignature,
      ndaSignatureImage: ndaSignatureImage ?? this.ndaSignatureImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CollaborationRequestModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';

    // Project extraction
    final project = json['project'] is Map
        ? Map<String, dynamic>.from(json['project'] as Map)
        : const <String, dynamic>{};
    final projectName = project['title']?.toString() ?? 'Untitled Project';
    final projectId = project['id'] is int
        ? project['id'] as int
        : int.tryParse(project['id']?.toString() ?? '');

    // Investor extraction
    final investor = json['investor'] is Map
        ? Map<String, dynamic>.from(json['investor'] as Map)
        : const <String, dynamic>{};
    final investorName = investor['name']?.toString() ?? 'Investor';
    final investorId = investor['id'] is int
        ? investor['id'] as int
        : int.tryParse(investor['id']?.toString() ?? '');
    final investorType =
        formatInvestorType(investor['investor_type']?.toString());
    final avatarUrl = formatPhoto(investor['photo']?.toString());

    // Budget & proposal
    final rawBudget = json['proposed_budget']?.toString() ?? '';
    final proposedBudget = formatCurrency(rawBudget);
    final rawCommitted =
        json['committed_amount']?.toString() ?? json['proposed_budget']?.toString() ?? '';
    final committedAmount = formatCurrency(rawCommitted);
    final currency = json['currency']?.toString() ?? 'USD';
    final proposalText = json['proposal_text']?.toString() ?? '';

    // Status & NDA
    final status = json['status']?.toString().toUpperCase() ?? 'INTERESTED';
    final ndaSigned = json['nda_signed'] == true;
    final ndaDigitalSignature =
        json['nda_digital_signature']?.toString() ?? '';
    final ndaSignatureImage = json['nda_signature_image']?.toString();

    // Dates
    final createdAtStr = json['created_at']?.toString();
    final createdAt =
        createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;
    final roadmapSentAtStr = json['roadmap_sent_at']?.toString();
    final roadmapSentAt =
        roadmapSentAtStr != null ? DateTime.tryParse(roadmapSentAtStr) : null;

    final isAgreed = status == 'AGREED_TO_PROCEED' ||
        status == 'APPROVED' ||
        status == 'ACCEPTED';
    final isRoadmap = status == 'ROADMAP_SENT';
    final isClosed = status == 'CLOSED_OFF_PLATFORM' ||
        status == 'CONFIRMED' ||
        status == 'RECEIVED';
    final isDeclinedOrWithdrawn = status == 'DECLINED' ||
        status == 'REJECTED' ||
        status == 'WITHDRAWN';

    String? badgeText;
    bool isApprovedBadge = false;
    if (status == 'CLOSED_OFF_PLATFORM') {
      badgeText = 'Closed Off-Platform';
      isApprovedBadge = true;
    } else if (status == 'CONFIRMED' || status == 'RECEIVED') {
      badgeText = 'Received';
      isApprovedBadge = true;
    } else if (status == 'ROADMAP_SENT') {
      badgeText = 'Roadmap Sent';
      isApprovedBadge = true;
    } else if (status == 'AGREED_TO_PROCEED') {
      badgeText = 'Agreed to Proceed';
      isApprovedBadge = true;
    } else if (status == 'APPROVED' || status == 'ACCEPTED') {
      badgeText = 'Approved';
      isApprovedBadge = true;
    } else if (isDeclinedOrWithdrawn) {
      badgeText = status == 'WITHDRAWN' ? 'Withdrawn' : 'Declined';
      isApprovedBadge = false;
    } else if (ndaSigned) {
      badgeText = 'NDA Signed';
      isApprovedBadge = false;
    } else {
      badgeText = status == 'INTERESTED' ? 'Interested' : 'NDA Sign';
      isApprovedBadge = false;
    }

    return CollaborationRequestModel(
      id: id,
      investorName: investorName,
      investorType: investorType,
      avatarUrl: avatarUrl,
      badgeText: badgeText,
      isApprovedBadge: isApprovedBadge,
      projectName: projectName,
      proposedBudget: proposedBudget,
      committedAmount: committedAmount,
      currency: currency,
      roadmapSentAt: roadmapSentAt,
      proposalText: proposalText,
      isHistory: isAgreed || isRoadmap || isClosed,
      confirmedDate: formatConfirmedDate(createdAtStr),
      projectStatusText: isClosed
          ? 'Closed off-platform'
          : (isRoadmap ? 'Roadmap sent' : 'Project in progress'),
      hasFundReceivedButton: isAgreed && !isClosed,
      projectId: projectId,
      investorId: investorId,
      status: status,
      ndaSigned: ndaSigned,
      ndaDigitalSignature: ndaDigitalSignature,
      ndaSignatureImage: ndaSignatureImage,
      createdAt: createdAt,
    );
  }

  // ── Helper Formatting Methods ──────────────────────────────────────────

  static String formatCurrency(dynamic value) {
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
          : inMillions.toStringAsFixed(1);
      return '\$${formatted}M';
    }
    if (number >= 1000) {
      final double inThousands = number / 1000;
      final formatted = inThousands % 1 == 0
          ? inThousands.toInt().toString()
          : inThousands.toStringAsFixed(1);
      return '\$${formatted}K';
    }
    return '\$${number.toStringAsFixed(0)}';
  }

  static String formatInvestorType(String? type) {
    if (type == null || type.isEmpty) return 'Investor';
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

  static String formatPhoto(String? rawPhoto) {
    const defaultPlaceholder =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop';
    if (rawPhoto == null || rawPhoto == 'null' || rawPhoto.isEmpty) {
      return defaultPlaceholder;
    }
    if (rawPhoto.startsWith('http://') || rawPhoto.startsWith('https://')) {
      return rawPhoto;
    }
    final base = ApiEndpoints.baseUrl.endsWith('/')
        ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
        : ApiEndpoints.baseUrl;
    final path = rawPhoto.startsWith('/') ? rawPhoto : '/$rawPhoto';
    return '$base$path';
  }

  static String formatConfirmedDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Confirmed Recently';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return 'Confirmed $dateStr';
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
    return 'Confirmed ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

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
