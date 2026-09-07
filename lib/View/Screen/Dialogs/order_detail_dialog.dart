import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/AppConst/app_const.dart';
import '../../../global/Model/krishi_models.dart';
import '../../../global/controller/krishi_controller.dart';
import '../../Widgegt/custom_button/custom_button.dart';

class OrderDetailDialog extends StatelessWidget {
  final MarketplaceOrder order;

  const OrderDetailDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<KrishiController>();

    return AlertDialog(
      title: Row(
        children: [
          Text('অর্ডার #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primaryGreen), onPressed: () => controller.openChat(order)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(order.productTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
            const SizedBox(height: 6),
            Text('কৃষক: ${order.farmerName} (${order.farmerPhone})'),
            Text('ক্রেতা: ${order.buyerName} (${order.buyerPhone})'),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('মোট মূল্য:'),
                Text('${AppConst.currencySymbol}${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('২০% ডিপোজিট:'),
                Text('${AppConst.currencySymbol}${order.depositRequired.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              ],
            ),
            const SizedBox(height: 12),

            // Transport Status Steps
            const Text('ডেলিভারি ও পরিবহন ট্র্যাকিং', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            _buildStepRow('১. কালেকশন সেন্টার প্রাপ্তি', order.deliveryInfo.transportStatus.index >= 1),
            _buildStepRow('২. ইন ট্রানজিট (গন্তব্যের পথে)', order.deliveryInfo.transportStatus.index >= 2),
            _buildStepRow('৩. ডেলিভারি সম্পন্ন', order.deliveryInfo.transportStatus.index >= 3),

            const SizedBox(height: 16),
            if (!order.isDepositPaid && controller.currentRole == UserRole.buyer)
              CustomButton(
                text: '২০% ডিপোজিট প্রদান করুন (৳${order.depositRequired.toStringAsFixed(0)})',
                onTap: () => controller.payDeposit(order.id),
              ),

            if (controller.currentRole == UserRole.farmer)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: CustomButton(
                  text: 'পরিবহন স্ট্যাটাস পরবর্তী ধাপে নিন',
                  backgroundColor: AppColors.primaryGold,
                  textColor: Colors.black,
                  onTap: () {
                    final nextIdx = (order.deliveryInfo.transportStatus.index + 1).clamp(0, 3);
                    controller.advanceTransport(order.id, TransportStatus.values[nextIdx]);
                  },
                ),
              ),

            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => controller.openDisputeDialog(order),
              icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
              label: const Text('কোনো সমস্যা আছে? ডিসপিউট রিপোর্ট করুন', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => controller.closeOrderDetail(), child: const Text('বন্ধ করুন')),
      ],
    );
  }

  Widget _buildStepRow(String title, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, color: isDone ? AppColors.primaryGreen : AppColors.textMuted, size: 18),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: isDone ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
