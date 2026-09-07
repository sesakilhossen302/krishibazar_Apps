import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class BuyerSearchController extends ChangeNotifier {
  final KrishiRepository repository;

  BuyerSearchController(this.repository);

  String get searchQuery => repository.searchQuery;
  ProductCategory? get selectedCategory => repository.selectedCategory;
  String? get selectedDistrict => repository.selectedDistrict;
  bool get onlyVerifiedFarmers => repository.onlyVerifiedFarmers;

  List<ProductListing> get filteredProducts {
    return repository.products.where((p) {
      if (selectedCategory != null && p.category != selectedCategory) {
        return false;
      }
      if (selectedDistrict != null && selectedDistrict!.isNotEmpty) {
        if (!p.farmerDistrict.contains(selectedDistrict!) &&
            !p.location.contains(selectedDistrict!)) {
          return false;
        }
      }
      if (onlyVerifiedFarmers && !p.farmerVerified) {
        return false;
      }
      if (searchQuery.isNotEmpty &&
          !p.title.toLowerCase().contains(searchQuery.toLowerCase()) &&
          !p.farmerDistrict.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  void setSearchQuery(String query) => repository.setSearchQuery(query);
  void setSelectedCategory(ProductCategory? cat) => repository.setSelectedCategory(cat);
  void setSelectedDistrict(String? district) => repository.setSelectedDistrict(district);
  void toggleOnlyVerifiedFarmers() => repository.toggleOnlyVerifiedFarmers();
  void openDetail(ProductListing product) => repository.openProductDetail(product);
}
