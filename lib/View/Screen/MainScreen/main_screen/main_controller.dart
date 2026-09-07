import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class MainController extends ChangeNotifier {
  final KrishiRepository repository;

  MainController(this.repository);

  void onTabSelected(int index) {
    switch (repository.currentRole) {
      case UserRole.farmer:
        repository.setFarmerTab(index);
        break;
      case UserRole.buyer:
        repository.setBuyerTab(index);
        break;
    }
    notifyListeners();
  }
}
