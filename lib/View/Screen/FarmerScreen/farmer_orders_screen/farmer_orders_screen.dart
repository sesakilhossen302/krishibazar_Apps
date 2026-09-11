import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../Widgegt/Cards/order_card.dart';
import 'farmer_orders_controller.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<KrishiRepository>(context, listen: false).fetchOrdersFromBackend();
      }
    });
  }

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
    final isLoading = repo.isLoadingOrders && myOrders.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        color: const Color(0xFF166534),
        onRefresh: () => repo.fetchOrdersFromBackend(force: true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'আমার অর্ডার ও বিক্রয় (${_toBnDigits(myOrders.length)} টি)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (repo.isLoadingOrders)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF166534),
                          ),
                        ),
                    ],
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
              child: isLoading
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF166534)),
                          SizedBox(height: 12),
                          Text(
                            'অর্ডার লোড হচ্ছে...',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : myOrders.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2_outlined,
                                    size: 48,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'আপনার কোনো সক্রিয় অর্ডার নেই',
                                  style: TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'ক্রেতারা যখন আপনার পণ্যের অফার গ্রহণ করবেন, তখন এখানে অর্ডার তালিকা প্রদর্শিত হবে।',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                ),
                                const SizedBox(height: 20),
                                OutlinedButton.icon(
                                  onPressed: () => repo.fetchOrdersFromBackend(force: true),
                                  icon: const Icon(Icons.refresh_rounded, size: 18),
                                  label: const Text('রিফ্রেশ করুন'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF166534),
                                    side: const BorderSide(color: Color(0xFF166534)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }
}
