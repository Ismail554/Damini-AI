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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    String timeStr =
        json['time_ago']?.toString() ?? json['time']?.toString() ?? '';
    if (timeStr.isEmpty && json['created_at'] != null) {
      final dt = DateTime.tryParse(json['created_at'].toString())?.toLocal();
      if (dt != null) {
        final diff = DateTime.now().difference(dt);
        if (diff.inMinutes < 60) {
          timeStr = '${diff.inMinutes}m ago';
        } else if (diff.inHours < 24) {
          timeStr = '${diff.inHours}h ago';
        } else if (diff.inDays < 7) {
          timeStr = '${diff.inDays}d ago';
        } else {
          timeStr = '${dt.month}/${dt.day}';
        }
      }
    }

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ??
          json['message']?.toString() ??
          json['body']?.toString() ??
          '',
      timeAgo: timeStr.isNotEmpty ? timeStr : 'Just now',
      isUnread: json['is_unread'] == true ||
          json['is_read'] == false ||
          json['unread'] == true,
      route: json['route']?.toString() ?? json['target_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time_ago': timeAgo,
      'is_unread': isUnread,
      'route': route,
    };
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
