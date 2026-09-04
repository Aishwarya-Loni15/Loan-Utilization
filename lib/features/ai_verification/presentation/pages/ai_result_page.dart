import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/ai_verification/providers/ai_provider.dart';
import '../widgets/ai_reason_card.dart';
import '../widgets/ai_score_card.dart';

class AiResultPage extends ConsumerWidget {
  final String submissionId;

  const AiResultPage({super.key, required this.submissionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiAsync = ref.watch(aiAnalysisFamilyProvider(submissionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Verification Report'),
      ),
      body: aiAsync.when(
        data: (ai) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                AiScoreCardWidget(score: ai.aiScore),
                const SizedBox(height: 16),
                AiReasonCardWidget(reasons: ai.reasons),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Generating AI verification report...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}
