import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../global/controller/krishi_controller.dart';
import '../../Widgegt/Cards/demand_card.dart';

class BuyerDemandsScreen extends StatelessWidget {
  const BuyerDemandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<KrishiController>();
    final buyer = controller.currentBuyer;
    final myDemands = controller.demands.where((d) => d.buyerId == buyer.id).toList();

    return Scaffold(
      body: myDemands.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📦', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  const Text('আপনার কোনো সক্রিয় চাহিদা পোস্ট নেই', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => controller.openAddDemandDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('নতুন চাহিদা পোস্ট করুন'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myDemands.length,
              itemBuilder: (context, index) {
                final demand = myDemands[index];
                return DemandCard(
                  demand: demand,
                  onAction: () => controller.openDemandOfferManagement(demand),
                  actionText: 'প্রাপ্ত অফারসমূহ দেখুন (${demand.offersCount}টি)',
                  isFarmerView: false,
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGold,
        onPressed: () => controller.openAddDemandDialog(),
        icon: const Icon(Icons.post_add, color: Colors.black),
        label: const Text('চাহিদা পোস্ট করুন', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
