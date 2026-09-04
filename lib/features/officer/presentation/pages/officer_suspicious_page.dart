import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/officer/providers/officer_provider.dart';

class OfficerSuspiciousPage extends ConsumerWidget {
  const OfficerSuspiciousPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(officerFilteredSubmissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('District Suspicious Cases'),
      ),
      body: submissionsAsync.when(
        data: (submissions) {
          final highRisk = submissions.where((s) => s.riskLevel.name == 'high' || s.status.name == 'rejected').toList();

          if (highRisk.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_rounded, size: 64, color: AppColors.success),
                  const SizedBox(height: 12),
                  const Text(
                    'No Suspicious Cases Flagged in District',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'All evidence submissions in your jurisdiction meet confidence standards.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: highRisk.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sub = highRisk[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.red.shade300),
                ),
                color: Colors.red.shade50.withValues(alpha: 0.3),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'High-Risk Flag: ${sub.submissionId}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red.shade900),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Risk Level: HIGH',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Loan: ${sub.loanId}  •  Beneficiary: ${sub.beneficiaryId}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.report_problem_outlined, size: 16, color: Colors.red),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'AI Detection Reason: Geotag radius mismatch (>120m from asset location) & photo similarity anomaly.',
                                style: TextStyle(fontSize: 11, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.push('/review-submission/${sub.submissionId}');
                          },
                          icon: const Icon(Icons.fact_check_outlined, size: 16),
                          label: const Text('Review Evidence'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Checking district risk flags...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}
