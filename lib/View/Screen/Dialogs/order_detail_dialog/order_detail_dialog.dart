import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import 'order_detail_controller.dart';

class OrderDetailDialog extends StatelessWidget {
  final MarketplaceOrder order;

  const OrderDetailDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<KrishiRepository>();
    // Fetch latest updated order state from repository
    final currentOrder = repo.orders.firstWhere(
      (o) => o.id == order.id,
      orElse: () => order,
    );
    final controller = OrderDetailController(repo, currentOrder);
    final isFarmer = controller.currentRole == UserRole.farmer;

    final isRejected =
        currentOrder.isQualityPassed == false ||
        currentOrder.orderStatus == OrderStatus.qualityRejected ||
        currentOrder.orderStatus == OrderStatus.refunded;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        controller.close();
      },
      child: Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F7F4),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
              onPressed: () {
                controller.close();
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'অর্ডার ট্র্যাকিং #${currentOrder.orderNumber}',
                  style: const TextStyle(
                    color: Color(0xFF166534),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'তারিখ: ${currentOrder.createdAt}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: Color(0xFF166534),
                ),
                onPressed: controller.openChat,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Order Status Box
                _buildStatusBox(currentOrder, isFarmer),
                const SizedBox(height: 14),

                // 2. Order Parties Box ("অর্ডারের পক্ষসমূহ")
                _buildPartiesBox(currentOrder),
                const SizedBox(height: 14),

                // 3. Payment & Escrow Box ("পেমেন্ট ও ডিপোজিট এসক্রো 💰")
                _buildPaymentEscrowBox(currentOrder, controller, isFarmer),

                // 4. Quality Inspection Failure & Refund Box ("পণ্য মান বাতিল ও রিফান্ড")
                // দেখা যাবে যদি পণ্য টেস্টে বাতিল হয়
                if (isRejected) ...[
                  const SizedBox(height: 14),
                  _buildQualityRejectionBox(currentOrder, context, isFarmer),
                ],

                // 5. Weight & Quality Verification Box ("ওজন ও গুণমান যাচাই ⚖️")
                // দেখা যাবে যখন ক্রেতা ডিপোজিট জমা দিয়েছে এবং পণ্য বাতিল হয়নি
                if (!isRejected &&
                    (currentOrder.isDepositPaid ||
                        currentOrder.paymentStatus == 'pending_verification' ||
                        currentOrder.paymentStatus == 'confirmed' ||
                        currentOrder.orderStatus ==
                            OrderStatus.paymentPending ||
                        currentOrder.orderStatus ==
                            OrderStatus.paymentConfirmed ||
                        currentOrder.orderStatus ==
                            OrderStatus.collectionVerified)) ...[
                  const SizedBox(height: 14),
                  _buildVerificationBox(currentOrder),
                ],

                // 6. Transport & Tracking Box ("পরিবহন ও ট্র্যাকিং 🚚")
                // দেখা যাবে শুধুমাত্র কালেকশন হাবে এডমিন কর্তৃক মান যাচাই সফলভাবে সম্পন্ন হবার পর (isQualityPassed == true)
                if (!isRejected &&
                    (currentOrder.isQualityPassed == true ||
                        currentOrder.orderStatus ==
                            OrderStatus.collectionVerified ||
                        currentOrder.orderStatus == OrderStatus.inTransit ||
                        currentOrder.orderStatus == OrderStatus.delivered ||
                        currentOrder.orderStatus == OrderStatus.completed) &&
                    currentOrder.deliveryInfo.driverName.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildTransportBox(currentOrder, controller, isFarmer),
                ],

                // 7. Bottom Action Buttons (Dispute & Rating)
                // দেখা যাবে শুধুমাত্র পণ্য সফলভাবে ডেলিভারি বা সম্পন্ন হবার পর
                if (currentOrder.orderStatus == OrderStatus.delivered ||
                    currentOrder.orderStatus == OrderStatus.completed) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.openDispute,
                          icon: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          label: const Text(
                            'সমস্যা রিপোর্ট',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: controller.openRating,
                          icon: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            'রেটিং দিন',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA580C),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper 1: Order Current Status Box ---
  Widget _buildStatusBox(MarketplaceOrder currentOrder, bool isFarmer) {
    final isPaid =
        currentOrder.isDepositPaid || currentOrder.paymentStatus == 'confirmed';
    final isPaymentPending =
        currentOrder.paymentStatus == 'pending_verification' ||
        currentOrder.orderStatus == OrderStatus.paymentPending;
    final isQualityRejected =
        currentOrder.isQualityPassed == false ||
        currentOrder.orderStatus == OrderStatus.qualityRejected;
    final isRefunded =
        currentOrder.orderStatus == OrderStatus.refunded ||
        currentOrder.refundStatus == 'completed';

    String statusBadgeText = 'ডিপোজিট বাকি ⏳';
    Color statusBadgeBg = const Color(0xFFFFEDD5);
    Color statusBadgeTextCol = const Color(0xFFEA580C);
    IconData statusBadgeIcon = Icons.schedule;

    if (isRefunded) {
      statusBadgeText = 'টাকা রিফান্ড সম্পন্ন 💰';
      statusBadgeBg = const Color(0xFFE0F2FE);
      statusBadgeTextCol = const Color(0xFF0284C7);
      statusBadgeIcon = Icons.monetization_on;
    } else if (isQualityRejected) {
      statusBadgeText = 'পণ্য মানসম্মত নয় (বাতিল) ❌';
      statusBadgeBg = const Color(0xFFFEE2E2);
      statusBadgeTextCol = const Color(0xFFDC2626);
      statusBadgeIcon = Icons.cancel;
    } else if (isFarmer && currentOrder.farmerPayoutStatus == 'completed') {
      statusBadgeText = 'পেআউট সম্পন্ন ✅';
      statusBadgeBg = const Color(0xFFDCFCE7);
      statusBadgeTextCol = const Color(0xFF166534);
      statusBadgeIcon = Icons.check_circle;
    } else if (isFarmer &&
        (currentOrder.orderStatus == OrderStatus.delivered ||
            currentOrder.orderStatus == OrderStatus.completed)) {
      statusBadgeText = 'পেআউট পেন্ডিং ⏳';
      statusBadgeBg = const Color(0xFFFFF7ED);
      statusBadgeTextCol = const Color(0xFFEA580C);
      statusBadgeIcon = Icons.hourglass_top;
    } else if (currentOrder.orderStatus == OrderStatus.completed) {
      statusBadgeText = 'অর্ডার সম্পন্ন 🎉';
      statusBadgeBg = const Color(0xFFDCFCE7);
      statusBadgeTextCol = const Color(0xFF166534);
      statusBadgeIcon = Icons.check_circle;
    } else if (currentOrder.orderStatus == OrderStatus.delivered) {
      statusBadgeText = 'ডেলিভারি সম্পন্ন 📦';
      statusBadgeBg = const Color(0xFFDCFCE7);
      statusBadgeTextCol = const Color(0xFF166534);
      statusBadgeIcon = Icons.check_circle;
    } else if (currentOrder.orderStatus == OrderStatus.inTransit) {
      statusBadgeText = 'ইন ট্রানজিট 🚚';
      statusBadgeBg = const Color(0xFFE0F2FE);
      statusBadgeTextCol = const Color(0xFF0284C7);
      statusBadgeIcon = Icons.local_shipping;
    } else if (currentOrder.orderStatus == OrderStatus.collectionVerified ||
        (currentOrder.isQualityPassed == true &&
            currentOrder.verification.isVerified)) {
      statusBadgeText = 'হাব মান যাচাই সম্পন্ন ⚖️';
      statusBadgeBg = const Color(0xFFE0E7FF);
      statusBadgeTextCol = const Color(0xFF4338CA);
      statusBadgeIcon = Icons.verified;
    } else if (currentOrder.orderStatus == OrderStatus.paymentConfirmed ||
        isPaid) {
      statusBadgeText = 'পেমেন্ট গৃহীত ও টেস্ট চলমান 🔬';
      statusBadgeBg = const Color(0xFFDCFCE7);
      statusBadgeTextCol = const Color(0xFF166534);
      statusBadgeIcon = Icons.check_circle;
    } else if (isPaymentPending) {
      statusBadgeText = 'পেমেন্ট যাচাই পেন্ডিং ⏳';
      statusBadgeBg = const Color(0xFFFEF3C7);
      statusBadgeTextCol = const Color(0xFFB45309);
      statusBadgeIcon = Icons.hourglass_top;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPaid
            ? const Color(0xFFEBF5EC)
            : (isQualityRejected
                  ? const Color(0xFFFFF1F2)
                  : const Color(0xFFFFF7ED)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid
              ? const Color(0xFFC7E0CB)
              : (isQualityRejected
                    ? const Color(0xFFFECDD3)
                    : const Color(0xFFFFEDD5)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'অর্ডার বর্তমান অবস্থা:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBadgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusBadgeIcon, color: statusBadgeTextCol, size: 14),
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
          Text(
            currentOrder.productTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF166534),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'একক দর: ৳${currentOrder.pricePerUnit.toStringAsFixed(0)}/${currentOrder.unit.labelBn} • মান গ্রেড: ${currentOrder.verification.qualityGrade.labelBn}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 16),
          // Live Tracking Progress Stepper
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.route_outlined,
                      size: 16,
                      color: Color(0xFF166534),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'লাইভ ট্র্যাকিং টাইমলাইন 📍',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildTrackingStep(
                  title: 'অফার গৃহীত ও অর্ডার তৈরি',
                  subtitle:
                      'অর্ডার নং #${currentOrder.orderNumber} নিশ্চিত হয়েছে',
                  isCompleted: true,
                  isActive: false,
                  icon: Icons.assignment_turned_in_rounded,
                ),
                _buildTrackingStep(
                  title: '২০% সিকিউরিটি ডিপোজিট',
                  subtitle: isPaid
                      ? '৳${currentOrder.depositRequired.toStringAsFixed(0)} ডিপোজিট এসক্রোতে জমা হয়েছে'
                      : (isPaymentPending
                            ? 'পেমেন্ট জমা পড়েছে, এডমিন যাচাই চলছে'
                            : 'ডিপোজিট বাকি (৳${currentOrder.depositRequired.toStringAsFixed(0)})'),
                  isCompleted: isPaid,
                  isActive: !isPaid,
                  icon: Icons.account_balance_wallet_rounded,
                ),
                _buildTrackingStep(
                  title: isQualityRejected
                      ? 'কালেকশন হাব মান যাচাই (বাতিল)'
                      : 'কালেকশন হাব ও গুণমান যাচাই',
                  subtitle: isQualityRejected
                      ? 'পণ্য নির্দিষ্ট মান পূরণ না করায় বাতিল হয়েছে'
                      : (currentOrder.isQualityPassed == true
                            ? 'ওজন ও ডিজিটাল মান যাচাই সম্পন্ন'
                            : (currentOrder.inspectorName.isNotEmpty
                                  ? 'এজেন্ট ${currentOrder.inspectorName} টেস্ট করছেন'
                                  : '${currentOrder.deliveryInfo.collectionCenter} এ পরীক্ষার অপেক্ষায়')),
                  isCompleted:
                      currentOrder.isQualityPassed == true ||
                      currentOrder.orderStatus ==
                          OrderStatus.collectionVerified ||
                      currentOrder.orderStatus == OrderStatus.inTransit ||
                      currentOrder.orderStatus == OrderStatus.delivered ||
                      currentOrder.orderStatus == OrderStatus.completed,
                  isActive:
                      (isPaid || isPaymentPending) &&
                      currentOrder.isQualityPassed != true &&
                      !isQualityRejected,
                  isFailed: isQualityRejected,
                  icon: isQualityRejected
                      ? Icons.cancel
                      : Icons.verified_outlined,
                ),
                if (!isQualityRejected && !isRefunded) ...[
                  _buildTrackingStep(
                    title: 'ট্রাকে লোড ও পরিবহন',
                    subtitle:
                        currentOrder.deliveryInfo.transportStatus ==
                            TransportStatus.inTransit
                        ? '${currentOrder.deliveryInfo.vehicleNumber.isNotEmpty ? currentOrder.deliveryInfo.vehicleNumber : "গাড়ি"} পথে রয়েছে'
                        : (currentOrder.deliveryInfo.transportStatus ==
                                  TransportStatus.delivered
                              ? 'গন্তব্যে পৌঁছেছে'
                              : 'পরিবহনের জন্য রেডি হচ্ছে'),
                    isCompleted:
                        currentOrder.deliveryInfo.transportStatus ==
                            TransportStatus.delivered ||
                        currentOrder.orderStatus == OrderStatus.delivered ||
                        currentOrder.orderStatus == OrderStatus.completed,
                    isActive:
                        currentOrder.deliveryInfo.transportStatus ==
                            TransportStatus.inTransit ||
                        currentOrder.orderStatus == OrderStatus.inTransit,
                    icon: Icons.local_shipping_rounded,
                  ),
                  _buildTrackingStep(
                    title: 'ডেলিভারি ও খালাস সম্পন্ন',
                    subtitle: currentOrder.orderStatus == OrderStatus.completed
                        ? 'সম্পূর্ণ পণ্য গ্রহণ ও পেমেন্ট সেটেলমেন্ট সম্পন্ন'
                        : 'ডেলিভারি ঠিকানা: ${currentOrder.deliveryLocation}',
                    isCompleted:
                        currentOrder.orderStatus == OrderStatus.completed,
                    isActive: currentOrder.orderStatus == OrderStatus.delivered,
                    isLast: true,
                    icon: Icons.check_circle_rounded,
                  ),
                ] else ...[
                  _buildTrackingStep(
                    title: isRefunded
                        ? 'রিফান্ড নিষ্পত্তি সম্পন্ন'
                        : '২০% ডিপোজিট রিফান্ড',
                    subtitle: isRefunded
                        ? 'ক্রেতার অ্যাকাউন্টে ২০% ডিপোজিট ফেরত পাঠানো হয়েছে'
                        : 'এডমিন রিফান্ড প্রক্রিয়াধীন রয়েছে',
                    isCompleted: isRefunded,
                    isActive: !isRefunded,
                    isLast: true,
                    icon: Icons.replay_rounded,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    required IconData icon,
    bool isFailed = false,
    bool isLast = false,
  }) {
    Color color = const Color(0xFF94A3B8);
    Color bgColor = const Color(0xFFF1F5F9);
    Color borderColor = const Color(0xFFCBD5E1);

    if (isFailed) {
      color = const Color(0xFFDC2626);
      bgColor = const Color(0xFFFEE2E2);
      borderColor = const Color(0xFFEF4444);
    } else if (isCompleted) {
      color = const Color(0xFF166534);
      bgColor = const Color(0xFFDCFCE7);
      borderColor = const Color(0xFF166534);
    } else if (isActive) {
      color = const Color(0xFFEA580C);
      bgColor = const Color(0xFFFFF7ED);
      borderColor = const Color(0xFFEA580C);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: (isActive || isFailed) ? 2 : 1.5,
                ),
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 26,
                color: isCompleted
                    ? const Color(0xFF166534)
                    : (isFailed
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFE2E8F0)),
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isCompleted || isActive || isFailed
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: isFailed
                        ? const Color(0xFFDC2626)
                        : (isCompleted
                              ? const Color(0xFF0F172A)
                              : (isActive
                                    ? const Color(0xFFEA580C)
                                    : const Color(0xFF64748B))),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isFailed
                        ? const Color(0xFFB91C1C)
                        : (isActive
                              ? const Color(0xFFC2410C)
                              : const Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Helper 2: Order Parties Box ("অর্ডারের পক্ষসমূহ") ---
  Widget _buildPartiesBox(MarketplaceOrder currentOrder) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'অর্ডারের পক্ষসমূহ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          // Farmer Row
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👨‍🌾', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentOrder.farmerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            'কৃষক • ${currentOrder.farmerLocation}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                currentOrder.farmerPhone,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF166534),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          // Buyer Row
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF7ED),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🏢', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentOrder.buyerBusinessName.isNotEmpty
                          ? currentOrder.buyerBusinessName
                          : currentOrder.buyerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            'ক্রেতা (${currentOrder.buyerName}) • ${currentOrder.deliveryLocation}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                currentOrder.buyerPhone,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEA580C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helper 3: Payment & Escrow Box ("পেমেন্ট ও ডিপোজিট এসক্রো 💰") ---
  Widget _buildPaymentEscrowBox(
    MarketplaceOrder currentOrder,
    OrderDetailController controller,
    bool isFarmer,
  ) {
    final isPaid =
        currentOrder.isDepositPaid || currentOrder.paymentStatus == 'confirmed';
    final isPaymentPending =
        currentOrder.paymentStatus == 'pending_verification' ||
        currentOrder.orderStatus == OrderStatus.paymentPending;
    final isRefundPending =
        currentOrder.refundStatus == 'pending' ||
        currentOrder.paymentStatus == 'refund_pending';
    final isRefunded =
        currentOrder.refundStatus == 'completed' ||
        currentOrder.orderStatus == OrderStatus.refunded;

    String badgeText = 'ডিপোজিট বাকি ⏳';
    Color badgeBg = const Color(0xFFFFF7ED);
    Color badgeColor = const Color(0xFFEA580C);

    if (isRefunded) {
      badgeText = 'রিফান্ড সম্পন্ন 💸';
      badgeBg = const Color(0xFFE0F2FE);
      badgeColor = const Color(0xFF0284C7);
    } else if (isRefundPending) {
      badgeText = 'রিফান্ড অপেক্ষমাণ ⏳';
      badgeBg = const Color(0xFFFEF3C7);
      badgeColor = const Color(0xFFB45309);
    } else if (isPaid) {
      badgeText = 'ডিপোজিট পেইড ও কনফার্মড ✅';
      badgeBg = const Color(0xFFDCFCE7);
      badgeColor = const Color(0xFF166534);
    } else if (isPaymentPending) {
      badgeText = 'পেমেন্ট যাচাই পেন্ডিং ⏳';
      badgeBg = const Color(0xFFFEF3C7);
      badgeColor = const Color(0xFFB45309);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'পেমেন্ট ও ডিপোজিট এসক্রো 💰',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isFarmer) ...[
            _buildRowText(
              'পণ্যের বিক্রয় মূল্য:',
              '৳${(currentOrder.productAmount > 0 ? currentOrder.productAmount : currentOrder.totalAmount).toStringAsFixed(0)}',
              isBold: true,
            ),
            const SizedBox(height: 6),
            _buildRowText(
              'প্ল্যাটফর্ম সার্ভিস ফি (-৫%):',
              '- ৳${(currentOrder.farmerServiceFee > 0 ? currentOrder.farmerServiceFee : currentOrder.totalAmount * 0.05).toStringAsFixed(0)}',
              color: const Color(0xFFEA580C),
              isBold: true,
            ),
            const SizedBox(height: 6),
            const Divider(height: 14, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 4),
            _buildRowText(
              'নিট পাওনা (আপনি মোট পাবেন):',
              '৳${(currentOrder.farmerPayoutAmount > 0 ? currentOrder.farmerPayoutAmount : currentOrder.totalAmount * 0.95).toStringAsFixed(0)}',
              color: const Color(0xFF166534),
              isBold: true,
            ),
          ] else ...[
            _buildRowText(
              'পণ্যের চুক্তি মূল্য:',
              '৳${(currentOrder.productAmount > 0 ? currentOrder.productAmount : currentOrder.totalAmount).toStringAsFixed(0)}',
              isBold: true,
            ),
            const SizedBox(height: 6),
            _buildRowText(
              'প্ল্যাটফর্ম সার্ভিস চার্জ (+৫%):',
              '+ ৳${(currentOrder.buyerServiceFee > 0 ? currentOrder.buyerServiceFee : currentOrder.totalAmount * 0.05).toStringAsFixed(0)}',
              color: const Color(0xFFEA580C),
              isBold: true,
            ),
            const SizedBox(height: 6),
            const Divider(height: 14, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 4),
            _buildRowText(
              'মোট প্রদেয়:',
              '৳${(currentOrder.buyerTotalAmount > 0 ? currentOrder.buyerTotalAmount : currentOrder.totalAmount * 1.05).toStringAsFixed(0)}',
              color: const Color(0xFF0F172A),
              isBold: true,
            ),
            const SizedBox(height: 6),
            _buildRowText(
              'প্রয়োজনীয় ২০% ডিপোজিট:',
              '৳${currentOrder.depositRequired.toStringAsFixed(0)}',
              color: const Color(0xFFEA580C),
              isBold: true,
            ),
            const SizedBox(height: 6),
            _buildRowText(
              'অবশিষ্ট প্রদেয় (ডেলিভারির সময়):',
              '৳${((currentOrder.buyerTotalAmount > 0 ? currentOrder.buyerTotalAmount : currentOrder.totalAmount * 1.05) - currentOrder.depositRequired).toStringAsFixed(0)}',
              isBold: true,
            ),
          ],
          const SizedBox(height: 14),

          // Post-delivery payout status notice for farmer
          if (isFarmer &&
              (currentOrder.orderStatus == OrderStatus.delivered ||
                  currentOrder.orderStatus == OrderStatus.completed)) ...[
            if (currentOrder.farmerPayoutStatus == 'completed') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.check_circle, size: 16, color: Color(0xFF166534)),
                        SizedBox(width: 8),
                        Text(
                          'টাকা পরিশোধিত / পেআউট সম্পন্ন ✅',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'আপনার নিট পাওনা ৳${(currentOrder.farmerPayoutAmount > 0 ? currentOrder.farmerPayoutAmount : currentOrder.totalAmount * 0.95).toStringAsFixed(0)} টাকা সফলভাবে আপনার অ্যাকাউন্টে পরিশোধ করা হয়েছে।',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF14532D)),
                    ),
                    if (currentOrder.farmerPayoutNotes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'পেমেন্ট তথ্য: ${currentOrder.farmerPayoutNotes}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF15803D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.hourglass_top, size: 16, color: Color(0xFFD97706)),
                        SizedBox(width: 8),
                        Text(
                          'পেআউট পেন্ডিং ⏳ (টাকা প্রক্রিয়াধীন)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'পণ্য ক্রেতার নিকট সফলভাবে ডেলিভারি হয়েছে। ডেলিভারি ম্যানের নিকট থেকে অবশিষ্ট নগদ টাকা প্রধান কার্যালয়ে পৌঁছানোর সাথে সাথে কৃষিবাজার এডমিন সরাসরি আপনার অ্যাকাউন্টে নিট ৳${(currentOrder.farmerPayoutAmount > 0 ? currentOrder.farmerPayoutAmount : currentOrder.totalAmount * 0.95).toStringAsFixed(0)} টাকা পাঠিয়ে দেবে।',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF78350F),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
          ],

          // Pay Deposit Button for Buyer when unpaid
          if (!isPaid &&
              !isPaymentPending &&
              !isFarmer &&
              !isRefundPending &&
              !isRefunded) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.payDeposit,
                icon: const Icon(Icons.payment, color: Colors.white),
                label: Text(
                  'এখনই ডিপোজিট পে করুন (৳${currentOrder.depositRequired.toStringAsFixed(0)})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // 1. Pending Verification Notice Card (Shown to both buyer & farmer)
          if (isPaymentPending) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.hourglass_top,
                        size: 16,
                        color: Color(0xFFD97706),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'এডমিন পেমেন্ট ভেরিফিকেশন চলছে ⏳',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isFarmer
                        ? 'দোকানদার/ক্রেতা ২০% অগ্রিম ডিপোজিট জমা দিয়েছেন। কৃষিবাজার এডমিন টাকা প্রাপ্তি যাচাই করছেন। টাকা প্রাপ্তি নিশ্চিত হলে এডমিন পণ্য যাচাইকারী এজেন্ট নিয়োগ করবেন।'
                        : 'আপনার প্রেরিত ২০% ডিপোজিট কৃষিবাজার এডমিন শাখা যাচাই করছে। টাকা নিশ্চিত হলে এডমিন দ্রুতই গুণমান পরীক্ষক নিয়োগ করবেন।',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF78350F),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // 2. Confirmed & Inspector Info Card
          if (isPaid && currentOrder.inspectorName.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.assignment_ind,
                        size: 16,
                        color: Color(0xFF166534),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'পণ্য পরীক্ষা এজেন্ট নিযুক্ত ✅',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'নিযুক্ত এজেন্ট: ${currentOrder.inspectorName} • পদবী: ${currentOrder.inspectorDesignation.isNotEmpty ? currentOrder.inspectorDesignation : "গুণমান পরিদর্শক"}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF14532D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'টাকা প্রাপ্তি নিশ্চিত হবার পর এজেন্ট কালেকশন হাবে কৃষকের সরবরাহকৃত পণ্যের সতেজতা ও ওজন পরীক্ষা করছেন।',
                    style: TextStyle(fontSize: 11, color: Color(0xFF166534)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Escrow Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF5EC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const [
                Text('🔒 ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Text(
                    'ডিপোজিট মানি নিরাপদ কৃষিবাজার এসক্রো অ্যাকাউন্টে সংরক্ষিত থাকে। পণ্য গুণমান পরীক্ষায় উত্তীর্ণ ও খালাস হলে চূড়ান্ত সেটেলমেন্ট সম্পন্ন হয়।',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF166534),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper 4: Quality Rejection & Refund Card ("পণ্য মান বাতিল ও রিফান্ড ❌") ---
  Widget _buildQualityRejectionBox(
    MarketplaceOrder currentOrder,
    BuildContext context,
    bool isFarmer,
  ) {
    final isRefunded =
        currentOrder.refundStatus == 'completed' ||
        currentOrder.orderStatus == OrderStatus.refunded;
    final refundAmt = currentOrder.refundAmount > 0
        ? currentOrder.refundAmount
        : currentOrder.depositRequired;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECDD3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'পণ্য গুণগত মান পরীক্ষায় উত্তীর্ণ হয়নি ❌',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF991B1B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Rejection Reason
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'বাতিলের কারণ:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB91C1C),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  currentOrder.rejectionReason.isNotEmpty
                      ? currentOrder.rejectionReason
                      : 'কালেকশন হাবে পণ্যের গুণগত মান ও সতেজতা প্রত্যাশিত মানদণ্ড পূরণ করতে পারেনি।',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7F1D1D),
                  ),
                ),
                if (currentOrder.inspectorName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'পরীক্ষক: ${currentOrder.inspectorName} (${currentOrder.inspectorDesignation})',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Role Specific Messaging
          if (!isFarmer) ...[
            // BUYER / SHOPKEEPER VIEW
            const Text(
              'আমরা দুঃখিত! কালেকশন হাবে কৃষকের সরবরাহকৃত পণ্যের মান যাচাই করে আমাদের গুণগত মান পাওয়া যায়নি। আপনার সুরক্ষা নিশ্চিত করতে অর্ডারটি বাতিল করা হয়েছে।',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7F1D1D),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Refund Box for Buyer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isRefunded
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isRefunded
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFFFDE68A),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isRefunded
                            ? Icons.check_circle
                            : Icons.replay_circle_filled_rounded,
                        size: 18,
                        color: isRefunded
                            ? const Color(0xFF166534)
                            : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isRefunded
                            ? 'ডিপোজিট রিফান্ড সফল ✅'
                            : '২০% ডিপোজিট রিফান্ড প্রক্রিয়াধীন ⏳',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isRefunded
                              ? const Color(0xFF166534)
                              : const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isRefunded
                        ? 'আপনার ২০% সিকিউরিটি ডিপোজিট ৳${refundAmt.toStringAsFixed(0)} সফলভাবে আপনার অ্যাকাউন্টে ফেরত দেওয়া হয়েছে।${currentOrder.refundNotes.isNotEmpty ? "\nমন্তব্য: ${currentOrder.refundNotes}" : ""}'
                        : 'আপনার ২০% অগ্রিম ডিপোজিট (৳${refundAmt.toStringAsFixed(0)}) ফেরত দেওয়া হচ্ছে। কৃষিবাজার এডমিন টিম দ্রুতই আপনার কাছে টাকা পৌঁছে দেবেন।',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isRefunded
                          ? const Color(0xFF14532D)
                          : const Color(0xFF78350F),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Button to look for alternative produce
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'সতেজ ও মানসম্মত অন্যান্য পণ্য খুঁজতে মার্কেটপ্লেস ব্রাউজ করুন',
                      ),
                      backgroundColor: Color(0xFF166534),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text(
                  'মার্কেটপ্লেসে অন্য বিকল্প পণ্য দেখুন 🛒',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ] else ...[
            // FARMER VIEW
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '⚠️ কৃষক ভাইদের জন্য দিকনির্দেশনা:',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'আপনার সরবরাহকৃত পণ্যটি কালেকশন হাবে নির্ধারিত মান পরীক্ষায় উত্তীর্ণ হতে পারেনি। ভোক্তাদের সর্বোচ্চ খাদ্য নিরাপত্তা বজায় রাখতে অর্ডারটি বাতিল করা হয়েছে। পরবর্তী চালানে সতেজ, দাগমুক্ত ও উৎকৃষ্ট গ্রেডের ফসল সরবরাহের অনুরোধ করা যাচ্ছে।',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF78350F),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Helper 5: Transport & Tracking Box ("পরিবহন ও ট্র্যাকিং 🚚") ---
  Widget _buildTransportBox(
    MarketplaceOrder currentOrder,
    OrderDetailController controller,
    bool isFarmer,
  ) {
    final status = currentOrder.deliveryInfo.transportStatus;
    final isDelivered =
        status == TransportStatus.delivered ||
        currentOrder.orderStatus == OrderStatus.delivered ||
        currentOrder.orderStatus == OrderStatus.completed;
    final isInTransit =
        status == TransportStatus.inTransit ||
        currentOrder.orderStatus == OrderStatus.inTransit;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'পরিবহন ও ট্র্যাকিং 🚚',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDelivered
                      ? const Color(0xFFDCFCE7)
                      : (isInTransit
                            ? const Color(0xFFE0F2FE)
                            : const Color(0xFFFEF3C7)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDelivered
                          ? Icons.check_circle
                          : (isInTransit
                                ? Icons.local_shipping
                                : Icons.schedule),
                      size: 13,
                      color: isDelivered
                          ? const Color(0xFF166534)
                          : (isInTransit
                                ? const Color(0xFF0284C7)
                                : const Color(0xFFB45309)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isDelivered
                          ? 'ডেলিভারি সম্পন্ন 🎉'
                          : (isInTransit
                                ? 'ইন ট্রানজিট (পথে আছে)'
                                : 'পিকআপের অপেক্ষায় ⏳'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDelivered
                            ? const Color(0xFF166534)
                            : (isInTransit
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFFB45309)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (currentOrder.transportAgency.isNotEmpty) ...[
            _buildRowText('পরিবহন সংস্থা:', currentOrder.transportAgency),
            const SizedBox(height: 6),
          ],
          _buildRowText(
            'ড্রাইভারের নাম:',
            currentOrder.deliveryInfo.driverName.isNotEmpty
                ? '${currentOrder.deliveryInfo.driverName}${currentOrder.deliveryInfo.driverPhone.isNotEmpty ? " (${currentOrder.deliveryInfo.driverPhone})" : ""}'
                : 'নিযুক্ত করা হয়নি (অপেক্ষমাণ)',
          ),
          const SizedBox(height: 6),
          _buildRowText(
            'গাড়ির নম্বর:',
            currentOrder.deliveryInfo.vehicleNumber.isNotEmpty
                ? currentOrder.deliveryInfo.vehicleNumber
                : 'নির্ধারিত হয়নি',
          ),
          const SizedBox(height: 6),
          _buildRowText(
            'সংগ্রহ পয়েন্ট:',
            currentOrder.deliveryInfo.pickupLocation.isNotEmpty
                ? currentOrder.deliveryInfo.pickupLocation
                : (currentOrder.farmerLocation.isNotEmpty ? currentOrder.farmerLocation : 'কৃষকের ঠিকানা'),
          ),
          const SizedBox(height: 6),
          _buildRowText('গন্তব্য:', currentOrder.deliveryLocation),
          const SizedBox(height: 6),
          _buildRowText(
            'আনুমানিক সময়:',
            isDelivered
                ? 'ডেলিভারি সফল হয়েছে'
                : (currentOrder.expectedDeliveryDate.isNotEmpty
                    ? currentOrder.expectedDeliveryDate
                    : (currentOrder.deliveryInfo.estimatedArrival.isNotEmpty
                        ? currentOrder.deliveryInfo.estimatedArrival
                        : 'প্রক্রিয়াধীন')),
            color: isDelivered
                ? const Color(0xFF166534)
                : const Color(0xFF0284C7),
            isBold: isDelivered,
          ),
          const SizedBox(height: 14),

          // Informational note that transport is centrally managed from admin
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, size: 15, color: Color(0xFF64748B)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'পরিবহন ও ট্র্যাকিং কৃষিবাজার কেন্দ্রীয় হাব ও এডমিন ড্যাশবোর্ড থেকে নিয়ন্ত্রিত হয়।',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper 6: Weight & Quality Verification Box ---
  Widget _buildVerificationBox(MarketplaceOrder currentOrder) {
    final v = currentOrder.verification;
    final isVerified =
        currentOrder.isQualityPassed == true ||
        v.isVerified ||
        currentOrder.orderStatus == OrderStatus.collectionVerified ||
        currentOrder.orderStatus == OrderStatus.inTransit ||
        currentOrder.orderStatus == OrderStatus.delivered ||
        currentOrder.orderStatus == OrderStatus.completed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? const Color(0xFFC7E0CB) : const Color(0xFFFED7AA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'ওজন ও গুণমান যাচাই ⚖️',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isVerified
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified ? Icons.check_circle : Icons.hourglass_top,
                      size: 13,
                      color: isVerified
                          ? const Color(0xFF166534)
                          : const Color(0xFFB45309),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isVerified ? 'যাচাই সম্পন্ন ✅' : 'যাচাই প্রক্রিয়াধীন 🔄',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isVerified
                            ? const Color(0xFF166534)
                            : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (!isVerified) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Text('🔬 ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      currentOrder.inspectorName.isNotEmpty
                          ? 'কালেকশন হাবে নিযুক্ত এজেন্ট ${currentOrder.inspectorName} (${currentOrder.inspectorDesignation}) পণ্যের মান ও ওজন পরীক্ষা করছেন। এডমিন রিপোর্ট দিলে পরিবহনে উঠবে।'
                          : 'কালেকশন হাবে পণ্যের গুণগত মান ও ওজন পরীক্ষা প্রক্রিয়াধীন। এডমিন টেস্ট রেজাল্ট অনুমোদন করলে পণ্য ট্রাকে উঠবে।',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          _buildRowText(
            'চুক্তিকৃত পরিমাণ:',
            '${currentOrder.quantity.toStringAsFixed(0)} ${currentOrder.unit.labelBn}',
          ),
          const SizedBox(height: 6),
          _buildRowText(
            'প্রকৃত মাপা ওজন:',
            isVerified
                ? '${v.actualWeight.toStringAsFixed(0)} ${currentOrder.unit.labelBn}'
                : 'যাচাই প্রক্রিয়াধীন...',
            color: isVerified
                ? const Color(0xFF166534)
                : const Color(0xFFB45309),
            isBold: true,
          ),
          const SizedBox(height: 6),
          _buildRowText(
            'যাচাইকৃত গ্রেড:',
            isVerified ? v.qualityGrade.labelBn : 'পরীক্ষা চলমান...',
            isBold: true,
          ),
          const SizedBox(height: 6),
          _buildRowText(
            'যাচাইকারী এজেন্ট:',
            currentOrder.inspectorName.isNotEmpty
                ? '${currentOrder.inspectorName} (${currentOrder.inspectorDesignation})'
                : (isVerified && v.verifiedBy.isNotEmpty ? v.verifiedBy : 'কৃষিবাজার কালেকশন হাব টিম'),
          ),
          if (isVerified) ...[
            const SizedBox(height: 6),
            _buildRowText(
              'মন্তব্য:',
              v.notes.isNotEmpty ? '"${v.notes}"' : 'কোনো বিশেষ মন্তব্য নেই',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRowText(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? const Color(0xFF0F172A),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
