import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../providers/beneficiary_provider.dart';

class LoanSummaryCard extends StatelessWidget {
  final BeneficiaryDashboardMetrics metrics;

  const LoanSummaryCard({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Financial Capital Overview',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${metrics.totalLoans} Active ${metrics.totalLoans == 1 ? "Loan" : "Loans"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMetricTile(
            title: 'Bank Manager Disbursed Capital (Static)',
            amount: metrics.disbursedAmount,
            color: AppColors.info,
            isHeadline: true,
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Utilized Proof',
                  amount: metrics.utilizedAmount,
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  title: 'Remaining Balance',
                  amount: metrics.remainingAmount,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required double amount,
    required Color color,
    bool isHeadline = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isHeadline ? Colors.white70 : Colors.white60,
            fontSize: isHeadline ? 13 : 12,
            fontWeight: isHeadline ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyUtils.formatINR(amount),
          style: TextStyle(
            color: color,
            fontSize: isHeadline ? 24 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
