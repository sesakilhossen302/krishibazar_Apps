import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import 'farmer_send_offer_controller.dart';

class FarmerSendOfferDialog extends StatelessWidget {
  final BuyerDemand demand;

  const FarmerSendOfferDialog({super.key, required this.demand});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<KrishiRepository>();
    final controller = FarmerSendOfferController(repo, demand);

    return Dialog(
      backgroundColor: const Color(0xFFEBE8F3), // Soft light purple background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Text(
                'অফার পাঠান: ${demand.productTitle}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1B4B),
                ),
              ),
              const SizedBox(height: 6),
              // Subtitle Info
              Text(
                'ক্রেতার চাহিদা: ${demand.requiredQuantity.toStringAsFixed(0)} ${demand.unit.labelBn} (বাজেট ৳${demand.minExpectedPrice.toStringAsFixed(0)}-${demand.maxExpectedPrice.toStringAsFixed(0)})',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 18),

              // 1. Quantity Field
              _buildCustomInputField(
                label: 'আপনি কতটুকু দিতে পারবেন? (${demand.unit.labelBn})',
                controller: controller.quantityController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),

              // 2. Price Field
              _buildCustomInputField(
                label: 'আপনার প্রস্তাবিত দর (৳ প্রতি ${demand.unit.labelBn})',
                controller: controller.priceController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),

              // 3. Date Field
              _buildCustomInputField(
                label: 'সরবরাহের সম্ভাব্য তারিখ',
                controller: controller.dateController,
              ),
              const SizedBox(height: 14),

              // 4. Note Field
              _buildCustomInputField(
                label: 'নোট / বার্তা',
                controller: controller.noteController,
                maxLines: 2,
              ),
              const SizedBox(height: 22),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: controller.close,
                    child: const Text(
                      'বাতিল',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton(
                    onPressed: controller.submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF166534),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'অফার জমা দিন',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFF475569),
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: const Color(0xFFE5E2F0),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC7C3D8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
        ),
      ),
    );
  }
}

