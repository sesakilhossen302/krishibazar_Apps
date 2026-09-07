import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class ProductDetailController extends ChangeNotifier {
  final KrishiRepository repository;
  final ProductListing product;

  int _selectedMediaIndex = 0;
  int get selectedMediaIndex => _selectedMediaIndex;

  bool _isPlayingVideo = false;
  bool get isPlayingVideo => _isPlayingVideo;

  ProductDetailController(this.repository, this.product);

  UserRole get currentRole => repository.currentRole;

  void setMediaIndex(int index) {
    _selectedMediaIndex = index;
    _isPlayingVideo = false;
    notifyListeners();
  }

  void togglePlayVideo() {
    _isPlayingVideo = !_isPlayingVideo;
    notifyListeners();
  }

  void close() {
    repository.closeProductDetail();
  }

  void deleteProduct() {
    repository.deleteProduct(product.id);
    repository.closeProductDetail();
  }

  void sendOffer() {
    repository.closeProductDetail();
    // Open offer or order flow if applicable
  }
}
