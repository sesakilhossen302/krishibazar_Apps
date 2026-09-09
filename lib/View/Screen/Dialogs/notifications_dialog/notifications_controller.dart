import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class NotificationsController extends ChangeNotifier {
  final KrishiRepository repository;

  NotificationsController(this.repository);

  List<NotificationItem> get notifications => repository.notifications;
  bool get isLoading => repository.isNotificationsLoading;

  Future<void> refresh() => repository.fetchNotificationsFromBackend();
  void markAsRead(String id) => repository.markNotificationAsRead(id);
  void markAllAsRead() => repository.markAllNotificationsAsRead();
  void delete(String id) => repository.deleteNotification(id);
  void close() => repository.closeNotifications();
}

