import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import 'buyer_offer_management_controller.dart';

class BuyerOfferManagementDialog extends StatelessWidget {
  final BuyerDemand demand;

  const BuyerOfferManagementDialog({super.key, required this.demand});

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
    final controller = BuyerOfferManagementController(repo, demand);
    final offers = controller.offers;

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7F5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF334155)),
                      onPressed: controller.close,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'কৃষকদের প্রাপ্ত অফারসমূহ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF165228),
                            ),
                          ),
                          Text(
                            '${demand.productTitle} (${_toBnDigits(demand.requiredQuantity.toInt())} ${demand.unit.labelBn})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Demand Summary Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECF7ED),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFC8E6C9)),
                        ),
                        child: Row(
                          children: [
                            Text(demand.category.icon, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    demand.productTitle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF165228),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'মোট প্রয়োজন: ${_toBnDigits(demand.requiredQuantity.toInt())} ${demand.unit.labelBn} • কাঙ্ক্ষিত দর: ৳${_toBnDigits(demand.minExpectedPrice.toInt())}–${_toBnDigits(demand.maxExpectedPrice.toInt())}/${demand.unit.labelBn}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Section Title
                      Text(
                        'কৃষকদের পাঠানো প্রস্তাব (${_toBnDigits(offers.length)} টি)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Offers List
                      if (offers.isEmpty)
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
                              'এখনো কোনো কৃষক অফার পাঠায়নি',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          ),
                        )
                      else
                        ...offers.map((offer) {
                          final isAccepted = offer.status == OfferStatus.accepted;
                          final totalPrice = (offer.offeredQuantity * offer.pricePerUnit).toInt();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isAccepted
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFFE2E8F0),
                              ),
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
                                // Top Row (Farmer Avatar & Info + Status Badge)
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFDCFCE7),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Text('👨🏻‍🌾', style: TextStyle(fontSize: 20)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            offer.farmerName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on_rounded,
                                                color: Color(0xFFEA580C),
                                                size: 13,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                offer.farmerLocation,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isAccepted
                                            ? const Color(0xFFDCFCE7)
                                            : const Color(0xFFFFF7ED),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        isAccepted ? 'গৃহীত (Accepted ✅)' : 'বিবেচনায় (Pending)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isAccepted
                                              ? const Color(0xFF15803D)
                                              : const Color(0xFFEA580C),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                // 3-Column Stats Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Col 1: Quantity
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'প্রস্তাবিত পরিমাণ',
                                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${_toBnDigits(offer.offeredQuantity.toInt())} ${offer.unit.labelBn}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF165228),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Col 2: Price per unit
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'প্রতি ইউনিটের দর',
                                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '৳${_toBnDigits(offer.pricePerUnit.toInt())}/${offer.unit.labelBn}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFEA580C),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Col 3: Total price
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'মোট প্রস্তাবিত মূল্য',
                                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '৳${_toBnDigits(totalPrice)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Grade & Date Line
                                Text(
                                  'মান: ${offer.qualityGrade.labelBn} • সরবরাহের সম্ভাব্য তারিখ: ${offer.availableDate}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF475569),
                                  ),
                                ),

                                // Note Line
                                if (offer.note.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'নোট: "${offer.note}"',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],

                                // Accept Button (only for pending offers)
                                if (!isAccepted) ...[
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => controller.acceptOffer(offer.id),
                                      icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                      label: const Text(
                                        'অফার গ্রহণ ও অর্ডার কনফার্ম করুন',
                                        style: TextStyle(
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
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
