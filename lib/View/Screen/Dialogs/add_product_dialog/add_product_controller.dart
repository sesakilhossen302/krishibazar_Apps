import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class AddProductController extends ChangeNotifier {
  final KrishiRepository repository;

  final titleController = TextEditingController();
  final quantityController = TextEditingController();
  final expectedPriceController = TextEditingController();
  final minPriceController = TextEditingController();
  final locationController = TextEditingController();
  final harvestDateController = TextEditingController();
  final deliveryDateController = TextEditingController();
  final descController = TextEditingController();

  ProductCategory category = ProductCategory.vegetables;
  ProductUnit unit = ProductUnit.kg;
  QualityGrade qualityGrade = QualityGrade.gradeA;
  bool isLiveVideoEnabled = false;

  AddProductController(this.repository) {
    locationController.text = 'গোদাগাড়ী, রাজশাহী';
    harvestDateController.text = '১০ সেপ্টেম্বর ২০২৪';
    deliveryDateController.text = '১৫ সেপ্টেম্বর ২০২৪';
  }

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

  void toggleLiveVideo(bool val) {
    isLiveVideoEnabled = val;
    notifyListeners();
  }

  void submit() {
    repository.submitProduct(
      title: titleController.text.isEmpty ? 'দেশি লাল টমেটো' : titleController.text,
      category: category,
      quantity: double.tryParse(quantityController.text) ?? 500.0,
      unit: unit,
      expectedPrice: double.tryParse(expectedPriceController.text) ?? 40.0,
      minPrice: double.tryParse(minPriceController.text) ?? 35.0,
      location: locationController.text.isEmpty ? 'গোদাগাড়ী, রাজশাহী' : locationController.text,
      availableDate: deliveryDateController.text.isNotEmpty ? deliveryDateController.text : '১৫ সেপ্টেম্বর ২০২৪',
      harvestDate: harvestDateController.text.isNotEmpty ? harvestDateController.text : '১০ সেপ্টেম্বর ২০২৪',
      qualityGrade: qualityGrade,
      description: descController.text,
    );
  }

  void close() => repository.closeAddProductDialog();
}

