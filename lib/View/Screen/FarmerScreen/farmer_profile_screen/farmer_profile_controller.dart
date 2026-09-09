import 'package:flutter/material.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../../helper/shared_pref/shared_pref_helper.dart';

class FarmerProfileController extends ChangeNotifier {
  final KrishiRepository repository;

  FarmerProfileController(this.repository);

  FarmerProfile get farmer => repository.currentFarmer;
  bool get isLoading => repository.isProfileLoading;

  Future<void> refreshProfile() async {
    await repository.loadProfileFromBackend();
  }

  Future<void> logout(BuildContext context) async {
    await SharedPrefHelper.clearSession();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoute.loginScreen,
        (route) => false,
      );
    }
  }
}
