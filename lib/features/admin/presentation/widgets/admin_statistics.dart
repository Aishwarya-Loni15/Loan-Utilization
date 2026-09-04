import 'package:flutter/material.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/utils/currency_utils.dart';
import 'package:laon/features/admin/providers/admin_provider.dart';

class AdminStatisticsWidget extends StatelessWidget {
  final AdminDashboardMetrics metrics;

  const AdminStatisticsWidget({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'National System Key Metrics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.45,
          children: [
            // 1. Total Loans
            _buildMetricCard(
              context,
              title: 'Total Loans',
              value: '${metrics.totalLoans}',
              subtitle: 'Monitored Scheme Portfolio',
              color: AppColors.primary,
              icon: Icons.assignment_outlined,
            ),
            // 2. Total Beneficiaries
            _buildMetricCard(
              context,
              title: 'Total Beneficiaries',
              value: '${metrics.totalBeneficiaries}',
              subtitle: 'Registered Asset Owners',
              color: AppColors.success,
              icon: Icons.people_alt_outlined,
            ),
            // 3. Total Amount Disbursed
            _buildMetricCard(
              context,
              title: 'Total Amount Disbursed',
              value: CurrencyUtils.formatINR(metrics.totalDisbursedAmount),
              subtitle: 'Sanctioned Outlay',
              color: Colors.indigo,
              icon: Icons.account_balance_wallet_outlined,
            ),
            // 4. Total Utilization Submissions
            _buildMetricCard(
              context,
              title: 'Total Submissions',
              value: '${metrics.totalSubmissions}',
              subtitle: 'Uploaded Proof Packages',
              color: Colors.teal,
              icon: Icons.upload_file_outlined,
            ),
            // 5. Approved Submissions
            _buildMetricCard(
              context,
              title: 'Approved Submissions',
              value: '${metrics.approvedSubmissions}',
              subtitle: 'Verified Evidence',
              color: AppColors.success,
              icon: Icons.check_circle_outline_rounded,
            ),
            // 6. Rejected Submissions
            _buildMetricCard(
              context,
              title: 'Rejected Submissions',
              value: '${metrics.rejectedSubmissions}',
              subtitle: 'Mismatched Claims',
              color: AppColors.danger,
              icon: Icons.cancel_outlined,
            ),
            // 7. Pending Submissions
            _buildMetricCard(
              context,
              title: 'Pending Submissions',
              value: '${metrics.pendingSubmissions}',
              subtitle: 'Awaiting Audit Review',
              color: AppColors.warning,
              icon: Icons.hourglass_top_rounded,
            ),
            // 8. Suspicious Cases
            _buildMetricCard(
              context,
              title: 'Suspicious Cases',
              value: '${metrics.suspiciousCases}',
              subtitle: 'High-Risk AI Flags',
              color: AppColors.danger,
              icon: Icons.gpp_maybe_outlined,
            ),
            // 9. Bank Managers
            _buildMetricCard(
              context,
              title: 'Bank Managers',
              value: '${metrics.totalBankManagers}',
              subtitle: 'Partner Branch Officers',
              color: Colors.deepPurple,
              icon: Icons.account_balance_outlined,
            ),
            // 10. State Officers
            _buildMetricCard(
              context,
              title: 'State Officers',
              value: '${metrics.totalStateOfficers}',
              subtitle: 'Jurisdiction Auditors',
              color: Colors.blue.shade800,
              icon: Icons.badge_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
