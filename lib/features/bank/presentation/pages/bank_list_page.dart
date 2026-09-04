import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laon/domain/entities/bank.dart';
import 'package:laon/features/bank/providers/bank_provider.dart';
import 'package:laon/features/bank/presentation/widgets/bank_card.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/empty_state.dart';
import 'package:laon/features/auth/providers/auth_provider.dart';
import 'package:laon/core/enums/user_role.dart';

class BankListPage extends ConsumerWidget {
  const BankListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banksAsync = ref.watch(banksProvider);
    final user = ref.watch(currentUserProvider).value;
    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Banks & Branches'),
      ),
      body: banksAsync.when(
        data: (banks) {
          if (banks.isEmpty) {
            return const EmptyStateWidget(
              title: 'No Banks Registered',
              description: 'There are currently no banks or branch nodes registered in the system.',
              icon: Icons.account_balance_outlined,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: banks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final bank = banks[index];
              return BankCard(
                bank: bank,
                onTap: () {
                  context.push('/bank-details/${bank.id}', extra: bank);
                },
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading registered banks...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.refresh(banksProvider),
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddBankDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Bank'),
            )
          : null,
    );
  }

  void _showAddBankDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final branchController = TextEditingController();
    final ifscController = TextEditingController();
    final districtController = TextEditingController();
    final stateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Register New Bank Branch'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Bank Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: branchController,
                  decoration: const InputDecoration(labelText: 'Branch Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ifscController,
                  decoration: const InputDecoration(labelText: 'IFSC Code'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: districtController,
                  decoration: const InputDecoration(labelText: 'District'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stateController,
                  decoration: const InputDecoration(labelText: 'State'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && ifscController.text.isNotEmpty) {
                  final newBank = BankEntity(
                    id: 'bank_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text.trim(),
                    branchName: branchController.text.trim(),
                    ifscCode: ifscController.text.trim(),
                    district: districtController.text.trim(),
                    state: stateController.text.trim(),
                  );
                  await ref.read(createBankUseCaseProvider).call(newBank);
                  if (context.mounted) Navigator.pop(context);
                  ref.invalidate(banksProvider);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
