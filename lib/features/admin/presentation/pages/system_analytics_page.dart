import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/admin/providers/admin_provider.dart';

class SystemAnalyticsPage extends ConsumerWidget {
  const SystemAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(adminMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Analytics & Insights'),
      ),
      body: metricsAsync.when(
        data: (metrics) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top KPI Grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    _KpiCard(
                      title: 'Total Disbursed',
                      value: '₹${(metrics.totalDisbursedAmount / 100000).toStringAsFixed(1)} Lakh',
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppColors.primary,
                    ),
                    _KpiCard(
                      title: 'Verification Rate',
                      value: '${metrics.verificationCompletionRate.toStringAsFixed(1)}%',
                      icon: Icons.verified_user_outlined,
                      color: AppColors.success,
                    ),
                    _KpiCard(
                      title: 'Active Beneficiaries',
                      value: '${metrics.totalBeneficiaries}',
                      icon: Icons.people_outline,
                      color: AppColors.secondary,
                    ),
                    _KpiCard(
                      title: 'High Risk Flags',
                      value: '${metrics.suspiciousCases}',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.danger,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Loan Status Distribution Chart Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Loan Status Distribution',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  color: AppColors.success,
                                  value: 55,
                                  title: '55%\nVerified',
                                  radius: 50,
                                  titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                PieChartSectionData(
                                  color: AppColors.primary,
                                  value: 25,
                                  title: '25%\nPending',
                                  radius: 50,
                                  titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                PieChartSectionData(
                                  color: AppColors.danger,
                                  value: 10,
                                  title: '10%\nRejected',
                                  radius: 50,
                                  titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                PieChartSectionData(
                                  color: Colors.amber,
                                  value: 10,
                                  title: '10%\nFlagged',
                                  radius: 50,
                                  titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Monthly Disbursement Trend Chart Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Disbursement & Verification Trend',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 220,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, meta) {
                                      const titles = ['Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];
                                      if (val.toInt() < titles.length) {
                                        return Text(titles[val.toInt()], style: const TextStyle(fontSize: 10));
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 40, color: AppColors.primary)]),
                                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 55, color: AppColors.primary)]),
                                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 70, color: AppColors.primary)]),
                                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 65, color: AppColors.primary)]),
                                BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 85, color: AppColors.primary)]),
                                BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 95, color: AppColors.success)]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Calculating system analytics...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
