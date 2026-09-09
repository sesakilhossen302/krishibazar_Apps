import 'package:flutter/material.dart';
import '../../Utils/AppColors/app_colors.dart';
import '../../service/location_service.dart';

class LocationPickerCard extends StatelessWidget {
  final bool isLoading;
  final DetectedLocation? detectedLocation;
  final VoidCallback onDetectLocation;

  const LocationPickerCard({
    super.key,
    required this.isLoading,
    required this.detectedLocation,
    required this.onDetectLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: detectedLocation != null ? const Color(0xFF86EFAC) : const Color(0xFFBBF7D0),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: AppColors.primaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'স্বয়ংক্রিয় লোকেশন সনাক্তকরণ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF14532D),
                      ),
                    ),
                    Text(
                      'Google Maps ও GPS দিয়ে এক ক্লিকে ঠিকানা নিন',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onDetectLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.location_searching_rounded, size: 18),
              label: Text(
                isLoading
                    ? 'স্যাটেলাইট থেকে লোকেশন খোঁজা হচ্ছে...'
                    : (detectedLocation == null
                        ? 'বর্তমান লোকেশন সনাক্ত করুন'
                        : '🔄 পুনরায় লোকেশন সনাক্ত করুন'),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),

          if (detectedLocation != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFDCFCE7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (detectedLocation!.district.isNotEmpty)
                    Text(
                      '📍 জেলা: ${detectedLocation!.district}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  if (detectedLocation!.upazila.isNotEmpty)
                    Text(
                      '🏛️ উপজেলা: ${detectedLocation!.upazila}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                    ),
                  if (detectedLocation!.fullAddress.isNotEmpty)
                    Text(
                      '🏡 সম্পূর্ণ ঠিকানা: ${detectedLocation!.fullAddress}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
