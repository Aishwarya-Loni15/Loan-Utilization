import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/enums/user_role.dart';
import 'package:laon/core/utils/date_utils.dart';
import 'package:laon/core/widgets/empty_state.dart';
import 'package:laon/features/notifications/providers/notification_provider.dart';

class BeneficiaryNotificationsPage extends ConsumerWidget {
  const BeneficiaryNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allNotifications = ref.watch(notificationsProvider);
    final beneficiaryNotifications = allNotifications
        .where((n) => n.targetRole == UserRole.beneficiary)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficiary Notifications'),
      ),
      body: beneficiaryNotifications.isEmpty
          ? const EmptyStateWidget(
              title: 'No New Notifications',
              description: 'You are all caught up! Updates regarding loan linking, proof submissions, and officer reviews will appear here.',
              icon: Icons.notifications_none_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: beneficiaryNotifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = beneficiaryNotifications[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: notif.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.4),
                      width: notif.isRead ? 1.0 : 1.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                    ),
                    title: Text(
                      notif.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
