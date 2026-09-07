import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class RatingReviewController extends ChangeNotifier {
  final KrishiRepository repository;
  final MarketplaceOrder order;

  int overallRating = 5;
  int qualityRating = 5;
  int quantityRating = 5;
  int communicationRating = 5;
  int paymentRating = 5;

  final commentController = TextEditingController();

  RatingReviewController(this.repository, this.order);

  void setOverallRating(int val) {
    overallRating = val;
    notifyListeners();
  }

  void setQualityRating(int val) {
    qualityRating = val;
    notifyListeners();
  }

  void setQuantityRating(int val) {
    quantityRating = val;
    notifyListeners();
  }

  void setCommunicationRating(int val) {
    communicationRating = val;
    notifyListeners();
  }

  void setPaymentRating(int val) {
    paymentRating = val;
    notifyListeners();
  }

  void submit() {
    repository.closeRatingDialog();
  }

  void close() {
    repository.closeRatingDialog();
  }
}
