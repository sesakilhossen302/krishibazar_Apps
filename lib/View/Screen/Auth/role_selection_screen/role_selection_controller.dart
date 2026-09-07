import 'package:flutter/material.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../helper/shared_pref/shared_pref_helper.dart';

class RoleSelectionController extends ChangeNotifier {
  UserRole selectedRole = UserRole.farmer;

  void selectRole(UserRole role) {
    selectedRole = role;
    notifyListeners();
  }

  Future<void> onProceedToRegister(BuildContext context) async {
    // Store preliminary chosen role in SharedPreferences
    await SharedPrefHelper.saveUserSession(
      isLoggedIn: false,
      role: selectedRole.name,
      name: '',
      email: '',
      phone: '',
    );

    if (context.mounted) {
      Navigator.pushNamed(
        context,
        AppRoute.registerScreen,
        arguments: selectedRole,
      );
    }
  }
}
