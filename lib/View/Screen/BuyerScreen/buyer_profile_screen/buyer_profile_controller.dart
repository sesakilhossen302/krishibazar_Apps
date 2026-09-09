import 'package:flutter/material.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../../helper/shared_pref/shared_pref_helper.dart';

class BuyerProfileController extends ChangeNotifier {
  final KrishiRepository repository;

  BuyerProfileController(this.repository);

  BuyerProfile get buyer => repository.currentBuyer;
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
