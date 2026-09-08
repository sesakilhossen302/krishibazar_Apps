import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../service/api_client.dart';
import '../../../Widgegt/image_picker_dialog/image_picker_dialog.dart';
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
  String? nidFrontUrl;
  bool isUploadingNidFront = false;

  String? nidBackImageName;
  String? nidBackUrl;
  bool isUploadingNidBack = false;

  String? tradeLicenseImageName;
  String? tradeLicenseUrl;
  bool isUploadingTradeLicense = false;

  String? errorMessage;
  bool isLoading = false;

  void init(UserRole role) {
    formData = RegistrationFormData(role: role);
  }

  /// Pick & Upload NID Front Image via Camera/Gallery
  Future<void> pickNidFront(BuildContext context) async {
    final File? file = await ImagePickerDialog.showImageSourceSelector(context);
    if (file == null) return;

    nidFrontImageName = file.path.split(Platform.pathSeparator).last;
    isUploadingNidFront = true;
    notifyListeners();

    final res = await ApiClient.uploadImageFile(file);
    isUploadingNidFront = false;

    if (res["success"] == true) {
      nidFrontUrl = res["full_url"];
      formData.nidFrontPath = res["full_url"];
    } else {
      errorMessage = res["message"];
    }
    notifyListeners();
  }

  /// Pick & Upload NID Back Image via Camera/Gallery
  Future<void> pickNidBack(BuildContext context) async {
    final File? file = await ImagePickerDialog.showImageSourceSelector(context);
    if (file == null) return;

    nidBackImageName = file.path.split(Platform.pathSeparator).last;
    isUploadingNidBack = true;
    notifyListeners();

    final res = await ApiClient.uploadImageFile(file);
    isUploadingNidBack = false;

    if (res["success"] == true) {
      nidBackUrl = res["full_url"];
      formData.nidBackPath = res["full_url"];
    } else {
      errorMessage = res["message"];
    }
    notifyListeners();
  }

  /// Pick & Upload Trade License Image via Camera/Gallery
  Future<void> pickTradeLicense(BuildContext context) async {
    final File? file = await ImagePickerDialog.showImageSourceSelector(context);
    if (file == null) return;

    tradeLicenseImageName = file.path.split(Platform.pathSeparator).last;
    isUploadingTradeLicense = true;
    notifyListeners();

    final res = await ApiClient.uploadImageFile(file);
    isUploadingTradeLicense = false;

    if (res["success"] == true) {
      tradeLicenseUrl = res["full_url"];
      formData.tradeLicensePath = res["full_url"];
    } else {
      errorMessage = res["message"];
    }
    notifyListeners();
  }

  /// Submit Registration and Trigger Gmail OTP Sending
  Future<void> submitRegistration(BuildContext context) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      errorMessage = "অনুগ্রহ করে নাম, ফোন, জিমেইল ও পাসওয়ার্ড পূরণ করুন।";
      notifyListeners();
      return;
    }

    if (formData.role == UserRole.buyer && shopNameController.text.trim().isEmpty) {
      errorMessage = "পাইকার সাইনআপের জন্য ব্যবসা/আড়তের নাম প্রদান করুন।";
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    // 1. Send OTP to Gmail
    final otpRes = await ApiClient.sendOtp(
      email: email,
      name: name,
      purpose: "signup",
      phone: phone,
    );

    isLoading = false;
    notifyListeners();

    if (otpRes["success"] == true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(otpRes["message"] ?? "আপনার জিমেইলে ওটিপি কোড পাঠানো হয়েছে।"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushNamed(
          context,
          AppRoute.otpScreen,
          arguments: {
            'role': formData.role,
            'name': name,
            'email': email,
            'phone': phone,
            'password': password,
            'nidFrontUrl': nidFrontUrl ?? "",
            'nidBackUrl': nidBackUrl ?? "",
            'tradeLicenseUrl': tradeLicenseUrl ?? "",
            'businessName': shopNameController.text.trim(),
            'businessType': businessLicenseController.text.trim(),
            'arotLocation': shopLocationController.text.trim(),
            'farmerType': farmerTypeController.text.trim(),
            'farmerLocation': farmerLocationController.text.trim(),
          },
        );
      }
    } else {
      errorMessage = otpRes["message"] ?? "ওটিপি পাঠাতে সমস্যা হয়েছে।";
      notifyListeners();
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
