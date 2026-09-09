import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../service/api_client.dart';
import '../../../../service/location_service.dart';
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

  // Structured Location Controllers (Populated automatically via GPS/Google Maps or manual input)
  final TextEditingController districtController = TextEditingController();
  final TextEditingController upazilaController = TextEditingController();
  final TextEditingController unionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool isDetectingLocation = false;
  DetectedLocation? detectedLocation;

  File? nidFrontFile;
  String? nidFrontImageName;
  bool isUploadingNidFront = false;

  File? nidBackFile;
  String? nidBackImageName;
  bool isUploadingNidBack = false;

  File? tradeLicenseFile;
  String? tradeLicenseImageName;
  bool isUploadingTradeLicense = false;

  String? errorMessage;
  bool isLoading = false;

  void init(UserRole role) {
    formData = RegistrationFormData(role: role);
  }

  /// Automatically fetch user's GPS/Google Maps location and fill district, upazila, union & address
  Future<void> autoDetectLocation(BuildContext context) async {
    isDetectingLocation = true;
    notifyListeners();

    try {
      final loc = await LocationService.getCurrentLocation();
      detectedLocation = loc;

      if (loc.district.isNotEmpty) districtController.text = loc.district;
      if (loc.upazila.isNotEmpty) upazilaController.text = loc.upazila;
      if (loc.unionOrArea.isNotEmpty) unionController.text = loc.unionOrArea;
      if (loc.fullAddress.isNotEmpty) addressController.text = loc.fullAddress;

      // Update legacy fields as well
      if (farmerLocationController.text.trim().isEmpty) {
        final parts = <String>[];
        if (loc.upazila.isNotEmpty) parts.add(loc.upazila);
        if (loc.district.isNotEmpty) parts.add(loc.district);
        farmerLocationController.text = parts.join(', ');
      }
      if (shopLocationController.text.trim().isEmpty) {
        final parts = <String>[];
        if (loc.unionOrArea.isNotEmpty) parts.add(loc.unionOrArea);
        if (loc.district.isNotEmpty) parts.add(loc.district);
        shopLocationController.text = parts.join(', ');
      }

      if (context.mounted) {
        _showSnackBar(
          context,
          "✓ লোকেশন সনাক্ত হয়েছে: ${loc.district.isNotEmpty ? loc.district : ''} ${loc.upazila.isNotEmpty ? '• ${loc.upazila}' : ''}",
          isError: false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString(), isError: true);
      }
    } finally {
      isDetectingLocation = false;
      notifyListeners();
    }
  }

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

  /// Pick NID Front Image via Camera/Gallery (Stored locally)
  Future<void> pickNidFront(BuildContext context) async {
    final File? file = await ImagePickerDialog.showImageSourceSelector(context);
    if (file == null) return;

    nidFrontFile = file;
    nidFrontImageName = file.path.split(Platform.pathSeparator).last;
    formData.nidFrontPath = file.path;
    notifyListeners();
  }

  /// Pick NID Back Image via Camera/Gallery (Stored locally)
  Future<void> pickNidBack(BuildContext context) async {
    final File? file = await ImagePickerDialog.showImageSourceSelector(context);
    if (file == null) return;

    nidBackFile = file;
    nidBackImageName = file.path.split(Platform.pathSeparator).last;
    formData.nidBackPath = file.path;
    notifyListeners();
  }

  /// Pick Trade License Image via Camera/Gallery (Stored locally)
  Future<void> pickTradeLicense(BuildContext context) async {
    final File? file = await ImagePickerDialog.showImageSourceSelector(context);
    if (file == null) return;

    tradeLicenseFile = file;
    tradeLicenseImageName = file.path.split(Platform.pathSeparator).last;
    formData.tradeLicensePath = file.path;
    notifyListeners();
  }

  /// Submit Registration and Trigger Gmail OTP Sending
  Future<void> submitRegistration(BuildContext context) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      _showSnackBar(context, "অনুগ্রহ করে নাম, ফোন, জিমেইল ও পাসওয়ার্ড পূরণ করুন।");
      return;
    }

    if (formData.role == UserRole.buyer && shopNameController.text.trim().isEmpty) {
      _showSnackBar(context, "পাইকার সাইনআপের জন্য ব্যবসা/আড়তের নাম প্রদান করুন।");
      return;
    }

    isLoading = true;
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
        _showSnackBar(
          context,
          otpRes["message"] ?? "আপনার জিমেইলে ওটিপি কোড পাঠানো হয়েছে।",
          isError: false,
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
            'nidFrontFile': nidFrontFile,
            'nidBackFile': nidBackFile,
            'tradeLicenseFile': tradeLicenseFile,
            'businessName': shopNameController.text.trim(),
            'businessType': businessLicenseController.text.trim(),
            'arotLocation': shopLocationController.text.trim(),
            'farmerType': farmerTypeController.text.trim(),
            'farmerLocation': farmerLocationController.text.trim(),
            'district': districtController.text.trim(),
            'upazila': upazilaController.text.trim().isNotEmpty
                ? upazilaController.text.trim()
                : (formData.role == UserRole.farmer ? farmerLocationController.text.trim() : ''),
            'union': unionController.text.trim(),
            'address': addressController.text.trim().isNotEmpty
                ? addressController.text.trim()
                : (formData.role == UserRole.buyer ? shopLocationController.text.trim() : farmerLocationController.text.trim()),
          },
        );
      }
    } else {
      if (context.mounted) {
        _showSnackBar(context, otpRes["message"] ?? "ওটিপি পাঠাতে ব্যর্থ হয়েছে।");
      }
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
    districtController.dispose();
    upazilaController.dispose();
    unionController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
