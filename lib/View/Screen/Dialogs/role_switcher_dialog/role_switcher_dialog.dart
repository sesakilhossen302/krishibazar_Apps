import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import 'role_switcher_controller.dart';

class RoleSwitcherDialog extends StatelessWidget {
  const RoleSwitcherDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<KrishiRepository>();
    final controller = RoleSwitcherController(repo);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.swap_horiz, color: AppColors.primaryGreen),
          SizedBox(width: 8),
          Text(StaticString.selectRole, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: UserRole.values.map((role) {
          final isSelected = controller.currentRole == role;
          return Card(
            color: isSelected ? AppColors.lightGreen : Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(role.labelBn, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.primaryGreen : Colors.black)),
              trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primaryGreen) : null,
              onTap: () => controller.switchRole(role),
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(onPressed: controller.close, child: const Text(StaticString.close)),
      ],
    );
  }
}
