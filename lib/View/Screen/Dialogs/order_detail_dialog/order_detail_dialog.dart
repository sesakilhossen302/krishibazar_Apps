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
              icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF166534)),
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
              _buildStatusBox(currentOrder),
              const SizedBox(height: 14),

              // 2. Order Parties Box ("অর্ডারের পক্ষসমূহ")
              _buildPartiesBox(currentOrder),
              const SizedBox(height: 14),

              // 3. Payment & Escrow Box ("পেমেন্ট ও ডিপোজিট এসক্রো 💰")
              _buildPaymentEscrowBox(currentOrder, controller, isFarmer),

              // 4. Weight & Quality Verification Box ("ওজন ও গুণমান যাচাই ⚖️")
              // দেখা যাবে শুধুমাত্র যখন ক্রেতা ২০% ডিপোজিট প্রদান করেছে
              if (currentOrder.isDepositPaid) ...[
                const SizedBox(height: 14),
                _buildVerificationBox(currentOrder),
              ],

              // 5. Transport & Tracking Box ("পরিবহন ও ট্র্যাকিং 🚚")
              // দেখা যাবে শুধুমাত্র কালেকশন হাবে এডমিন কর্তৃক মান যাচাই সম্পন্ন হবার পর
              if (currentOrder.isDepositPaid && currentOrder.verification.isVerified) ...[
                const SizedBox(height: 14),
                _buildTransportBox(currentOrder, controller, isFarmer),
              ],

              // 6. Bottom Action Buttons (Dispute & Rating)
              // দেখা যাবে শুধুমাত্র পণ্য সফলভাবে ডেলিভারি বা সম্পন্ন হবার পর
              if (currentOrder.orderStatus == OrderStatus.delivered ||
                  currentOrder.orderStatus == OrderStatus.completed) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.openDispute,
                        icon: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
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
                        icon: const Icon(Icons.star, color: Colors.white, size: 18),
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
  Widget _buildStatusBox(MarketplaceOrder currentOrder) {
    final isPaid = currentOrder.isDepositPaid;
    final isCompleted = currentOrder.orderStatus == OrderStatus.completed;

    String statusBadgeText = 'ডিপোজিট বাকি ⏳';
    Color statusBadgeBg = const Color(0xFFFFEDD5);
    Color statusBadgeTextCol = const Color(0xFFEA580C);
    IconData statusBadgeIcon = Icons.schedule;

    if (isCompleted) {
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
    } else if (currentOrder.orderStatus == OrderStatus.collectionVerified || currentOrder.verification.isVerified) {
      statusBadgeText = 'হাব যাচাই সম্পন্ন ⚖️';
      statusBadgeBg = const Color(0xFFE0E7FF);
      statusBadgeTextCol = const Color(0xFF4338CA);
      statusBadgeIcon = Icons.verified;
    } else if (isPaid) {
      statusBadgeText = 'ডিপোজিট পেইড ✅';
      statusBadgeBg = const Color(0xFFDCFCE7);
      statusBadgeTextCol = const Color(0xFF166534);
      statusBadgeIcon = Icons.check_circle;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xFFEBF5EC) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPaid ? const Color(0xFFC7E0CB) : const Color(0xFFFFEDD5)),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBadgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusBadgeIcon,
                      color: statusBadgeTextCol,
                      size: 14,
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
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF475569),
            ),
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
                    Icon(Icons.route_outlined, size: 16, color: Color(0xFF166534)),
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
                  subtitle: 'অর্ডার নং #${currentOrder.orderNumber} সফলভাবে নিশ্চিত হয়েছে',
                  isCompleted: true,
                  isActive: false,
                  icon: Icons.assignment_turned_in_rounded,
                ),
                _buildTrackingStep(
                  title: '২০% সিকিউরিটি ডিপোজিট',
                  subtitle: currentOrder.isDepositPaid
                      ? '৳${currentOrder.depositRequired.toStringAsFixed(0)} ডিপোজিট এসক্রোতে সুরক্ষিত রয়েছে'
                      : 'ডিপোজিট বাকি (৳${currentOrder.depositRequired.toStringAsFixed(0)})',
                  isCompleted: currentOrder.isDepositPaid,
                  isActive: !currentOrder.isDepositPaid,
                  icon: Icons.account_balance_wallet_rounded,
                ),
                _buildTrackingStep(
                  title: 'কালেকশন হাব ও গুণমান যাচাই',
                  subtitle: currentOrder.verification.isVerified
                      ? 'ওজন ও ডিজিটাল মান যাচাই সম্পন্ন'
                      : '${currentOrder.deliveryInfo.collectionCenter} এ পণ্য গ্রহণের অপেক্ষায়',
                  isCompleted: currentOrder.verification.isVerified ||
                      currentOrder.orderStatus == OrderStatus.collectionVerified ||
                      currentOrder.orderStatus == OrderStatus.inTransit ||
                      currentOrder.orderStatus == OrderStatus.delivered ||
                      currentOrder.orderStatus == OrderStatus.completed,
                  isActive: currentOrder.isDepositPaid && !currentOrder.verification.isVerified,
                  icon: Icons.verified_outlined,
                ),
                _buildTrackingStep(
                  title: 'ট্রাকে লোড ও পরিবহন',
                  subtitle: currentOrder.deliveryInfo.transportStatus == TransportStatus.inTransit
                      ? 'ঢাকা মেট্রো-ট ১১-৪৫২৩ গাড়িতে পথে রয়েছে'
                      : (currentOrder.deliveryInfo.transportStatus == TransportStatus.delivered
                          ? 'গন্তব্যে পৌঁছেছে'
                          : 'পরিবহনের জন্য রেডি হচ্ছে'),
                  isCompleted: currentOrder.deliveryInfo.transportStatus == TransportStatus.delivered ||
                      currentOrder.orderStatus == OrderStatus.delivered ||
                      currentOrder.orderStatus == OrderStatus.completed,
                  isActive: currentOrder.deliveryInfo.transportStatus == TransportStatus.inTransit ||
                      currentOrder.orderStatus == OrderStatus.inTransit,
                  icon: Icons.local_shipping_rounded,
                ),
                _buildTrackingStep(
                  title: 'ডেলিভারি ও খালাস সম্পন্ন',
                  subtitle: currentOrder.orderStatus == OrderStatus.completed
                      ? 'সম্পূর্ণ পণ্য গ্রহণ ও পেমেন্ট সেটেলমেন্ট সম্পন্ন'
                      : 'ডেলিভারি ঠিকানা: ${currentOrder.deliveryLocation}',
                  isCompleted: currentOrder.orderStatus == OrderStatus.completed,
                  isActive: currentOrder.orderStatus == OrderStatus.delivered,
                  isLast: true,
                  icon: Icons.check_circle_rounded,
                ),
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
    bool isLast = false,
  }) {
    final color = isCompleted
        ? const Color(0xFF166534)
        : (isActive ? const Color(0xFFEA580C) : const Color(0xFF94A3B8));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFFDCFCE7)
                    : (isActive ? const Color(0xFFFFF7ED) : const Color(0xFFF1F5F9)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF166534)
                      : (isActive ? const Color(0xFFEA580C) : const Color(0xFFCBD5E1)),
                  width: isActive ? 2 : 1.5,
                ),
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 26,
                color: isCompleted ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
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
                    fontWeight: isCompleted || isActive ? FontWeight.bold : FontWeight.w500,
                    color: isCompleted
                        ? const Color(0xFF0F172A)
                        : (isActive ? const Color(0xFFEA580C) : const Color(0xFF64748B)),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isActive ? const Color(0xFFC2410C) : const Color(0xFF64748B),
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
                child: const Center(child: Text('👨‍🌾', style: TextStyle(fontSize: 22))),
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
                        const Icon(Icons.location_on, color: Colors.redAccent, size: 12),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            'কৃষক • ${currentOrder.farmerLocation}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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
                child: const Center(child: Text('🏢', style: TextStyle(fontSize: 22))),
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
                        const Icon(Icons.location_on, color: Colors.redAccent, size: 12),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            'ক্রেতা (${currentOrder.buyerName}) • ${currentOrder.deliveryLocation}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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
      MarketplaceOrder currentOrder, OrderDetailController controller, bool isFarmer) {
    final isPaid = currentOrder.isDepositPaid;

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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isPaid ? 'ডিপোজিট পেইড ✅' : 'ডিপোজিট আবশ্যক ⏳',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPaid ? const Color(0xFF166534) : const Color(0xFFEA580C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildRowText('মোট চুক্তি মূল্য:', '৳${currentOrder.totalAmount.toStringAsFixed(0)}', isBold: true),
          const SizedBox(height: 6),
          _buildRowText('প্রয়োজনীয় ২০% ডিপোজিট:', '৳${currentOrder.depositRequired.toStringAsFixed(0)}', color: const Color(0xFFEA580C), isBold: true),
          const SizedBox(height: 6),
          _buildRowText('বাকি ৮০% (ডেলিভারির পর):', '৳${(currentOrder.totalAmount - currentOrder.depositRequired).toStringAsFixed(0)}', isBold: true),
          const SizedBox(height: 14),

          // Pay Deposit Button for Buyer when unpaid
          if (!isPaid && !isFarmer) ...[
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
                    'ডিপোজিট মানি নিরাপদ এসক্রো অ্যাকাউন্টে সংরক্ষিত আছে। পণ্য প্রাপ্তি নিশ্চিত হলে কৃষক পাবেন।',
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

  // --- Helper 4: Transport & Tracking Box ("পরিবহন ও ট্র্যাকিং 🚚") ---
  Widget _buildTransportBox(
      MarketplaceOrder currentOrder, OrderDetailController controller, bool isFarmer) {
    final status = currentOrder.deliveryInfo.transportStatus;
    final isDelivered = status == TransportStatus.delivered ||
        currentOrder.orderStatus == OrderStatus.delivered ||
        currentOrder.orderStatus == OrderStatus.completed;
    final isInTransit = status == TransportStatus.inTransit ||
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDelivered
                      ? const Color(0xFFDCFCE7)
                      : (isInTransit ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDelivered
                          ? Icons.check_circle
                          : (isInTransit ? Icons.local_shipping : Icons.schedule),
                      size: 13,
                      color: isDelivered
                          ? const Color(0xFF166534)
                          : (isInTransit ? const Color(0xFF0284C7) : const Color(0xFFB45309)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isDelivered
                          ? 'ডেলিভারি সম্পন্ন 🎉'
                          : (isInTransit ? 'ইন ট্রানজিট (পথে আছে)' : 'পিকআপের অপেক্ষায় ⏳'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDelivered
                            ? const Color(0xFF166534)
                            : (isInTransit ? const Color(0xFF0284C7) : const Color(0xFFB45309)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildRowText(
            'ড্রাইভারের নাম:',
            '${currentOrder.deliveryInfo.driverName} (${currentOrder.deliveryInfo.driverPhone})',
          ),
          const SizedBox(height: 6),
          _buildRowText('গাড়ির নম্বর:', currentOrder.deliveryInfo.vehicleNumber),
          const SizedBox(height: 6),
          _buildRowText('সংগ্রহ পয়েন্ট:', currentOrder.deliveryInfo.pickupLocation),
          const SizedBox(height: 6),
          _buildRowText('গন্তব্য:', currentOrder.deliveryLocation),
          const SizedBox(height: 6),
          _buildRowText(
            'আনুমানিক সময়:',
            isDelivered ? 'ডেলিভারি সফল হয়েছে' : 'আজ বিকাল ৫:০০ (চলমান)',
            color: isDelivered ? const Color(0xFF166534) : const Color(0xFF0284C7),
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
                    'পরিবহন ট্র্যাকিং কৃষিবাজার কেন্দ্রীয় হাব ও এডমিন ড্যাশবোর্ড থেকে পরিচালিত হয়।',
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

  // --- Helper 5: Weight & Quality Verification Box ---
  Widget _buildVerificationBox(MarketplaceOrder currentOrder) {
    final v = currentOrder.verification;
    final isVerified = v.isVerified ||
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isVerified ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified ? Icons.check_circle : Icons.hourglass_top,
                      size: 13,
                      color: isVerified ? const Color(0xFF166534) : const Color(0xFFB45309),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isVerified ? 'যাচাই সম্পন্ন ✅' : 'যাচাই প্রক্রিয়াধীন 🔄',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isVerified ? const Color(0xFF166534) : const Color(0xFFB45309),
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
                children: const [
                  Text('🔬 ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      'কালেকশন হাবে পণ্যের গুণগত মান ও ওজন পরীক্ষা করা হচ্ছে। এডমিন ড্যাশবোর্ড থেকে টেস্ট কনফার্ম হলে পণ্য পরিবহনে উঠবে।',
                      style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          _buildRowText('চুক্তিকৃত পরিমাণ:', '${currentOrder.quantity.toStringAsFixed(0)} ${currentOrder.unit.labelBn}'),
          const SizedBox(height: 6),
          _buildRowText(
            'প্রকৃত মাপা ওজন:',
            isVerified ? '${v.actualWeight.toStringAsFixed(0)} ${currentOrder.unit.labelBn}' : 'যাচাই প্রক্রিয়াধীন...',
            color: isVerified ? const Color(0xFF166534) : const Color(0xFFB45309),
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
            isVerified ? v.verifiedBy : 'কৃষিবাজার কালেকশন হাব টিম',
          ),
          if (isVerified) ...[
            const SizedBox(height: 6),
            _buildRowText('মন্তব্য:', '"${v.notes}"'),
          ],
        ],
      ),
    );
  }

  Widget _buildRowText(String label, String value, {Color? color, bool isBold = false}) {
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


