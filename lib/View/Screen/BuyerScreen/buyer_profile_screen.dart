import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../global/controller/krishi_controller.dart';
import '../../Widgegt/Cards/status_badge.dart';

class BuyerProfileScreen extends StatelessWidget {
  const BuyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<KrishiController>();
    final buyer = controller.currentBuyer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryGold.withValues(
                      alpha: 0.3,
                    ),
                    child: Text(
                      buyer.name[0],
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    buyer.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    buyer.businessName,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    buyer.businessType,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  StatusBadge(
                    label: buyer.verificationStatus.labelBn,
                    backgroundColor: AppColors.lightGreen,
                    textColor: AppColors.primaryGreen,
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileStat('রেটিং', '⭐ ${buyer.rating}'),
                      _buildProfileStat(
                        'ক্রয় অর্ডার',
                        '${buyer.completedOrders}টি',
                      ),
                      _buildProfileStat(
                        'পেমেন্ট বিশ্বাসযোগ্যতা',
                        '${buyer.paymentReliability}%',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ব্যবসা ও ঠিকানা',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.phone, 'ফোন নাম্বার', buyer.phone),
                  _buildInfoRow(
                    Icons.store,
                    'আড়ত/ব্যবসার স্থান',
                    '${buyer.district}, ${buyer.area}',
                  ),
                  _buildInfoRow(
                    Icons.location_on,
                    'বিস্তারিত ঠিকানা',
                    buyer.address,
                  ),
                  _buildInfoRow(
                    Icons.receipt_long,
                    'ট্রেড লাইসেন্স/ডকুমেন্ট',
                    buyer.tradeInfo,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
