import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../global/Model/krishi_models.dart';
import '../../../global/controller/krishi_controller.dart';
import '../../../global/controller/krishi_repository.dart';
import '../../../helper/shared_pref/shared_pref_helper.dart';
import '../../../service/api_client.dart';
import '../../../service/api_url.dart';
import '../../../service/location_service.dart';
import '../../Widgegt/custom_text_field/custom_text_field.dart';
import '../../Widgegt/image_picker_dialog/image_picker_dialog.dart';
import '../../Widgegt/location_picker_card.dart';

class EditProfileDialog extends StatefulWidget {
  final bool isFarmer;
  final FarmerProfile? farmer;
  final BuyerProfile? buyer;

  const EditProfileDialog({
    super.key,
    required this.isFarmer,
    this.farmer,
    this.buyer,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isFarmer,
    FarmerProfile? farmer,
    BuyerProfile? buyer,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditProfileDialog(
        isFarmer: isFarmer,
        farmer: farmer,
        buyer: buyer,
      ),
    );
  }

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;

  // Farmer specific
  late final TextEditingController farmerTypeController;

  // Buyer specific
  late final TextEditingController businessNameController;
  late final TextEditingController businessTypeController;

  // Location controllers
  late final TextEditingController districtController;
  late final TextEditingController upazilaController;
  late final TextEditingController unionController;
  late final TextEditingController addressController;

  File? newPhotoFile;
  bool isDetectingLocation = false;
  bool isSaving = false;
  DetectedLocation? detectedLocation;

  @override
  void initState() {
    super.initState();
    if (widget.isFarmer) {
      final f = widget.farmer;
      nameController = TextEditingController(text: f?.name ?? '');
      phoneController = TextEditingController(text: f?.phone ?? '');
      emailController = TextEditingController(text: f?.email ?? '');
      farmerTypeController = TextEditingController(text: f?.farmerType ?? '');
      businessNameController = TextEditingController();
      businessTypeController = TextEditingController();
      districtController = TextEditingController(text: f?.district ?? '');
      upazilaController = TextEditingController(text: f?.upazila ?? '');
      unionController = TextEditingController(text: f?.union ?? '');
      addressController = TextEditingController(text: f?.address ?? '');
    } else {
      final b = widget.buyer;
      nameController = TextEditingController(text: b?.name ?? '');
      phoneController = TextEditingController(text: b?.phone ?? '');
      emailController = TextEditingController(text: b?.email ?? '');
      farmerTypeController = TextEditingController();
      businessNameController = TextEditingController(text: b?.businessName ?? '');
      businessTypeController = TextEditingController(text: b?.businessType ?? '');
      districtController = TextEditingController(text: b?.district ?? '');
      upazilaController = TextEditingController();
      unionController = TextEditingController(text: b?.area ?? '');
      addressController = TextEditingController(text: b?.address ?? '');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    farmerTypeController.dispose();
    businessNameController.dispose();
    businessTypeController.dispose();
    districtController.dispose();
    upazilaController.dispose();
    unionController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePickerDialog.showImageSourceSelector(context);
    if (file != null) {
      setState(() {
        newPhotoFile = file;
      });
    }
  }

  void _onLocationSelected(LocationSearchResult result) {
    setState(() {
      if (result.district.isNotEmpty) districtController.text = result.district;
      if (result.upazila.isNotEmpty) upazilaController.text = result.upazila;
      if (result.unionOrArea.isNotEmpty) unionController.text = result.unionOrArea;
      if (result.fullAddress.isNotEmpty) addressController.text = result.fullAddress;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✓ '${result.title}' এর জেলা, উপজেলা ও বিস্তারিত ঠিকানা পূরণ হয়েছে!"),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _autoDetectLocation() async {
    setState(() => isDetectingLocation = true);
    try {
      final loc = await LocationService.getCurrentLocation();
      setState(() {
        detectedLocation = loc;
        if (loc.district.isNotEmpty) districtController.text = loc.district;
        if (loc.upazila.isNotEmpty) upazilaController.text = loc.upazila;
        if (loc.unionOrArea.isNotEmpty) unionController.text = loc.unionOrArea;
        if (loc.fullAddress.isNotEmpty) addressController.text = loc.fullAddress;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✓ লোকেশন সনাক্ত হয়েছে: ${loc.district} ${loc.upazila}"),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final cleanMsg = e.toString().replaceAll('Exception:', '').trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cleanMsg),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isDetectingLocation = false);
    }
  }

  Future<void> _saveProfile() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে আপনার নাম পূরণ করুন।'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      String? uploadedPhotoUrl;
      if (newPhotoFile != null) {
        final uploadRes = await ApiClient.uploadImageFile(newPhotoFile!);
        debugPrint('📸 [UPLOAD PHOTO RESULT]: $uploadRes');
        if (uploadRes["success"] == true) {
          uploadedPhotoUrl = (uploadRes["url"] ?? uploadRes["full_url"] ?? uploadRes["file_url"])?.toString();
          debugPrint('📸 [EXTRACTED PHOTO URL]: $uploadedPhotoUrl');
        }
      }

      final token = await SharedPrefHelper.getToken();
      final userId = await SharedPrefHelper.getUserId();

      final Map<String, dynamic> updateData = {
        "name": name,
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "district": districtController.text.trim(),
        "address": addressController.text.trim(),
      };

      if (uploadedPhotoUrl != null && uploadedPhotoUrl.isNotEmpty) {
        updateData["photo_url"] = uploadedPhotoUrl;
      }

      if (widget.isFarmer) {
        updateData["farmer_type"] = farmerTypeController.text.trim();
        updateData["upazila"] = upazilaController.text.trim();
        updateData["union"] = unionController.text.trim();
      } else {
        updateData["business_name"] = businessNameController.text.trim();
        updateData["business_type"] = businessTypeController.text.trim();
        updateData["arot_location"] = unionController.text.trim();
      }

      final res = await ApiClient.updateUserProfile(
        token: token.isNotEmpty ? token : null,
        userId: userId.isNotEmpty ? userId : (widget.isFarmer ? widget.farmer?.id : widget.buyer?.id),
        updateData: updateData,
      );

      if (!mounted) return;
      setState(() => isSaving = false);

      if (res["success"] == true) {
        await SharedPrefHelper.saveUserSession(
          isLoggedIn: true,
          role: widget.isFarmer ? 'farmer' : 'buyer',
          name: name,
          phone: phoneController.text.trim(),
          email: emailController.text.trim(),
          photoUrl: uploadedPhotoUrl ?? (widget.isFarmer ? widget.farmer?.photoUrl : widget.buyer?.photoUrl),
          district: districtController.text.trim(),
          upazila: upazilaController.text.trim(),
          union: unionController.text.trim(),
          address: addressController.text.trim(),
          farmerType: widget.isFarmer ? farmerTypeController.text.trim() : null,
          shopName: !widget.isFarmer ? businessNameController.text.trim() : null,
          shopLocation: !widget.isFarmer ? unionController.text.trim() : null,
        );

        if (mounted) {
          context.read<KrishiRepository>().loadProfileFromBackend();
          context.read<KrishiController>().loadProfileFromBackend();

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✓ আপনার প্রোফাইল তথ্য সফলভাবে আপডেট হয়েছে! 🎉"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res["message"] ?? "প্রোফাইল আপডেট করতে সমস্যা হয়েছে।"),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ত্রুটি: $e'), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingPhoto = widget.isFarmer ? (widget.farmer?.photoUrl ?? '') : (widget.buyer?.photoUrl ?? '');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_note_rounded, color: AppColors.primaryGreen, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'প্রোফাইল এডিট ও আপডেট',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 16),

            // Profile Photo Picker Section
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFDCFCE7),
                      border: Border.all(color: AppColors.primaryGreen, width: 2.5),
                    ),
                    child: ClipOval(
                      child: newPhotoFile != null
                          ? Image.file(newPhotoFile!, fit: BoxFit.cover)
                          : (existingPhoto.isNotEmpty
                              ? Image.network(
                                  ApiUrl.formatMediaUrl(existingPhoto),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Center(
                                    child: Icon(Icons.person_rounded, size: 50, color: AppColors.primaryGreen),
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.person_rounded, size: 50, color: AppColors.primaryGreen),
                                )),
                    ),
                  ),
                  InkWell(
                    onTap: _pickPhoto,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.photo_camera_outlined, size: 16, color: AppColors.primaryGreen),
                label: const Text(
                  'ছবি পরিবর্তন করুন',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Basic Info Fields
            const Text(
              'সাধারণ তথ্য',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: nameController,
              hintText: 'আপনার পুরো নাম',
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: phoneController,
              hintText: 'মোবাইল নম্বর',
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: emailController,
              hintText: 'ইমেইল/জিমেইল এড্রেস',
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 14),

            // Role specific fields
            if (widget.isFarmer) ...[
              const Text(
                'খামার ও ফসলের বিবরণ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: farmerTypeController,
                hintText: 'কৃষকের ধরন / ফসল (যেমন: আলু, বেগুন, ২০ বিঘা)',
                prefixIcon: Icons.grass_rounded,
              ),
            ] else ...[
              const Text(
                'ব্যবসা সংক্রান্ত বিবরণ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: businessNameController,
                hintText: 'ব্যবসা / আড়তের নাম',
                prefixIcon: Icons.store_rounded,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: businessTypeController,
                hintText: 'ব্যবসার ধরন (যেমন: পাইকারি আড়তদার)',
                prefixIcon: Icons.badge_outlined,
              ),
            ],
            const SizedBox(height: 18),

            // Google Maps & Location Section
            const Text(
              'ঠিকানা ও অবস্থান (Google Maps / GPS)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            LocationPickerCard(
              isLoadingGps: isDetectingLocation,
              detectedLocation: detectedLocation,
              onDetectLocation: _autoDetectLocation,
              onLocationSelected: _onLocationSelected,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: districtController,
                    hintText: 'জেলা (যেমন: ঢাকা, রাজশাহী)',
                    prefixIcon: Icons.location_city_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextField(
                    controller: upazilaController,
                    hintText: 'উপজেলা/থানা (যেমন: গুলশান, গোদাগাড়ী)',
                    prefixIcon: Icons.map_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: unionController,
                    hintText: 'ইউনিয়ন/গ্রাম/এলাকা',
                    prefixIcon: Icons.holiday_village_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextField(
                    controller: addressController,
                    hintText: 'বিস্তারিত সম্পূর্ণ ঠিকানা',
                    prefixIcon: Icons.home_work_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: isSaving ? null : _saveProfile,
                icon: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: Text(
                  isSaving ? 'সংরক্ষণ করা হচ্ছে...' : 'প্রোফাইল সংরক্ষণ ও আপডেট করুন',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
