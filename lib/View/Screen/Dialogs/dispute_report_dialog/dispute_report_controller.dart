import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class DisputeReportController extends ChangeNotifier {
  final KrishiRepository repository;
  final MarketplaceOrder order;

  ProblemType problemType = ProblemType.quantityMismatch;
  final descController = TextEditingController();

  DisputeReportController(this.repository, this.order);

  void setProblemType(ProblemType type) {
    problemType = type;
    notifyListeners();
  }

  void submit() {
    repository.submitDispute(
      order.id,
      problemType,
      descController.text.isEmpty ? 'পণ্য বা ওজনে অসঙ্গতি পাওয়া গেছে' : descController.text,
    );
  }

  void close() => repository.closeDisputeDialog();
}
