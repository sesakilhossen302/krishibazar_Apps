import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../Widgegt/Cards/demand_card.dart';
import 'buyer_demands_controller.dart';

class BuyerDemandsScreen extends StatefulWidget {
  const BuyerDemandsScreen({super.key});

  @override
  State<BuyerDemandsScreen> createState() => _BuyerDemandsScreenState();
}

class _BuyerDemandsScreenState extends State<BuyerDemandsScreen> {
  late BuyerDemandsController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<KrishiRepository>().fetchDemandsFromBackend();
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
    _controller = BuyerDemandsController(repo);
    final myDemands = _controller.myDemands;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _controller.refreshDemands,
        color: const Color(0xFFE65100),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.campaign_rounded,
                                color: Color(0xFFE65100),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'আমার চাহিদাপত্র',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFFCC80)),
                          ),
                          child: Text(
                            'মোট: ${_toBnDigits(myDemands.length)} টি',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'আপনার দোকানের প্রয়োজনীয় পণ্যের চাহিদা পোস্ট করুন। সারাদেশের কৃষকরা সরাসরি এই চাহিদা দেখে অফার পাঠাবে।',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Demands List or Empty State
            if (myDemands.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFCC80), width: 2),
                          ),
                          child: const Icon(
                            Icons.post_add_rounded,
                            size: 54,
                            color: Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          StaticString.noActiveDemands,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'আপনার ব্যবসা বা আরতের জন্য যে কোনো ফসল বা সবজির চাহিদা সহজে পোস্ট করুন এবং কৃষকদের সেরা অফার গ্রহণ করুন।',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _controller.openAddDemand,
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text(
                            StaticString.postDemandButton,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE65100),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final demand = myDemands[index];
                      return DemandCard(
                        demand: demand,
                        onAction: () => _controller.openOffers(demand),
                        actionText: '${StaticString.viewOffersButton} (${_toBnDigits(demand.offersCount)}টি)',
                        isFarmerView: false,
                        onDelete: () => _controller.confirmDeleteDemand(context, demand),
                      );
                    },
                    childCount: myDemands.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE65100),
        elevation: 4,
        onPressed: _controller.openAddDemand,
        icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
        label: const Text(
          StaticString.postDemandButton,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
