import 'package:flutter/material.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../domain/entities/utilization_submission.dart';

class RecentSubmissionCard extends StatelessWidget {
  final UtilizationSubmissionEntity submission;
  final VoidCallback? onTap;

  const RecentSubmissionCard({
    super.key,
    required this.submission,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyUtils.formatINR(submission.amountSpent),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Row(
                children: [
                  if (submission.isImageFake) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: submission.isAiGeneratedImage
                            ? Colors.purple.shade900
                            : Colors.red.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            submission.isAiGeneratedImage ? Icons.smart_toy_rounded : Icons.gpp_bad_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            submission.isAiGeneratedImage ? '🤖 AI FAKE' : '⚠️ FAKE IMAGE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  SubmissionStatusChip(status: submission.status),
                  const SizedBox(width: 6),
                  const SyncStatusChip(isSynced: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            submission.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Submitted ${AppDateUtils.formatDate(submission.uploadedAt)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
