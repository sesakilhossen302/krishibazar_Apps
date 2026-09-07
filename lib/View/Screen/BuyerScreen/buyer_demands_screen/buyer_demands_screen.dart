import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../Widgegt/Cards/demand_card.dart';
import 'buyer_demands_controller.dart';

class BuyerDemandsScreen extends StatelessWidget {
  const BuyerDemandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<KrishiRepository>();
    final controller = BuyerDemandsController(repo);
    final myDemands = controller.myDemands;

    return Scaffold(
      body: myDemands.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📦', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  const Text(StaticString.noActiveDemands, style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: controller.openAddDemand,
                    icon: const Icon(Icons.add),
                    label: const Text(StaticString.postDemandButton),
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
                  onAction: () => controller.openOffers(demand),
                  actionText: '${StaticString.viewOffersButton} (${demand.offersCount}টি)',
                  isFarmerView: false,
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGold,
        onPressed: controller.openAddDemand,
        icon: const Icon(Icons.post_add, color: Colors.black),
        label: const Text(StaticString.postDemandButton, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
