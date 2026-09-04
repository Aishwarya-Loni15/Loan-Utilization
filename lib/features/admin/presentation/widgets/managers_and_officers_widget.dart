import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/features/admin/presentation/widgets/add_user_dialog.dart';
import 'package:laon/features/admin/providers/admin_provider.dart';

class ManagersAndOfficersWidget extends ConsumerWidget {
  const ManagersAndOfficersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bankManagersAsync = ref.watch(bankManagersProvider);
    final stateOfficersAsync = ref.watch(stateOfficersProvider);

    final bankManagers = bankManagersAsync.value ?? [];
    final stateOfficers = stateOfficersAsync.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bank Managers & State Officers',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
              tooltip: 'Add Manager or Officer',
              onPressed: () => AddUserDialog.show(context),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Cards Row
        Row(
          children: [
            // Bank Managers Card
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.deepPurple.shade50,
                            child: const Icon(Icons.account_balance_outlined, color: Colors.deepPurple, size: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bank Managers',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${bankManagers.length} Active Branch Officers',
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (bankManagers.isNotEmpty) ...[
                        _buildUserChip(
                          name: bankManagers.first.name,
                          subtitle: (bankManagers.first.bankId != null && bankManagers.first.bankId!.isNotEmpty)
                              ? bankManagers.first.bankId!
                              : bankManagers.first.email,
                          icon: Icons.business,
                        ),
                        const SizedBox(height: 8),
                      ] else ...[
                        _buildUserChip(
                          name: 'No Managers Registered',
                          subtitle: 'Tap to add branch manager',
                          icon: Icons.person_off_outlined,
                        ),
                        const SizedBox(height: 8),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                          label: const Text('Manage Managers', style: TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            foregroundColor: Colors.deepPurple,
                            side: const BorderSide(color: Colors.deepPurple),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => context.push('/manage-bank-managers'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // State Officers Card
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.blue.shade50,
                            child: Icon(Icons.badge_outlined, color: Colors.blue.shade800, size: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'State Officers',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${stateOfficers.length} Jurisdiction Auditors',
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (stateOfficers.isNotEmpty) ...[
                        _buildUserChip(
                          name: stateOfficers.first.name,
                          subtitle: stateOfficers.first.district.isNotEmpty
                              ? stateOfficers.first.district
                              : stateOfficers.first.email,
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 8),
                      ] else ...[
                        _buildUserChip(
                          name: 'No Officers Registered',
                          subtitle: 'Tap to add state officer',
                          icon: Icons.person_off_outlined,
                        ),
                        const SizedBox(height: 8),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                          label: const Text('Manage Officers', style: TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            foregroundColor: Colors.blue.shade800,
                            side: BorderSide(color: Colors.blue.shade800),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => context.push('/manage-state-officers'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserChip({
    required String name,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
