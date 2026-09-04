import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../beneficiary/presentation/widgets/recent_submission_card.dart';
import '../../providers/utilization_provider.dart';

class SubmissionHistoryPage extends ConsumerWidget {
  const SubmissionHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(userSubmissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidence Submission History'),
      ),
      body: submissionsAsync.when(
        data: (submissions) {
          if (submissions.isEmpty) {
            return const EmptyStateWidget(
              title: 'No Submissions History',
              description: 'You have not submitted any loan utilization evidence yet.',
              icon: Icons.history_toggle_off_rounded,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: submissions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sub = submissions[index];
              return RecentSubmissionCard(
                submission: sub,
                onTap: () {
                  context.push('/submission-details/${sub.submissionId}');
                },
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading evidence history...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.refresh(userSubmissionsProvider),
        ),
      ),
    );
  }
}
