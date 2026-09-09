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

  FarmerProductsController(this.repository) {
    repository.fetchProductsFromBackend();
  }

  void setFilterIndex(int index) {
    _selectedFilterIndex = index;
    notifyListeners();
  }

  List<ProductListing> get allMyProducts {
    final myId = repository.currentFarmer.id;
    final myName = repository.currentFarmer.name.trim().toLowerCase();

    return repository.products.where((p) {
      if (p.farmerId.isNotEmpty && p.farmerId == myId) return true;
      if (myName.isNotEmpty && p.farmerName.trim().toLowerCase() == myName) return true;
      // If products belong to current farmer in DB or created locally
      return false;
    }).toList();
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

  Future<void> refreshFromBackend() => repository.fetchProductsFromBackend();
  void openAddProduct() => repository.openAddProductDialog();
  void deleteProduct(String id) => repository.deleteProduct(id);
  void openDetail(ProductListing product) => repository.openProductDetail(product);
}

