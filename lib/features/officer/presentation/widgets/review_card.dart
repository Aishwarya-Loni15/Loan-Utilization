import 'package:flutter/material.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../domain/entities/utilization_submission.dart';

class ReviewCardWidget extends StatelessWidget {
  final UtilizationSubmissionEntity submission;
  final VoidCallback? onTap;

  const ReviewCardWidget({
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
                  RiskLevelChip(level: submission.riskLevel, isCompact: true),
                  const SizedBox(width: 6),
                  SubmissionStatusChip(status: submission.status),
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
                'Ben ID: ${submission.beneficiaryId}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
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
