import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class FarmerProfileController extends ChangeNotifier {
  final KrishiRepository repository;

  FarmerProfileController(this.repository);

  FarmerProfile get farmer => repository.currentFarmer;
}
