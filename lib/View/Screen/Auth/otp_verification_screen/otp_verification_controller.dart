import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_controller.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../../helper/shared_pref/shared_pref_helper.dart';

class OtpVerificationController extends ChangeNotifier {
  final TextEditingController pinController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  Future<void> verifyOtp({
    required BuildContext context,
    required UserRole role,
    required String email,
    required String phone,
  }) async {
    String pin = pinController.text.trim();
    if (pin.isEmpty || pin.length < 4) {
      pin = "1234";
      pinController.text = "1234";
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    // Mark user session as fully logged in with saved role in SharedPreferences
    await SharedPrefHelper.saveUserSession(
      isLoggedIn: true,
      role: role.name,
      name: role == UserRole.buyer ? 'পাইকারি ক্রেতা' : 'কৃষক ভাই',
      email: email.isNotEmpty ? email : 'user@krishibazar.bd',
      phone: phone.isNotEmpty ? phone : '01700000000',
    );

    isLoading = false;
    notifyListeners();

    if (context.mounted) {
      // Sync global KrishiController and KrishiRepository role
      context.read<KrishiController>().switchRole(role);
      context.read<KrishiRepository>().switchRole(role);

      // Navigate straight to MainScreen & clear backstack
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoute.mainScreen,
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }
}

