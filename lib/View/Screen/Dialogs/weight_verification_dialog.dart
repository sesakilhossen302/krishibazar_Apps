import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../global/Model/krishi_models.dart';
import '../../../global/controller/krishi_controller.dart';
import '../../Widgegt/custom_button/custom_button.dart';
import '../../Widgegt/custom_text_field/custom_text_field.dart';

class WeightVerificationDialog extends StatefulWidget {
  final MarketplaceOrder order;

  const WeightVerificationDialog({super.key, required this.order});

  @override
  State<WeightVerificationDialog> createState() => _WeightVerificationDialogState();
}

class _WeightVerificationDialogState extends State<WeightVerificationDialog> {
  final actualWeightController = TextEditingController();
  final notesController = TextEditingController();
  QualityGrade qualityGrade = QualityGrade.gradeA;

  @override
  void initState() {
    super.initState();
    actualWeightController.text = widget.order.quantity.toStringAsFixed(0);
    notesController.text = 'ওজন সম্পূর্ণ সঠিক, গ্রেড A মান নিশ্চিত করা হয়েছে';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<KrishiController>();

    return AlertDialog(
      title: Text('হাব কোয়ালিটি ও ওজন যাচাই: #${widget.order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('প্রত্যাশিত ওজন: ${widget.order.quantity.toStringAsFixed(0)} ${widget.order.unit.labelBn}'),
            const SizedBox(height: 10),
            CustomTextField(controller: actualWeightController, label: 'পরিমাপকৃত প্রকৃত ওজন (${widget.order.unit.labelBn})', keyboardType: TextInputType.number),
            const Text('যাচাইকৃত গ্রেড:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            DropdownButton<QualityGrade>(
              value: qualityGrade,
              isExpanded: true,
              items: QualityGrade.values.map((q) => DropdownMenuItem(value: q, child: Text(q.labelBn))).toList(),
              onChanged: (val) => setState(() => qualityGrade = val!),
            ),
            CustomTextField(controller: notesController, label: 'ইন্সপেকশন নোট/মন্তব্য'),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => controller.closeVerificationDialog(), child: const Text('বাতিল')),
        CustomButton(
          text: 'যাচাইকরণ সংরক্ষণ করুন',
          onTap: () {
            controller.submitWeightVerification(
              widget.order.id,
              double.tryParse(actualWeightController.text) ?? widget.order.quantity,
              qualityGrade,
              notesController.text,
            );
          },
        ),
      ],
    );
  }
}
