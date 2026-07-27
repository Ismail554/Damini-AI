import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications =
      NotificationModel.mockNotifications();

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount =>
      _notifications.where((item) => item.isUnread).length;

  void markAllAsRead() {
    _notifications = _notifications.map((item) {
      return item.copyWith(isUnread: false);
    }).toList();
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index != -1 && _notifications[index].isUnread) {
      _notifications[index] = _notifications[index].copyWith(isUnread: false);
      notifyListeners();
    }
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
