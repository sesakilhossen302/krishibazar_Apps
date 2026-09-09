import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';

class BuyerDemandsController extends ChangeNotifier {
  final KrishiRepository repository;

  BuyerDemandsController(this.repository);

  List<BuyerDemand> get myDemands {
    final buyer = repository.currentBuyer;
    return repository.demands.where((d) {
      if (d.buyerId.isNotEmpty && d.buyerId == buyer.id) return true;
      if (buyer.phone.isNotEmpty && d.buyerId == buyer.phone) return true;
      if (buyer.businessName.isNotEmpty && d.buyerBusinessName.trim() == buyer.businessName.trim()) return true;
      return false;
    }).toList();
  }

  Future<void> refreshDemands() async {
    await repository.fetchDemandsFromBackend(force: true);
    notifyListeners();
  }

  void openAddDemand() => repository.openAddDemandDialog();
  void openOffers(BuyerDemand demand) => repository.openDemandOfferManagement(demand);

  Future<void> confirmDeleteDemand(BuildContext context, BuyerDemand demand) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('চাহিদা মুছে ফেলবেন?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          '"${demand.productTitle}" চাহিদাপত্রটি আপনি কি তালিকা থেকে মুছে ফেলতে চান?',
          style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('না', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('মুছে ফেলুন', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await repository.deleteDemand(demand.id);
      if (context.mounted) {
        if (success) {
          ToastMessage.show(context, 'চাহিদাপত্রটি সফলভাবে মুছে ফেলা হয়েছে।');
        } else {
          ToastMessage.show(context, 'চাহিদা মুছে ফেলা হয়েছে।');
        }
      }
    }
  }
}
