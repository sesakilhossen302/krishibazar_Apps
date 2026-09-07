import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../global/controller/krishi_controller.dart';

class NotificationsDialog extends StatelessWidget {
  const NotificationsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<KrishiController>();
    final notifs = controller.notifications;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.notifications, color: AppColors.primaryGreen),
          SizedBox(width: 8),
          Text('নোটিফিকেশন সেন্টার', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: notifs.isEmpty
            ? const Padding(padding: EdgeInsets.all(16), child: Text('কোনো নতুন নোটিফিকেশন নেই'))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: notifs.length,
                itemBuilder: (context, index) {
                  final notif = notifs[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(notif.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(notif.message, style: const TextStyle(fontSize: 12)),
                    trailing: Text(notif.timestamp, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  );
                },
              ),
      ),
      actions: [
        TextButton(onPressed: () => controller.closeNotifications(), child: const Text('বন্ধ করুন')),
      ],
    );
  }
}
