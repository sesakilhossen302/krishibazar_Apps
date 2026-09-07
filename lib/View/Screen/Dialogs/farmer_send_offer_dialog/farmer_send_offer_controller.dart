import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class FarmerSendOfferController extends ChangeNotifier {
  final KrishiRepository repository;
  final BuyerDemand demand;

  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final dateController = TextEditingController();
  final noteController = TextEditingController();

  FarmerSendOfferController(this.repository, this.demand) {
    quantityController.text = demand.requiredQuantity.toStringAsFixed(0);
    priceController.text = demand.minExpectedPrice.toStringAsFixed(0);
    dateController.text = demand.requiredDate;
    noteController.text = 'সম্পূর্ণ খাঁটি ও টাটকা ফসল সরবরাহ করব।';
  }

  void submit() {
    repository.submitOffer(
      demand.id,
      double.tryParse(quantityController.text) ?? demand.requiredQuantity,
      demand.unit,
      double.tryParse(priceController.text) ?? demand.minExpectedPrice,
      demand.qualityGrade,
      dateController.text.isNotEmpty ? dateController.text : 'আগামীকাল সকাল',
      noteController.text,
    );
  }

  void close() => repository.closeOfferDialog();
}

