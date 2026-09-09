import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../../service/api_url.dart';
import '../../../Widgegt/verification_feedback_banner.dart';
import '../../Dialogs/edit_profile_dialog.dart';
import 'buyer_profile_controller.dart';

class BuyerProfileScreen extends StatefulWidget {
  const BuyerProfileScreen({super.key});

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<KrishiRepository>().loadProfileFromBackend();
      }
    });
  }

  String _toBnDigits(dynamic input) {
    const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final str = input.toString();
    final sb = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final char = str[i];
      final digit = int.tryParse(char);
      if (digit != null) {
        sb.write(bnDigits[digit]);
      } else {
        sb.write(char);
      }
    }
    return sb.toString();
  }

  void _showImagePreview(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: InteractiveViewer(
                  maxScale: 4.0,
                  child: Image.network(
                    ApiUrl.formatMediaUrl(imageUrl),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 220,
                      color: const Color(0xFFF8FAFC),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('ছবি লোড করা যায়নি', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 220,
                        color: const Color(0xFFF8FAFC),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, BuyerProfileController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('লগআউট নিশ্চিতকরণ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'আপনি কি আপনার অ্যাকাউন্ট থেকে লগআউট করতে চান?',
          style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('না', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('লগআউট', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<KrishiRepository>();
    final controller = BuyerProfileController(repo);
    final buyer = controller.buyer;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        color: const Color(0xFF166534),
        onRefresh: () => controller.refreshProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 0. Verification Feedback Banner (Shows NID rejection or verification notes)
              VerificationFeedbackBanner(
                verificationStatus: buyer.verificationStatus,
                adminNote: buyer.adminNote,
                nidStatus: buyer.nidStatus,
                nidRejectionNote: buyer.nidRejectionNote,
                currentNidNumber: buyer.nidOrDoc,
              ),

              // 1. Top Dokandar Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar & Verification Icon (Clickable to Edit)
                    InkWell(
                      onTap: () => EditProfileDialog.show(context, isFarmer: false, buyer: buyer),
                      borderRadius: BorderRadius.circular(50),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFD97706), width: 2),
                            ),
                            child: buyer.photoUrl.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      ApiUrl.formatMediaUrl(buyer.photoUrl),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Center(
                                        child: Text('🏪', style: TextStyle(fontSize: 44)),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: buyer.name.isNotEmpty
                                        ? Text(
                                            buyer.name[0].toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 34,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF92400E),
                                            ),
                                          )
                                        : const Text('🏪', style: TextStyle(fontSize: 44)),
                                  ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Color(0xFF166534),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Name
                    Text(
                      buyer.name.isNotEmpty ? buyer.name : 'দোকানদার / পাইকার',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Business Name
                    if (buyer.businessName.isNotEmpty) ...[
                      Text(
                        buyer.businessName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF166534),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],

                    // Mobile
                    Text(
                      'মোবাইল: ${_toBnDigits(buyer.phone)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Email (if available)
                    if (buyer.email.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        buyer.email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Status & ID Badges Row
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: buyer.verificationStatus == VerificationStatus.verified
                                ? const Color(0xFFDCFCE7)
                                : buyer.verificationStatus == VerificationStatus.inProgress
                                    ? const Color(0xFFE0F2FE)
                                    : buyer.verificationStatus == VerificationStatus.suspended || buyer.verificationStatus == VerificationStatus.rejected
                                        ? const Color(0xFFFEE2E2)
                                        : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: buyer.verificationStatus == VerificationStatus.verified
                                  ? const Color(0xFF86EFAC)
                                  : buyer.verificationStatus == VerificationStatus.inProgress
                                      ? const Color(0xFFBAE6FD)
                                      : buyer.verificationStatus == VerificationStatus.suspended || buyer.verificationStatus == VerificationStatus.rejected
                                          ? const Color(0xFFFCA5A5)
                                          : const Color(0xFFFDE68A),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                buyer.verificationStatus == VerificationStatus.verified
                                    ? Icons.verified
                                    : buyer.verificationStatus == VerificationStatus.inProgress
                                        ? Icons.autorenew_rounded
                                        : buyer.verificationStatus == VerificationStatus.suspended
                                            ? Icons.block_rounded
                                            : buyer.verificationStatus == VerificationStatus.rejected
                                                ? Icons.cancel_rounded
                                                : Icons.hourglass_top_rounded,
                                color: buyer.verificationStatus == VerificationStatus.verified
                                    ? const Color(0xFF166534)
                                    : buyer.verificationStatus == VerificationStatus.inProgress
                                        ? const Color(0xFF0284C7)
                                        : buyer.verificationStatus == VerificationStatus.suspended || buyer.verificationStatus == VerificationStatus.rejected
                                            ? const Color(0xFFDC2626)
                                            : const Color(0xFFD97706),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                buyer.verificationStatus == VerificationStatus.verified
                                    ? 'ভেরিফাইড ব্যবসায়ী'
                                    : buyer.verificationStatus == VerificationStatus.inProgress
                                        ? 'যাচাই প্রক্রিয়াধীন'
                                        : buyer.verificationStatus == VerificationStatus.suspended
                                            ? 'সাময়িক স্থগিত'
                                            : buyer.verificationStatus == VerificationStatus.rejected
                                                ? 'বাতিলকৃত'
                                                : 'অনুমোদনাধীন ব্যবসায়ী',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: buyer.verificationStatus == VerificationStatus.verified
                                      ? const Color(0xFF166534)
                                      : buyer.verificationStatus == VerificationStatus.inProgress
                                          ? const Color(0xFF0284C7)
                                          : buyer.verificationStatus == VerificationStatus.suspended || buyer.verificationStatus == VerificationStatus.rejected
                                              ? const Color(0xFFDC2626)
                                              : const Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (buyer.tradeInfo.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Text(
                              'ট্রেড: ${buyer.tradeInfo}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        if (buyer.id.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Text(
                              'ID: ${buyer.id}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Quick Stats Row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'রেটিং',
                            '⭐ ${_toBnDigits(buyer.rating.toStringAsFixed(1))}',
                            const Color(0xFFD97706),
                          ),
                          Container(height: 28, width: 1, color: const Color(0xFFE2E8F0)),
                          _buildStatItem(
                            'ক্রয় অর্ডার',
                            '${_toBnDigits(buyer.completedOrders)} টি',
                            const Color(0xFF166534),
                          ),
                          Container(height: 28, width: 1, color: const Color(0xFFE2E8F0)),
                          _buildStatItem(
                            'পেমেন্ট বিশ্বাস্যতা',
                            '${_toBnDigits(buyer.paymentReliability)}%',
                            const Color(0xFF0284C7),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Edit Profile Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () => EditProfileDialog.show(context, isFarmer: false, buyer: buyer),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF166534),
                          side: const BorderSide(color: Color(0xFF86EFAC), width: 1.5),
                          backgroundColor: const Color(0xFFF0FDF4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.edit_note_rounded, size: 20),
                        label: const Text(
                          'দোকান ও প্রোফাইল তথ্য এডিট করুন',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Business & Address Card ("দোকান ও ব্যবসার তথ্য এবং ঠিকানা")
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.storefront_rounded, color: Color(0xFF166534), size: 22),
                            SizedBox(width: 8),
                            Text(
                              'ব্যবসা ও দোকানের তথ্য ও ঠিকানা',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.edit_location_alt_outlined, size: 16, color: Color(0xFF166534)),
                          label: const Text(
                            'তথ্য পরিবর্তন',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                          ),
                          onPressed: () => EditProfileDialog.show(context, isFarmer: false, buyer: buyer),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ),

                    _buildInfoRow(
                      'দোকান / ব্যবসার নাম:',
                      buyer.businessName.isNotEmpty ? buyer.businessName : 'তথ্য দেওয়া হয়নি',
                      isBold: true,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'ব্যবসার ধরণ:',
                      buyer.businessType.isNotEmpty ? buyer.businessType : 'পাইকারি ব্যবসায়ী / আড়তদার',
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'ট্রেড লাইসেন্স নম্বর:',
                      buyer.tradeInfo.isNotEmpty ? buyer.tradeInfo : 'তথ্য দেওয়া হয়নি',
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'জেলা ও আড়ত এলাকা:',
                      '${buyer.district.isNotEmpty ? buyer.district : 'তথ্য দেওয়া হয়নি'}${buyer.area.isNotEmpty ? ', ${buyer.area}' : ''}',
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'বিস্তারিত ঠিকানা:',
                      buyer.address.isNotEmpty ? buyer.address : 'তথ্য দেওয়া হয়নি',
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'সম্পন্ন ক্রয় অর্ডার:',
                      '${_toBnDigits(buyer.completedOrders)} টি',
                      isBold: true,
                      color: const Color(0xFF166534),
                    ),
                    if (buyer.productsCount > 0) ...[
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        'পোস্ট করা চাহিদা:',
                        '${_toBnDigits(buyer.productsCount)} টি',
                      ),
                    ],
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'পেমেন্ট বিশ্বাসযোগ্যতা:',
                      '${_toBnDigits(buyer.paymentReliability)}%',
                      isBold: true,
                      color: const Color(0xFF0284C7),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'রেটিং ও সুনাম:',
                      buyer.reviewsCount > 0
                          ? '⭐ ${_toBnDigits(buyer.rating.toStringAsFixed(1))} (${_toBnDigits(buyer.reviewsCount)} রিভিউ)'
                          : '⭐ নতুন ক্রেতা (০ রিভিউ)',
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Documents Card (Trade License & NID)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.badge_outlined, color: Color(0xFF166534), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'ট্রেড লাইসেন্স ও জাতীয় পরিচয়পত্র',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ),

                    if (buyer.tradeLicenseUrl.isNotEmpty ||
                        buyer.nidFrontUrl.isNotEmpty ||
                        buyer.nidBackUrl.isNotEmpty) ...[
                      // Trade License Document (if available)
                      if (buyer.tradeLicenseUrl.isNotEmpty) ...[
                        _buildDocumentPreview(
                          title: 'ট্রেড লাইসেন্স ডকুমেন্ট',
                          imageUrl: buyer.tradeLicenseUrl,
                          context: context,
                        ),
                        if (buyer.nidFrontUrl.isNotEmpty || buyer.nidBackUrl.isNotEmpty)
                          const SizedBox(height: 12),
                      ],

                      // NID Front & Back (if available)
                      if (buyer.nidFrontUrl.isNotEmpty || buyer.nidBackUrl.isNotEmpty) ...[
                        Row(
                          children: [
                            if (buyer.nidFrontUrl.isNotEmpty)
                              Expanded(
                                child: _buildDocumentPreview(
                                  title: 'NID সামনের অংশ',
                                  imageUrl: buyer.nidFrontUrl,
                                  context: context,
                                ),
                              ),
                            if (buyer.nidFrontUrl.isNotEmpty && buyer.nidBackUrl.isNotEmpty)
                              const SizedBox(width: 12),
                            if (buyer.nidBackUrl.isNotEmpty)
                              Expanded(
                                child: _buildDocumentPreview(
                                  title: 'NID পেছনের অংশ',
                                  imageUrl: buyer.nidBackUrl,
                                  context: context,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFF64748B), size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'রেজিস্ট্রেশনের সময় আপলোড করা ট্রেড লাইসেন্স ও জাতীয় পরিচয়পত্রের কপি এখানে সংরক্ষিত রয়েছে।',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. Action Buttons (Refresh & Logout)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.refreshProfile(),
                      icon: const Icon(Icons.refresh, color: Color(0xFF166534), size: 18),
                      label: const Text(
                        'রিফ্রেশ করুন',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF166534),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF166534)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutDialog(context, controller),
                      icon: const Icon(Icons.logout, color: Colors.white, size: 18),
                      label: const Text(
                        'লগআউট',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentPreview({
    required String title,
    required String imageUrl,
    required BuildContext context,
  }) {
    final formattedUrl = ApiUrl.formatMediaUrl(imageUrl);
    return InkWell(
      onTap: () => _showImagePreview(context, formattedUrl, title),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          color: const Color(0xFFF8FAFC),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              child: AspectRatio(
                aspectRatio: 1.6,
                child: Image.network(
                  formattedUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFF1F5F9),
                    child: const Center(
                      child: Icon(Icons.image_outlined, color: Colors.grey, size: 30),
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.fullscreen, size: 16, color: Color(0xFF166534)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
