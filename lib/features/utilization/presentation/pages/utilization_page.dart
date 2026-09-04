import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../beneficiary/presentation/widgets/recent_submission_card.dart';
import '../../providers/utilization_provider.dart';

class UtilizationPage extends ConsumerWidget {
  const UtilizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(allSubmissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Utilization Submissions Portfolio'),
      ),
      body: submissionsAsync.when(
        data: (submissions) {
          if (submissions.isEmpty) {
            return const EmptyStateWidget(
              title: 'No Submissions Available',
              description: 'There are no active evidence submissions to display.',
              icon: Icons.assignment_turned_in_outlined,
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
        loading: () => const LoadingWidget(message: 'Loading utilization records...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.refresh(allSubmissionsProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/submit-evidence'),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('New Submission'),
      ),
    );
  }
}
