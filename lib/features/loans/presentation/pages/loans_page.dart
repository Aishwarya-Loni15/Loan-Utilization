import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laon/core/widgets/empty_state.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/loans/providers/loan_provider.dart';
import '../widgets/loan_card.dart';

class LoansPage extends ConsumerWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(allLoansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Loan Records'),
      ),
      body: loansAsync.when(
        data: (loans) {
          if (loans.isEmpty) {
            return const EmptyStateWidget(
              title: 'No Loans Disbursed',
              description: 'There are no active loan records available in the system.',
              icon: Icons.account_balance_wallet_outlined,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: loans.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final loan = loans[index];
              return LoanCard(
                loan: loan,
                onTap: () {
                  context.push('/loan-details/${loan.loanId}', extra: loan);
                },
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading loans portfolio...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.refresh(allLoansProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-loan'),
        icon: const Icon(Icons.add),
        label: const Text('New Loan'),
      ),
    );
  }
}
