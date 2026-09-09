import 'package:flutter/material.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../Widgegt/custom_button/custom_button.dart';
import '../../../Widgegt/custom_text_field/custom_text_field.dart';
import '../../../Widgegt/location_picker_card.dart';
import 'register_controller.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole role;

  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final RegisterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RegisterController();
    _controller.init(widget.role);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBuyer = widget.role == UserRole.buyer;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text(
              isBuyer ? 'দোকানদার / ক্রেতা রেজিস্ট্রেশন' : 'কৃষক / বিক্রেতা রেজিস্ট্রেশন',
            ),
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Card showing selected Role
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isBuyer ? Icons.storefront_rounded : Icons.agriculture_rounded,
                          color: AppColors.primaryGreen,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBuyer ? StaticString.roleBuyer : StaticString.roleFarmer,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                              const Text(
                                'অনুগ্রহ করে নিচের সব সঠিক তথ্য ও নথিপত্র প্রদান করুন',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // General Information Section
                  const Text('মৌলিক ব্যক্তিগত তথ্য', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _controller.nameController,
                    hintText: StaticString.fullNameHint,
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _controller.phoneController,
                    hintText: StaticString.phoneHint,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _controller.emailController,
                    hintText: StaticString.emailHint,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _controller.passwordController,
                    hintText: StaticString.passwordHint,
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 24),

                  // Mandatory NID Photo Upload Section (For Both Farmer & Buyer)
                  const Text(
                    'এনআইডি (NID) কার্ডের ছবি (ক্যামেরা/গ্যালারি)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildUploadCard(
                          title: StaticString.nidFrontLabel,
                          fileName: _controller.nidFrontImageName,
                          isUploading: _controller.isUploadingNidFront,
                          onTap: () => _controller.pickNidFront(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildUploadCard(
                          title: StaticString.nidBackLabel,
                          fileName: _controller.nidBackImageName,
                          isUploading: _controller.isUploadingNidBack,
                          onTap: () => _controller.pickNidBack(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Location Section (GPS & Google Maps Auto Detection)
                  const Text(
                    'ঠিকানা ও অবস্থান (Google Maps / GPS)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 10),
                  LocationPickerCard(
                    isLoading: _controller.isDetectingLocation,
                    detectedLocation: _controller.detectedLocation,
                    onDetectLocation: () => _controller.autoDetectLocation(context),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _controller.districtController,
                          hintText: 'জেলা (যেমন: ঢাকা, রাজশাহী)',
                          prefixIcon: Icons.location_city_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomTextField(
                          controller: _controller.upazilaController,
                          hintText: 'উপজেলা/থানা (যেমন: গুলশান)',
                          prefixIcon: Icons.map_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _controller.unionController,
                          hintText: 'ইউনিয়ন/গ্রাম/এলাকা',
                          prefixIcon: Icons.holiday_village_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomTextField(
                          controller: _controller.addressController,
                          hintText: 'বিস্তারিত ঠিকানা (বাড়ি/রোড)',
                          prefixIcon: Icons.home_work_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Role-Specific Sections
                  if (isBuyer) ...[
                    // Buyer / Shopkeeper Section
                    const Text(
                      'দোকান ও ব্যবসা সংক্রান্ত তথ্য (দোকানদার/ক্রেতা)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: _controller.shopNameController,
                      hintText: StaticString.shopNameHint,
                      prefixIcon: Icons.store,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: _controller.businessLicenseController,
                      hintText: StaticString.businessLicenseNoHint,
                      prefixIcon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Trade License Photo Upload (Mandatory for Buyer)
                    const Text(
                      'ট্রেড লাইসেন্সের ছবি (ক্যামেরা/গ্যালারি)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    _buildUploadCard(
                      title: StaticString.tradeLicenseLabel,
                      fileName: _controller.tradeLicenseImageName,
                      isUploading: _controller.isUploadingTradeLicense,
                      onTap: () => _controller.pickTradeLicense(context),
                    ),
                  ] else ...[
                    // Farmer / Seller Section
                    const Text(
                      'কৃষি তথ্য (কৃষক)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: _controller.farmerTypeController,
                      hintText: StaticString.farmerTypeHint,
                      prefixIcon: Icons.grass_rounded,
                    ),
                  ],

                  const SizedBox(height: 28),

                  CustomButton(
                    text: _controller.isLoading ? 'ওটিপি পাঠানো হচ্ছে...' : 'ওটিপি সেন্ড করুন ও এগিয়ে যান',
                    onTap: _controller.isLoading ? null : () => _controller.submitRegistration(context),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String? fileName,
    required bool isUploading,
    required VoidCallback onTap,
  }) {
    final isUploaded = fileName != null;
    return InkWell(
      onTap: isUploading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.lightGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded ? AppColors.primaryGreen : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            if (isUploading)
              const SizedBox(
                height: 32,
                width: 32,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryGreen),
              )
            else
              Icon(
                isUploaded ? Icons.check_circle_rounded : Icons.add_a_photo_outlined,
                color: isUploaded ? AppColors.primaryGreen : AppColors.primaryGreen,
                size: 32,
              ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isUploaded ? FontWeight.bold : FontWeight.normal,
                color: isUploaded ? AppColors.primaryGreen : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isUploading
                  ? "আপলোড হচ্ছে..."
                  : (isUploaded ? fileName : "ক্যামেরা / গ্যালারি"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isUploaded ? AppColors.primaryGreen : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
