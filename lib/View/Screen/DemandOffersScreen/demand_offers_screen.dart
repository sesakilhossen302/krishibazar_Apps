import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../global/Model/krishi_models.dart';
import '../../../global/controller/krishi_repository.dart';
import '../../Widgegt/app_media_image.dart';

class DemandOffersScreen extends StatefulWidget {
  final BuyerDemand demand;

  const DemandOffersScreen({super.key, required this.demand});

  @override
  State<DemandOffersScreen> createState() => _DemandOffersScreenState();
}

class _DemandOffersScreenState extends State<DemandOffersScreen> {
  bool _isLoading = true;
  String? _acceptingOfferId;
  List<FarmerOffer> _offers = [];

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
    final fetched = await context.read<KrishiRepository>().fetchOffersForDemand(widget.demand.id);
    if (mounted) {
      setState(() {
        _offers = fetched;
        _isLoading = false;
      });
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

  void _handleBack() {
    final repo = context.read<KrishiRepository>();
    repo.closeDemandOfferManagement();
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<KrishiRepository>();
    final demand = widget.demand;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          repo.closeDemandOfferManagement();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
            tooltip: 'ফিরে যান',
            onPressed: _handleBack,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'প্রাপ্ত দরপত্র ও অফারসমূহ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '${demand.productTitle} • ${_toBnDigits(demand.requiredQuantity)} ${demand.unit.labelBn}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF166534)),
              tooltip: 'রিফ্রেশ করুন',
              onPressed: _loadOffers,
            ),
          ],
        ),
        body: RefreshIndicator(
          color: const Color(0xFF166534),
          onRefresh: _loadOffers,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Demand Summary Card
                    _buildDemandSummaryCard(demand),
                    const SizedBox(height: 18),

                    // 2. Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.gavel_rounded, size: 20, color: Color(0xFF166534)),
                            const SizedBox(width: 8),
                            const Text(
                              'জমা পড়া অফারসমূহ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Text(
                            '${_toBnDigits(_offers.length)} টি অফার',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 3. Loading State
                    if (_isLoading)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF166534)),
                            SizedBox(height: 16),
                            Text(
                              'সার্ভার থেকে কৃষকদের অফার লোড হচ্ছে...',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 13.5, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    // 4. Empty State
                    else if (_offers.isEmpty)
                      _buildEmptyState()
                    // 5. Offers List
                    else
                      ..._offers.map((offer) => _buildOfferCard(offer, demand, repo)),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemandSummaryCard(BuyerDemand demand) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(demand.category.icon, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      demand.productTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${demand.buyerBusinessName} • ${demand.buyerDistrict}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('চাহিদার পরিমাণ', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  const SizedBox(height: 3),
                  Text(
                    '${_toBnDigits(demand.requiredQuantity)} ${demand.unit.labelBn}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('কাঙ্ক্ষিত বাজেট সীমা', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  const SizedBox(height: 3),
                  Text(
                    '৳${_toBnDigits(demand.minExpectedPrice.toStringAsFixed(0))}-${_toBnDigits(demand.maxExpectedPrice.toStringAsFixed(0))}/${demand.unit.labelBn}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEA580C)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'পৌঁছানোর স্থান: ${demand.requiredLocation} • শেষ সময়: ${demand.requiredDate}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
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
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_outlined, size: 44, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          const Text(
            'এখনও কোনো কৃষক অফার জমা দেননি',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'কৃষকেরা আপনার চাহিদা দেখে দ্রুত অফার পাঠাবেন। একটু পর পুনরায় রিফ্রেশ করে দেখুন।',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _loadOffers,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('পুনরায় রিফ্রেশ করুন', style: TextStyle(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF166534),
              side: const BorderSide(color: Color(0xFF166534), width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

    final isWithinBudget = offer.pricePerUnit <= demand.maxExpectedPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAccepted ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          width: isAccepted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farmer Profile Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Farmer Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF166534), width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: offer.farmerPhotoUrl.isNotEmpty
                      ? AppMediaImage(
                          url: offer.farmerPhotoUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          fallbackEmoji: '👨🏻‍🌾',
                          placeholderWidget: _buildAvatarFallback(),
                        )
                      : _buildAvatarFallback(),
                ),
                const SizedBox(width: 12),
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
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (offer.farmerVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 16, color: Color(0xFF166534)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF64748B)),
                          const SizedBox(width: 2),
                          Text(
                            offer.farmerLocation.isNotEmpty ? offer.farmerLocation : 'বাংলাদেশ',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          if (offer.createdAt.isNotEmpty) ...[
                            const Text(' • ', style: TextStyle(color: Color(0xFF94A3B8))),
                            Text(
                              offer.createdAt,
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isAccepted ? const Color(0xFF15803D) : const Color(0xFFC2410C),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 3-Column Metrics Grid (NO OVERFLOW - CLEAN VERTICAL STACK)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFF8FAFC),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Offered Quantity
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'প্রস্তাবিত পরিমাণ',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_toBnDigits(offer.offeredQuantity)} ${offer.unit.labelBn}',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // 2. Price Per Unit with Budget Comparison Tag
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'প্রস্তাবিত দর',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '৳${_toBnDigits(offer.pricePerUnit.toStringAsFixed(0))}/${offer.unit.labelBn}',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFFEA580C)),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isWithinBudget ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isWithinBudget ? 'বাজেটে ✅' : 'বাজেট অতিরিক্ত',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isWithinBudget ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 3. Total Deal Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'মোট চুক্তি মূল্য',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '৳${_toBnDigits(totalAmount.toStringAsFixed(0))}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Security Deposit & Delivery Details Strip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.security_rounded, size: 15, color: Color(0xFF166534)),
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
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote_rounded, size: 16, color: Color(0xFF64748B)),
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

          // Accept Action Button
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: isAccepted
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'অফারটি গৃহীত হয়েছে ও অর্ডার কনফার্ম করা হয়েছে',
                            style: TextStyle(
                              fontSize: 13.5,
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
                                _loadOffers();
                              }
                            },
                      icon: isAccepting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_circle_rounded, size: 20),
                      label: Text(
                        isAccepting ? 'অর্ডার প্রস্তুত হচ্ছে...' : 'অফার গ্রহণ ও অর্ডার কনফার্ম করুন ➔',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF166534),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF166534).withValues(alpha: 0.6),
                        disabledForegroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
