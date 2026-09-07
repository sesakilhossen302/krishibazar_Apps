import 'package:flutter/material.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../helper/shared_pref/shared_pref_helper.dart';
import 'register_model.dart';

class RegisterController extends ChangeNotifier {
  late RegistrationFormData formData;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Buyer Specific Controllers
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController businessLicenseController = TextEditingController();
  final TextEditingController shopLocationController = TextEditingController();

  // Farmer Specific Controllers
  final TextEditingController farmerTypeController = TextEditingController();
  final TextEditingController farmerLocationController = TextEditingController();

  String? nidFrontImageName;
  String? nidBackImageName;
  String? tradeLicenseImageName;

  String? errorMessage;
  bool isLoading = false;

  void init(UserRole role) {
    formData = RegistrationFormData(role: role);
  }

  void pickNidFront() {
    nidFrontImageName = "nid_front_uploaded.jpg";
    formData.nidFrontPath = "path/to/nid_front_uploaded.jpg";
    notifyListeners();
  }

  void pickNidBack() {
    nidBackImageName = "nid_back_uploaded.jpg";
    formData.nidBackPath = "path/to/nid_back_uploaded.jpg";
    notifyListeners();
  }

  void pickTradeLicense() {
    tradeLicenseImageName = "trade_license_uploaded.jpg";
    formData.tradeLicensePath = "path/to/trade_license_uploaded.jpg";
    notifyListeners();
  }

  Future<void> submitRegistration(BuildContext context) async {
    final name = nameController.text.trim().isNotEmpty
        ? nameController.text.trim()
        : (formData.role == UserRole.buyer ? 'পাইকারি ক্রেতা' : 'কৃষক ভাই');
    final email = emailController.text.trim().isNotEmpty
        ? emailController.text.trim()
        : 'user@krishibazar.bd';
    final phone = phoneController.text.trim().isNotEmpty
        ? phoneController.text.trim()
        : '01700000000';

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    // Save preliminary registration info to SharedPreferences
    await SharedPrefHelper.saveUserSession(
      isLoggedIn: false,
      role: formData.role.name,
      name: name,
      email: email,
      phone: phone,
      nidFront: formData.nidFrontPath,
      nidBack: formData.nidBackPath,
      tradeLicense: formData.tradeLicensePath,
      shopName: shopNameController.text.trim(),
      businessLicenseNo: businessLicenseController.text.trim(),
      shopLocation: shopLocationController.text.trim(),
    );

    isLoading = false;
    notifyListeners();

    if (context.mounted) {
      Navigator.pushNamed(
        context,
        AppRoute.otpScreen,
        arguments: {
          'role': formData.role,
          'email': email,
          'phone': phone,
        },
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    shopNameController.dispose();
    businessLicenseController.dispose();
    shopLocationController.dispose();
    farmerTypeController.dispose();
    farmerLocationController.dispose();
    super.dispose();
  }
}
