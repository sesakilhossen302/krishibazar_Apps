import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class FarmerOrdersController extends ChangeNotifier {
  final KrishiRepository repository;

  FarmerOrdersController(this.repository);

  List<MarketplaceOrder> get myOrders {
    return repository.orders.where((o) => o.farmerId == repository.currentFarmer.id).toList();
  }

  void openDetail(MarketplaceOrder order) => repository.openOrderDetail(order);
}
