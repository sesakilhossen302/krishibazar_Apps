import 'package:flutter/material.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../Widgegt/custom_button/custom_button.dart';
import '../../../Widgegt/custom_text_field/custom_text_field.dart';
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
                  Text('মৌলিক ব্যক্তিগত তথ্য', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
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
                  Text(
                    'এনআইডি (NID) কার্ডের ছবি (বাধ্যতামূলক)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildUploadCard(
                          title: StaticString.nidFrontLabel,
                          fileName: _controller.nidFrontImageName,
                          onTap: _controller.pickNidFront,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildUploadCard(
                          title: StaticString.nidBackLabel,
                          fileName: _controller.nidBackImageName,
                          onTap: _controller.pickNidBack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Role-Specific Sections
                  if (isBuyer) ...[
                    // Buyer / Shopkeeper Section
                    Text(
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
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: _controller.shopLocationController,
                      hintText: StaticString.shopLocationHint,
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Trade License Photo Upload (Mandatory for Buyer)
                    Text(
                      'ট্রেড লাইসেন্সের ছবি (বাধ্যতামূলক)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    _buildUploadCard(
                      title: StaticString.tradeLicenseLabel,
                      fileName: _controller.tradeLicenseImageName,
                      onTap: _controller.pickTradeLicense,
                    ),
                  ] else ...[
                    // Farmer / Seller Section
                    Text(
                      'কৃষি তথ্য ও এলাকা (কৃষক)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: _controller.farmerTypeController,
                      hintText: StaticString.farmerTypeHint,
                      prefixIcon: Icons.grass_rounded,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: _controller.farmerLocationController,
                      hintText: StaticString.farmerLocationHint,
                      prefixIcon: Icons.my_location_rounded,
                    ),
                  ],

                  if (_controller.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _controller.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),

                  CustomButton(
                    text: _controller.isLoading ? StaticString.loading : StaticString.registerSubmitButton,
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
    required VoidCallback onTap,
  }) {
    final isUploaded = fileName != null;
    return InkWell(
      onTap: onTap,
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
            Icon(
              isUploaded ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
              color: isUploaded ? AppColors.primaryGreen : AppColors.textMuted,
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
              isUploaded ? fileName : StaticString.uploadPhotoPrompt,
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
