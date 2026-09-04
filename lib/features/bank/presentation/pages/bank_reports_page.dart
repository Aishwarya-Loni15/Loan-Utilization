import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/bank/providers/bank_provider.dart';

class BankReportsPage extends ConsumerWidget {
  const BankReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(bankDashboardMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Branch Analytics & Reports'),
      ),
      body: metricsAsync.when(
        data: (metrics) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Branch Capital Utilization Audit',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_balance),
                    title: const Text('Total Managed Accounts'),
                    trailing: Text('${metrics.totalLoans}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                    title: const Text('Active Disbursed Accounts'),
                    trailing: Text('${metrics.activeLoans}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.pie_chart, color: Colors.blue),
                    title: const Text('Verified Utilization Ratio'),
                    trailing: Text(
                      '${metrics.utilizationPercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.pending_actions, color: Colors.orange),
                    title: const Text('Pending Verification Queue'),
                    trailing: Text('${metrics.pendingReviews}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.verified, color: Colors.green),
                    title: const Text('Approved Utilization Claims'),
                    trailing: Text('${metrics.approvedSubmissions}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.cancel, color: Colors.red),
                    title: const Text('Rejected Claim Records'),
                    trailing: Text('${metrics.rejectedSubmissions}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.orange),
                    title: const Text('Flagged High-Risk Exceptions'),
                    trailing: Text('${metrics.highRiskCases}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Generating branch analytics...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}
