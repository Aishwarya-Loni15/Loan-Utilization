import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/loans/presentation/widgets/loan_card.dart';
import 'package:laon/features/officer/presentation/widgets/officer_filter_bar.dart';
import 'package:laon/features/officer/providers/officer_provider.dart';

class OfficerLoansPage extends ConsumerWidget {
  const OfficerLoansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(officerFilteredLoansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('District Loans (Read-Only)'),
      ),
      body: Column(
        children: [
          // Security Policy Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.amber.shade50,
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: Colors.amber.shade900, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Read-Only Access: Loan schema modifications require System Admin authorization.',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber.shade900),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: const OfficerFilterBarWidget(),
          ),

          Expanded(
            child: loansAsync.when(
              data: (loans) {
                if (loans.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No loans found matching filter criteria',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: loans.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
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
              loading: () => const LoadingWidget(message: 'Loading district loans...'),
              error: (e, _) => AppErrorWidget(message: e.toString()),
            ),
          ),
        ],
      ),
    );
  }
}
