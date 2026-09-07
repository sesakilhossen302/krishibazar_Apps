import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../global/Model/krishi_models.dart';
import '../../../global/controller/krishi_controller.dart';
import '../../Widgegt/custom_button/custom_button.dart';
import '../../Widgegt/custom_text_field/custom_text_field.dart';

class DisputeReportDialog extends StatefulWidget {
  final MarketplaceOrder order;

  const DisputeReportDialog({super.key, required this.order});

  @override
  State<DisputeReportDialog> createState() => _DisputeReportDialogState();
}

class _DisputeReportDialogState extends State<DisputeReportDialog> {
  ProblemType problemType = ProblemType.quantityMismatch;
  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = context.read<KrishiController>();

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 8),
          Text('অভিযোগ বা ডিসপিউট রিপোর্ট', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('সমস্যার ধরন নির্বাচন করুন:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            DropdownButton<ProblemType>(
              value: problemType,
              isExpanded: true,
              items: ProblemType.values.map((p) {
                return DropdownMenuItem(value: p, child: Text(p.labelBn));
              }).toList(),
              onChanged: (val) => setState(() => problemType = val!),
            ),
            const SizedBox(height: 10),
            CustomTextField(controller: descController, label: 'সমস্যার বিস্তারিত বিবরণ', hint: 'কি সমস্যা হয়েছে বিস্তারিত লিখুন...'),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => controller.closeDisputeDialog(), child: const Text('বাতিল')),
        CustomButton(
          text: 'অভিযোগ জমা দিন',
          backgroundColor: Colors.red,
          onTap: () {
            controller.submitDispute(
              widget.order.id,
              problemType,
              descController.text.isEmpty ? 'পণ্য বা ওজনে অসঙ্গতি পাওয়া গেছে' : descController.text,
            );
          },
        ),
      ],
    );
  }
}
