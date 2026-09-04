import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../officer/presentation/widgets/review_card.dart';
import '../../../utilization/providers/utilization_provider.dart';

class SuspiciousCasesPage extends ConsumerWidget {
  const SuspiciousCasesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(allSubmissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('High-Risk & Suspicious Cases'),
      ),
      body: submissionsAsync.when(
        data: (submissions) {
          final suspicious = submissions.where((s) => s.riskLevel.name == 'high').toList();

          if (suspicious.isEmpty) {
            return const EmptyStateWidget(
              title: 'No Suspicious Cases',
              description: 'Zero high-risk evidence submissions detected in system.',
              icon: Icons.verified_user_rounded,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: suspicious.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sub = suspicious[index];
              return ReviewCardWidget(
                submission: sub,
                onTap: () => context.push('/review-submission/${sub.submissionId}'),
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Filtering suspicious cases...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}
