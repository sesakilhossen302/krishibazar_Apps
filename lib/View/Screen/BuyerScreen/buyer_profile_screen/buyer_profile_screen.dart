import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../../helper/shared_pref/shared_pref_helper.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../../Widgegt/image_picker_dialog/image_picker_dialog.dart';
import '../../../Widgegt/verification_feedback_banner.dart';
import '../../Dialogs/edit_profile_dialog.dart';
import 'buyer_profile_controller.dart';

class BuyerProfileScreen extends StatefulWidget {
  const BuyerProfileScreen({super.key});

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  bool _isUploadingDoc = false;

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

  /// Full screen zoomable image preview with ZERO layout overflow
  void _showImagePreview(BuildContext context, String imageUrl, String title) {
    if (imageUrl.trim().isEmpty) return;
    final formattedUrl = ApiUrl.formatMediaUrl(imageUrl);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.82,
            maxWidth: 520,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.zoom_in_rounded, color: Color(0xFF166534), size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Image viewer wrapped in Flexible to strictly prevent RenderFlex overflow
              Flexible(
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF0F172A),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          formattedUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 240,
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
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Avatar tap action sheet: option to view photo or edit
  void _onAvatarTap(BuildContext context, BuyerProfile buyer) {
    if (buyer.photoUrl.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.zoom_in_rounded, color: Color(0xFF166534), size: 28),
                title: const Text('প্রোফাইল ছবি বড় করে দেখুন', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showImagePreview(context, buyer.photoUrl, '${buyer.name} - প্রোফাইল ছবি');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Color(0xFFD97706), size: 28),
                title: const Text('প্রোফাইল তথ্য ও ছবি পরিবর্তন করুন', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  EditProfileDialog.show(context, isFarmer: false, buyer: buyer);
                },
              ),
            ],
          ),
        ),
      );
    } else {
      EditProfileDialog.show(context, isFarmer: false, buyer: buyer);
    }
  }

  /// Pick & upload document (Trade License, NID Front, NID Back)
  Future<void> _uploadDocument({
    required String docKey,
    required String successMsg,
  }) async {
    final File? file = await ImagePickerDialog.showImageSourceSelector(context);
    if (file == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isUploadingDoc = true);

    try {
      final uploadRes = await ApiClient.uploadImageFile(file);
      if (uploadRes['success'] != true) {
        throw Exception(uploadRes['message'] ?? 'ছবি আপলোড করতে সমস্যা হয়েছে');
      }

      final uploadedUrl = (uploadRes['full_url'] ??
              uploadRes['url'] ??
              uploadRes['file_url'] ??
              uploadRes['data']?['file_url'] ??
              uploadRes['data']?['url'] ??
              '')
          .toString();

      if (uploadedUrl.isEmpty) {
        throw Exception('সার্ভার থেকে সঠিক ইউআরএল পাওয়া যায়নি');
      }

      final token = await SharedPrefHelper.getToken();
      final userId = await SharedPrefHelper.getUserId();

      final updateRes = await ApiClient.updateUserProfile(
        token: token.isNotEmpty ? token : null,
        userId: userId.isNotEmpty ? userId : null,
        updateData: {
          docKey: uploadedUrl,
        },
      );

      if (updateRes['success'] == true) {
        if (mounted) {
          await context.read<KrishiRepository>().loadProfileFromBackend();
          messenger.showSnackBar(
            SnackBar(
              content: Text('$successMsg ✅'),
              backgroundColor: const Color(0xFF166534),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw Exception(updateRes['message'] ?? 'প্রোফাইল আপডেট ব্যর্থ হয়েছে');
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('ব্যর্থ হয়েছে: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingDoc = false);
    }
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
      body: Stack(
        children: [
          RefreshIndicator(
            color: const Color(0xFF166534),
            onRefresh: () => controller.refreshProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 0. Verification Feedback Banner
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
                        // Avatar (Clickable: zoom or edit)
                        InkWell(
                          onTap: () => _onAvatarTap(context, buyer),
                          borderRadius: BorderRadius.circular(50),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFD97706), width: 2.5),
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
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF166534),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 14,
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

                        // Trade License Row with DIRECT view/upload button
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ট্রেড লাইসেন্স নম্বর:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    buyer.tradeInfo.isNotEmpty
                                        ? buyer.tradeInfo
                                        : (buyer.tradeLicenseUrl.isNotEmpty ? 'লাইসেন্স সংযুক্ত' : 'তথ্য দেওয়া হয়নি'),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (buyer.tradeLicenseUrl.isNotEmpty) ...[
                                    InkWell(
                                      onTap: () => _showImagePreview(
                                        context,
                                        buyer.tradeLicenseUrl,
                                        'ট্রেড লাইসেন্স ডকুমেন্ট',
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFF86EFAC)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.visibility_rounded, size: 13, color: Color(0xFF166534)),
                                            SizedBox(width: 4),
                                            Text(
                                              'ট্রেড লাইসেন্স দেখুন 📄',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF166534),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    InkWell(
                                      onTap: () => _uploadDocument(
                                        docKey: 'trade_license_url',
                                        successMsg: 'ট্রেড লাইসেন্স সফলভাবে আপলোড সম্পন্ন হয়েছে',
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFFCBD5E1)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.upload_file_rounded, size: 13, color: Color(0xFF475569)),
                                            SizedBox(width: 4),
                                            Text(
                                              '+ লাইসেন্স আপলোড করুন',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
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

                  // 3. Documents Card (Trade License & NID Cards)
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
                            Icon(Icons.badge_outlined, color: Color(0xFF166534), size: 22),
                            SizedBox(width: 8),
                            Text(
                              'ট্রেড লাইসেন্স ও জাতীয় পরিচয়পত্র ডকুমেন্টস',
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

                        // A. Trade License Document Section (Always available)
                        const Text(
                          '১. ট্রেড লাইসেন্স ডকুমেন্ট:',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (buyer.tradeLicenseUrl.isNotEmpty) ...[
                          _buildDocumentPreviewCard(
                            title: 'ট্রেড লাইসেন্স ডকুমেন্ট',
                            imageUrl: buyer.tradeLicenseUrl,
                            onView: () => _showImagePreview(
                              context,
                              buyer.tradeLicenseUrl,
                              'ট্রেড লাইসেন্স ডকুমেন্ট',
                            ),
                            onChange: () => _uploadDocument(
                              docKey: 'trade_license_url',
                              successMsg: 'ট্রেড লাইসেন্স সফলভাবে পরিবর্তন সম্পন্ন হয়েছে',
                            ),
                          ),
                        ] else ...[
                          _buildEmptyDocumentCard(
                            title: 'ট্রেড লাইসেন্স আপলোড করা হয়নি',
                            description: 'আপনার ব্যবসা/দোকানের ট্রেড লাইসেন্স যুক্ত করুন',
                            icon: Icons.receipt_long_rounded,
                            onUpload: () => _uploadDocument(
                              docKey: 'trade_license_url',
                              successMsg: 'ট্রেড লাইসেন্স সফলভাবে আপলোড সম্পন্ন হয়েছে',
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        // B. NID Documents Section (Front & Back)
                        const Text(
                          '২. জাতীয় পরিচয়পত্র (NID) ডকুমেন্টস:',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // NID Front
                        if (buyer.nidFrontUrl.isNotEmpty) ...[
                          _buildDocumentPreviewCard(
                            title: 'NID কার্ড (সামনের দিক)',
                            imageUrl: buyer.nidFrontUrl,
                            onView: () => _showImagePreview(
                              context,
                              buyer.nidFrontUrl,
                              'NID কার্ড (সামনের দিক)',
                            ),
                            onChange: () => _uploadDocument(
                              docKey: 'nid_front_url',
                              successMsg: 'এনআইডি সামনের ছবি পরিবর্তন সম্পন্ন হয়েছে',
                            ),
                          ),
                        ] else ...[
                          _buildEmptyDocumentCard(
                            title: 'এনআইডি (সামনের দিক) আপলোড করা হয়নি',
                            description: 'জাতীয় পরিচয়পত্রের সামনের অংশের ছবি যুক্ত করুন',
                            icon: Icons.credit_card_rounded,
                            onUpload: () => _uploadDocument(
                              docKey: 'nid_front_url',
                              successMsg: 'এনআইডি সামনের ছবি আপলোড সম্পন্ন হয়েছে',
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),

                        // NID Back
                        if (buyer.nidBackUrl.isNotEmpty) ...[
                          _buildDocumentPreviewCard(
                            title: 'NID কার্ড (পেছনের দিক)',
                            imageUrl: buyer.nidBackUrl,
                            onView: () => _showImagePreview(
                              context,
                              buyer.nidBackUrl,
                              'NID কার্ড (পেছনের দিক)',
                            ),
                            onChange: () => _uploadDocument(
                              docKey: 'nid_back_url',
                              successMsg: 'এনআইডি পেছনের ছবি পরিবর্তন সম্পন্ন হয়েছে',
                            ),
                          ),
                        ] else ...[
                          _buildEmptyDocumentCard(
                            title: 'এনআইডি (পেছনের দিক) আপলোড করা হয়নি',
                            description: 'জাতীয় পরিচয়পত্রের পেছনের অংশের ছবি যুক্ত করুন',
                            icon: Icons.credit_card_rounded,
                            onUpload: () => _uploadDocument(
                              docKey: 'nid_back_url',
                              successMsg: 'এনআইডি পেছনের ছবি আপলোড সম্পন্ন হয়েছে',
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

          // Uploading loading overlay
          if (_isUploadingDoc)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF166534)),
                        SizedBox(height: 14),
                        Text('ডকুমেন্ট আপলোড হচ্ছে, অপেক্ষা করুন...', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
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

  Widget _buildDocumentPreviewCard({
    required String title,
    required String imageUrl,
    required VoidCallback onView,
    required VoidCallback onChange,
  }) {
    final formattedUrl = ApiUrl.formatMediaUrl(imageUrl);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'সংযুক্ত ✓',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          InkWell(
            onTap: onView,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1.8,
                  child: Image.network(
                    formattedUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: Icon(Icons.image_outlined, color: Colors.grey, size: 36),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_in_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'বড় করে দেখুন',
                          style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onView,
                    icon: const Icon(Icons.visibility_outlined, size: 15, color: Color(0xFF166534)),
                    label: const Text(
                      'বড় করে দেখুন',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF86EFAC)),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onChange,
                  icon: const Icon(Icons.photo_camera_outlined, size: 15, color: Color(0xFF475569)),
                  label: const Text(
                    'পরিবর্তন',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDocumentCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onUpload,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF475569), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_file_rounded, size: 15, color: Colors.white),
            label: const Text('আপলোড', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
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
