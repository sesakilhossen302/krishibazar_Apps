import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../DemandOffersScreen/demand_offers_screen.dart';

class BuyerOfferManagementDialog extends StatelessWidget {
  final BuyerDemand demand;

  const BuyerOfferManagementDialog({super.key, required this.demand});

  @override
  Widget build(BuildContext context) {
    return DemandOffersScreen(demand: demand);
  }
}
