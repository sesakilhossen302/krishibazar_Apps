import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../Widgegt/custom_button/custom_button.dart';
import '../../../Widgegt/custom_text_field/custom_text_field.dart';
import 'weight_verification_controller.dart';

class WeightVerificationDialog extends StatelessWidget {
  final MarketplaceOrder order;

  const WeightVerificationDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<KrishiRepository>();
    final controller = WeightVerificationController(repo, order);

    return AlertDialog(
      title: Text('${StaticString.weightVerifTitle}: #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('প্রত্যাশিত ওজন: ${order.quantity.toStringAsFixed(0)} ${order.unit.labelBn}'),
            const SizedBox(height: 10),
            CustomTextField(controller: controller.actualWeightController, label: '${StaticString.actualWeightLabel} (${order.unit.labelBn})', keyboardType: TextInputType.number),
            const Text('যাচাইকৃত গ্রেড:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            DropdownButton<QualityGrade>(
              value: controller.qualityGrade,
              isExpanded: true,
              items: QualityGrade.values.map((q) => DropdownMenuItem(value: q, child: Text(q.labelBn))).toList(),
              onChanged: (val) {
                if (val != null) controller.setQualityGrade(val);
              },
            ),
            CustomTextField(controller: controller.notesController, label: 'ইন্সপেকশন নোট/মন্তব্য'),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: controller.close, child: const Text(StaticString.cancel)),
        CustomButton(text: StaticString.saveVerifButton, onTap: controller.submit),
      ],
    );
  }
}
