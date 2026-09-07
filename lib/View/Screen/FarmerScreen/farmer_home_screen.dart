import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../global/controller/krishi_controller.dart';
import '../../Widgegt/Cards/demand_card.dart';
import '../../Widgegt/Cards/order_card.dart';

class FarmerHomeScreen extends StatelessWidget {
  const FarmerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<KrishiController>();
    final farmer = controller.currentFarmer;
    final myProducts = controller.products.where((p) => p.farmerId == farmer.id).toList();
    final myOrders = controller.orders.where((o) => o.farmerId == farmer.id).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner / Welcome Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.accentGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'আসসালামু আলাইকুম, ${farmer.name}!',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'লোকেশন: ${farmer.district}, ${farmer.upazila}',
                        style: const TextStyle(color: AppColors.lightGold, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => controller.openAddProductDialog(),
                        icon: const Icon(Icons.add_a_photo, size: 18),
                        label: const Text('নতুন ফসল বিক্রি করুন'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text('🌾', style: TextStyle(fontSize: 54)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stat Cards
          Row(
            children: [
              _buildStatBox('আমার ফসল', '${myProducts.length}', Icons.inventory_2, AppColors.primaryGreen),
              const SizedBox(width: 10),
              _buildStatBox('চাহিদা বাজার', '${controller.demands.length}', Icons.campaign, AppColors.primaryGold),
              const SizedBox(width: 10),
              _buildStatBox('আমার অর্ডার', '${myOrders.length}', Icons.local_shipping, AppColors.statusCompleted),
            ],
          ),
          const SizedBox(height: 24),

          // Active Demands Section
          Row(
            children: [
              const Text('সাম্প্রতিক পাইকারি চাহিদা', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () => controller.setFarmerTab(2),
                child: const Text('সব দেখুন'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (controller.demands.isEmpty)
            const Center(child: Text('বর্তমানে কোনো নতুন চাহিদা পোস্ট নেই'))
          else
            ...controller.demands.take(3).map(
                  (demand) => DemandCard(
                    demand: demand,
                    onAction: () => controller.openOfferDialog(demand),
                    actionText: 'অফার পাঠাতেন চান?',
                    isFarmerView: true,
                  ),
                ),

          const SizedBox(height: 20),

          // Active Orders Section
          Row(
            children: [
              const Text('চলতি বিক্রি অর্ডার', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () => controller.setFarmerTab(3),
                child: const Text('সব দেখুন'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (myOrders.isEmpty)
            const Center(child: Text('আপনার কোনো সক্রিয় অর্ডার নেই'))
          else
            ...myOrders.take(2).map(
                  (order) => OrderCard(
                    order: order,
                    onTap: () => controller.openOrderDetail(order),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
