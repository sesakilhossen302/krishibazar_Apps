import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../Widgegt/Cards/order_card.dart';
import 'farmer_orders_controller.dart';

class FarmerOrdersScreen extends StatelessWidget {
  const FarmerOrdersScreen({super.key});

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
  Widget build(BuildContext context) {
    final repo = context.watch<KrishiRepository>();
    final controller = FarmerOrdersController(repo);
    final myOrders = controller.myOrders;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'আমার অর্ডার ও বিক্রয় (${_toBnDigits(myOrders.length)} টি)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'ডিপোজিট ও অর্ডার অগ্রগতি ট্র্যাক করুন',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Orders Feed
          Expanded(
            child: myOrders.isEmpty
                ? const Center(
                    child: Text(
                      'আপনার কোনো সক্রিয় অর্ডার নেই',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: myOrders.length,
                    itemBuilder: (context, index) {
                      final order = myOrders[index];
                      return OrderCard(
                        order: order,
                        onTap: () => controller.openDetail(order),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
