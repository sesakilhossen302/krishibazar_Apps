import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class WeightVerificationController extends ChangeNotifier {
  final KrishiRepository repository;
  final MarketplaceOrder order;

  final actualWeightController = TextEditingController();
  final notesController = TextEditingController();
  QualityGrade qualityGrade = QualityGrade.gradeA;

  WeightVerificationController(this.repository, this.order) {
    actualWeightController.text = order.quantity.toStringAsFixed(0);
    notesController.text = 'ওজন সম্পূর্ণ সঠিক, গ্রেড A মান নিশ্চিত করা হয়েছে';
  }

  void setQualityGrade(QualityGrade grade) {
    qualityGrade = grade;
    notifyListeners();
  }

  void submit() {
    repository.submitWeightVerification(
      order.id,
      double.tryParse(actualWeightController.text) ?? order.quantity,
      qualityGrade,
      notesController.text,
    );
  }

  void close() => repository.closeVerificationDialog();
}
