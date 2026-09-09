import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../../service/api_url.dart';
import '../../../Widgegt/Cards/status_badge.dart';
import '../../../Widgegt/verification_feedback_banner.dart';
import 'buyer_profile_controller.dart';

class BuyerProfileScreen extends StatelessWidget {
  const BuyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<KrishiRepository>();
    final controller = BuyerProfileController(repo);
    final buyer = controller.buyer;
    Color badgeBg;
    Color badgeFg;
    String badgeText;

    switch (buyer.verificationStatus) {
      case VerificationStatus.verified:
        badgeBg = const Color(0xFFDCFCE7);
        badgeFg = const Color(0xFF166534);
        badgeText = 'ভেরিফাইড পাইকার ✅';
        break;
      case VerificationStatus.inProgress:
        badgeBg = const Color(0xFFE0F2FE);
        badgeFg = const Color(0xFF0284C7);
        badgeText = 'যাচাই প্রক্রিয়াধীন 🔄';
        break;
      case VerificationStatus.suspended:
        badgeBg = const Color(0xFFFFEDD5);
        badgeFg = const Color(0xFFEA580C);
        badgeText = 'অ্যাকাউন্ট স্থগিত 🚫';
        break;
      case VerificationStatus.rejected:
        badgeBg = const Color(0xFFFEE2E2);
        badgeFg = const Color(0xFFDC2626);
        badgeText = 'আবেদন বাতিল ❌';
        break;
      case VerificationStatus.pending:
        badgeBg = const Color(0xFFFEF3C7);
        badgeFg = const Color(0xFFD97706);
        badgeText = 'অনুমোদনাধীন (অপেক্ষমাণ) ⏳';
        break;
    }

    return RefreshIndicator(
      onRefresh: () async {
        await repo.loadProfileFromBackend();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            VerificationFeedbackBanner(
              verificationStatus: buyer.verificationStatus,
              adminNote: buyer.adminNote,
              nidStatus: buyer.nidStatus,
              nidRejectionNote: buyer.nidRejectionNote,
              currentNidNumber: '',
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: repo.isProfileLoading ? null : () => repo.loadProfileFromBackend(),
                          icon: repo.isProfileLoading
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('রিফ্রেশ করুন', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryGold.withValues(alpha: 0.3),
                      backgroundImage: (buyer.photoUrl.isNotEmpty)
                          ? NetworkImage(ApiUrl.formatMediaUrl(buyer.photoUrl))
                          : null,
                      child: (buyer.photoUrl.isEmpty)
                          ? Text(buyer.name.isNotEmpty ? buyer.name[0] : 'ব', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.brown))
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(buyer.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(buyer.businessName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(buyer.businessType, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(height: 10),
                    StatusBadge(
                      label: badgeText,
                      backgroundColor: badgeBg,
                      textColor: badgeFg,
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildProfileStat('রেটিং', '⭐ ${buyer.rating}'),
                        _buildProfileStat('ক্রয় অর্ডার', '${buyer.completedOrders}টি'),
                        _buildProfileStat('পেমেন্ট বিশ্বাসযোগ্যতা', '${buyer.paymentReliability}%'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ব্যবসা ও ঠিকানা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.phone, 'ফোন নাম্বার', buyer.phone),
                  _buildInfoRow(Icons.store, 'আড়ত/ব্যবসার স্থান', '${buyer.district}, ${buyer.area}'),
                  _buildInfoRow(Icons.location_on, 'বিস্তারিত ঠিকানা', buyer.address),
                  _buildInfoRow(Icons.receipt_long, 'ট্রেড লাইসেন্স/ডকুমেন্ট', buyer.tradeInfo),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
