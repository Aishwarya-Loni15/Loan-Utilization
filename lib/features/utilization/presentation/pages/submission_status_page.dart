import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../providers/utilization_provider.dart';
import '../widgets/submission_status_card.dart';

class SubmissionStatusPage extends ConsumerWidget {
  final String submissionId;

  const SubmissionStatusPage({
    super.key,
    required this.submissionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(allSubmissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Verification Status'),
      ),
      body: submissionsAsync.when(
        data: (submissions) {
          final sub = submissions.firstWhere(
            (s) => s.submissionId == submissionId,
            orElse: () => throw Exception('Submission record not found'),
          );

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SubmissionStatusCardWidget(
                  status: sub.status,
                  rejectionReason: sub.rejectionReason,
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Checking status...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}
