import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class BuyerOfferManagementController extends ChangeNotifier {
  final KrishiRepository repository;
  final BuyerDemand demand;

  BuyerOfferManagementController(this.repository, this.demand);

  List<FarmerOffer> get offers => repository.offers.where((o) => o.demandId == demand.id).toList();

  void acceptOffer(String offerId) => repository.acceptOffer(offerId);
  void close() => repository.closeDemandOfferManagement();
}
