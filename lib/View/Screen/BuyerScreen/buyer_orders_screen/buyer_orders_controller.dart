import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class BuyerOrdersController extends ChangeNotifier {
  final KrishiRepository repository;

  BuyerOrdersController(this.repository);

  List<MarketplaceOrder> get myOrders {
    final bId = repository.currentBuyer.id.trim();
    final bPhone = repository.currentBuyer.phone.trim();
    if (bId.isEmpty && bPhone.isEmpty) {
      return repository.orders;
    }
    final filtered = repository.orders.where((o) {
      final matchesId = bId.isNotEmpty && (o.buyerId == bId || o.buyerId.contains(bId) || bId.contains(o.buyerId));
      final matchesPhone = bPhone.isNotEmpty && (o.buyerPhone == bPhone || o.buyerPhone.contains(bPhone));
      return matchesId || matchesPhone;
    }).toList();

    return filtered.isNotEmpty ? filtered : repository.orders;
  }

  Future<void> refresh() => repository.fetchOrdersFromBackend(force: true);

  void openDetail(MarketplaceOrder order) => repository.openOrderDetail(order);
}
