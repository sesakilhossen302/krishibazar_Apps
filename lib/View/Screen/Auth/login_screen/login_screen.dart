import 'package:flutter/material.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../Widgegt/custom_button/custom_button.dart';
import '../../../Widgegt/custom_text_field/custom_text_field.dart';
import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  // Header Logo & Branding
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.agriculture_rounded,
                        size: 56,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    StaticString.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    StaticString.loginSubTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Form Container Card
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
                          StaticString.emailLabel,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _controller.emailController,
                          hintText: StaticString.emailHint,
                          prefixIcon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          StaticString.passwordLabel,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _controller.passwordController,
                          hintText: StaticString.passwordHint,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline,
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
                          text: _controller.isLoading ? StaticString.loading : StaticString.loginButton,
                          onTap: _controller.isLoading ? null : () => _controller.onLoginClick(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Create Account Navigation Text Prompt
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          StaticString.noAccountPrompt,
                          style: TextStyle(fontSize: 14, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => _controller.onNavigateToRoleSelection(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryGreen),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primaryGreen),
                          label: const Text(
                            StaticString.createAccountButton,
                            style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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
