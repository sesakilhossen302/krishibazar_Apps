import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class FarmerHomeController extends ChangeNotifier {
  final KrishiRepository repository;

  FarmerHomeController(this.repository);

  FarmerProfile get farmer => repository.currentFarmer;
  List<ProductListing> get myProducts => repository.products.where((p) => p.farmerId == farmer.id).toList();
  List<MarketplaceOrder> get myOrders => repository.orders.where((o) => o.farmerId == farmer.id).toList();
  List<BuyerDemand> get demands => repository.demands;

  void openAddProduct() => repository.openAddProductDialog();
  void goToDemandsTab() => repository.setFarmerTab(2);
  void goToOrdersTab() => repository.setFarmerTab(3);
  void openOffer(BuyerDemand demand) => repository.openOfferDialog(demand);
  void openOrder(MarketplaceOrder order) => repository.openOrderDetail(order);
}
