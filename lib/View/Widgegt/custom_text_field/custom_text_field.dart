import 'package:flutter/material.dart';
import '../../../Utils/AppColors/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final String? hint;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHint = hintText ?? hint;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: effectiveHint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primaryGreen) : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
        ),
      ),
    );
  }
}
