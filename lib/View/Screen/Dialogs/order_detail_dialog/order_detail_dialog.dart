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

    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F4),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: controller.close,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'অর্ডার #${currentOrder.orderNumber}',
                style: const TextStyle(
                  color: Color(0xFF166534),
                  fontSize: 18,
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
              const SizedBox(height: 14),

              // 4. Transport & Tracking Box ("পরিবহন ও ট্রাক ট্র্যাকিং 🚚")
              _buildTransportBox(currentOrder, controller, isFarmer),
              const SizedBox(height: 14),

              // 5. Weight & Quality Verification Box ("ওজন ও গুণমান যাচাই ⚖️")
              _buildVerificationBox(currentOrder),
              const SizedBox(height: 20),

              // 6. Bottom Action Buttons (Dispute & Rating)
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper 1: Order Current Status Box ---
  Widget _buildStatusBox(MarketplaceOrder currentOrder) {
    final isPaid = currentOrder.isDepositPaid;
    final isCompleted = currentOrder.orderStatus == OrderStatus.completed;

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
                  color: isCompleted
                      ? const Color(0xFFDCFCE7)
                      : (isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : (isPaid ? Icons.check_circle : Icons.schedule),
                      color: isCompleted ? const Color(0xFF166534) : (isPaid ? const Color(0xFF166534) : const Color(0xFFEA580C)),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCompleted
                          ? 'সম্পন্ন 🎉'
                          : (isPaid ? 'ডিপোজিট পেইড ✅' : 'ডিপোজিট বাকি'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? const Color(0xFF166534) : (isPaid ? const Color(0xFF166534) : const Color(0xFFEA580C)),
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
        ],
      ),
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

  // --- Helper 4: Transport & Tracking Box ("পরিবহন ও ট্রাক ট্র্যাকিং 🚚") ---
  Widget _buildTransportBox(
      MarketplaceOrder currentOrder, OrderDetailController controller, bool isFarmer) {
    final status = currentOrder.deliveryInfo.transportStatus;

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
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status == TransportStatus.delivered
                      ? 'গন্তব্যে পৌঁছেছে'
                      : (status == TransportStatus.inTransit ? 'ইন ট্রানজিট' : 'পিকআপের অপেক্ষায়'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildRowText('ড্রাইভারের নাম:', 'মোঃ কাশেম ড্রাইভার (০১৭১১-২২৩৭৪৪)'),
          const SizedBox(height: 6),
          _buildRowText('গাড়ির নম্বর:', 'ঢাকা মেট্রো-ট ১১-৪৫২৩'),
          const SizedBox(height: 6),
          _buildRowText('সংগ্রহ পয়েন্ট:', currentOrder.deliveryInfo.pickupLocation),
          const SizedBox(height: 6),
          _buildRowText('গন্তব্য:', currentOrder.deliveryLocation),
          const SizedBox(height: 6),
          _buildRowText('আনুমানিক সময়:', status == TransportStatus.delivered ? 'পৌঁছেছে' : 'আজ বিকাল ৫:০০'),
          const SizedBox(height: 14),

          // Controls to change transport status
          const Text(
            'পরিবহন স্ট্যাটাস পরিবর্তন করুন (টেস্টিং):',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTransportChip(
                label: 'পিকআপ',
                isSelected: status == TransportStatus.atCollectionCenter,
                onTap: () => controller.setTransportStatus(TransportStatus.atCollectionCenter),
              ),
              const SizedBox(width: 8),
              _buildTransportChip(
                label: 'ট্রানজিট',
                isSelected: status == TransportStatus.inTransit,
                onTap: () => controller.setTransportStatus(TransportStatus.inTransit),
              ),
              const SizedBox(width: 8),
              _buildTransportChip(
                label: 'ডেলিভার্ড',
                isSelected: status == TransportStatus.delivered,
                onTap: () => controller.setTransportStatus(TransportStatus.delivered),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helper 5: Weight & Quality Verification Box ---
  Widget _buildVerificationBox(MarketplaceOrder currentOrder) {
    final v = currentOrder.verification;

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
                  'ওজন ও গুণমান যাচাই ⚖️',
                  style: TextStyle(
                    fontSize: 14,
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
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'যাচাই সম্পন্ন ✅',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildRowText('চুক্তিকৃত পরিমাণ:', '${currentOrder.quantity.toStringAsFixed(0)} ${currentOrder.unit.labelBn}'),
          const SizedBox(height: 6),
          _buildRowText('প্রকৃত মাপা ওজন:', '${(currentOrder.quantity - 5).toStringAsFixed(0)} ${currentOrder.unit.labelBn}', color: const Color(0xFF166534), isBold: true),
          const SizedBox(height: 6),
          _buildRowText('যাচাইকৃত গ্রেড:', v.qualityGrade.labelBn, isBold: true),
          const SizedBox(height: 6),
          _buildRowText('যাচাইকারী এজেন্ট:', 'সেলিম রেজা (ইনস্পেক্টর) (০১ সেপ্টেম্বর সকাল ৯টা)'),
          const SizedBox(height: 6),
          _buildRowText('মন্তব্য:', '"পণ্য ফ্রেশ ও পাকা ছিল"'),
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

  Widget _buildTransportChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF166534) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF166534)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF166534),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

