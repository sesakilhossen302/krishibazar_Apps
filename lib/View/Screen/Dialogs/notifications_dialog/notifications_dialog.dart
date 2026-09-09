import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../reupload_nid_dialog.dart';
import 'notifications_controller.dart';

class NotificationsDialog extends StatelessWidget {
  const NotificationsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<KrishiRepository>();
    final controller = NotificationsController(repo);
    final notifs = controller.notifications;
    final unreadCount = notifs.where((n) => !n.isRead).length;

    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
            onPressed: controller.close,
            tooltip: 'বন্ধ করুন',
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              const Text(
                'বিজ্ঞপ্তি কেন্দ্র',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount টি নতুন',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            if (unreadCount > 0)
              TextButton.icon(
                onPressed: controller.markAllAsRead,
                icon: const Icon(Icons.done_all_rounded, size: 16, color: Color(0xFF16A34A)),
                label: const Text(
                  'সব পড়া হয়েছে',
                  style: TextStyle(
                    color: Color(0xFF16A34A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            IconButton(
              icon: controller.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF16A34A)),
                    )
                  : const Icon(Icons.refresh_rounded, color: Color(0xFF475569), size: 22),
              onPressed: controller.isLoading ? null : controller.refresh,
              tooltip: 'রিফ্রেশ করুন',
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: RefreshIndicator(
          color: const Color(0xFF16A34A),
          onRefresh: controller.refresh,
          child: notifs.isEmpty
              ? _buildEmptyState(context, controller)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: notifs.length,
                  itemBuilder: (context, index) {
                    final notif = notifs[index];
                    return _buildNotificationCard(context, notif, controller, repo);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, NotificationsController controller) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.22),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_off_outlined,
                    size: 48,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'কোনো নতুন বিজ্ঞপ্তি নেই',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'আপনার অ্যাকাউন্ট যাচাই, অর্ডার বা অফারের আপডেট আসলে এখানে দেখতে পাবেন।',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: controller.refresh,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF16A34A),
                    side: const BorderSide(color: Color(0xFF16A34A)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('পুনরায় চেক করুন'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationItem notif,
    NotificationsController controller,
    KrishiRepository repo,
  ) {
    final style = _getNotificationStyle(notif);
    final isNidRejected = notif.notificationType == 'nid' &&
        (notif.title.contains('সতর্কতা') || notif.message.contains('বাতিল') || notif.message.contains('অস্পষ্ট'));

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => controller.delete(notif.id),
      child: GestureDetector(
        onTap: () {
          if (!notif.isRead) {
            controller.markAsRead(notif.id);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: notif.isRead ? Colors.white : style.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: notif.isRead ? const Color(0xFFE2E8F0) : style.borderColor,
              width: notif.isRead ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: notif.isRead ? 0.02 : 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Accent Left Strip
                  Container(
                    width: 5,
                    color: notif.isRead ? const Color(0xFFCBD5E1) : style.accentColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Meta Row: Badge & Timestamp
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: style.badgeBackground,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(style.icon, size: 13, color: style.badgeTextColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      style.badgeText,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: style.badgeTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                notif.timestamp,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              if (!notif.isRead) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: style.accentColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Title
                          Text(
                            notif.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                              color: notif.isRead ? const Color(0xFF334155) : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Message Body
                          Text(
                            notif.message,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: const Color(0xFF475569),
                              height: 1.45,
                              fontWeight: notif.isRead ? FontWeight.normal : FontWeight.w500,
                            ),
                          ),

                          // Action Button for NID re-upload if rejected
                          if (isNidRejected) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEA580C),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.upload_file_rounded, size: 16),
                                label: const Text(
                                  'সংশোধিত NID পুনরায় আপলোড করুন',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  controller.markAsRead(notif.id);
                                  controller.close();
                                  final currentNid = repo.currentRole == UserRole.farmer
                                      ? repo.currentFarmer.nidOrDoc
                                      : repo.currentBuyer.nidOrDoc;
                                  ReuploadNidDialog.show(
                                    context,
                                    currentNid: currentNid,
                                    rejectionReason: notif.message,
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _NotificationStyle _getNotificationStyle(NotificationItem notif) {
    final type = notif.notificationType.toLowerCase();
    final title = notif.title.toLowerCase();

    // 1. Verification: Verified
    if (title.contains('ভেরিফাইড') || title.contains('অনুমোদিত') || title.contains('সফল')) {
      return _NotificationStyle(
        cardBackground: const Color(0xFFF0FDF4),
        borderColor: const Color(0xFFBBF7D0),
        accentColor: const Color(0xFF16A34A),
        badgeBackground: const Color(0xFFDCFCE7),
        badgeTextColor: const Color(0xFF15803D),
        badgeText: 'ভেরিফিকেশন সফল',
        icon: Icons.verified_user_rounded,
      );
    }

    // 2. Verification / Account Rejection or Suspension
    if (title.contains('বাতিল') || title.contains('স্থগিত') || title.contains('rejected') || title.contains('suspended')) {
      return _NotificationStyle(
        cardBackground: const Color(0xFFFEF2F2),
        borderColor: const Color(0xFFFECACA),
        accentColor: const Color(0xFFDC2626),
        badgeBackground: const Color(0xFFFEE2E2),
        badgeTextColor: const Color(0xFFB91C1C),
        badgeText: 'সতর্কতা / বাতিল',
        icon: Icons.error_outline_rounded,
      );
    }

    // 3. In progress / Pending
    if (title.contains('যাচাই চলছে') || title.contains('প্রক্রিয়া') || title.contains('জমা')) {
      return _NotificationStyle(
        cardBackground: const Color(0xFFFFFBEB),
        borderColor: const Color(0xFFFDE68A),
        accentColor: const Color(0xFFD97706),
        badgeBackground: const Color(0xFFFEF3C7),
        badgeTextColor: const Color(0xFFB45309),
        badgeText: 'যাচাই প্রক্রিয়া',
        icon: Icons.hourglass_top_rounded,
      );
    }

    // 4. NID Related
    if (type == 'nid' || title.contains('এনআইডি') || title.contains('nid')) {
      return _NotificationStyle(
        cardBackground: const Color(0xFFFFF7ED),
        borderColor: const Color(0xFFFED7AA),
        accentColor: const Color(0xFFEA580C),
        badgeBackground: const Color(0xFFFFEDD5),
        badgeTextColor: const Color(0xFFC2410C),
        badgeText: 'জাতীয় পরিচয়পত্র',
        icon: Icons.badge_rounded,
      );
    }

    // 5. Order Related
    if (type == 'order' || title.contains('অর্ডার')) {
      return _NotificationStyle(
        cardBackground: const Color(0xFFEFF6FF),
        borderColor: const Color(0xFFBFDBFE),
        accentColor: const Color(0xFF2563EB),
        badgeBackground: const Color(0xFFDBEAFE),
        badgeTextColor: const Color(0xFF1D4ED8),
        badgeText: 'অর্ডার আপডেট',
        icon: Icons.local_shipping_rounded,
      );
    }

    // 6. Demand or Offer
    if (type == 'demand' || type == 'offer' || title.contains('অফার') || title.contains('চাহিদা')) {
      return _NotificationStyle(
        cardBackground: const Color(0xFFFAF5FF),
        borderColor: const Color(0xFFE9D5FF),
        accentColor: const Color(0xFF9333EA),
        badgeBackground: const Color(0xFFF3E8FF),
        badgeTextColor: const Color(0xFF7E22CE),
        badgeText: 'চাহিদা ও অফার',
        icon: Icons.handshake_rounded,
      );
    }

    // Default System / Info
    return _NotificationStyle(
      cardBackground: const Color(0xFFF0FDF4),
      borderColor: const Color(0xFFE2E8F0),
      accentColor: const Color(0xFF0284C7),
      badgeBackground: const Color(0xFFE0F2FE),
      badgeTextColor: const Color(0xFF0369A1),
      badgeText: 'কৃষিবাজার বার্তা',
      icon: Icons.notifications_active_rounded,
    );
  }
}

class _NotificationStyle {
  final Color cardBackground;
  final Color borderColor;
  final Color accentColor;
  final Color badgeBackground;
  final Color badgeTextColor;
  final String badgeText;
  final IconData icon;

  _NotificationStyle({
    required this.cardBackground,
    required this.borderColor,
    required this.accentColor,
    required this.badgeBackground,
    required this.badgeTextColor,
    required this.badgeText,
    required this.icon,
  });
}
