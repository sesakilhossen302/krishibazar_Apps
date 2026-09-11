import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class FarmerOrdersController extends ChangeNotifier {
  final KrishiRepository repository;

  FarmerOrdersController(this.repository);

  List<MarketplaceOrder> get myOrders {
    final fId = repository.currentFarmer.id.trim();
    final fPhone = repository.currentFarmer.phone.trim();
    if (fId.isEmpty && fPhone.isEmpty) {
      return repository.orders;
    }
    final filtered = repository.orders.where((o) {
      final matchesId = fId.isNotEmpty && (o.farmerId == fId || o.farmerId.contains(fId) || fId.contains(o.farmerId));
      final matchesPhone = fPhone.isNotEmpty && (o.farmerPhone == fPhone || o.farmerPhone.contains(fPhone));
      return matchesId || matchesPhone;
    }).toList();

    return filtered.isNotEmpty ? filtered : repository.orders;
  }

  Future<void> refresh() => repository.fetchOrdersFromBackend(force: true);

  void openDetail(MarketplaceOrder order) => repository.openOrderDetail(order);
}
