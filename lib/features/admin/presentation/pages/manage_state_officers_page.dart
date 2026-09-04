import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/admin/providers/admin_provider.dart';
import 'package:laon/features/admin/presentation/widgets/add_user_dialog.dart';

class ManageStateOfficersPage extends ConsumerStatefulWidget {
  const ManageStateOfficersPage({super.key});

  @override
  ConsumerState<ManageStateOfficersPage> createState() => _ManageStateOfficersPageState();
}

class _ManageStateOfficersPageState extends ConsumerState<ManageStateOfficersPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final officersAsync = ref.watch(stateOfficersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage State Officers'),
      ),
      body: officersAsync.when(
        data: (officers) {
          final filtered = officers.where((o) {
            final query = _searchQuery.toLowerCase();
            return o.name.toLowerCase().contains(query) ||
                o.email.toLowerCase().contains(query) ||
                o.phone.contains(query) ||
                o.district.toLowerCase().contains(query);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search officer by name, district, or email...',
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
                            Icon(Icons.badge_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isEmpty ? 'No State Officers Registered' : 'No matching officers found',
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
                          final officer = filtered[index];
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
                                        backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                                        child: const Icon(Icons.shield_outlined, color: AppColors.secondary),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              officer.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              officer.email,
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: officer.isBlocked ? Colors.red.shade50 : Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: officer.isBlocked ? Colors.red.shade300 : Colors.blue.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          officer.isBlocked ? 'Blocked' : 'Active Officer',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: officer.isBlocked ? Colors.red.shade700 : Colors.blue.shade700,
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
                                          icon: Icons.map_outlined,
                                          label: 'Jurisdiction District',
                                          value: officer.district.isNotEmpty ? officer.district : 'Solapur District',
                                        ),
                                      ),
                                      Expanded(
                                        child: _InfoChip(
                                          icon: Icons.phone_outlined,
                                          label: 'Phone Contact',
                                          value: officer.phone.isNotEmpty ? officer.phone : 'Not provided',
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
                                          officer.isBlocked ? Icons.check_circle_outline : Icons.block_outlined,
                                          size: 16,
                                        ),
                                        label: Text(officer.isBlocked ? 'Unblock Access' : 'Block Access'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: officer.isBlocked ? Colors.green : Colors.red,
                                        ),
                                        onPressed: () async {
                                          await ref
                                              .read(userBlockNotifierProvider.notifier)
                                              .toggleUserBlockStatus(officer.uid, officer.isBlocked);
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
        loading: () => const LoadingWidget(message: 'Loading State Officers...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddUserDialog.show(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add State Officer'),
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
