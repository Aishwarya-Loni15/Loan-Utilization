import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/app/router/route_names.dart';
import 'package:laon/features/bank/providers/bank_provider.dart';

class BankStatisticsWidget extends StatelessWidget {
  final BankDashboardMetrics metrics;

  const BankStatisticsWidget({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCard(
                context,
                title: 'Total Branch Loans',
                value: '${metrics.totalLoans}',
                subtitle: '${metrics.activeLoans} Active Accounts',
                color: AppColors.primary,
                icon: Icons.account_balance_outlined,
                onTap: () => context.push(RouteNames.bankLoans),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCard(
                context,
                title: 'Pending Verification',
                value: '${metrics.pendingReviews}',
                subtitle: 'Verification Queue',
                color: AppColors.warning,
                icon: Icons.hourglass_empty_rounded,
                onTap: () => context.push('${RouteNames.bankSubmissions}?filter=pending'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCard(
                context,
                title: 'Approved Submissions',
                value: '${metrics.approvedSubmissions}',
                subtitle: 'Verified Capital Claims',
                color: AppColors.success,
                icon: Icons.check_circle_outline_rounded,
                onTap: () => context.push('${RouteNames.bankSubmissions}?filter=approved'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCard(
                context,
                title: 'Rejected Submissions',
                value: '${metrics.rejectedSubmissions}',
                subtitle: 'Evidence Discrepancies',
                color: AppColors.danger,
                icon: Icons.highlight_off_rounded,
                onTap: () => context.push('${RouteNames.bankSubmissions}?filter=rejected'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCard(
                context,
                title: 'Resubmission Required',
                value: '2',
                subtitle: 'Awaiting Beneficiary Response',
                color: Colors.orange.shade800,
                icon: Icons.published_with_changes_rounded,
                onTap: () => context.push('${RouteNames.bankSubmissions}?filter=resubmission'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCard(
                context,
                title: 'Suspicious Submissions',
                value: '${metrics.highRiskCases}',
                subtitle: 'Flagged Exception Submissions',
                color: AppColors.danger,
                icon: Icons.warning_amber_rounded,
                onTap: () => context.push('${RouteNames.bankSubmissions}?filter=highRisk'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
