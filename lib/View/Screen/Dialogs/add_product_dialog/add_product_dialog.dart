import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import 'add_product_controller.dart';

class AddProductDialog extends StatelessWidget {
  const AddProductDialog({super.key});

  void _showVideoSourcePicker(BuildContext context, AddProductController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🎬 ফসলের ভিডিও উৎস নির্বাচন করুন',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'ক্রেতার বিশ্বাস বাড়াতে ক্ষেতের তাজা ভিডিও দিন:',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),

              // Option 1: Gallery Video
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                tileColor: const Color(0xFFF8FAFC),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.video_library_rounded, color: Color(0xFF2563EB), size: 26),
                ),
                title: const Text(
                  'গ্যালারির ভিডিও',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                ),
                subtitle: const Text(
                  'ফোনে সংরক্ষিত পূর্বে ধারণকৃত ভিডিও বেছে নিন',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black38),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.pickVideoFromGallery();
                },
              ),
              const SizedBox(height: 12),

              // Option 2: Live Camera Video
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFDCFCE7)),
                ),
                tileColor: const Color(0xFFF0FDF4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.videocam_rounded, color: Color(0xFF166534), size: 26),
                ),
                title: const Text(
                  'লাইভ ভিডিও (ক্যামেরা)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF166534),
                  ),
                ),
                subtitle: const Text(
                  'সরাসরি ক্যামেরা দিয়ে ক্ষেতের তাজা ভিডিও রেকর্ড করুন',
                  style: TextStyle(fontSize: 12, color: Color(0xFF15803D)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF166534)),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.recordLiveVideo();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<KrishiRepository>();
    return ChangeNotifierProvider(
      create: (_) => AddProductController(repo),
      child: Consumer<AddProductController>(
        builder: (context, controller, child) {
          return Dialog.fullscreen(
            child: Scaffold(
              backgroundColor: const Color(0xFFF4F7F4),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0.5,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: controller.close,
                ),
                title: const Text(
                  'নতুন পণ্য লিস্টিং (বিক্রি)',
                  style: TextStyle(
                    color: Color(0xFF166534),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Crop Title Field
                    _buildTextField(
                      controller: controller.titleController,
                      hint: 'পণ্যের নাম (যেমন: দেশি লাল টমেটো)',
                    ),
                    const SizedBox(height: 16),

                    // 2. Category Selection Section
                    const Text(
                      'ক্যাটাগরি নির্বাচন করুন:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ProductCategory.values.map((cat) {
                          final isSelected = controller.category == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text('${cat.icon} ${cat.labelBn}'),
                              selected: isSelected,
                              onSelected: (_) => controller.setCategory(cat),
                              selectedColor: const Color(0xFFDCFCE7),
                              backgroundColor: Colors.white,
                              checkmarkColor: const Color(0xFF166534),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF166534) : const Color(0xFFCBD5E1),
                              ),
                              labelStyle: TextStyle(
                                color: isSelected ? const Color(0xFF166534) : const Color(0xFF334155),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Quantity & Unit Row
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            controller: controller.quantityController,
                            hint: 'পরিমাণ (সংখ্যা)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF166534), width: 1.2),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<ProductUnit>(
                                value: controller.unit,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF166534)),
                                items: ProductUnit.values.map((u) {
                                  return DropdownMenuItem(
                                    value: u,
                                    child: Text(
                                      u.labelBn,
                                      style: const TextStyle(
                                        color: Color(0xFF166534),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) controller.setUnit(val);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Unit & Price Explanation Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Color(0xFF166534), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.unitExplanationText,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF166534),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 4. Expected Price & Minimum Price Row (Dynamic Unit Label)
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: controller.expectedPriceController,
                            hint: controller.expectedPriceLabel,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: controller.minPriceController,
                            hint: controller.minPriceLabel,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 5. Farm Location / Delivery Point with Google Places Autocomplete
                    const Text(
                      'খামারের লোকেশন / ডেলিভারি পয়েন্ট:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller.locationController,
                      onChanged: controller.onLocationChanged,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'খামারের ঠিকানা লিখুন (যেমন: শেরপুর, বগুড়া)',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        prefixIcon: const Icon(Icons.location_on, color: Color(0xFF166534), size: 20),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (controller.isSearchingLocation)
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF166534)),
                                ),
                              ),
                            IconButton(
                              tooltip: 'বর্তমান জিপিএস লোকেশন',
                              icon: const Icon(Icons.my_location, color: Color(0xFFEA580C), size: 20),
                              onPressed: () => controller.autoDetectLocation(context),
                            ),
                          ],
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
                        ),
                      ),
                    ),

                    // Location Autocomplete Suggestions List
                    if (controller.showLocationSuggestions && controller.locationSuggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.locationSuggestions.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (ctx, i) {
                            final item = controller.locationSuggestions[i];
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.place_outlined, color: Color(0xFF166534), size: 20),
                              title: Text(
                                item.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              subtitle: Text(
                                item.fullAddress.isNotEmpty ? item.fullAddress : item.district,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                              onTap: () => controller.selectLocationSuggestion(item),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 14),

                    // 6. Harvest Date & Delivery Date Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildFloatingLabelTextField(
                            controller: controller.harvestDateController,
                            label: 'ফসল তোলার তারিখ',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFloatingLabelTextField(
                            controller: controller.deliveryDateController,
                            label: 'ডেলিভারির তারিখ',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 7. Quality Grade Section
                    const Text(
                      'গুণগত মান (Grade):',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: QualityGrade.values.map((grade) {
                          final isSelected = controller.qualityGrade == grade;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(grade.labelBn),
                              selected: isSelected,
                              onSelected: (_) => controller.setQualityGrade(grade),
                              selectedColor: const Color(0xFFDCFCE7),
                              backgroundColor: Colors.white,
                              checkmarkColor: const Color(0xFF166534),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF166534) : const Color(0xFFCBD5E1),
                              ),
                              labelStyle: TextStyle(
                                color: isSelected ? const Color(0xFF166534) : const Color(0xFF334155),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 8. Description Text Field
                    _buildTextField(
                      controller: controller.descController,
                      hint: 'পণ্যের বিস্তারিত বিবরণ (যেমন: সার ও কীটনাশকমুক্ত তাজা ফসল)',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // 9. Photo Upload Section (Multiple Gallery + Direct Camera)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '📸 ফসলের ছবি যুক্ত করুন',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF166534),
                          ),
                        ),
                        if (controller.selectedImages.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${controller.selectedImages.length}টি ছবি যুক্ত হয়েছে',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Gallery Multi-Image Button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.pickImagesFromGallery,
                            icon: const Icon(Icons.photo_library_outlined, color: Color(0xFF166534)),
                            label: const Text(
                              'ছবি যুক্ত করুন',
                              style: TextStyle(
                                color: Color(0xFF166534),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFF166534), width: 1.5),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Live Camera Fresh Photo Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.capturePhotoWithCamera,
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            label: const Text(
                              'তাজা ছবি তুলুন',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF166534),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Preview of Selected Images
                    if (controller.selectedImages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.selectedImages.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 10),
                          itemBuilder: (ctx, index) {
                            final xfile = controller.selectedImages[index];
                            return Stack(
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF166534), width: 1.5),
                                    image: DecorationImage(
                                      image: kIsWeb
                                          ? NetworkImage(xfile.path)
                                          : FileImage(File(xfile.path)) as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => controller.removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // 10. Crop Video Section (Modernized with BottomSheet: Gallery Video + Live Video)
                    const Text(
                      '🎬 ফসলের ভিডিও ক্লিপ (ক্রেতার গভীর আস্থার জন্য)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (controller.selectedVideo == null)
                      InkWell(
                        onTap: () => _showVideoSourcePicker(context, controller),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.videocam_rounded, color: Color(0xFFEA580C), size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'ভিডিও যুক্ত করুন (গ্যালারি বা লাইভ ভিডিও)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'সরাসরি ক্ষেত থেকে ভিডিও করলে বিক্রির সম্ভাবনা বাড়ে',
                                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.add_circle, color: Color(0xFFEA580C), size: 26),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFDBA74)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.video_collection_rounded, color: Color(0xFFEA580C), size: 26),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.videoFileName ?? 'ভিডিও ফাইল যুক্ত হয়েছে',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF9A3412),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    '✓ ফসলের ভিডিও সফলভাবে নির্বাচন করা হয়েছে',
                                    style: TextStyle(fontSize: 11, color: Color(0xFFC2410C)),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showVideoSourcePicker(context, controller),
                              child: const Text('বদলান', style: TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: controller.removeVideo,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 28),

                    // 11. Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.isSubmitting
                            ? null
                            : () => controller.submit(context),
                        icon: controller.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
                        label: Text(
                          controller.isSubmitting
                              ? (controller.submitProgressText.isNotEmpty
                                  ? controller.submitProgressText
                                  : 'আপলোড হচ্ছে...')
                              : 'লিস্টিং নিশ্চিত করুন',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF166534),
                          disabledBackgroundColor: const Color(0xFF166534).withValues(alpha: 0.6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFF64748B),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildFloatingLabelTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFF475569),
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
        ),
      ),
    );
  }
}


