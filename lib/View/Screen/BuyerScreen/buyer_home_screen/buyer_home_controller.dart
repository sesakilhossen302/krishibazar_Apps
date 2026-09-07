import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class BuyerHomeController extends ChangeNotifier {
  final KrishiRepository repository;

  BuyerHomeController(this.repository);

  BuyerProfile get buyer => repository.currentBuyer;
  List<ProductListing> get products => repository.products;
  List<BuyerDemand> get myDemands =>
      repository.demands.where((d) => d.buyerId == buyer.id).toList();
  List<MarketplaceOrder> get myOrders =>
      repository.orders.where((o) => o.buyerId == buyer.id).toList();

  void openAddDemand() => repository.openAddDemandDialog();
  void selectCategory(ProductCategory cat) {
    repository.setSelectedCategory(cat);
    repository.setBuyerTab(1);
  }

  void goToSearch() => repository.setBuyerTab(1);
  void goToDemands() => repository.setBuyerTab(2);
  void openProductDetail(ProductListing product) => repository.openProductDetail(product);
  void openDemandOffers(BuyerDemand demand) => repository.openDemandOfferManagement(demand);
  void openOrderDetail(MarketplaceOrder order) => repository.openOrderDetail(order);
}
