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

  void _showSnackBar(BuildContext context, String message, {bool isError = true}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red.shade700 : AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> onLoginClick(BuildContext context) async {
    final identifier = emailController.text.trim();
    final password = passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _showSnackBar(context, "ফোন নম্বর/ইমেইল এবং পাসওয়ার্ড প্রদান করুন।");
      return;
    }

    isLoading = true;
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

      final userMap = (res["data"] is Map) ? (res["data"] as Map) : {};
      final token = res["access_token"] ?? userMap["access_token"] ?? "";
      final userId = res["user_id"] ?? userMap["user_id"] ?? "";
      final userDistrict = userMap["district"] ?? "";
      final vStatus = userMap["verification_status"] ?? "verified";

      await SharedPrefHelper.saveUserSession(
        isLoggedIn: true,
        role: roleEnum.name,
        name: res["name"] ?? userMap["name"] ?? "ব্যবহারকারী",
        email: identifier.contains("@") ? identifier : (userMap["email"] ?? ""),
        phone: !identifier.contains("@") ? identifier : (userMap["phone"] ?? ""),
        userId: userId.toString(),
        token: token.toString(),
        district: userDistrict.toString(),
        verificationStatus: vStatus.toString(),
      );

      if (context.mounted) {
        context.read<KrishiController>().switchRole(roleEnum);
        context.read<KrishiRepository>().switchRole(roleEnum);

        // Immediately load user profile from backend
        context.read<KrishiRepository>().loadProfileFromBackend();
        context.read<KrishiController>().loadProfileFromBackend();

        _showSnackBar(
          context,
          "স্বাগতম ${res['name'] ?? userMap['name'] ?? ''}! আপনার অ্যাকাউন্টে সফলভাবে প্রবেশ করেছেন। 🎉",
          isError: false,
        );

        Navigator.pushReplacementNamed(context, AppRoute.mainScreen);
      }
    } else {
      if (context.mounted) {
        _showSnackBar(context, res["message"] ?? "ফোন নম্বর বা পাসওয়ার্ড ভুল প্রদান করা হয়েছে।");
      }
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
