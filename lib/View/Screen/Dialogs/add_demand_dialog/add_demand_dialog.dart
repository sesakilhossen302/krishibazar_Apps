import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import 'add_demand_controller.dart';

class AddDemandDialog extends StatefulWidget {
  const AddDemandDialog({super.key});

  @override
  State<AddDemandDialog> createState() => _AddDemandDialogState();
}

class _AddDemandDialogState extends State<AddDemandDialog> {
  late AddDemandController _controller;

  @override
  void initState() {
    super.initState();
    final repo = context.read<KrishiRepository>();
    _controller = AddDemandController(repo);
    _controller.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? labelText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7F5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF334155)),
                      onPressed: _controller.close,
                    ),
                    const Expanded(
                      child: Text(
                        'নতুন চাহিদা পোস্ট করুন (ক্রেতা)',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer to balance close button
                  ],
                ),
              ),

              // 2. Form Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Title
                      _buildTextField(
                        controller: _controller.titleController,
                        hintText: 'কী পণ্য প্রয়োজন? (যেমন: ফ্রেশ টমেটো)',
                      ),

                      // Category Selector Label
                      const Text(
                        'ক্যাটাগরি নির্বাচন করুন:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Category Chips
                      SizedBox(
                        height: 42,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: ProductCategory.values.length,
                          itemBuilder: (context, index) {
                            final cat = ProductCategory.values[index];
                            final isSelected = _controller.category == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () => _controller.setCategory(cat),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFECF7ED)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFCBD5E1),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(cat.icon, style: const TextStyle(fontSize: 15)),
                                      const SizedBox(width: 6),
                                      Text(
                                        cat.labelBn,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Quantity & Unit Row
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildTextField(
                              controller: _controller.quantityController,
                              hintText: 'প্রয়োজনীয় পরিমাণ',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFD1D5DB)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<ProductUnit>(
                                  value: _controller.unit,
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2E7D32)),
                                  items: ProductUnit.values.map((u) {
                                    return DropdownMenuItem(
                                      value: u,
                                      child: Text(
                                        u.labelBn,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) _controller.setUnit(val);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Min & Max Budget Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _controller.minPriceController,
                              hintText: 'সর্বনিম্ন বাজেট (৳)',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              controller: _controller.maxPriceController,
                              hintText: 'সর্বোচ্চ বাজেট (৳)',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      // Delivery Location
                      _buildTextField(
                        controller: _controller.locationController,
                        hintText: 'কাওরান বাজার, ঢাকা',
                        labelText: 'ডেলিভারি গ্রহণের স্থান (যেমন: কাওরান বাজার, ঢাকা)',
                      ),

                      // Required Date
                      _buildTextField(
                        controller: _controller.requiredDateController,
                        hintText: '২৫ সেপ্টেম্বর ২০২৪',
                        labelText: 'কবে প্রয়োজন? (তারিখ)',
                      ),

                      // Quality Grade Selector Label
                      const Text(
                        'কাঙ্ক্ষিত গ্রেড:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Quality Grade Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: QualityGrade.values.map((grade) {
                          final isSelected = _controller.qualityGrade == grade;
                          return InkWell(
                            onTap: () => _controller.setQualityGrade(grade),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFECF7ED) : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFFCBD5E1),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                grade.labelBn,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 14),

                      // Note field
                      _buildTextField(
                        controller: _controller.noteController,
                        hintText: 'বিশেষ কোনো নির্দেশনা বা নোট',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Submit Button Footer
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _controller.submit,
                    icon: const Icon(Icons.campaign_rounded, color: Colors.white, size: 20),
                    label: const Text(
                      'চাহিদাপত্র পোস্ট করুন',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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
}
