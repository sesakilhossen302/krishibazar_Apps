import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../global/controller/krishi_repository.dart';
import '../../../helper/shared_pref/shared_pref_helper.dart';
import '../../../service/api_client.dart';
import '../../Widgegt/image_picker_dialog/image_picker_dialog.dart';

class ReuploadNidDialog extends StatefulWidget {
  final String currentNid;
  final String rejectionReason;

  const ReuploadNidDialog({
    super.key,
    required this.currentNid,
    required this.rejectionReason,
  });

  static Future<void> show(
    BuildContext context, {
    required String currentNid,
    required String rejectionReason,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReuploadNidDialog(
        currentNid: currentNid,
        rejectionReason: rejectionReason,
      ),
    );
  }

  @override
  State<ReuploadNidDialog> createState() => _ReuploadNidDialogState();
}

class _ReuploadNidDialogState extends State<ReuploadNidDialog> {
  late final TextEditingController _nidController;
  File? _nidFrontFile;
  File? _nidBackFile;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nidController = TextEditingController(
      text: (widget.currentNid.isNotEmpty && widget.currentNid != 'NID নেই')
          ? widget.currentNid
          : '',
    );
  }

  @override
  void dispose() {
    _nidController.dispose();
    super.dispose();
  }

  Future<void> _pickFrontImage() async {
    final file = await ImagePickerDialog.showImageSourceSelector(context);
    if (file != null) {
      setState(() => _nidFrontFile = file);
    }
  }

  Future<void> _pickBackImage() async {
    final file = await ImagePickerDialog.showImageSourceSelector(context);
    if (file != null) {
      setState(() => _nidBackFile = file);
    }
  }

  Future<void> _submit() async {
    if (_nidFrontFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে এনআইডি কার্ডের সামনের দিকের ছবি যুক্ত করুন।'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_nidBackFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে এনআইডি কার্ডের পেছনের দিকের ছবি যুক্ত করুন।'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await SharedPrefHelper.getToken();

      // 1. Upload NID Front Image
      final frontRes = await ApiClient.uploadImageFile(_nidFrontFile!);
      if (frontRes['success'] != true || frontRes['data'] == null) {
        throw Exception(frontRes['message'] ?? 'সামনের ছবি আপলোড করতে সমস্যা হয়েছে');
      }
      final String frontUrl = frontRes['data']['file_url'] ?? '';

      // 2. Upload NID Back Image
      final backRes = await ApiClient.uploadImageFile(_nidBackFile!);
      if (backRes['success'] != true || backRes['data'] == null) {
        throw Exception(backRes['message'] ?? 'পেছনের ছবি আপলোড করতে সমস্যা হয়েছে');
      }
      final String backUrl = backRes['data']['file_url'] ?? '';

      // 3. Call reupload-nid endpoint
      final submitRes = await ApiClient.reuploadNid(
        token: token,
        nidFrontUrl: frontUrl,
        nidBackUrl: backUrl,
        nidNumber: _nidController.text.trim(),
      );

      if (submitRes['success'] == true) {
        if (!mounted) return;
        final repo = context.read<KrishiRepository>();
        final nav = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);

        nav.pop();
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'এনআইডি কার্ড সফলভাবে পুনরায় জমা দেওয়া হয়েছে! অ্যাডমিন পর্যালোচনার পর অনুমোদন করবেন। ✅',
            ),
            backgroundColor: Color(0xFF15803D),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );

        await repo.loadProfileFromBackend();
      } else {
        throw Exception(submitRes['message'] ?? 'জমা দিতে সমস্যা হয়েছে');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ব্যর্থ হয়েছে: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pull Bar Indicator
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.badge_rounded, color: Color(0xFF166534), size: 24),
                      SizedBox(width: 10),
                      Text(
                        'এনআইডি পুনরায় আপলোড',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Admin Rejection Reason Alert Box
              if (widget.rejectionReason.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'অ্যাডমিনের কারণ ও নির্দেশনা:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.rejectionReason,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7F1D1D),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Guidance Text
              const Text(
                'এনআইডি কার্ডের সামনের ও পেছনের অংশের স্পষ্ট ছবি তুলুন অথবা গ্যালারি থেকে নির্বাচন করুন:',
                style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 14),

              // Image Pickers (Front & Back)
              Row(
                children: [
                  Expanded(
                    child: _buildImagePickerCard(
                      title: 'এনআইডি (সামনের দিক)',
                      file: _nidFrontFile,
                      onTap: _pickFrontImage,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildImagePickerCard(
                      title: 'এনআইডি (পেছনের দিক)',
                      file: _nidBackFile,
                      onTap: _pickBackImage,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // NID Number TextField
              const Text(
                'জাতীয় পরিচয়পত্র নম্বর (ঐচ্ছিক):',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nidController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'যেমন: 1988291029384',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.pin_rounded, size: 20, color: Color(0xFF166534)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload_rounded, size: 20),
                label: Text(
                  _isSubmitting ? 'আপলোড হচ্ছে...' : 'এনআইডি জমা দিন (Submit NID)',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerCard({
    required String title,
    required File? file,
    required VoidCallback onTap,
  }) {
    final bool hasFile = file != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFile ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
            width: hasFile ? 1.5 : 1.0,
          ),
        ),
        child: hasFile
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(file, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                      ),
                      child: const Text(
                        'ছবি পরিবর্তন করুন',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_a_photo_rounded, color: Color(0xFF166534), size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'ক্লিক করে ছবি দিন',
                    style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
      ),
    );
  }
}
