import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../../../service/location_service.dart';
import '../../../../helper/shared_pref/shared_pref_helper.dart';
import '../../../Widgegt/custom_text_field/custom_text_field.dart';
import '../../../Widgegt/location_picker_card.dart';
import 'farmer_profile_controller.dart';

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
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

  void _showLogoutDialog(BuildContext context, FarmerProfileController controller) {
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
    final controller = FarmerProfileController(repo);
    final farmer = controller.farmer;

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
              // 1. Top Farmer Profile Card
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
                    // Avatar & Verification Icon
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF166534), width: 2),
                          ),
                          child: farmer.photoUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    ApiUrl.formatMediaUrl(farmer.photoUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Center(
                                      child: Text('👨‍🌾', style: TextStyle(fontSize: 44)),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Text('👨‍🌾', style: TextStyle(fontSize: 44)),
                                ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF166534),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Name
                    Text(
                      farmer.name.isNotEmpty ? farmer.name : 'কৃষক',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Mobile
                    Text(
                      'মোবাইল: ${_toBnDigits(farmer.phone)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Email (if available)
                    if (farmer.email.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        farmer.email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Status Badge Row
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, color: Color(0xFF166534), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                farmer.verificationStatus == VerificationStatus.verified
                                    ? 'ভেরিফাইড কৃষক'
                                    : 'অনুমোদনাধীন কৃষক',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF166534),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (farmer.id.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Text(
                              'ID: ${farmer.id}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Farm Info Card ("খামারের তথ্য ও ঠিকানা")
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
                            Icon(Icons.location_on_outlined, color: Color(0xFF166534), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'খামারের তথ্য ও ঠিকানা',
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
                            'ঠিকানা পরিবর্তন',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                          ),
                          onPressed: () => _showLocationUpdateDialog(context, farmer),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ),

                    _buildInfoRow('জেলা:', farmer.district.isNotEmpty ? farmer.district : 'তথ্য দেওয়া হয়নি'),
                    const SizedBox(height: 10),
                    _buildInfoRow('উপজেলা / অবস্থান:', farmer.upazila.isNotEmpty ? farmer.upazila : 'তথ্য দেওয়া হয়নি'),
                    const SizedBox(height: 10),
                    _buildInfoRow('ইউনিয়ন / গ্রাম:', farmer.union.isNotEmpty ? farmer.union : 'তথ্য দেওয়া হয়নি'),
                    const SizedBox(height: 10),
                    _buildInfoRow('কৃষকের ধরন / ফসল:', farmer.farmerType.isNotEmpty ? farmer.farmerType : 'তথ্য দেওয়া হয়নি'),
                    const SizedBox(height: 10),
                    _buildInfoRow('বিস্তারিত ঠিকানা:', farmer.address.isNotEmpty ? farmer.address : 'তথ্য দেওয়া হয়নি'),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'সম্পন্ন অর্ডার:',
                      '${_toBnDigits(farmer.totalCompletedOrders)} টি',
                      isBold: true,
                      color: const Color(0xFF166534),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'রেটিং ও সুনাম:',
                      farmer.reviewsCount > 0
                          ? '⭐ ${_toBnDigits(farmer.rating.toStringAsFixed(1))} (${_toBnDigits(farmer.reviewsCount)} রিভিউ)'
                          : '⭐ নতুন সদস্য (০ রিভিউ)',
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. NID & Verification Documents Card
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
                          'জাতীয় পরিচয়পত্র ও ডকুমেন্টস',
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

                    if (farmer.nidFrontUrl.isNotEmpty || farmer.nidBackUrl.isNotEmpty) ...[
                      Row(
                        children: [
                          if (farmer.nidFrontUrl.isNotEmpty)
                            Expanded(
                              child: _buildDocumentPreview(
                                title: 'NID সামনের অংশ',
                                imageUrl: farmer.nidFrontUrl,
                                context: context,
                              ),
                            ),
                          if (farmer.nidFrontUrl.isNotEmpty && farmer.nidBackUrl.isNotEmpty)
                            const SizedBox(width: 12),
                          if (farmer.nidBackUrl.isNotEmpty)
                            Expanded(
                              child: _buildDocumentPreview(
                                title: 'NID পেছনের অংশ',
                                imageUrl: farmer.nidBackUrl,
                                context: context,
                              ),
                            ),
                        ],
                      ),
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
                                'রেজিস্ট্রেশনের সময় আপলোড করা জাতীয় পরিচয়পত্রের ছবি এখানে সংরক্ষিত রয়েছে।',
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

  void _showLocationUpdateDialog(BuildContext context, FarmerProfile farmer) {
    final distCtrl = TextEditingController(text: farmer.district);
    final upazilaCtrl = TextEditingController(text: farmer.upazila);
    final unionCtrl = TextEditingController(text: farmer.union);
    final addressCtrl = TextEditingController(text: farmer.address);
    bool isDetecting = false;
    bool isSaving = false;
    DetectedLocation? detected;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ঠিকানা ও অবস্থান আপডেট',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(height: 12),
                LocationPickerCard(
                  isLoading: isDetecting,
                  detectedLocation: detected,
                  onDetectLocation: () async {
                    setModalState(() => isDetecting = true);
                    try {
                      final loc = await LocationService.getCurrentLocation();
                      setModalState(() {
                        detected = loc;
                        if (loc.district.isNotEmpty) distCtrl.text = loc.district;
                        if (loc.upazila.isNotEmpty) upazilaCtrl.text = loc.upazila;
                        if (loc.unionOrArea.isNotEmpty) unionCtrl.text = loc.unionOrArea;
                        if (loc.fullAddress.isNotEmpty) addressCtrl.text = loc.fullAddress;
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("✓ লোকেশন সনাক্ত হয়েছে: ${loc.district} ${loc.upazila}"),
                            backgroundColor: Colors.green.shade700,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade700),
                        );
                      }
                    } finally {
                      setModalState(() => isDetecting = false);
                    }
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: distCtrl,
                  hintText: 'জেলা (যেমন: ঢাকা, রাজশাহী)',
                  prefixIcon: Icons.location_city_rounded,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: upazilaCtrl,
                  hintText: 'উপজেলা/থানা (যেমন: গোদাগাড়ী, গুলশান)',
                  prefixIcon: Icons.map_outlined,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: unionCtrl,
                  hintText: 'ইউনিয়ন/গ্রাম/এলাকা',
                  prefixIcon: Icons.holiday_village_outlined,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: addressCtrl,
                  hintText: 'বিস্তারিত সম্পূর্ণ ঠিকানা',
                  prefixIcon: Icons.home_work_outlined,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF166534),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isSaving ? null : () async {
                      setModalState(() => isSaving = true);
                      final token = await SharedPrefHelper.getToken();
                      final updatePayload = {
                        "district": distCtrl.text.trim(),
                        "upazila": upazilaCtrl.text.trim(),
                        "union": unionCtrl.text.trim(),
                        "address": addressCtrl.text.trim(),
                      };

                      final res = await ApiClient.updateUserProfile(
                        token: token,
                        updateData: updatePayload,
                      );

                      if (!context.mounted) return;
                      setModalState(() => isSaving = false);
                      Navigator.pop(ctx);
                      if (res["success"] == true) {
                        await SharedPrefHelper.updateUserLocation(
                          district: distCtrl.text.trim(),
                          upazila: upazilaCtrl.text.trim(),
                          union: unionCtrl.text.trim(),
                          address: addressCtrl.text.trim(),
                        );
                        if (context.mounted) {
                          context.read<KrishiRepository>().loadProfileFromBackend();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("✓ আপনার ঠিকানা সফলভাবে ব্যাকএন্ডে সংরক্ষিত হয়েছে!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(res["message"] ?? "ঠিকানা আপডেট করতে সমস্যা হয়েছে।"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('সংরক্ষণ করুন ও ব্যাকএন্ডে আপডেট করুন', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
