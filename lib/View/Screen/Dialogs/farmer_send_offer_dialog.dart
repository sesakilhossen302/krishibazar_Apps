import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../global/Model/krishi_models.dart';
import '../../../global/controller/krishi_controller.dart';
import '../../Widgegt/custom_button/custom_button.dart';
import '../../Widgegt/custom_text_field/custom_text_field.dart';

class FarmerSendOfferDialog extends StatefulWidget {
  final BuyerDemand demand;

  const FarmerSendOfferDialog({super.key, required this.demand});

  @override
  State<FarmerSendOfferDialog> createState() => _FarmerSendOfferDialogState();
}

class _FarmerSendOfferDialogState extends State<FarmerSendOfferDialog> {
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    quantityController.text = widget.demand.requiredQuantity.toStringAsFixed(0);
    priceController.text = widget.demand.minExpectedPrice.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<KrishiController>();

    return AlertDialog(
      title: Text('অফার পাঠান: ${widget.demand.productTitle}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ক্রেতার বাজেট: ৳${widget.demand.minExpectedPrice.toStringAsFixed(0)} - ৳${widget.demand.maxExpectedPrice.toStringAsFixed(0)} / ${widget.demand.unit.labelBn}'),
            const SizedBox(height: 12),
            CustomTextField(controller: quantityController, label: 'আপনার বিক্রয়যোগ্য পরিমাণ', keyboardType: TextInputType.number),
            CustomTextField(controller: priceController, label: 'আপনার অফারকৃত দর (৳/একক)', keyboardType: TextInputType.number),
            CustomTextField(controller: noteController, label: 'অফার সংক্রান্ত নোট/শর্ত', hint: 'যেমন: ট্রাক লোড প্রস্তুত'),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => controller.closeOfferDialog(), child: const Text('বাতিল')),
        CustomButton(
          text: 'অফার পাঠাতেন',
          onTap: () {
            controller.submitOffer(
              widget.demand.id,
              double.tryParse(quantityController.text) ?? widget.demand.requiredQuantity,
              widget.demand.unit,
              double.tryParse(priceController.text) ?? widget.demand.minExpectedPrice,
              widget.demand.qualityGrade,
              'আগামীকাল সকাল',
              noteController.text,
            );
          },
        ),
      ],
    );
  }
}
