import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_controller.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../../helper/shared_pref/shared_pref_helper.dart';

class SplashController extends ChangeNotifier {
  Future<void> init(BuildContext context) async {
    // Show splash screen animation briefly
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!context.mounted) return;

    final token = await SharedPrefHelper.getToken();
    final isLoggedIn = await SharedPrefHelper.isLoggedIn();

    debugPrint('🌾 [SPLASH CHECK] Token present: ${token.isNotEmpty}, isLoggedIn: $isLoggedIn');

    if (token.trim().isNotEmpty && isLoggedIn) {
      // User has token and is authenticated
      final roleStr = await SharedPrefHelper.getUserRole();
      final roleEnum = (roleStr.toLowerCase() == 'buyer') ? UserRole.buyer : UserRole.farmer;

      debugPrint('🌾 [SPLASH AUTO-LOGIN] Role: ${roleEnum.name} -> Navigating to Home');

      if (context.mounted) {
        final repo = context.read<KrishiRepository>();
        final krishiCtrl = context.read<KrishiController>();

        // Switch role according to saved token/session
        repo.switchRole(roleEnum);
        krishiCtrl.switchRole(roleEnum);

        // Ensure user lands on Home tab (Index 0)
        repo.setFarmerTab(0);
        repo.setBuyerTab(0);
        krishiCtrl.setFarmerTab(0);
        krishiCtrl.setBuyerTab(0);

        // Fetch fresh profile and live market data in background
        repo.loadProfileFromBackend();
        krishiCtrl.loadProfileFromBackend();

        Navigator.of(context).pushReplacementNamed(AppRoute.mainScreen);
      }
    } else {
      // No token found -> Navigate to Login Screen
      debugPrint('🌾 [SPLASH GUEST] No token -> Navigating to Login');
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoute.loginScreen);
      }
    }
  }
}
