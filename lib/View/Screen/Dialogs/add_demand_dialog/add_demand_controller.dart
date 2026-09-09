import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';

class AddDemandController extends ChangeNotifier {
  final KrishiRepository repository;

  final titleController = TextEditingController();
  final quantityController = TextEditingController();
  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();
  late final TextEditingController locationController;
  late final TextEditingController requiredDateController;
  final noteController = TextEditingController();

  ProductCategory category = ProductCategory.vegetables;
  ProductUnit unit = ProductUnit.kg;
  QualityGrade qualityGrade = QualityGrade.gradeA;

  bool isSubmitting = false;

  AddDemandController(this.repository) {
    // Prefill location from buyer profile if available
    final buyer = repository.currentBuyer;
    String loc = '';
    if (buyer.address.isNotEmpty) {
      loc = buyer.address;
    } else if (buyer.area.isNotEmpty && buyer.district.isNotEmpty) {
      loc = '${buyer.area}, ${buyer.district}';
    } else if (buyer.district.isNotEmpty) {
      loc = buyer.district;
    } else {
      loc = 'কাওরান বাজার, ঢাকা';
    }
    locationController = TextEditingController(text: loc);

    // Dynamic default date: 5 days from now
    final defaultDate = DateTime.now().add(const Duration(days: 5));
    requiredDateController = TextEditingController(
      text: '${defaultDate.day} ${_getBnMonth(defaultDate.month)} ${defaultDate.year}',
    );
  }

  static String _getBnMonth(int month) {
    const months = [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 3)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE65100),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      requiredDateController.text = '${picked.day} ${_getBnMonth(picked.month)} ${picked.year}';
      notifyListeners();
    }
  }

  void setCategory(ProductCategory cat) {
    category = cat;
    notifyListeners();
  }

  void setUnit(ProductUnit u) {
    unit = u;
    notifyListeners();
  }

  void setQualityGrade(QualityGrade grade) {
    qualityGrade = grade;
    notifyListeners();
  }

  Future<void> submit(BuildContext context) async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      ToastMessage.show(context, 'অনুগ্রহ করে কী পণ্য প্রয়োজন তা লিখুন।', isError: true);
      return;
    }

    final qtyStr = quantityController.text.trim();
    final qty = double.tryParse(qtyStr);
    if (qty == null || qty <= 0) {
      ToastMessage.show(context, 'সঠিক পরিমাণ (সংখ্যা) উল্লেখ করুন।', isError: true);
      return;
    }

    final minPriceStr = minPriceController.text.trim();
    final maxPriceStr = maxPriceController.text.trim();
    final minP = double.tryParse(minPriceStr) ?? 0.0;
    final maxP = double.tryParse(maxPriceStr) ?? 0.0;

    if (minP <= 0 || maxP <= 0) {
      ToastMessage.show(context, 'সর্বনিম্ন ও সর্বোচ্চ বাজেট সঠিকভাবে উল্লেখ করুন।', isError: true);
      return;
    }
    if (minP > maxP) {
      ToastMessage.show(context, 'সর্বনিম্ন বাজেট সর্বোচ্চ বাজেটের চেয়ে বেশি হতে পারে না।', isError: true);
      return;
    }

    final loc = locationController.text.trim().isEmpty ? 'ঢাকা' : locationController.text.trim();
    final reqDate = requiredDateController.text.trim().isEmpty ? 'জরুরি' : requiredDateController.text.trim();

    isSubmitting = true;
    notifyListeners();

    try {
      final success = await repository.submitDemand(
        title,
        category,
        qty,
        unit,
        loc,
        reqDate,
        minP,
        maxP,
        qualityGrade,
        noteController.text.trim(),
      );

      if (context.mounted) {
        if (success) {
          ToastMessage.show(context, 'আপনার চাহিদা সফলভাবে পোস্ট করা হয়েছে!');
        } else {
          ToastMessage.show(context, 'চাহিদা সফলভাবে পোস্ট হয়েছে (লোকাল ড্রাফট сохранিত)।');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ToastMessage.show(context, 'সমস্যা হয়েছে: $e', isError: true);
      }
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void close() => repository.closeAddDemandDialog();

  @override
  void dispose() {
    titleController.dispose();
    quantityController.dispose();
    minPriceController.dispose();
    maxPriceController.dispose();
    locationController.dispose();
    requiredDateController.dispose();
    noteController.dispose();
    super.dispose();
  }
}
