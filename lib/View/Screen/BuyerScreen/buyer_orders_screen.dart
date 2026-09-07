import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../global/controller/krishi_controller.dart';
import '../../Widgegt/Cards/order_card.dart';

class BuyerOrdersScreen extends StatelessWidget {
  const BuyerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<KrishiController>();
    final buyer = controller.currentBuyer;
    final myOrders = controller.orders.where((o) => o.buyerId == buyer.id).toList();

    return myOrders.isEmpty
        ? const Center(child: Text('আপনার কোনো সক্রিয় ক্রয় অর্ডার নেই'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myOrders.length,
            itemBuilder: (context, index) {
              final order = myOrders[index];
              return OrderCard(
                order: order,
                onTap: () => controller.openOrderDetail(order),
              );
            },
          );
  }
}
