import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/core/enums/user_role.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/domain/entities/bank.dart';
import 'package:laon/features/auth/providers/auth_provider.dart';
import 'package:laon/features/bank/presentation/widgets/bank_statistics.dart';
import 'package:laon/features/bank/providers/bank_provider.dart';

class BankDetailsPage extends ConsumerWidget {
  final String bankId;
  final BankEntity? initialBank;

  const BankDetailsPage({
    super.key,
    required this.bankId,
    this.initialBank,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bankAsync = ref.watch(bankDetailsProvider(bankId));
    final user = ref.watch(currentUserProvider).value;
    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text(initialBank?.name ?? 'Bank Details'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                final bank = bankAsync.value ?? initialBank;
                if (bank != null) {
                  _showEditBankDialog(context, ref, bank);
                }
              },
            ),
        ],
      ),
      body: bankAsync.when(
        data: (bankData) {
          final bank = bankData ?? initialBank;
          if (bank == null) {
            return const Center(child: Text('Bank not found.'));
          }

          final dummyMetrics = BankDashboardMetrics(
            totalLoans: bank.totalLoansDisbursed,
            activeLoans: bank.totalLoansDisbursed,
            utilizationPercentage: 78.5,
            pendingReviews: 3,
            approvedSubmissions: bank.totalLoansDisbursed > 2 ? bank.totalLoansDisbursed - 2 : 1,
            rejectedSubmissions: 0,
            highRiskCases: 1,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BankStatisticsWidget(metrics: dummyMetrics),
                const SizedBox(height: 24),
                Text(
                  'Branch Metadata',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.account_balance),
                  title: const Text('Bank Name'),
                  subtitle: Text(bank.name),
                ),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: const Text('Branch'),
                  subtitle: Text(bank.branchName),
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('IFSC Code'),
                  subtitle: Text(bank.ifscCode),
                ),
                ListTile(
                  leading: const Icon(Icons.map),
                  title: const Text('District / State'),
                  subtitle: Text('${bank.district}, ${bank.state}'),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Assigned Bank Manager'),
                  subtitle: Text(bank.managerName ?? 'Unassigned'),
                  trailing: isAdmin
                      ? IconButton(
                          icon: const Icon(Icons.person_add_alt),
                          onPressed: () => _showAssignManagerDialog(context, ref, bank),
                        )
                      : null,
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading bank details...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }

  void _showEditBankDialog(BuildContext context, WidgetRef ref, BankEntity bank) {
    final branchController = TextEditingController(text: bank.branchName);
    final ifscController = TextEditingController(text: bank.ifscCode);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${bank.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: branchController,
                decoration: const InputDecoration(labelText: 'Branch Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ifscController,
                decoration: const InputDecoration(labelText: 'IFSC Code'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updated = BankEntity(
                  id: bank.id,
                  name: bank.name,
                  branchName: branchController.text.trim(),
                  ifscCode: ifscController.text.trim(),
                  district: bank.district,
                  state: bank.state,
                  managerId: bank.managerId,
                  managerName: bank.managerName,
                  totalLoansDisbursed: bank.totalLoansDisbursed,
                  totalAmountDisbursed: bank.totalAmountDisbursed,
                );
                await ref.read(updateBankUseCaseProvider).call(updated);
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(bankDetailsProvider(bank.id));
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAssignManagerDialog(BuildContext context, WidgetRef ref, BankEntity bank) {
    final managerIdController = TextEditingController(text: bank.managerId);
    final managerNameController = TextEditingController(text: bank.managerName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign Bank Manager'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: managerNameController,
                decoration: const InputDecoration(labelText: 'Manager Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: managerIdController,
                decoration: const InputDecoration(labelText: 'Manager User ID'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(assignBankManagerUseCaseProvider).call(
                      bankId: bank.id,
                      managerId: managerIdController.text.trim(),
                      managerName: managerNameController.text.trim(),
                    );
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(bankDetailsProvider(bank.id));
              },
              child: const Text('Assign'),
            ),
          ],
        );
      },
    );
  }
}
