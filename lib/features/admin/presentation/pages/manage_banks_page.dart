import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../bank/presentation/widgets/bank_card.dart';
import '../../../bank/providers/bank_provider.dart';
import '../widgets/add_bank_dialog.dart';

class ManageBanksPage extends ConsumerWidget {
  const ManageBanksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banksAsync = ref.watch(banksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Partner Banks'),
      ),
      body: banksAsync.when(
        data: (banks) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: banks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final bank = banks[index];
              return BankCard(
                bank: bank,
                onTap: () => context.push('/bank-details/${bank.id}', extra: bank),
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading bank branches...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddBankDialog.show(context),
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Add Bank'),
      ),
    );
  }
}
