import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../global/Model/krishi_models.dart';
import '../../../global/controller/krishi_controller.dart';
import '../../Widgegt/custom_text_field/custom_text_field.dart';

class OrderChatDialog extends StatefulWidget {
  final MarketplaceOrder order;

  const OrderChatDialog({super.key, required this.order});

  @override
  State<OrderChatDialog> createState() => _OrderChatDialogState();
}

class _OrderChatDialogState extends State<OrderChatDialog> {
  final messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<KrishiController>();
    final messages = controller.chatMessages.where((m) => m.orderId == widget.order.id).toList();

    return AlertDialog(
      title: Text('লাইভ চ্যাট: অর্ডার #${widget.order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      content: SizedBox(
        width: double.maxFinite,
        height: 350,
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? const Center(child: Text('এখনও কোনো বার্তা আদান-প্রদান হয়নি'))
                  : ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderRole == controller.currentRole;
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primaryGreen : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(msg.senderName, style: TextStyle(fontSize: 10, color: isMe ? AppColors.lightGold : AppColors.textMuted)),
                                Text(msg.message, style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 13)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Row(
              children: [
                Expanded(child: CustomTextField(controller: messageController, label: '', hint: 'মেসেজ লিখুন...')),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primaryGreen),
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      controller.sendChatMessage(widget.order.id, messageController.text);
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => controller.closeChat(), child: const Text('বন্ধ করুন')),
      ],
    );
  }
}
