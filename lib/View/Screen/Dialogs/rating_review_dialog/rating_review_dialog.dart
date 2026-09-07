import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import 'rating_review_controller.dart';

class RatingReviewDialog extends StatelessWidget {
  final MarketplaceOrder order;

  const RatingReviewDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<KrishiRepository>();
    final controller = RatingReviewController(repo, order);

    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<RatingReviewController>(
        builder: (context, ctrl, child) {
          return Dialog(
            backgroundColor: const Color(0xFFEBE8F3), // Soft light purple/lavender
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title
                    const Center(
                      child: Text(
                        'রেটিং ও মতামত প্রদান',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF166534),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 1. Overall Rating
                    _buildRatingCategory(
                      title: 'সার্বিক রেটিং:',
                      value: ctrl.overallRating,
                      onRatingChanged: ctrl.setOverallRating,
                    ),
                    const SizedBox(height: 12),

                    // 2. Product Quality Rating
                    _buildRatingCategory(
                      title: 'পণ্যের গুণমান:',
                      value: ctrl.qualityRating,
                      onRatingChanged: ctrl.setQualityRating,
                    ),
                    const SizedBox(height: 12),

                    // 3. Quantity & Weight Rating
                    _buildRatingCategory(
                      title: 'ওজন ও পরিমাণের সঠিকতা:',
                      value: ctrl.quantityRating,
                      onRatingChanged: ctrl.setQuantityRating,
                    ),
                    const SizedBox(height: 12),

                    // 4. Communication Rating
                    _buildRatingCategory(
                      title: 'যোগাযোগ ও ব্যবহার:',
                      value: ctrl.communicationRating,
                      onRatingChanged: ctrl.setCommunicationRating,
                    ),
                    const SizedBox(height: 12),

                    // 5. Payment & Commitment Rating
                    _buildRatingCategory(
                      title: 'পেমেন্ট ও প্রতিশ্রুতি রক্ষা:',
                      value: ctrl.paymentRating,
                      onRatingChanged: ctrl.setPaymentRating,
                    ),
                    const SizedBox(height: 18),

                    // Comment TextField
                    TextField(
                      controller: ctrl.commentController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'আপনার মন্তব্য লিখুন',
                        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFFE5E2F0),
                        contentPadding: const EdgeInsets.all(14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFC7C3D8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Action Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: ctrl.close,
                          child: const Text(
                            'পরে',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        ElevatedButton(
                          onPressed: ctrl.submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF166534),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'রিভিউ জমা দিন',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
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
        },
      ),
    );
  }

  Widget _buildRatingCategory({
    required String title,
    required int value,
    required ValueChanged<int> onRatingChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return GestureDetector(
              onTap: () => onRatingChanged(starIndex),
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  starIndex <= value ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: const Color(0xFFF59E0B),
                  size: 24,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
