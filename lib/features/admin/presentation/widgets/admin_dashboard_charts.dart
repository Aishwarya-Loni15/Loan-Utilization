import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/features/admin/providers/admin_provider.dart';

class AdminDashboardChartsWidget extends StatelessWidget {
  final AdminDashboardMetrics metrics;

  const AdminDashboardChartsWidget({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics & Visual Breakdown',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
        ),
        const SizedBox(height: 12),
        // 1. Donut Chart - Submission Status Breakdown
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.pie_chart_outline_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Utilization Submissions Breakdown',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 190,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 42,
                      sections: _buildPieSections(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildLegendItem('Approved', AppColors.success, '${metrics.approvedSubmissions}'),
                    _buildLegendItem('Pending', AppColors.warning, '${metrics.pendingSubmissions}'),
                    _buildLegendItem('Rejected', AppColors.danger, '${metrics.rejectedSubmissions}'),
                    _buildLegendItem('Suspicious', Colors.redAccent, '${metrics.suspiciousCases}'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 2. Bar Chart - Officers & Personnel Distribution
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.bar_chart_rounded, color: Colors.indigo, size: 20),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Personnel & System Role Distribution',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(),
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Text('Bank Managers', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  );
                                case 1:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Text('State Officers', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  );
                                case 2:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Text('Beneficiaries', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  );
                                default:
                                  return const Text('');
                              }
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: metrics.totalBankManagers.toDouble(),
                              color: Colors.deepPurple,
                              width: 22,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: metrics.totalStateOfficers.toDouble(),
                              color: Colors.blue.shade800,
                              width: 22,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: metrics.totalBeneficiaries.toDouble(),
                              color: AppColors.success,
                              width: 22,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final total = metrics.approvedSubmissions +
        metrics.pendingSubmissions +
        metrics.rejectedSubmissions +
        metrics.suspiciousCases;

    final safeTotal = total > 0 ? total : 1;

    return [
      PieChartSectionData(
        color: AppColors.success,
        value: metrics.approvedSubmissions.toDouble(),
        title: '${((metrics.approvedSubmissions / safeTotal) * 100).toStringAsFixed(0)}%',
        radius: 46,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: AppColors.warning,
        value: metrics.pendingSubmissions.toDouble(),
        title: '${((metrics.pendingSubmissions / safeTotal) * 100).toStringAsFixed(0)}%',
        radius: 46,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: AppColors.danger,
        value: metrics.rejectedSubmissions.toDouble(),
        title: '${((metrics.rejectedSubmissions / safeTotal) * 100).toStringAsFixed(0)}%',
        radius: 46,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.redAccent,
        value: metrics.suspiciousCases.toDouble(),
        title: '${((metrics.suspiciousCases / safeTotal) * 100).toStringAsFixed(0)}%',
        radius: 46,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  Widget _buildLegendItem(String label, Color color, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ($count)',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  double _getMaxY() {
    final maxVal = [
      metrics.totalBankManagers,
      metrics.totalStateOfficers,
      metrics.totalBeneficiaries,
    ].reduce((a, b) => a > b ? a : b);
    return (maxVal * 1.25).toDouble();
  }
}
