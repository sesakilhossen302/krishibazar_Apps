import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class BuyerOrdersController extends ChangeNotifier {
  final KrishiRepository repository;

  BuyerOrdersController(this.repository);

  List<MarketplaceOrder> get myOrders {
    return repository.orders.where((o) => o.buyerId == repository.currentBuyer.id).toList();
  }

  void openDetail(MarketplaceOrder order) => repository.openOrderDetail(order);
}
