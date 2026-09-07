import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_controller.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../../helper/shared_pref/shared_pref_helper.dart';

class LoginController extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  void onLoginClick(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage = "ইমেইল ও পাসওয়ার্ড প্রদান করুন";
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    // Simulate authentication process
    Future.delayed(const Duration(milliseconds: 800), () async {
      final roleStr = await SharedPrefHelper.getUserRole();
      final role = roleStr == 'buyer' ? UserRole.buyer : UserRole.farmer;
      isLoading = false;
      notifyListeners();
      if (context.mounted) {
        context.read<KrishiController>().switchRole(role);
        context.read<KrishiRepository>().switchRole(role);
        Navigator.pushReplacementNamed(context, AppRoute.mainScreen);
      }
    });
  }

  void onNavigateToRoleSelection(BuildContext context) {
    Navigator.pushNamed(context, AppRoute.roleSelectScreen);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
