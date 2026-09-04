import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:laon/app/theme/app_colors.dart';

class UtilizationAnalyticsChart extends StatelessWidget {
  const UtilizationAnalyticsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'District Loan Utilization Trend',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                'Solapur District - Solapur, Pandharpur & Malshiras Talukas',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Expanded(
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
                          getTitlesWidget: (double value, TitleMeta meta) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text('Pandharpur', style: TextStyle(fontSize: 10));
                              case 1:
                                return const Text('Malshiras', style: TextStyle(fontSize: 10));
                              case 2:
                                return const Text('Baramati', style: TextStyle(fontSize: 10));
                              default:
                                return const Text('');
                            }
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 9)),
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(toY: 92.5, color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4)),
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(toY: 78.0, color: AppColors.info, width: 16, borderRadius: BorderRadius.circular(4)),
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(toY: 85.4, color: AppColors.secondary, width: 16, borderRadius: BorderRadius.circular(4)),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
