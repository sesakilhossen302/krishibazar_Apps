import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../Widgegt/Cards/order_card.dart';
import 'buyer_orders_controller.dart';

class BuyerOrdersScreen extends StatelessWidget {
  const BuyerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<KrishiRepository>();
    final controller = BuyerOrdersController(repo);
    final myOrders = controller.myOrders;

    return myOrders.isEmpty
        ? const Center(child: Text(StaticString.noDataFound))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myOrders.length,
            itemBuilder: (context, index) {
              final order = myOrders[index];
              return OrderCard(
                order: order,
                onTap: () => controller.openDetail(order),
              );
            },
          );
  }
}
