import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../Widgegt/Cards/demand_card.dart';
import 'farmer_demands_controller.dart';

class FarmerDemandsScreen extends StatelessWidget {
  const FarmerDemandsScreen({super.key});

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
    final controller = FarmerDemandsController(repo);
    final demands = controller.demands;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ঢাকার ক্রেতাদের চাহিদা ফিড (${_toBnDigits(demands.length)} টি)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'সরাসরি পাইকারি ক্রেতাদের কাছে আপনার ফসলের অফার পাঠান',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Demands List
          Expanded(
            child: demands.isEmpty
                ? const Center(
                    child: Text(
                      'বর্তমানে কোনো চাহিদা খোলা নেই',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: demands.length,
                    itemBuilder: (context, index) {
                      final demand = demands[index];
                      return DemandCard(
                        demand: demand,
                        onAction: () => controller.openOffer(demand),
                        actionText: 'আমি দিতে পারব (অফার পাঠান)',
                        isFarmerView: true,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
