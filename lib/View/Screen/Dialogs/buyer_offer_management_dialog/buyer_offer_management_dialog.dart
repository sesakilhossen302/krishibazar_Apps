import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../Widgegt/app_media_image.dart';

class BuyerOfferManagementDialog extends StatefulWidget {
  final BuyerDemand demand;

  const BuyerOfferManagementDialog({super.key, required this.demand});

  @override
  State<BuyerOfferManagementDialog> createState() => _BuyerOfferManagementDialogState();
}

class _BuyerOfferManagementDialogState extends State<BuyerOfferManagementDialog> {
  bool _isLoading = true;
  String? _acceptingOfferId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOffers();
    });
  }

  Future<void> _loadOffers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await context.read<KrishiRepository>().fetchOffersForDemand(widget.demand.id);
    if (mounted) {
      setState(() => _isLoading = false);
    }
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
    final demand = widget.demand;
    final offers = repo.offers.where((o) => o.demandId == demand.id).toList();

    return Stack(
      children: [
        // 1. Dark Backdrop Scrim
        Positioned.fill(
          child: GestureDetector(
            onTap: repo.closeDemandOfferManagement,
            child: Container(
              color: Colors.black.withValues(alpha: 0.65),
            ),
          ),
        ),

        // 2. Centered Modal Card
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Scaffold(
                backgroundColor: const Color(0xFFF8FAFC),
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0.5,
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(demand.category.icon, style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'কৃষকদের প্রাপ্ত দরপত্র (Offers)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              '${demand.productTitle} (${_toBnDigits(demand.requiredQuantity)} ${demand.unit.labelBn})',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Color(0xFF166534)),
                      tooltip: 'রিফ্রেশ করুন',
                      onPressed: _loadOffers,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.black54),
                      tooltip: 'বন্ধ করুন',
                      onPressed: repo.closeDemandOfferManagement,
                    ),
                  ],
                ),
                body: RefreshIndicator(
                  color: const Color(0xFF166534),
                  onRefresh: _loadOffers,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Demand Summary Header Card
                        _buildDemandSummaryCard(demand),
                        const SizedBox(height: 16),

                        // Section Title with Count Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.gavel_rounded, size: 18, color: Color(0xFF166534)),
                                const SizedBox(width: 6),
                                const Text(
                                  'জমা পড়া অফারসমূহ',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_toBnDigits(offers.length)} টি অফার',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF166534),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Loading State
                        if (_isLoading)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Color(0xFF166534)),
                                SizedBox(height: 14),
                                Text(
                                  'সার্ভার থেকে কৃষকদের অফার লোড হচ্ছে...',
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        // Empty State
                        else if (offers.isEmpty)
                          _buildEmptyState()
                        // Offers List
                        else
                          ...offers.map((offer) => _buildOfferCard(offer, demand, repo)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDemandSummaryCard(BuyerDemand demand) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FDF4), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCFCE7), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  demand.productTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  demand.qualityGrade.labelBn,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFDCFCE7)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('চাহিদার পরিমাণ', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  const SizedBox(height: 2),
                  Text(
                    '${_toBnDigits(demand.requiredQuantity)} ${demand.unit.labelBn}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('কাঙ্ক্ষিত বাজেট সীমা', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  const SizedBox(height: 2),
                  Text(
                    '৳${_toBnDigits(demand.minExpectedPrice.toStringAsFixed(0))}-${_toBnDigits(demand.maxExpectedPrice.toStringAsFixed(0))}/${demand.unit.labelBn}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFEA580C)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'গন্তব্য: ${demand.requiredLocation} • পৌঁছানোর তারিখ: ${demand.requiredDate}',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_outlined, size: 40, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 14),
          const Text(
            'এখনও কোনো কৃষক অফার জমা দেননি',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'কৃষকেরা আপনার চাহিদা দেখে দ্রুত অফার পাঠাবেন। একটু অপেক্ষা করুন অথবা পুনরায় রিফ্রেশ করুন।',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _loadOffers,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('রিফ্রেশ করুন'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF166534),
              side: const BorderSide(color: Color(0xFF166534)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(FarmerOffer offer, BuyerDemand demand, KrishiRepository repo) {
    final isAccepted = offer.status == OfferStatus.accepted;
    final isAccepting = _acceptingOfferId == offer.id;
    final totalAmount = offer.offeredQuantity * offer.pricePerUnit;
    final depositAmount = totalAmount * 0.20;

    // Budget comparison logic
    final isWithinBudget = offer.pricePerUnit <= demand.maxExpectedPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAccepted ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          width: isAccepted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farmer Profile Row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Farmer Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF166534), width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: offer.farmerPhotoUrl.isNotEmpty
                      ? AppMediaImage(
                          url: offer.farmerPhotoUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          fallbackEmoji: '👨🏻‍🌾',
                          placeholderWidget: _buildAvatarFallback(),
                        )
                      : _buildAvatarFallback(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              offer.farmerName,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (offer.farmerVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 15, color: Color(0xFF166534)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF64748B)),
                          const SizedBox(width: 2),
                          Text(
                            offer.farmerLocation.isNotEmpty ? offer.farmerLocation : 'বাংলাদেশ',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                          ),
                          if (offer.createdAt.isNotEmpty) ...[
                            const Text(' • ', style: TextStyle(color: Color(0xFF94A3B8))),
                            Text(
                              offer.createdAt,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAccepted ? const Color(0xFFDCFCE7) : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isAccepted ? const Color(0xFF86EFAC) : const Color(0xFFFED7AA),
                    ),
                  ),
                  child: Text(
                    isAccepted ? 'গৃহীত (Accepted ✅)' : 'বিবেচনায় (Pending)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isAccepted ? const Color(0xFF15803D) : const Color(0xFFC2410C),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Pricing & Quantity Grid
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: const Color(0xFFF8FAFC),
            child: Row(
              children: [
                // 1. Quantity
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('প্রস্তাবিত পরিমাণ', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      const SizedBox(height: 2),
                      Text(
                        '${_toBnDigits(offer.offeredQuantity)} ${offer.unit.labelBn}',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                      ),
                    ],
                  ),
                ),
                // 2. Price Per Unit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('প্রস্তাবিত দর', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '৳${_toBnDigits(offer.pricePerUnit.toStringAsFixed(0))}/${offer.unit.labelBn}',
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFFEA580C)),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: isWithinBudget ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isWithinBudget ? 'বাজেটে ✅' : 'উচ্চ',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isWithinBudget ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 3. Total Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('মোট চুক্তি মূল্য', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      const SizedBox(height: 2),
                      Text(
                        '৳${_toBnDigits(totalAmount.toStringAsFixed(0))}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Deposit and Delivery Info Strip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.security_rounded, size: 14, color: Color(0xFF166534)),
                    const SizedBox(width: 4),
                    Text(
                      '২০% অগ্রিম ডিপোজিট: ৳${_toBnDigits(depositAmount.toStringAsFixed(0))}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF166534), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  'ডেলিভারি: ${offer.availableDate}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                ),
              ],
            ),
          ),

          // Farmer's Note (if present)
          if (offer.note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote_rounded, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        offer.note,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Action Button
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
            child: isAccepted
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 18),
                          SizedBox(width: 6),
                          Text(
                            'এই অফারটি গৃহীত হয়েছে ও অর্ডার তৈরি করা হয়েছে',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isAccepting
                          ? null
                          : () async {
                              setState(() => _acceptingOfferId = offer.id);
                              await repo.acceptOffer(offer.id);
                              if (mounted) {
                                setState(() => _acceptingOfferId = null);
                              }
                            },
                      icon: isAccepting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_circle_rounded, size: 18),
                      label: Text(
                        isAccepting ? 'অর্ডার প্রসেস হচ্ছে...' : 'অফার গ্রহণ ও অর্ডার কনফার্ম করুন ➔',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF166534),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF166534).withValues(alpha: 0.6),
                        disabledForegroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: const Color(0xFFDCFCE7),
      child: const Center(
        child: Text('👨🏻‍🌾', style: TextStyle(fontSize: 22)),
      ),
    );
  }
}
