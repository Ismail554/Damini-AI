import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;

  const NotificationState({
    required this.notifications,
    this.isLoading = false,
  });

  int get unreadCount => notifications.where((item) => item.isUnread).length;

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  late final NotificationRepository _repository;

  @override
  NotificationState build() {
    _repository = ref.watch(notificationRepositoryProvider);
    final sub = NotificationService.onForegroundMessage.listen(
      (_) => _loadNotifications(),
    );
    ref.onDispose(sub.cancel);
    _loadNotifications();
    return NotificationState(
      notifications: NotificationModel.mockNotifications(),
      isLoading: true,
    );
  }

  Future<void> _loadNotifications() async {
    try {
      final list = await _repository.fetchNotifications();
      if (list.isNotEmpty) {
        state = state.copyWith(notifications: list, isLoading: false);
      } else {
        state = state.copyWith(
          notifications: NotificationModel.mockNotifications(),
          isLoading: false,
        );
      }
    } catch (_) {
      state = state.copyWith(
        notifications: NotificationModel.mockNotifications(),
        isLoading: false,
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadNotifications();
  }

  void markAllAsRead() {
    state = state.copyWith(
      notifications: state.notifications.map((item) {
        return item.copyWith(isUnread: false);
      }).toList(),
    );
    _repository.markAllAsRead();
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
    _repository.markAsRead(id);
  }

  Future<bool> deleteNotification(String id) async {
    final previous = state.notifications;
    state = state.copyWith(
      notifications:
          state.notifications.where((item) => item.id != id).toList(),
    );
    final success = await _repository.deleteNotification(id);
    if (!success) {
      state = state.copyWith(notifications: previous);
    }
    return success;
  }

  Future<bool> clearAllNotifications() async {
    final previous = state.notifications;
    state = state.copyWith(notifications: const []);
    final success = await _repository.clearAllNotifications();
    if (!success) {
      state = state.copyWith(notifications: previous);
    }
    return success;
  }
}

final notificationProvider =
    NotifierProvider.autoDispose<NotificationNotifier, NotificationState>(
  NotificationNotifier.new,
);
