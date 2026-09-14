import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';

class NotificationState {
  final List<NotificationModel> notifications;

  const NotificationState({
    required this.notifications,
  });

  int get unreadCount => notifications.where((item) => item.isUnread).length;

  NotificationState copyWith({
    List<NotificationModel>? notifications,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    return NotificationState(
      notifications: NotificationModel.mockNotifications(),
    );
  }

  void markAllAsRead() {
    state = state.copyWith(
      notifications: state.notifications.map((item) {
        return item.copyWith(isUnread: false);
      }).toList(),
    );
  }

  void markAsRead(String id) {
    state = state.copyWith(
      notifications: state.notifications.map((item) {
        if (item.id == id && item.isUnread) {
          return item.copyWith(isUnread: false);
        }
        return item;
      }).toList(),
    );
  }

  void deleteNotification(String id) {
    state = state.copyWith(
      notifications: state.notifications.where((item) => item.id != id).toList(),
    );
  }
}

final notificationProvider =
    NotifierProvider.autoDispose<NotificationNotifier, NotificationState>(
  NotificationNotifier.new,
);
