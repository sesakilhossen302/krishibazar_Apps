import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class FarmerDemandsController extends ChangeNotifier {
  final KrishiRepository repository;

  FarmerDemandsController(this.repository);

  List<BuyerDemand> get demands => repository.demands;

  void openOffer(BuyerDemand demand) => repository.openOfferDialog(demand);
}
