import 'package:flutter/material.dart';
import '../../../global/Model/krishi_models.dart';

class OrderCard extends StatelessWidget {
  final MarketplaceOrder order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

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
    final isPaid = order.isDepositPaid || order.paymentStatus == 'confirmed';
    final isPaymentPending = order.paymentStatus == 'pending_verification' ||
        order.orderStatus == OrderStatus.paymentPending;
    final isQualityRejected = order.isQualityPassed == false ||
        order.orderStatus == OrderStatus.qualityRejected;
    final isRefunded = order.refundStatus == 'completed' ||
        order.orderStatus == OrderStatus.refunded;

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

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Line: Order Number & Top Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          '#${order.orderNumber}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF166534),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '• ${order.createdAt}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
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
                          color: statusBadgeTextCol,
                          size: 12,
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

              const SizedBox(height: 12),

              // Title Line
              Text(
                '${order.productTitle} — ${_toBnDigits(order.quantity.toInt())} ${order.unit.labelBn}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Buyer Line
              Text(
                'ক্রেতা: ${order.buyerBusinessName.isNotEmpty ? order.buyerBusinessName : order.buyerName} (${order.buyerName})',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 14),

              // Bottom Price & Deposit Chip Row
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
                      const SizedBox(height: 2),
                      Text(
                        '৳${_toBnDigits(order.totalAmount.toInt())}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
      ),
    );
  }
}
