import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class BuyerDemandsController extends ChangeNotifier {
  final KrishiRepository repository;

  BuyerDemandsController(this.repository);

  List<BuyerDemand> get myDemands {
    return repository.demands.where((d) => d.buyerId == repository.currentBuyer.id).toList();
  }

  void openAddDemand() => repository.openAddDemandDialog();
  void openOffers(BuyerDemand demand) => repository.openDemandOfferManagement(demand);
}
