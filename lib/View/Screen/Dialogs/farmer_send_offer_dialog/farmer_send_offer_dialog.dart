import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class FarmerSendOfferDialog extends StatefulWidget {
  final BuyerDemand demand;

  const FarmerSendOfferDialog({super.key, required this.demand});

  @override
  State<FarmerSendOfferDialog> createState() => _FarmerSendOfferDialogState();
}

class _FarmerSendOfferDialogState extends State<FarmerSendOfferDialog> {
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _dateController;
  late final TextEditingController _noteController;

  double _totalAmount = 0.0;
  double _depositAmount = 0.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.demand.requiredQuantity.toStringAsFixed(0),
    );
    _priceController = TextEditingController(
      text: widget.demand.minExpectedPrice.toStringAsFixed(0),
    );
    _dateController = TextEditingController(
      text: widget.demand.requiredDate,
    );
    _noteController = TextEditingController(
      text: 'সম্পূর্ণ খাঁটি ও ভালো মানের ফসল সরবরাহ করব।',
    );

    _quantityController.addListener(_calculateTotal);
    _priceController.addListener(_calculateTotal);
    _calculateTotal();
  }

  void _calculateTotal() {
    final qty = double.tryParse(_quantityController.text.trim()) ?? 0.0;
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    setState(() {
      _totalAmount = qty * price;
      _depositAmount = _totalAmount * 0.20;
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

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<KrishiRepository>();
    final demand = widget.demand;

    return Stack(
      children: [
        // 1. Dark Backdrop Scrim
        Positioned.fill(
          child: GestureDetector(
            onTap: repo.closeOfferDialog,
            child: Container(
              color: Colors.black.withValues(alpha: 0.65),
            ),
          ),
        ),

        // 2. Centered Modal Card
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Scaffold(
                backgroundColor: const Color(0xFFF8FAFC),
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0.5,
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(demand.category.icon, style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'দরপত্র / অফার পাঠান',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'পাইকারি ক্রেতার কাছে আপনার প্রস্তাব',
                              style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      tooltip: 'বন্ধ করুন',
                      onPressed: repo.closeOfferDialog,
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Demand Summary Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF0FDF4), Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDCFCE7), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              demand.productTitle,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.storefront_outlined, size: 14, color: Color(0xFF166534)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${demand.buyerBusinessName} • ${demand.buyerDistrict}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(height: 1, color: Color(0xFFDCFCE7)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'চাহিদা: ${_toBnDigits(demand.requiredQuantity)} ${demand.unit.labelBn}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF166534), fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'বাজেট: ৳${_toBnDigits(demand.minExpectedPrice.toStringAsFixed(0))}-${_toBnDigits(demand.maxExpectedPrice.toStringAsFixed(0))}/${demand.unit.labelBn}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFFEA580C), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 1. Quantity Input Field
                      _buildModernTextField(
                        controller: _quantityController,
                        label: 'আপনি কতটুকু সরবরাহ করতে পারবেন?',
                        hint: 'পরিমাণ লিখুন (${demand.unit.labelBn})',
                        icon: Icons.inventory_2_rounded,
                        iconColor: const Color(0xFF166534),
                        suffixText: demand.unit.labelBn,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),

                      // 2. Price Input Field
                      _buildModernTextField(
                        controller: _priceController,
                        label: 'আপনার প্রস্তাবিত দর (৳ প্রতি ${demand.unit.labelBn})',
                        hint: 'দর লিখুন (যেমন: ${demand.minExpectedPrice.toStringAsFixed(0)})',
                        icon: Icons.payments_rounded,
                        iconColor: const Color(0xFFEA580C),
                        suffixText: '৳ / ${demand.unit.labelBn}',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),

                      // Live Calculation Card
                      if (_totalAmount > 0) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'মোট বিক্রয়মূল্য:',
                                    style: TextStyle(fontSize: 13, color: Color(0xFF166534), fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '৳ ${_toBnDigits(_totalAmount.toStringAsFixed(0))}',
                                    style: const TextStyle(fontSize: 17, color: Color(0xFF166534), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'অর্ডার নিশ্চিত হলে অগ্রিম ২০% ডিপোজিট:',
                                    style: TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                                  ),
                                  Text(
                                    '৳ ${_toBnDigits(_depositAmount.toStringAsFixed(0))}',
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF15803D), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // 3. Delivery Date
                      _buildModernTextField(
                        controller: _dateController,
                        label: 'সরবরাহের সম্ভাব্য তারিখ',
                        hint: 'যেমন: ২০২৬-০৯-১৫',
                        icon: Icons.calendar_month_rounded,
                        iconColor: const Color(0xFF0284C7),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 14),

                      // 4. Note
                      _buildModernTextField(
                        controller: _noteController,
                        label: 'অফার সংক্রান্ত নোট বা বিশেষ বার্তা',
                        hint: 'যেমন: সম্পূর্ণ টাটকা ও প্যাকিং সম্পন্ন',
                        icon: Icons.edit_note_rounded,
                        iconColor: const Color(0xFF64748B),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: repo.closeOfferDialog,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('বাতিল'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting
                              ? null
                              : () async {
                                  final qty = double.tryParse(_quantityController.text.trim()) ?? 0.0;
                                  final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
                                  final date = _dateController.text.trim().isNotEmpty
                                      ? _dateController.text.trim()
                                      : 'আগামীকাল সকাল';
                                  final note = _noteController.text.trim();

                                  if (qty <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('অনুগ্রহ করে সঠিক পরিমাণ লিখুন।'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }
                                  if (price <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('অনুগ্রহ করে সঠিক প্রস্তাবিত দর লিখুন।'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => _isSubmitting = true);
                                  await repo.submitOffer(
                                    demand.id,
                                    qty,
                                    demand.unit,
                                    price,
                                    demand.qualityGrade,
                                    date,
                                    note,
                                  );
                                  if (mounted) {
                                    setState(() => _isSubmitting = false);
                                  }
                                },
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_circle_rounded, size: 18),
                          label: Text(
                            _isSubmitting ? 'অফার পাঠানো হচ্ছে...' : 'অফার জমা দিন ➔',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF166534),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF166534).withValues(alpha: 0.6),
                            disabledForegroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
    String? suffixText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, color: iconColor, size: 20),
            suffixText: suffixText,
            suffixStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF166534),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF166534), width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
