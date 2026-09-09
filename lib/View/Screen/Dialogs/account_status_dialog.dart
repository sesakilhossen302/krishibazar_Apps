import 'package:flutter/material.dart';

class AccountStatusDialog extends StatelessWidget {
  final String status;
  final String adminNote;
  final String userName;

  const AccountStatusDialog({
    super.key,
    required this.status,
    required this.adminNote,
    this.userName = '',
  });

  static Future<void> show(
    BuildContext context, {
    required String status,
    required String adminNote,
    String userName = '',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AccountStatusDialog(
        status: status,
        adminNote: adminNote,
        userName: userName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSuspended = status.toLowerCase() == 'suspended';

    final Color primaryColor = isSuspended ? const Color(0xFFEA580C) : const Color(0xFFDC2626);
    final Color bgColor = isSuspended ? const Color(0xFFFFF7ED) : const Color(0xFFFEF2F2);
    final Color borderColor = isSuspended ? const Color(0xFFFDBA74) : const Color(0xFFFCA5A5);

    final title = isSuspended
        ? 'অ্যাকাউন্ট সাময়িক স্থগিত 🚫'
        : 'অ্যাকাউন্ট আবেদন বাতিলকৃত ❌';

    final subtitle = isSuspended
        ? 'আপনার অ্যাকাউন্টটি অ্যাডমিন কর্তৃক সাময়িকভাবে স্থগিত করা হয়েছে।'
        : 'আপনার অ্যাকাউন্ট যাচাই আবেদনটি অ্যাডমিন কর্তৃক বাতিল করা হয়েছে।';

    final note = adminNote.trim().isNotEmpty
        ? adminNote.trim()
        : (isSuspended
            ? 'নিয়মভঙ্গ বা অসম্পূর্ণ তথ্যের কারণে সাময়িক স্থগিত।'
            : 'প্রদত্ত তথ্যের অসংগতির কারণে বাতিল করা হয়েছে।');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Icon Container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Icon(
                isSuspended ? Icons.block_rounded : Icons.cancel_outlined,
                color: primaryColor,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Admin Note Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notes_rounded, size: 16, color: primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        'অ্যাডমিনের নোট / কারণ:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    note,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'ঠিক আছে, বুঝতে পেরেছি',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
