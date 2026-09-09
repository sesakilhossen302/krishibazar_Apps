import 'package:flutter/material.dart';
import '../../global/Model/krishi_models.dart';
import '../Screen/Dialogs/reupload_nid_dialog.dart';

class VerificationFeedbackBanner extends StatelessWidget {
  final VerificationStatus verificationStatus;
  final String adminNote;
  final String nidStatus;
  final String nidRejectionNote;
  final String currentNidNumber;

  const VerificationFeedbackBanner({
    super.key,
    required this.verificationStatus,
    this.adminNote = '',
    this.nidStatus = 'pending',
    this.nidRejectionNote = '',
    this.currentNidNumber = '',
  });

  @override
  Widget build(BuildContext context) {
    final bool isNidRejected = nidStatus.toLowerCase() == 'rejected';
    final bool isSuspended = verificationStatus == VerificationStatus.suspended;
    final bool isRejected = verificationStatus == VerificationStatus.rejected;
    final bool isInProgress = verificationStatus == VerificationStatus.inProgress;
    final bool isPending = verificationStatus == VerificationStatus.pending;

    // If completely verified and NID is not rejected, hide banner
    if (verificationStatus == VerificationStatus.verified && !isNidRejected) {
      return const SizedBox.shrink();
    }

    // 1. NID REJECTED (High Priority Alert)
    if (isNidRejected) {
      final reason = nidRejectionNote.isNotEmpty
          ? nidRejectionNote
          : (adminNote.isNotEmpty ? adminNote : 'প্রদত্ত তথ্যের সাথে এনআইডি কার্ডের অমিল রয়েছে');

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'এনআইডি (NID) কার্ড বাতিল করা হয়েছে ❌',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                      Text(
                        'পুনরায় সঠিক ও পরিষ্কার ছবি আপলোড প্রয়োজন',
                        style: TextStyle(fontSize: 11, color: Color(0xFFB91C1C)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Text(
                'অ্যাডমিনের কারণ: $reason',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7F1D1D),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ReuploadNidDialog.show(
                    context,
                    currentNid: currentNidNumber,
                    rejectionReason: reason,
                  );
                },
                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                label: const Text(
                  'নতুন এনআইডি ছবি আপলোড করুন 📸',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 2. ACCOUNT SUSPENDED
    if (isSuspended) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFDBA74), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFEA580C),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.block_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'অ্যাকাউন্ট সাময়িক স্থগিত (Suspended 🚫)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9A3412),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    adminNote.isNotEmpty
                        ? 'অ্যাডমিনের কারণ: $adminNote'
                        : 'নিয়মভঙ্গ বা তথ্যের গরমিলের কারণে আপনার অ্যাকাউন্ট স্থগিত করা হয়েছে।',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFC2410C), height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 3. ACCOUNT REJECTED
    if (isRejected) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFDC2626),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'অ্যাকাউন্ট আবেদন বাতিল (Rejected ❌)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    adminNote.isNotEmpty
                        ? 'কারণ: $adminNote'
                        : 'প্রয়োজনীয় তথ্যের গরমিলের কারণে অ্যাকাউন্ট আবেদনটি বাতিল করা হয়েছে।',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C), height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 4. IN PROGRESS
    if (isInProgress) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF0284C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.autorenew_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'তথ্য যাচাই প্রক্রিয়াধীন (In Progress 🔄)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0369A1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'অ্যাডমিন টিম আপনার জাতীয় পরিচয়পত্র ও তথ্যাদি পর্যালোচনা করছেন। শীঘ্রই যাচাই সম্পন্ন হবে।',
                    style: TextStyle(fontSize: 12, color: Color(0xFF075985), height: 1.4),
                  ),
                  if (adminNote.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'অ্যাডমিন নোট: $adminNote',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 5. PENDING
    if (isPending) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFD97706),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hourglass_top_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'যাচাইকরণের অপেক্ষায় (Pending ⏳)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'আপনার অ্যাকাউন্টটি অ্যাডমিন যাচাইয়ের জন্য অপেক্ষমাণ রয়েছে।',
                    style: TextStyle(fontSize: 12, color: Color(0xFFB45309), height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
