import 'package:flutter/material.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../Widgegt/custom_button/custom_button.dart';
import '../../../Widgegt/custom_text_field/custom_text_field.dart';
import 'otp_verification_controller.dart';

class OtpVerificationScreen extends StatefulWidget {
  final UserRole role;
  final String email;
  final String phone;

  const OtpVerificationScreen({
    super.key,
    required this.role,
    required this.email,
    required this.phone,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final OtpVerificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OtpVerificationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> signupArgs =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
            {
              'role': widget.role,
              'email': widget.email,
              'phone': widget.phone,
            };

    final displayEmail = signupArgs['email'] ?? widget.email;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text(StaticString.otpTitle),
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.lightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_read_rounded,
                        size: 64,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    StaticString.otpTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'আপনার জিমেইলে পাঠানো ৬-সংখ্যার ওটিপি (OTP) লিখুন\n($displayEmail)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // PIN Input Field Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '৬-সংখ্যার ওটিপি (OTP) কোড দিন',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _controller.pinController,
                          hintText: 'উদাহরণ: ৪৮২৯১০',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.security,
                        ),
                        if (_controller.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _controller.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: 24),
                        CustomButton(
                          text: _controller.isLoading ? 'ভেরিফাই করা হচ্ছে...' : 'ওটিপি ভেরিফাই ও একাউন্ট খুলুন',
                          onTap: _controller.isLoading
                              ? null
                              : () => _controller.verifyOtpAndSignup(
                                    context: context,
                                    signupArgs: signupArgs,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('নতুন ওটিপি কোড জিমেইলে পুনঃপ্রেরণ করা হয়েছে!'),
                            backgroundColor: AppColors.primaryGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGreen),
                      label: const Text(
                        'কোড পাননি? পুনরায় ওটিপি পাঠান',
                        style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
