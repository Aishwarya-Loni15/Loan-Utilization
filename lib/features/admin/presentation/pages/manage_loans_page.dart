import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../loans/presentation/widgets/loan_card.dart';
import '../../../loans/providers/loan_provider.dart';

class ManageLoansPage extends ConsumerWidget {
  const ManageLoansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(allLoansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage System Loans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/create-loan'),
          ),
        ],
      ),
      body: loansAsync.when(
        data: (loans) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: loans.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final loan = loans[index];
              return LoanCard(
                loan: loan,
                onTap: () => context.push('/loan-details/${loan.loanId}', extra: loan),
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading loans portfolio...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}
