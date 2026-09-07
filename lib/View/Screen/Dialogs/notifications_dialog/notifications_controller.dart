import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class NotificationsController extends ChangeNotifier {
  final KrishiRepository repository;

  NotificationsController(this.repository);

  List<NotificationItem> get notifications => repository.notifications;

  void close() => repository.closeNotifications();
}
