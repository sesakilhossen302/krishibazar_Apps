import 'dart:io';
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

  void _showSnackBar(BuildContext context, String message, {bool isError = true}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> verifyOtpAndSignup({
    required BuildContext context,
    required Map<String, dynamic> signupArgs,
  }) async {
    final String pin = pinController.text.trim();
    if (pin.isEmpty) {
      _showSnackBar(context, "অনুগ্রহ করে জিমেইলে প্রাপ্ত ৬ সংখ্যার ওটিপি কোড লিখুন।");
      return;
    }

    isLoading = true;
    notifyListeners();

    // 1. Upload deferred images (NID Front, NID Back, Trade License) if present
    String nidFrontUrl = "";
    String nidBackUrl = "";
    String tradeLicenseUrl = "";

    if (signupArgs['nidFrontFile'] is File) {
      final res = await ApiClient.uploadImageFile(signupArgs['nidFrontFile'] as File);
      if (res["success"] == true) {
        nidFrontUrl = res["full_url"] ?? "";
      }
    }
    if (signupArgs['nidBackFile'] is File) {
      final res = await ApiClient.uploadImageFile(signupArgs['nidBackFile'] as File);
      if (res["success"] == true) {
        nidBackUrl = res["full_url"] ?? "";
      }
    }
    if (signupArgs['tradeLicenseFile'] is File) {
      final res = await ApiClient.uploadImageFile(signupArgs['tradeLicenseFile'] as File);
      if (res["success"] == true) {
        tradeLicenseUrl = res["full_url"] ?? "";
      }
    }

    final UserRole role = signupArgs['role'] ?? UserRole.farmer;

    final payload = {
      "role": role == UserRole.buyer ? "buyer" : "farmer",
      "name": signupArgs['name'] ?? "ইউজার",
      "phone": signupArgs['phone'] ?? "",
      "email": signupArgs['email'] ?? "",
      "password": signupArgs['password'] ?? "123456",
      "otp_code": pin,
      "nid_front_url": nidFrontUrl,
      "nid_back_url": nidBackUrl,
      "trade_license_url": tradeLicenseUrl,
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
      final userMap = (res["data"] is Map) ? (res["data"] as Map) : {};
      final token = res["access_token"] ?? userMap["access_token"] ?? "";
      final userId = res["user_id"] ?? userMap["user_id"] ?? "";

      await SharedPrefHelper.saveUserSession(
        isLoggedIn: true,
        role: role.name,
        name: signupArgs['name'] ?? userMap['name'] ?? "",
        email: signupArgs['email'] ?? userMap['email'] ?? "",
        phone: signupArgs['phone'] ?? userMap['phone'] ?? "",
        userId: userId.toString(),
        token: token.toString(),
        nidFront: nidFrontUrl,
        nidBack: nidBackUrl,
        tradeLicense: tradeLicenseUrl,
        shopName: signupArgs['businessName'],
        shopLocation: signupArgs['arotLocation'],
        farmerType: signupArgs['farmerType'],
        district: signupArgs['district'] ?? "রাজশাহী",
        upazila: signupArgs['farmerLocation'] ?? signupArgs['upazila'],
        verificationStatus: "verified",
      );

      if (context.mounted) {
        context.read<KrishiController>().switchRole(role);
        context.read<KrishiRepository>().switchRole(role);

        // Immediately load user profile from backend
        context.read<KrishiRepository>().loadProfileFromBackend();
        context.read<KrishiController>().loadProfileFromBackend();

        _showSnackBar(
          context,
          "অ্যাকাউন্ট ভেরিফিকেশন ও রেজিস্ট্রেশন সফল হয়েছে! 🎉",
          isError: false,
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoute.mainScreen,
          (route) => false,
        );
      }
    } else {
      if (context.mounted) {
        _showSnackBar(context, res["message"] ?? "ওটিপি মিলছে না বা মেয়াদ শেষ হয়ে গেছে।");
      }
    }
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }
}
