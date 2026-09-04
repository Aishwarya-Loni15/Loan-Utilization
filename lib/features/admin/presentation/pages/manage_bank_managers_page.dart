import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/admin/providers/admin_provider.dart';
import 'package:laon/features/admin/presentation/widgets/add_user_dialog.dart';

class ManageBankManagersPage extends ConsumerStatefulWidget {
  const ManageBankManagersPage({super.key});

  @override
  ConsumerState<ManageBankManagersPage> createState() => _ManageBankManagersPageState();
}

class _ManageBankManagersPageState extends ConsumerState<ManageBankManagersPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final managersAsync = ref.watch(bankManagersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bank Managers'),
      ),
      body: managersAsync.when(
        data: (managers) {
          final filtered = managers.where((m) {
            final query = _searchQuery.toLowerCase();
            return m.name.toLowerCase().contains(query) ||
                m.email.toLowerCase().contains(query) ||
                m.phone.contains(query) ||
                (m.bankId ?? '').toLowerCase().contains(query);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search bank manager by name, email, or bank ID...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_balance_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isEmpty ? 'No Bank Managers Registered' : 'No matching managers found',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final manager = filtered[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                        child: const Icon(Icons.account_balance_rounded, color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              manager.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              manager.email,
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: manager.isBlocked ? Colors.red.shade50 : Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: manager.isBlocked ? Colors.red.shade300 : Colors.green.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          manager.isBlocked ? 'Blocked' : 'Active',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: manager.isBlocked ? Colors.red.shade700 : Colors.green.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _InfoChip(
                                          icon: Icons.business_outlined,
                                          label: 'Bank Branch',
                                          value: (manager.bankId != null && manager.bankId!.isNotEmpty) ? manager.bankId! : 'Branch not assigned',
                                        ),
                                      ),
                                      Expanded(
                                        child: _InfoChip(
                                          icon: Icons.phone_outlined,
                                          label: 'Contact',
                                          value: manager.phone.isNotEmpty ? manager.phone : 'Not provided',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton.icon(
                                        icon: Icon(
                                          manager.isBlocked ? Icons.check_circle_outline : Icons.block_outlined,
                                          size: 16,
                                        ),
                                        label: Text(manager.isBlocked ? 'Unblock Access' : 'Block Access'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: manager.isBlocked ? Colors.green : Colors.red,
                                        ),
                                        onPressed: () async {
                                          await ref
                                              .read(userBlockNotifierProvider.notifier)
                                              .toggleUserBlockStatus(manager.uid, manager.isBlocked);
                                          ref.invalidate(allUsersProvider);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(message: 'Loading Bank Managers...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddUserDialog.show(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Bank Manager'),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
