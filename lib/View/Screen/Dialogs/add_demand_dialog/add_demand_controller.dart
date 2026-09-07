import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class AddDemandController extends ChangeNotifier {
  final KrishiRepository repository;

  final titleController = TextEditingController();
  final quantityController = TextEditingController();
  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();
  final locationController = TextEditingController(text: 'কাওরান বাজার, ঢাকা');
  final requiredDateController = TextEditingController(text: '২৫ সেপ্টেম্বর ২০২৪');
  final noteController = TextEditingController();

  ProductCategory category = ProductCategory.vegetables;
  ProductUnit unit = ProductUnit.kg;
  QualityGrade qualityGrade = QualityGrade.gradeA;

  AddDemandController(this.repository);

  void setCategory(ProductCategory cat) {
    category = cat;
    notifyListeners();
  }

  void setUnit(ProductUnit u) {
    unit = u;
    notifyListeners();
  }

  void setQualityGrade(QualityGrade grade) {
    qualityGrade = grade;
    notifyListeners();
  }

  void submit() {
    repository.submitDemand(
      titleController.text.isEmpty ? 'প্রয়োজনীয় কৃষি পণ্য' : titleController.text,
      category,
      double.tryParse(quantityController.text) ?? 500.0,
      unit,
      locationController.text.isEmpty ? 'কাওরান বাজার, ঢাকা' : locationController.text,
      requiredDateController.text.isEmpty ? '২৫ সেপ্টেম্বর ২০২৪' : requiredDateController.text,
      double.tryParse(minPriceController.text) ?? 40.0,
      double.tryParse(maxPriceController.text) ?? 50.0,
      qualityGrade,
      noteController.text,
    );
  }

  void close() => repository.closeAddDemandDialog();
}
