import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class OrderDetailController extends ChangeNotifier {
  final KrishiRepository repository;
  final MarketplaceOrder order;

  OrderDetailController(this.repository, this.order);

  UserRole get currentRole => repository.currentRole;

  void openChat() => repository.openChat(order);

  void payDeposit() {
    repository.payDeposit(order.id);
    notifyListeners();
  }

  void setTransportStatus(TransportStatus status) {
    repository.advanceTransport(order.id, status);
    notifyListeners();
  }

  void openDispute() => repository.openDisputeDialog(order);
  void openRating() => repository.openRatingDialog(order);
  void close() => repository.closeOrderDetail();
}

