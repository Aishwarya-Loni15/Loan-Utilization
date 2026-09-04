import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/enums/user_role.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/admin/providers/admin_provider.dart';
import '../widgets/user_management_card.dart';
import '../widgets/add_user_dialog.dart';

class ManageUsersPage extends ConsumerStatefulWidget {
  const ManageUsersPage({super.key});

  @override
  ConsumerState<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends ConsumerState<ManageUsersPage> {
  String _searchQuery = '';
  UserRole? _selectedRoleFilter;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage System Users'),
      ),
      body: usersAsync.when(
        data: (users) {
          final filtered = users.where((user) {
            final matchesQuery = _searchQuery.isEmpty ||
                user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                user.phone.contains(_searchQuery);
            final matchesRole = _selectedRoleFilter == null || user.role == _selectedRoleFilter;
            return matchesQuery && matchesRole;
          }).toList();

          return Column(
            children: [
              // Search and Filter Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search user by name, email, or phone...',
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

              // Role Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Roles'),
                      selected: _selectedRoleFilter == null,
                      onSelected: (_) => setState(() => _selectedRoleFilter = null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Beneficiaries'),
                      selected: _selectedRoleFilter == UserRole.beneficiary,
                      onSelected: (_) => setState(() => _selectedRoleFilter = UserRole.beneficiary),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Bank Managers'),
                      selected: _selectedRoleFilter == UserRole.bankManager,
                      onSelected: (_) => setState(() => _selectedRoleFilter = UserRole.bankManager),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('State Officers'),
                      selected: _selectedRoleFilter == UserRole.stateOfficer,
                      onSelected: (_) => setState(() => _selectedRoleFilter = UserRole.stateOfficer),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Admins'),
                      selected: _selectedRoleFilter == UserRole.admin,
                      onSelected: (_) => setState(() => _selectedRoleFilter = UserRole.admin),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Users List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'No matching users found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = filtered[index];
                          return UserManagementCardWidget(
                            user: user,
                            onToggleBlock: (isBlocked) async {
                              await ref
                                  .read(userBlockNotifierProvider.notifier)
                                  .toggleUserBlockStatus(user.uid, isBlocked);
                              ref.invalidate(allUsersProvider);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(message: 'Loading system users...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddUserDialog.show(context),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add User'),
      ),
    );
  }
}
