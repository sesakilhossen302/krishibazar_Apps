import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class BuyerProfileController extends ChangeNotifier {
  final KrishiRepository repository;

  BuyerProfileController(this.repository);

  BuyerProfile get buyer => repository.currentBuyer;
}
