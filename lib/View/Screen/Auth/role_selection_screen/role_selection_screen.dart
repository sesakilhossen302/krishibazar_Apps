import 'package:flutter/material.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../Widgegt/custom_button/custom_button.dart';
import 'role_selection_controller.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  late final RoleSelectionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RoleSelectionController();
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
          appBar: AppBar(
            title: const Text(StaticString.selectRoleTitle),
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    StaticString.selectRoleSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Farmer Role Option
                  _buildRoleCard(
                    role: UserRole.farmer,
                    icon: Icons.agriculture_rounded,
                    title: StaticString.roleFarmer,
                    subtitle: 'উৎপাদিত ফসল সরাসরি পাইকারি বাজারে বিক্রি করুন',
                    isSelected: _controller.selectedRole == UserRole.farmer,
                    onTap: () => _controller.selectRole(UserRole.farmer),
                  ),
                  const SizedBox(height: 16),

                  // Buyer Role Option
                  _buildRoleCard(
                    role: UserRole.buyer,
                    icon: Icons.storefront_rounded,
                    title: StaticString.roleBuyer,
                    subtitle: 'সরাসরি কৃষকদের থেকে পাইকারি ফসল বা আরতে মাল কিনুন',
                    isSelected: _controller.selectedRole == UserRole.buyer,
                    onTap: () => _controller.selectRole(UserRole.buyer),
                  ),
                  const Spacer(),

                  CustomButton(
                    text: 'পরবর্তী ধাপে যান (রেজিস্ট্রেশন)',
                    onTap: () => _controller.onProceedToRegister(context),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : AppColors.backgroundLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.white : AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primaryGreen : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryGreen,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
