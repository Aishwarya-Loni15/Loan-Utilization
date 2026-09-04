import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/features/admin/providers/admin_provider.dart';

class VerificationStatisticsPage extends ConsumerWidget {
  const VerificationStatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(verificationStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Statistics Console'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI & Officer Verification Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Real-time evidence verification accuracy and pipeline throughput',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Top Stat Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Evidence',
                    value: '${stats.totalSubmissions}',
                    subtitle: 'Submissions received',
                    icon: Icons.upload_file_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'AI Auto-Approved',
                    value: '${stats.autoApprovedCount}',
                    subtitle: 'Confidence > 85%',
                    icon: Icons.smart_toy_outlined,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Officer Approved',
                    value: '${stats.officerApprovedCount}',
                    subtitle: 'Manual reviews done',
                    icon: Icons.verified_outlined,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'High Risk Flags',
                    value: '${stats.highRiskCount}',
                    subtitle: 'Requires admin override',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // AI Performance Metrics Box
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
                      'AI Confidence & Processing Speed',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _MetricProgressBar(
                      label: 'Average AI Model Confidence Score',
                      value: stats.avgConfidenceScore / 100.0,
                      percentageText: '${stats.avgConfidenceScore.toStringAsFixed(1)}%',
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 16),
                    _MetricProgressBar(
                      label: 'Auto-Approval Ratio',
                      value: stats.totalSubmissions > 0 ? (stats.autoApprovedCount / stats.totalSubmissions) : 0.5,
                      percentageText: '${((stats.autoApprovedCount / stats.totalSubmissions) * 100).toStringAsFixed(1)}%',
                      color: AppColors.primary,
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Average Turnaround Time:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Chip(
                          avatar: const Icon(Icons.timer_outlined, size: 16, color: Colors.blue),
                          label: Text('${stats.avgTurnaroundHours} hrs'),
                          backgroundColor: Colors.blue.shade50,
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
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _MetricProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final String percentageText;
  final Color color;

  const _MetricProgressBar({
    required this.label,
    required this.value,
    required this.percentageText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              percentageText,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
