import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_controller.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../../helper/shared_pref/shared_pref_helper.dart';
import '../../../../service/api_client.dart';

class OtpVerificationController extends ChangeNotifier {
  final TextEditingController pinController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  Future<void> verifyOtpAndSignup({
    required BuildContext context,
    required Map<String, dynamic> signupArgs,
  }) async {
    final String pin = pinController.text.trim();
    if (pin.isEmpty) {
      errorMessage = "অনুগ্রহ করে জিমেইলে প্রাপ্ত ৬ সংখ্যার ওটিপি কোড লিখুন।";
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final UserRole role = signupArgs['role'] ?? UserRole.farmer;

    final payload = {
      "role": role == UserRole.buyer ? "buyer" : "farmer",
      "name": signupArgs['name'] ?? "ইউজার",
      "phone": signupArgs['phone'] ?? "",
      "email": signupArgs['email'] ?? "",
      "password": signupArgs['password'] ?? "123456",
      "otp_code": pin,
      "nid_front_url": signupArgs['nidFrontUrl'] ?? "",
      "nid_back_url": signupArgs['nidBackUrl'] ?? "",
      "trade_license_url": signupArgs['tradeLicenseUrl'] ?? "",
      "business_name": signupArgs['businessName'] ?? "",
      "business_type": signupArgs['businessType'] ?? "",
      "arot_location": signupArgs['arotLocation'] ?? "",
      "farmer_type": signupArgs['farmerType'] ?? "",
      "upazila": signupArgs['farmerLocation'] ?? "",
    };

    final res = await ApiClient.signup(payload);

    isLoading = false;
    notifyListeners();

    if (res["success"] == true) {
      await SharedPrefHelper.saveUserSession(
        isLoggedIn: true,
        role: role.name,
        name: signupArgs['name'] ?? "",
        email: signupArgs['email'] ?? "",
        phone: signupArgs['phone'] ?? "",
      );

      if (context.mounted) {
        context.read<KrishiController>().switchRole(role);
        context.read<KrishiRepository>().switchRole(role);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("অ্যাকাউন্ট ভেরিফিকেশন ও রেজিস্ট্রেশন সফল হয়েছে! 🎉"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoute.mainScreen,
          (route) => false,
        );
      }
    } else {
      errorMessage = res["message"] ?? "ওটিপি মিলছে না বা মেয়াদ শেষ হয়ে গেছে।";
      notifyListeners();
    }
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }
}
