import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../../service/api_url.dart';
import '../../DemandOffersScreen/demand_offers_screen.dart';
import 'buyer_home_controller.dart';

class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

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
    final controller = BuyerHomeController(repo);
    final buyer = controller.buyer;
    final myDemands = controller.myDemands;
    final myOrders = controller.myOrders;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Buyer Banner Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF165228),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                        ),
                        child: ClipOval(
                          child: (buyer.photoUrl.isNotEmpty)
                              ? Image.network(
                                  ApiUrl.formatMediaUrl(buyer.photoUrl),
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.apartment_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                )
                              : const Icon(
                                  Icons.apartment_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              buyer.businessName.isNotEmpty
                                  ? buyer.businessName
                                  : 'কাওরান বাজার পাইকারি আড়ত',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'স্বত্বাধিকারী: ${buyer.name} • ${buyer.district}',
                              style: const TextStyle(
                                color: Color(0xFFD1FAE5),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white38),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 14),
                            SizedBox(width: 4),
                            Text(
                              'ভেরিফাইড ক্রেতা ✅',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'পেমেন্ট নির্ভরযোগ্যতা: ৯৯%',
                        style: TextStyle(
                          color: Color(0xFFD1FAE5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Search Bar
            InkWell(
              onTap: controller.goToSearch,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Color(0xFF165228), size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'আপনার কী পণ্য দরকার? (যেমন: টমেটো, আলু, পেঁয়াজ)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, color: Color(0xFF165228), size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. Quick Action Cards (Grid - Responsive text)
            Row(
              children: [
                // Card 1: পণ্য খুঁজুন
                Expanded(
                  child: InkWell(
                    onTap: controller.goToSearch,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECF7ED),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFC8E6C9)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF165228),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 22),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'পণ্য খুঁজুন',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF165228),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            softWrap: true,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'কৃষকের সরাসরি ফসল',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Card 2: আমার প্রয়োজন পোস্ট করুন
                Expanded(
                  child: InkWell(
                    onTap: controller.openAddDemand,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFE0B2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE65100),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.post_add_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'আমার প্রয়োজন পোস্ট করুন',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC2410C),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            softWrap: true,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'কৃষকদের অফার আহ্বান',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 4. Crop Categories Section
            const Text(
              'পণ্যের ক্যাটাগরি',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ProductCategory.values.length,
                itemBuilder: (context, index) {
                  final cat = ProductCategory.values[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () => controller.selectCategory(cat),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Text(cat.icon, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              cat.labelBn,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // 5. My Published Demands Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'আমার প্রকাশিত চাহিদা (${_toBnDigits(myDemands.length)} টি)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                GestureDetector(
                  onTap: controller.openAddDemand,
                  child: const Text(
                    '+ নতুন চাহিদা',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEA580C),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (myDemands.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Text(
                    'আপনার কোনো সক্রিয় চাহিদা পোস্ট নেই',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ),
              )
            else
              ...myDemands.map((demand) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Title & Offers Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(demand.category.icon, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
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
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_toBnDigits(demand.offersCount)}টি অফার এসেছে 🔔',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Details line 1
                      Text(
                        'প্রয়োজন: ${_toBnDigits(demand.requiredQuantity.toInt())} ${demand.unit.labelBn} • কাঙ্ক্ষিত দর: ৳${_toBnDigits(demand.minExpectedPrice.toInt())}–${_toBnDigits(demand.maxExpectedPrice.toInt())}/${demand.unit.labelBn}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Details line 2
                      Text(
                        'ডেলিভারি লোকেশন: ${demand.requiredLocation} • তারিখ: ${demand.requiredDate}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Action button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DemandOffersScreen(demand: demand),
                              ),
                            );
                          },
                          icon: const Icon(Icons.people_rounded, color: Colors.white, size: 18),
                          label: Text(
                            'প্রাপ্ত অফার দেখুন ও নির্বাচন করুন (${_toBnDigits(demand.offersCount)} টি)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF165228),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 20),

            // 6. My Recent Orders Section
            const Row(
              children: [
                Text(
                  'আমার সাম্প্রতিক অর্ডার 📦',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (myOrders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Text(
                    'আপনার কোনো সাম্প্রতিক অর্ডার নেই',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ),
              )
            else
              ...myOrders.map((order) {
                final isPaid = order.isDepositPaid || order.paymentStatus == 'confirmed';
                final isPaymentPending = order.paymentStatus == 'pending_verification' ||
                    order.orderStatus == OrderStatus.paymentPending;
                final isQualityRejected = order.isQualityPassed == false ||
                    order.orderStatus == OrderStatus.qualityRejected;
                final isRefunded = order.refundStatus == 'completed' ||
                    order.orderStatus == OrderStatus.refunded;
                final isWaitingForDeposit = !order.isDepositPaid &&
                    order.paymentStatus != 'confirmed' &&
                    order.paymentStatus != 'pending_verification' &&
                    !isQualityRejected &&
                    !isRefunded;

                String statusBadgeText = 'ডিপোজিট বাকি ⏳';
                Color statusBadgeBg = const Color(0xFFFFEDD5);
                Color statusBadgeTextCol = const Color(0xFFEA580C);
                IconData statusBadgeIcon = Icons.schedule;

                String depositBadgeText = 'ডিপোজিট বাকি ⏳';
                Color depositBadgeBg = const Color(0xFFFFEDD5);
                Color depositBadgeTextCol = const Color(0xFFEA580C);

                if (isRefunded) {
                  statusBadgeText = 'রিফান্ড সম্পন্ন 💰';
                  statusBadgeBg = const Color(0xFFE0F2FE);
                  statusBadgeTextCol = const Color(0xFF0284C7);
                  statusBadgeIcon = Icons.monetization_on;
                  depositBadgeText = 'রিফান্ডেড 💸';
                  depositBadgeBg = const Color(0xFFE0F2FE);
                  depositBadgeTextCol = const Color(0xFF0284C7);
                } else if (isQualityRejected) {
                  statusBadgeText = 'পণ্য বাতিল ❌';
                  statusBadgeBg = const Color(0xFFFEE2E2);
                  statusBadgeTextCol = const Color(0xFFDC2626);
                  statusBadgeIcon = Icons.cancel;
                  depositBadgeText = 'বাতিলকৃত ❌';
                  depositBadgeBg = const Color(0xFFFEE2E2);
                  depositBadgeTextCol = const Color(0xFFDC2626);
                } else if (order.orderStatus == OrderStatus.completed) {
                  statusBadgeText = 'অর্ডার সম্পন্ন 🎉';
                  statusBadgeBg = const Color(0xFFDCFCE7);
                  statusBadgeTextCol = const Color(0xFF166534);
                  statusBadgeIcon = Icons.check_circle;
                  depositBadgeText = 'পরিশোধিত ✅';
                  depositBadgeBg = const Color(0xFFDCFCE7);
                  depositBadgeTextCol = const Color(0xFF166534);
                } else if (order.orderStatus == OrderStatus.delivered) {
                  statusBadgeText = 'ডেলিভারি সম্পন্ন 📦';
                  statusBadgeBg = const Color(0xFFDCFCE7);
                  statusBadgeTextCol = const Color(0xFF166534);
                  statusBadgeIcon = Icons.check_circle;
                  depositBadgeText = 'খালাস বাকি ⏳';
                  depositBadgeBg = const Color(0xFFDCFCE7);
                  depositBadgeTextCol = const Color(0xFF166534);
                } else if (order.orderStatus == OrderStatus.inTransit) {
                  statusBadgeText = 'ইন ট্রানজিট 🚚';
                  statusBadgeBg = const Color(0xFFE0F2FE);
                  statusBadgeTextCol = const Color(0xFF0284C7);
                  statusBadgeIcon = Icons.local_shipping;
                  depositBadgeText = 'ডিপোজিট পেইড ✅';
                  depositBadgeBg = const Color(0xFFDCFCE7);
                  depositBadgeTextCol = const Color(0xFF166534);
                } else if (order.orderStatus == OrderStatus.collectionVerified ||
                    (order.isQualityPassed == true && order.verification.isVerified)) {
                  statusBadgeText = 'হাব যাচাই সম্পন্ন ⚖️';
                  statusBadgeBg = const Color(0xFFE0E7FF);
                  statusBadgeTextCol = const Color(0xFF4338CA);
                  statusBadgeIcon = Icons.verified;
                  depositBadgeText = 'ডিপোজিট পেইড ✅';
                  depositBadgeBg = const Color(0xFFDCFCE7);
                  depositBadgeTextCol = const Color(0xFF166534);
                } else if (order.orderStatus == OrderStatus.paymentConfirmed || isPaid) {
                  statusBadgeText = 'পেমেন্ট কনফার্মড 🔬';
                  statusBadgeBg = const Color(0xFFDCFCE7);
                  statusBadgeTextCol = const Color(0xFF166534);
                  statusBadgeIcon = Icons.check_circle;
                  depositBadgeText = 'ডিপোজিট পেইড ✅';
                  depositBadgeBg = const Color(0xFFDCFCE7);
                  depositBadgeTextCol = const Color(0xFF166534);
                } else if (isPaymentPending) {
                  statusBadgeText = 'পেমেন্ট যাচাই পেন্ডিং ⏳';
                  statusBadgeBg = const Color(0xFFFEF3C7);
                  statusBadgeTextCol = const Color(0xFFB45309);
                  statusBadgeIcon = Icons.hourglass_top;
                  depositBadgeText = 'যাচাই পেন্ডিং ⏳';
                  depositBadgeBg = const Color(0xFFFEF3C7);
                  depositBadgeTextCol = const Color(0xFFB45309);
                }

                return InkWell(
                  onTap: () => controller.openOrderDetail(order),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Header (ID & Status)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '#${order.id.replaceAll('ord_', 'KB-')}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF165228),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusBadgeBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusBadgeIcon,
                                    size: 12,
                                    color: statusBadgeTextCol,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    statusBadgeText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: statusBadgeTextCol,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Product & Quantity Title
                        Text(
                          '${order.productTitle} — ${_toBnDigits(order.quantity.toInt())} ${order.unit.labelBn}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Farmer info
                        Text(
                          'কৃষক: ${order.farmerName} (${order.farmerLocation})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Price & Action Button Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'মোট মূল্য',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                                Text(
                                  '৳${_toBnDigits(order.totalAmount.toInt())}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF165228),
                                  ),
                                ),
                              ],
                            ),
                            if (isWaitingForDeposit)
                              ElevatedButton(
                                onPressed: () => controller.openOrderDetail(order),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEA580C),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'ডিপোজিট পে করুন',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: depositBadgeBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  depositBadgeText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: depositBadgeTextCol,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
