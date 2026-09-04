import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/ai_verification/providers/ai_provider.dart';
import '../widgets/ai_reason_card.dart';
import '../widgets/ai_score_card.dart';
import '../widgets/detected_objects_card.dart';
import '../widgets/risk_level_chip.dart';

class AiAnalysisPage extends ConsumerWidget {
  final String submissionId;

  const AiAnalysisPage({super.key, required this.submissionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiAsync = ref.watch(aiAnalysisFamilyProvider(submissionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistive AI Verification Analysis'),
      ),
      body: aiAsync.when(
        data: (ai) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Diagnostic Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    RiskLevelChipWidget(riskLevel: ai.riskLevel),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'AI provides assistive decision insights for verification officers. Final decisions remain with human auditors.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 20),
                AiScoreCardWidget(score: ai.aiScore),
                const SizedBox(height: 16),
                DetectedObjectsCardWidget(objects: ai.detectedObjects),
                const SizedBox(height: 16),
                AiReasonCardWidget(reasons: ai.reasons),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Executing assistive AI verification pipeline...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}
