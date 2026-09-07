import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class OrderChatController extends ChangeNotifier {
  final KrishiRepository repository;
  final MarketplaceOrder order;

  final messageController = TextEditingController();

  OrderChatController(this.repository, this.order);

  UserRole get currentRole => repository.currentRole;
  List<ChatMessage> get messages => repository.chatMessages.where((m) => m.orderId == order.id).toList();

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      repository.sendChatMessage(order.id, messageController.text);
      messageController.clear();
      notifyListeners();
    }
  }

  void close() => repository.closeChat();
}
