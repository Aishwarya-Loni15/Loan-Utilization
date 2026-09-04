import 'package:flutter/material.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/utils/currency_utils.dart';

class LoanProgressWidget extends StatelessWidget {
  final double disbursedAmount;
  final double utilizedAmount;
  final double utilizationPercentage;

  const LoanProgressWidget({
    super.key,
    required this.disbursedAmount,
    required this.utilizedAmount,
    required this.utilizationPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (disbursedAmount - utilizedAmount).clamp(0.0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Utilization Rate',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              '${utilizationPercentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (utilizationPercentage / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              utilizationPercentage >= 90
                  ? AppColors.success
                  : (utilizationPercentage >= 50 ? AppColors.warning : AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Utilized: ${CurrencyUtils.formatINR(utilizedAmount)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              'Remaining: ${CurrencyUtils.formatINR(remaining)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
