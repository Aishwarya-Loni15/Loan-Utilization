import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../utilization/providers/utilization_provider.dart';
import '../widgets/review_card.dart';

class PendingReviewsPage extends ConsumerWidget {
  const PendingReviewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingSubmissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Verification Audit Queue'),
      ),
      body: pendingAsync.when(
        data: (submissions) {
          if (submissions.isEmpty) {
            return const EmptyStateWidget(
              title: 'Queue Clear',
              description: 'All submitted loan utilization evidence packages have been audited.',
              icon: Icons.done_all_rounded,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: submissions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = submissions[index];
              return ReviewCardWidget(
                submission: item,
                onTap: () => context.push('/review-submission/${item.submissionId}'),
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading pending audit queue...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.refresh(pendingSubmissionsProvider),
        ),
      ),
    );
  }
}
