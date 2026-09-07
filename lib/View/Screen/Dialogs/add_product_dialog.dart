import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../global/Model/krishi_models.dart';
import '../../../global/controller/krishi_controller.dart';
import '../../Widgegt/custom_button/custom_button.dart';
import '../../Widgegt/custom_text_field/custom_text_field.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final titleController = TextEditingController();
  final quantityController = TextEditingController();
  final expectedPriceController = TextEditingController();
  final minPriceController = TextEditingController();
  final locationController = TextEditingController();
  final descController = TextEditingController();

  ProductCategory category = ProductCategory.vegetables;
  ProductUnit unit = ProductUnit.kg;
  QualityGrade qualityGrade = QualityGrade.gradeA;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<KrishiController>();

    return AlertDialog(
      title: const Row(
        children: [
          Text('🌾 ', style: TextStyle(fontSize: 22)),
          Text('নতুন ফসল বাজারে যোগ করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(controller: titleController, label: 'ফসল বা পণ্যের নাম', hint: 'যেমন: টাটকা ডায়মন্ড আলু'),
            const Text('ক্যাটাগরি নির্বাচন করুন', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            DropdownButton<ProductCategory>(
              value: category,
              isExpanded: true,
              items: ProductCategory.values.map((c) {
                return DropdownMenuItem(value: c, child: Text('${c.icon} ${c.labelBn}'));
              }).toList(),
              onChanged: (val) => setState(() => category = val!),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: CustomTextField(controller: quantityController, label: 'পরিমাণ', keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<ProductUnit>(
                    value: unit,
                    isExpanded: true,
                    items: ProductUnit.values.map((u) {
                      return DropdownMenuItem(value: u, child: Text(u.labelBn));
                    }).toList(),
                    onChanged: (val) => setState(() => unit = val!),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: CustomTextField(controller: expectedPriceController, label: 'প্রত্যাশিত মূল্য (৳)', keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: CustomTextField(controller: minPriceController, label: 'সর্বনিম্ন মূল্য (৳)', keyboardType: TextInputType.number)),
              ],
            ),
            CustomTextField(controller: locationController, label: 'ফসল কাটার স্থান / হিমাগার', hint: 'যেমন: শিবগঞ্জ, বগুড়া'),
            CustomTextField(controller: descController, label: 'ফসলের বিস্তারিত বিবরণ', hint: 'ফসলের গুণগত মান বা বিবরণ লিখুন'),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => controller.closeAddProductDialog(), child: const Text('বাতিল')),
        CustomButton(
          text: 'জমা দিন',
          onTap: () {
            controller.submitProduct(
              title: titleController.text.isEmpty ? 'উৎপাদিত ফসল' : titleController.text,
              category: category,
              quantity: double.tryParse(quantityController.text) ?? 100.0,
              unit: unit,
              expectedPrice: double.tryParse(expectedPriceController.text) ?? 35.0,
              minPrice: double.tryParse(minPriceController.text) ?? 30.0,
              location: locationController.text.isEmpty ? 'কৃষকের জমি' : locationController.text,
              availableDate: 'তাত্ক্ষণিক',
              harvestDate: 'আজ সকালে',
              qualityGrade: qualityGrade,
              description: descController.text,
            );
          },
        ),
      ],
    );
  }
}
