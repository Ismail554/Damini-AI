class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final bool isUnread;
  final String? route;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.isUnread = false,
    this.route,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? description,
    String? timeAgo,
    bool? isUnread,
    String? route,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timeAgo: timeAgo ?? this.timeAgo,
      isUnread: isUnread ?? this.isUnread,
      route: route ?? this.route,
    );
  }

  static List<NotificationModel> mockNotifications() {
    return const [
      NotificationModel(
        id: 'notif_1',
        title: 'New Collaboration Request',
        description:
            'Venture Partners LLC requested to collaborate on Downtown Tech Hub.',
        timeAgo: '10m ago',
        isUnread: true,
        route: '/collaboration-requests',
      ),
      NotificationModel(
        id: 'notif_2',
        title: 'New Message',
        description: 'Sarah Jenkins: "I\'ve reviewed the financials and..."',
        timeAgo: '1h ago',
        isUnread: true,
        route: '/group-chat',
      ),
      NotificationModel(
        id: 'notif_3',
        title: 'NDA Approved',
        description: 'Acme Corp approved your NDA for EcoTech Solar Farm.',
        timeAgo: '2h ago',
        isUnread: false,
        route: '/nda',
      ),
      NotificationModel(
        id: 'notif_4',
        title: 'Profile Verified',
        description: 'Your sponsor profile has been successfully verified.',
        timeAgo: '1d ago',
        isUnread: false,
      ),
    ];
  }
}
