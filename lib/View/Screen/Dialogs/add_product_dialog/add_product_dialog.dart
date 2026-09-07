import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import 'add_product_controller.dart';

class AddProductDialog extends StatelessWidget {
  const AddProductDialog({super.key});

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
                            hint: 'পরিমাণ',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFEBE5).withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<ProductUnit>(
                                value: controller.unit,
                                isExpanded: true,
                                items: ProductUnit.values.map((u) {
                                  return DropdownMenuItem(
                                    value: u,
                                    child: Text(
                                      u.labelBn,
                                      style: const TextStyle(
                                        color: Color(0xFF166534),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
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
                    const SizedBox(height: 14),

                    // 4. Expected Price & Minimum Price Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: controller.expectedPriceController,
                            hint: 'কাঙ্ক্ষিত দর (৳/ইউনিট)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: controller.minPriceController,
                            hint: 'সর্বনিম্ন দর (৳)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 5. Farm Location / Delivery Point
                    _buildFloatingLabelTextField(
                      controller: controller.locationController,
                      label: 'খামারের অবস্থান / ডেলিভারি পয়েন্ট',
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
                      hint: 'পণ্যের বিস্তারিত বিবরণ',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),

                    // 9. Photo & Video Upload Section
                    const Text(
                      '📸 ফসলের ছবি ও ভিডিও আপলোড (ক্রেতার আস্থার জন্য)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.image_outlined, color: Color(0xFF166534)),
                            label: const Text(
                              'ছবি যুক্ত করুন',
                              style: TextStyle(
                                color: Color(0xFF166534),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFF166534)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            label: const Text(
                              'তাজা ছবি তুলুন',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF166534),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 10. Live Video Toggle Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF3EC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFC7E0CB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.videocam, color: Colors.deepOrange, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'ক্ষেতের লাইভ ভিডিও ক্লিপ 🎬',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'ক্রেতাকে তাজা ফসল প্রমাণের জন্য ভিডিও যোগ করুন',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: controller.isLiveVideoEnabled,
                            onChanged: controller.toggleLiveVideo,
                            activeTrackColor: const Color(0xFF166534),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 11. Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          controller.submit();
                        },
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          'লিস্টিং নিশ্চিত করুন',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF166534),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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

