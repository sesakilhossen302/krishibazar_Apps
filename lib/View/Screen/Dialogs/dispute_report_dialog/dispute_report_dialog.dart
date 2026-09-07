import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import 'dispute_report_controller.dart';

class DisputeReportDialog extends StatelessWidget {
  final MarketplaceOrder order;

  const DisputeReportDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<KrishiRepository>();
    final controller = DisputeReportController(repo, order);

    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<DisputeReportController>(
        builder: (context, ctrl, child) {
          return Dialog(
            backgroundColor: const Color(0xFFEBE8F3), // Soft light purple/lavender background
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
                    // Header Title (Red Warning Icon + Title)
                    Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'অভিযোগ বা ডিসপুট রিপোর্ট',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Subtitle Label
                    const Text(
                      'সমস্যার ধরন নির্বাচন করুন:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Custom Dropdown Field
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E2F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFC7C3D8)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ProblemType>(
                          value: ctrl.problemType,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF475569)),
                          dropdownColor: const Color(0xFFF1F5F9),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                          items: ProblemType.values.map((p) {
                            return DropdownMenuItem<ProblemType>(
                              value: p,
                              child: Text(p.labelBn),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) ctrl.setProblemType(val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description Multi-line TextField
                    TextField(
                      controller: ctrl.descController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'ফসলের বিস্তারিত বিবরণ',
                        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFFE5E2F0),
                        contentPadding: const EdgeInsets.all(14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFC7C3D8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Action Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: ctrl.close,
                          child: const Text(
                            'বাতিল',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        ElevatedButton(
                          onPressed: ctrl.submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'অভিযোগ জমা দিন',
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
        },
      ),
    );
  }
}
