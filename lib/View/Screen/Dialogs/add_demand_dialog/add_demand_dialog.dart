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
    _controller.dispose();
    super.dispose();
  }

  Widget _buildFieldSection({
    required String label,
    required Widget child,
    IconData? icon,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: const Color(0xFFE65100)),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _buildStyledInput({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: Color(0xFF94A3B8),
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.94,
          constraints: const BoxConstraints(maxWidth: 490, maxHeight: 720),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Header Bar with Rich Gradient
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE65100), Color(0xFFF57C00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'নতুন চাহিদা পোস্ট করুন',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'কৃষকদের কাছে আপনার পণ্যের চাহিদা প্রকাশ করুন',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFFFE0B2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          padding: const EdgeInsets.all(6),
                        ),
                        onPressed: _controller.close,
                      ),
                    ],
                  ),
                ),

                // 2. Scrollable Form Body
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Title
                        _buildFieldSection(
                          label: 'কী পণ্য প্রয়োজন? (পণ্যের নাম)',
                          isRequired: true,
                          icon: Icons.inventory_2_outlined,
                          child: _buildStyledInput(
                            controller: _controller.titleController,
                            hintText: 'যেমন: ফ্রেশ টমেটো, দেশি আলু, চাল ইত্যাদি',
                          ),
                        ),

                        // Category Selector
                        _buildFieldSection(
                          label: 'ক্যাটাগরি নির্বাচন করুন',
                          isRequired: true,
                          icon: Icons.category_outlined,
                          child: SizedBox(
                            height: 44,
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
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFE65100)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFE65100)
                                              : const Color(0xFFCBD5E1),
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFFE65100).withValues(alpha: 0.25),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Row(
                                        children: [
                                          Text(cat.icon, style: const TextStyle(fontSize: 16)),
                                          const SizedBox(width: 6),
                                          Text(
                                            cat.labelBn,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                              color: isSelected ? Colors.white : const Color(0xFF334155),
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
                        ),

                        // Quantity & Unit Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildFieldSection(
                                label: 'প্রয়োজনীয় পরিমাণ',
                                isRequired: true,
                                icon: Icons.scale_outlined,
                                child: _buildStyledInput(
                                  controller: _controller.quantityController,
                                  hintText: 'যেমন: ৫০০',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: _buildFieldSection(
                                label: 'একক (Unit)',
                                isRequired: true,
                                icon: Icons.straighten_outlined,
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<ProductUnit>(
                                      value: _controller.unit,
                                      isExpanded: true,
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFE65100)),
                                      items: ProductUnit.values.map((u) {
                                        return DropdownMenuItem(
                                          value: u,
                                          child: Text(
                                            u.labelBn,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A),
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
                            ),
                          ],
                        ),

                        // Min & Max Budget
                        _buildFieldSection(
                          label: 'প্রত্যাশিত বাজেট রেঞ্জ (প্রতি একক ৳)',
                          isRequired: true,
                          icon: Icons.monetization_on_outlined,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildStyledInput(
                                  controller: _controller.minPriceController,
                                  hintText: 'সর্বনিম্ন (৳)',
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(left: 12, top: 12, bottom: 12, right: 4),
                                    child: Text('৳', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100), fontSize: 16)),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text('—', style: TextStyle(fontSize: 18, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: _buildStyledInput(
                                  controller: _controller.maxPriceController,
                                  hintText: 'সর্বোচ্চ (৳)',
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(left: 12, top: 12, bottom: 12, right: 4),
                                    child: Text('৳', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100), fontSize: 16)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Delivery Location
                        _buildFieldSection(
                          label: 'ডেলিভারি গ্রহণের স্থান / আরত',
                          isRequired: true,
                          icon: Icons.location_on_outlined,
                          child: _buildStyledInput(
                            controller: _controller.locationController,
                            hintText: 'যেমন: কাওরান বাজার আড়ত নং ১২, ঢাকা',
                            prefixIcon: const Icon(Icons.storefront_outlined, color: Color(0xFFE65100), size: 18),
                          ),
                        ),

                        // Required Date (with real DatePicker)
                        _buildFieldSection(
                          label: 'কবে পণ্য প্রয়োজন? (তারিখ)',
                          isRequired: true,
                          icon: Icons.event_available_outlined,
                          child: _buildStyledInput(
                            controller: _controller.requiredDateController,
                            hintText: 'তারিখ নির্বাচন করুন',
                            readOnly: true,
                            onTap: () => _controller.pickDate(context),
                            prefixIcon: const Icon(Icons.calendar_month_outlined, color: Color(0xFFE65100), size: 18),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.edit_calendar_rounded, color: Color(0xFFE65100), size: 18),
                              onPressed: () => _controller.pickDate(context),
                            ),
                          ),
                        ),

                        // Quality Grade Selector
                        _buildFieldSection(
                          label: 'কাঙ্ক্ষিত গুণগত মান (গ্রেড)',
                          isRequired: true,
                          icon: Icons.verified_outlined,
                          child: Wrap(
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
                                    color: isSelected
                                        ? const Color(0xFFFFF3E0)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFE65100)
                                          : const Color(0xFFCBD5E1),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isSelected) ...[
                                        const Icon(Icons.check_circle_rounded, color: Color(0xFFE65100), size: 14),
                                        const SizedBox(width: 4),
                                      ],
                                      Text(
                                        grade.labelBn,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? const Color(0xFFE65100) : const Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Additional Notes
                        _buildFieldSection(
                          label: 'অতিরিক্ত নির্দেশনা বা শর্তাবলী (ঐচ্ছিক)',
                          icon: Icons.notes_rounded,
                          child: _buildStyledInput(
                            controller: _controller.noteController,
                            hintText: 'যেমন: প্যাকেট বা ক্রেট ভালো হতে হবে, তাজা ডেলিভারি চাই...',
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Footer Action Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _controller.isSubmitting
                          ? null
                          : () => _controller.submit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: const Color(0xFFE65100).withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _controller.isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'পোস্ট করা হচ্ছে...',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.campaign_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'চাহিদাপত্র পোস্ট করুন',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
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
