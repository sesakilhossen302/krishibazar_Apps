import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../global/Model/krishi_models.dart';
import '../../../global/controller/krishi_repository.dart';
import '../../Widgegt/app_media_image.dart';

class ProductOffersScreen extends StatefulWidget {
  final ProductListing product;

  const ProductOffersScreen({super.key, required this.product});

  @override
  State<ProductOffersScreen> createState() => _ProductOffersScreenState();
}

class _ProductOffersScreenState extends State<ProductOffersScreen> {
  bool _isLoading = true;
  String? _processingOfferId;
  List<ProductOffer> _offers = [];

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
    final fetched = await context.read<KrishiRepository>().fetchOffersForProduct(widget.product.id);
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

  Widget _buildAvatarFallback() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(Icons.storefront_rounded, color: Color(0xFF64748B), size: 26),
      ),
    );
  }

  Future<void> _handleAccept(ProductOffer offer, KrishiRepository repo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Color(0xFF166534), size: 24),
            SizedBox(width: 8),
            Text('ক্রয় প্রস্তাব গ্রহণ করবেন?'),
          ],
        ),
        content: Text(
          'আপনি কি "${offer.buyerBusinessName}" এর ${_toBnDigits(offer.offeredQuantity.toStringAsFixed(0))} ${offer.unit.labelBn} ক্রয়ের প্রস্তাব (৳${_toBnDigits(offer.pricePerUnit.toStringAsFixed(0))}/${offer.unit.labelBn}) গ্রহণ করতে চান?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('না', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('হ্যাঁ, গ্রহণ করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _processingOfferId = offer.id);
    final ok = await repo.acceptProductOffer(offer.id);
    if (!mounted) return;
    setState(() => _processingOfferId = null);

    if (ok) {
      _loadOffers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ "${offer.buyerBusinessName}" এর ক্রয় প্রস্তাব সফলভাবে গৃহীত হয়েছে!'),
          backgroundColor: const Color(0xFF166534),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ প্রস্তাব গ্রহণ করতে সমস্যা হয়েছে। পুনরায় চেষ্টা করুন।'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleReject(ProductOffer offer, KrishiRepository repo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('প্রস্তাবটি বাতিল করবেন?'),
        content: Text(
          'আপনি কি নিশ্চিত যে "${offer.buyerBusinessName}" এর এই ক্রয় প্রস্তাবটি বাতিল করতে চান?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('না'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('বাতিল করুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _processingOfferId = offer.id);
    final ok = await repo.rejectProductOffer(offer.id);
    if (!mounted) return;
    setState(() => _processingOfferId = null);

    if (ok) {
      _loadOffers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('প্রস্তাবটি বাতিল করা হয়েছে।'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<KrishiRepository>();
    final product = widget.product;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          tooltip: 'ফিরে যান',
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'প্রাপ্ত ক্রয় প্রস্তাবসমূহ',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              '${product.title} • ${_toBnDigits(product.quantity.toStringAsFixed(0))} ${product.unit.labelBn}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF166534)),
            tooltip: 'রিফ্রেশ',
            onPressed: _loadOffers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF166534)),
                  SizedBox(height: 12),
                  Text('ক্রয় প্রস্তাব লোড হচ্ছে...', style: TextStyle(color: Color(0xFF64748B))),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadOffers,
              color: const Color(0xFF166534),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Top Summary Card
                  _buildProductSummaryHeader(product),
                  const SizedBox(height: 16),

                  // Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'পাইকারদের পাঠানো প্রস্তাব (${_toBnDigits(_offers.length)}টি)',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (_offers.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'সরাসরি দর কষাকষি',
                            style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_offers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      margin: const EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF7ED),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.shopping_bag_outlined, size: 48, color: Color(0xFFEA580C)),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'এখনো কোনো ক্রয় প্রস্তাব আসেনি',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'পাইকাররা আপনার পণ্যে প্রস্তাব পাঠালে এখানে দেখতে পাবেন।',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._offers.map((offer) => _buildOfferCard(offer, product, repo)),
                ],
              ),
            ),
    );
  }

  Widget _buildProductSummaryHeader(ProductListing product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: product.imageUrls.isNotEmpty
                  ? AppMediaImage(
                      url: product.imageUrls.first,
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                      fallbackEmoji: '🌾',
                    )
                  : const Center(child: Text('🌾', style: TextStyle(fontSize: 26))),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'কাঙ্ক্ষিত দর: ৳${_toBnDigits(product.expectedPrice.toStringAsFixed(0))}/${product.unit.labelBn}',
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF166534), fontWeight: FontWeight.bold),
                    ),
                    const Text(' • ', style: TextStyle(color: Color(0xFF94A3B8))),
                    Text(
                      'মজুত: ${_toBnDigits(product.quantity.toStringAsFixed(0))} ${product.unit.labelBn}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(ProductOffer offer, ProductListing product, KrishiRepository repo) {
    final isAccepted = offer.status == OfferStatus.accepted;
    final isRejected = offer.status == OfferStatus.rejected;
    final isProcessing = _processingOfferId == offer.id;
    final totalAmount = offer.offeredQuantity * offer.pricePerUnit;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAccepted
              ? const Color(0xFF86EFAC)
              : (isRejected ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0)),
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
          // Buyer Profile Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Buyer Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFEA580C), width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: offer.buyerPhotoUrl.isNotEmpty
                      ? AppMediaImage(
                          url: offer.buyerPhotoUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          fallbackEmoji: '🏪',
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
                              offer.buyerBusinessName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (offer.buyerVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 16, color: Color(0xFF166534)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            'স্বত্বাধিকারী: ${offer.buyerName}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                          ),
                          const Text(' • ', style: TextStyle(color: Color(0xFF94A3B8))),
                          const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF64748B)),
                          Text(
                            offer.buyerDistrict.isNotEmpty ? offer.buyerDistrict : 'বাংলাদেশ',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isAccepted
                        ? const Color(0xFFDCFCE7)
                        : (isRejected ? const Color(0xFFFEE2E2) : const Color(0xFFFFF7ED)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isAccepted
                          ? const Color(0xFF86EFAC)
                          : (isRejected ? const Color(0xFFFCA5A5) : const Color(0xFFFED7AA)),
                    ),
                  ),
                  child: Text(
                    isAccepted
                        ? 'গৃহীত (Accepted ✅)'
                        : (isRejected ? 'বাতিল (Rejected)' : 'বিবেচনায় (Pending)'),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isAccepted
                          ? const Color(0xFF15803D)
                          : (isRejected ? Colors.red : const Color(0xFFC2410C)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 3-Column Metrics Grid (Offered Qty, Price, Total Amount)
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
                        '${_toBnDigits(offer.offeredQuantity.toStringAsFixed(0))} ${offer.unit.labelBn}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                ),
                // 2. Offered Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'প্রস্তাবিত দর',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '৳${_toBnDigits(offer.pricePerUnit.toStringAsFixed(0))} /${offer.unit.labelBn}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEA580C)),
                      ),
                    ],
                  ),
                ),
                // 3. Total Amount
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'সর্বমোট মূল্য',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '৳${_toBnDigits(totalAmount.toStringAsFixed(0))}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Extra details: Delivery Location, Date, Note
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (offer.expectedDeliveryDate.isNotEmpty || offer.deliveryLocation.isNotEmpty)
                  Row(
                    children: [
                      if (offer.expectedDeliveryDate.isNotEmpty) ...[
                        const Icon(Icons.event_available_rounded, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          'প্রয়োজন: ${_toBnDigits(offer.expectedDeliveryDate)}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                        ),
                      ],
                      if (offer.expectedDeliveryDate.isNotEmpty && offer.deliveryLocation.isNotEmpty)
                        const Text('  •  ', style: TextStyle(color: Color(0xFF94A3B8))),
                      if (offer.deliveryLocation.isNotEmpty) ...[
                        const Icon(Icons.local_shipping_outlined, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'ডেলিভারি স্থান: ${offer.deliveryLocation}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),

                if (offer.note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'নোট: "${offer.note}"',
                      style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: Color(0xFF334155)),
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Action Buttons Row
                Row(
                  children: [
                    // Call Button
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('কল করা হচ্ছে: ${offer.buyerPhone.isNotEmpty ? offer.buyerPhone : offer.buyerName}'),
                              backgroundColor: const Color(0xFF166534),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.call, size: 16, color: Color(0xFF166534)),
                        label: const Text('কল', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          side: const BorderSide(color: Color(0xFF166534)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Reject Button
                    if (!isAccepted && !isRejected) ...[
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: isProcessing ? null : () => _handleReject(offer, repo),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('প্রত্যাখ্যান', style: TextStyle(fontSize: 13, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Accept Button
                    if (!isAccepted && !isRejected)
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: isProcessing ? null : () => _handleAccept(offer, repo),
                          icon: isProcessing
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                          label: const Text('প্রস্তাব গ্রহণ করুন', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF166534),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
