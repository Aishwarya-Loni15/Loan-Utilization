import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../loans/providers/loan_provider.dart';
import '../widgets/bank_loan_card.dart';
import '../widgets/link_offline_loan_dialog.dart';

class BankLoansPage extends ConsumerWidget {
  const BankLoansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(bankLoansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Authorized Branch Loan Accounts'),
      ),
      body: loansAsync.when(
        data: (loans) {
          if (loans.isEmpty) {
            return const EmptyStateWidget(
              title: 'No Loans Found',
              description: 'There are no active loan accounts associated with this bank branch.',
              icon: Icons.account_balance_outlined,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: loans.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final loan = loans[index];
              return BankLoanCardWidget(
                loan: loan,
                onTap: () {
                  context.push('/loan-details/${loan.loanId}', extra: loan);
                },
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading bank branch loans...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.refresh(bankLoansProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => LinkOfflineLoanDialog.show(context),
        icon: const Icon(Icons.add_link_rounded),
        label: const Text('Add Existing Offline Loan'),
      ),
    );
  }
}
