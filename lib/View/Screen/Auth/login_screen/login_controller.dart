import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Dialogs/account_status_dialog.dart';
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
      ),
    );
  }

  Future<void> onLoginClick(BuildContext context) => login(context);

  Future<void> login(BuildContext context) async {
    final identifier = emailController.text.trim();
    final password = passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      _showSnackBar(context, "অনুগ্রহ করে আপনার ফোন বা ইমেইল এবং পাসওয়ার্ড দিন।");
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
      final token = (res["access_token"] ?? userMap["access_token"] ?? res["token"] ?? userMap["token"] ?? "").toString();
      final userId = (res["user_id"] ?? userMap["user_id"] ?? userMap["id"] ?? "").toString();
      final userDistrict = (userMap["district"] ?? res["district"] ?? "").toString();
      final userName = (res["name"] ?? userMap["name"] ?? "ব্যবহারকারী").toString();
      final vStatus = (res["verification_status"] ?? userMap["verification_status"] ?? "pending").toString();
      final adminNote = (res["admin_note"] ?? userMap["admin_note"] ?? "").toString();

      await SharedPrefHelper.saveUserSession(
        isLoggedIn: true,
        role: roleEnum.name,
        name: userName,
        email: identifier.contains("@") ? identifier : (userMap["email"] ?? ""),
        phone: !identifier.contains("@") ? identifier : (userMap["phone"] ?? ""),
        userId: userId,
        token: token,
        district: userDistrict,
        verificationStatus: vStatus,
      );
      if (token.isNotEmpty) {
        await SharedPrefHelper.saveToken(token);
      }

      if (context.mounted) {
        final repo = context.read<KrishiRepository>();
        final krishiCtrl = context.read<KrishiController>();

        krishiCtrl.switchRole(roleEnum);
        repo.switchRole(roleEnum);

        repo.setFarmerTab(0);
        repo.setBuyerTab(0);
        krishiCtrl.setFarmerTab(0);
        krishiCtrl.setBuyerTab(0);

        // Immediately load user profile from backend
        context.read<KrishiRepository>().loadProfileFromBackend();
        context.read<KrishiController>().loadProfileFromBackend();

        final vLower = vStatus.toLowerCase();
        if (vLower == 'suspended' || vLower == 'rejected') {
          // Show popup dialog with admin's reason/note
          await AccountStatusDialog.show(
            context,
            status: vStatus,
            adminNote: adminNote,
            userName: userName,
          );
        } else {
          _showSnackBar(
            context,
            "স্বাগতম $userName! আপনার অ্যাকাউন্টে সফলভাবে প্রবেশ করেছেন। 🎉",
            isError: false,
          );
        }

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, AppRoute.mainScreen);
        }
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
