import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/utils/date_utils.dart';
import 'package:laon/core/widgets/empty_state.dart';
import 'package:laon/features/auth/providers/auth_provider.dart';
import 'package:laon/features/notifications/providers/notification_provider.dart';

class RoleNotificationsPage extends ConsumerWidget {
  const RoleNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final allNotifications = ref.watch(notificationsProvider);

    final roleNotifications = allNotifications
        .where((n) => n.targetRole == user?.role)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${user?.role.displayName ?? "System"} Notifications'),
      ),
      body: roleNotifications.isEmpty
          ? const EmptyStateWidget(
              title: 'No Pending Notifications',
              description: 'No system alerts or queue notifications pending.',
              icon: Icons.notifications_off_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: roleNotifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = roleNotifications[index];
                final isWarning = notif.title.toLowerCase().contains('suspicious') ||
                    notif.title.toLowerCase().contains('high-risk');

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isWarning ? AppColors.danger : AppColors.border,
                      width: isWarning ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: CircleAvatar(
                      backgroundColor: isWarning ? AppColors.danger.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(
                        isWarning ? Icons.warning_amber_rounded : Icons.notifications_active_outlined,
                        color: isWarning ? AppColors.danger : AppColors.primary,
                      ),
                    ),
                    title: Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isWarning ? AppColors.danger : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notif.message, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 6),
                        Text(
                          AppDateUtils.formatDateTime(notif.createdAt),
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    onTap: () => ref.read(notificationsProvider.notifier).markAsRead(notif.id),
                  ),
                );
              },
            ),
    );
  }
}
