import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laon/app/router/route_names.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/features/officer/providers/officer_provider.dart';

class OfficerStatisticsWidget extends StatelessWidget {
  final OfficerDashboardMetrics metrics;

  const OfficerStatisticsWidget({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jurisdiction Key Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            TextButton.icon(
              onPressed: () => context.push(RouteNames.jurisdictionDrilldown),
              icon: const Icon(Icons.account_tree_outlined, size: 16),
              label: const Text('6-Tier Drill-Down', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.45,
          children: [
            // 1. State-level loan statistics
            _buildStatCard(
              context,
              title: '1. State-Level Stats',
              value: '14,250 Loans',
              subtitle: 'Maharashtra Total Outlay ₹245 Cr',
              color: AppColors.primary,
              icon: Icons.map_outlined,
            ),
            // 2. District-wise statistics
            _buildStatCard(
              context,
              title: '2. District-Wise Stats',
              value: '1,420 Loans',
              subtitle: 'Solapur District Total Outlay ₹24.5 Cr',
              color: Colors.indigo,
              icon: Icons.location_city_outlined,
            ),
            // 3. Taluka-wise statistics
            _buildStatCard(
              context,
              title: '3. Taluka-Wise Stats',
              value: '3 Talukas',
              subtitle: 'Pandharpur, Malshiras, Baramati',
              color: Colors.teal,
              icon: Icons.holiday_village_outlined,
            ),
            // 4. Village-wise statistics
            _buildStatCard(
              context,
              title: '4. Village-Wise Stats',
              value: '12 Villages',
              subtitle: 'Kavathe, Bhalwani & 10 others',
              color: Colors.blueGrey,
              icon: Icons.house_outlined,
            ),
            // 5. Bank-wise statistics
            _buildStatCard(
              context,
              title: '5. Bank-Wise Stats',
              value: '8 Partner Banks',
              subtitle: 'SBI, Bank of Baroda, Mah. Gramin',
              color: AppColors.success,
              icon: Icons.account_balance_outlined,
            ),
            // 6. Verification status
            _buildStatCard(
              context,
              title: '6. Verification Status',
              value: '${metrics.approvedSubmissions} Approved',
              subtitle: '${metrics.pendingReviews} Pending Review',
              color: AppColors.warning,
              icon: Icons.fact_check_outlined,
            ),
            // 7. Suspicious cases
            _buildStatCard(
              context,
              title: '7. Suspicious Cases',
              value: '${metrics.highRiskSubmissions} Flagged',
              subtitle: 'PURPOSE_MISMATCH / Distance Flags',
              color: AppColors.danger,
              icon: Icons.warning_amber_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
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
