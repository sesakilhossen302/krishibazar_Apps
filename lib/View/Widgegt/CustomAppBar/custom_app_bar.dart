import 'package:flutter/material.dart';
import '../../../global/Model/krishi_models.dart';
import '../../../service/api_url.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserRole currentRole;
  final int unreadNotifications;
  final VoidCallback onNotificationsClick;
  final VerificationStatus verificationStatus;
  final String userName;
  final String userPhotoUrl;
  final VoidCallback? onStatusClick;

  const CustomAppBar({
    super.key,
    required this.currentRole,
    required this.unreadNotifications,
    required this.onNotificationsClick,
    this.verificationStatus = VerificationStatus.pending,
    this.userName = '',
    this.userPhotoUrl = '',
    this.onStatusClick,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  Widget _buildStatusBadge(BuildContext context) {
    String label;
    Color bg;
    Color textCol;
    IconData icon;

    switch (verificationStatus) {
      case VerificationStatus.verified:
        label = currentRole == UserRole.farmer ? 'ভেরিফাইড কৃষক ✅' : 'ভেরিফাইড ক্রেতা ✅';
        bg = const Color(0xFFDCFCE7);
        textCol = const Color(0xFF15803D);
        icon = Icons.verified_user_rounded;
        break;
      case VerificationStatus.inProgress:
        label = 'কাগজপত্র যাচাই চলছে 🔄';
        bg = const Color(0xFFE0F2FE);
        textCol = const Color(0xFF0369A1);
        icon = Icons.autorenew_rounded;
        break;
      case VerificationStatus.rejected:
        label = 'আবেদন বাতিল ❌';
        bg = const Color(0xFFFEE2E2);
        textCol = const Color(0xFFB91C1C);
        icon = Icons.cancel_outlined;
        break;
      case VerificationStatus.suspended:
        label = 'অ্যাকাউন্ট স্থগিত 🚫';
        bg = const Color(0xFFFFEDD5);
        textCol = const Color(0xFFC2410C);
        icon = Icons.block_rounded;
        break;
      case VerificationStatus.pending:
        label = 'যাচাই অপেক্ষমাণ ⏳';
        bg = Colors.white.withValues(alpha: 0.22);
        textCol = Colors.white;
        icon = Icons.hourglass_top_rounded;
        break;
    }

    return InkWell(
      onTap: onStatusClick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: textCol.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: textCol),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: textCol,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = userName.isNotEmpty
        ? userName
        : (currentRole == UserRole.farmer ? 'কৃষক ড্যাশবোর্ড' : 'ক্রেতা ড্যাশবোর্ড');

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF166534), // Deep forest green
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: userPhotoUrl.isNotEmpty
                      ? Image.network(
                          ApiUrl.formatMediaUrl(userPhotoUrl),
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              currentRole == UserRole.farmer ? '👨‍🌾' : '🏪',
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            currentRole == UserRole.farmer ? '👨‍🌾' : '🏪',
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    _buildStatusBadge(context),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onNotificationsClick,
                child: Container(
                  width: 38,

                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.notifications, color: Colors.white, size: 20),
                      if (unreadNotifications > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
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


