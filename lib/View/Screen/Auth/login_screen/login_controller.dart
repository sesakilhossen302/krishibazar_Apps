import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_controller.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../../helper/shared_pref/shared_pref_helper.dart';
import '../../../../service/api_client.dart';

class LoginController extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  Future<void> onLoginClick(BuildContext context) async {
    final identifier = emailController.text.trim();
    final password = passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      errorMessage = "ফোন নম্বর/ইমেইল এবং পাসওয়ার্ড প্রদান করুন।";
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final res = await ApiClient.login(
      identifier: identifier,
      password: password,
    );

    isLoading = false;
    notifyListeners();

    if (res["success"] == true) {
      final roleStr = (res["role"] ?? "farmer").toString().toLowerCase();
      final roleEnum = roleStr == 'buyer' ? UserRole.buyer : UserRole.farmer;

      await SharedPrefHelper.saveUserSession(
        isLoggedIn: true,
        role: roleEnum.name,
        name: res["name"] ?? "ব্যবহারকারী",
        email: identifier.contains("@") ? identifier : "",
        phone: !identifier.contains("@") ? identifier : "",
      );

      if (context.mounted) {
        context.read<KrishiController>().switchRole(roleEnum);
        context.read<KrishiRepository>().switchRole(roleEnum);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("স্বাগতম ${res['name'] ?? ''}! আপনার অ্যাকাউন্টে সফলভাবে প্রবেশ করেছেন। 🎉"),
            backgroundColor: AppColors.primaryGreen,
          ),
        );

        Navigator.pushReplacementNamed(context, AppRoute.mainScreen);
      }
    } else {
      errorMessage = res["message"] ?? "ফোন নম্বর বা পাসওয়ার্ড ভুল প্রদান করা হয়েছে।";
      notifyListeners();
    }
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
