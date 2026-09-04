import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/officer/presentation/widgets/officer_filter_bar.dart';
import 'package:laon/features/officer/providers/officer_provider.dart';

class OfficerUtilizationPage extends ConsumerWidget {
  const OfficerUtilizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(officerFilteredSubmissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Utilization Monitoring Console'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: const OfficerFilterBarWidget(),
          ),
          Expanded(
            child: submissionsAsync.when(
              data: (submissions) {
                if (submissions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No utilization proofs found',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: submissions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final sub = submissions[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Submission ID: ${sub.submissionId}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: sub.status.name == 'verified' || sub.status.name == 'approved'
                                        ? Colors.green.shade50
                                        : Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    sub.status.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: sub.status.name == 'verified' || sub.status.name == 'approved'
                                          ? Colors.green.shade700
                                          : Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Loan Ref: ${sub.loanId}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  'GPS Geotag: ${sub.latitude.toStringAsFixed(4)}, ${sub.longitude.toStringAsFixed(4)}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(message: 'Loading utilization status...'),
              error: (e, _) => AppErrorWidget(message: e.toString()),
            ),
          ),
        ],
      ),
    );
  }
}
