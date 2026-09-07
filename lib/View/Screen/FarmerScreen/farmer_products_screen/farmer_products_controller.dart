import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class FarmerProductsController extends ChangeNotifier {
  final KrishiRepository repository;

  int _selectedFilterIndex = 0;
  int get selectedFilterIndex => _selectedFilterIndex;

  final List<String> filterOptions = [
    'সকল',
    'পর্যালোচনায় (Pending)',
    'সক্রিয় (Active)',
    'আংশিক বিক্রিত',
    'বিক্রিত (Sold)',
    'মেয়াদোত্তীর্ণ',
  ];

  FarmerProductsController(this.repository);

  void setFilterIndex(int index) {
    _selectedFilterIndex = index;
    notifyListeners();
  }

  List<ProductListing> get allMyProducts {
    return repository.products
        .where((p) => p.farmerId == repository.currentFarmer.id)
        .toList();
  }

  List<ProductListing> get filteredProducts {
    final list = allMyProducts;
    switch (_selectedFilterIndex) {
      case 1: // Pending
        return list.where((p) => p.status == ProductStatus.pending).toList();
      case 2: // Active
        return list.where((p) => p.status == ProductStatus.active).toList();
      case 3: // Partially Sold
        return list.where((p) => p.status == ProductStatus.partiallySold).toList();
      case 4: // Sold
        return list.where((p) => p.status == ProductStatus.sold).toList();
      case 5: // Expired
        return list.where((p) => p.status == ProductStatus.expired).toList();
      default:
        return list;
    }
  }

  void openAddProduct() => repository.openAddProductDialog();
  void deleteProduct(String id) => repository.deleteProduct(id);
  void openDetail(ProductListing product) => repository.openProductDetail(product);
}
