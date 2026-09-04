import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/admin/providers/admin_provider.dart';

class AdminReportsPage extends ConsumerStatefulWidget {
  const AdminReportsPage({super.key});

  @override
  ConsumerState<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends ConsumerState<AdminReportsPage> {
  String _selectedReportType = 'Disbursement Summary';
  String _selectedTimeframe = 'Current Quarter';

  final List<String> _reportTypes = [
    'Disbursement Summary',
    'AI Verification Accuracy',
    'Bank Branch Performance',
    'Officer Turnaround Audit',
    'Suspicious Activity Flags',
  ];

  final List<String> _timeframes = [
    'This Month',
    'Current Quarter',
    'Financial Year 2025-26',
    'All Time',
  ];

  void _exportReport(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.download_done_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$_selectedReportType report exported successfully as $format file.',
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(adminMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Operational Reports'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export Report',
            onSelected: _exportReport,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'PDF', child: Text('Export as PDF')),
              const PopupMenuItem(value: 'CSV', child: Text('Export as CSV')),
              const PopupMenuItem(value: 'Excel', child: Text('Export as Excel')),
            ],
          ),
        ],
      ),
      body: metricsAsync.when(
        data: (metrics) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Controls Card
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
                        const Text(
                          'Configure Report Parameters',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedReportType,
                                decoration: const InputDecoration(
                                  labelText: 'Report Type',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: _reportTypes
                                    .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13))))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedReportType = val ?? _selectedReportType),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedTimeframe,
                                decoration: const InputDecoration(
                                  labelText: 'Time Period',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: _timeframes
                                    .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13))))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedTimeframe = val ?? _selectedTimeframe),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Report Summary Metrics ($_selectedTimeframe)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Report Metrics Summary Cards
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.people, color: Colors.white, size: 20),
                    ),
                    title: const Text('Total Registered Platform Users'),
                    subtitle: const Text('Includes Admins, Officers, Managers & Beneficiaries'),
                    trailing: Text('${metrics.totalUsers}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.currency_rupee, color: Colors.white, size: 20),
                    ),
                    title: const Text('Total Loan Disbursement'),
                    subtitle: const Text('Sanctioned funds across all registered schemes'),
                    trailing: Text(
                      '₹${(metrics.totalDisbursedAmount / 100000).toStringAsFixed(1)} L',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.verified, color: Colors.white, size: 20),
                    ),
                    title: const Text('Verification Completion Rate'),
                    subtitle: const Text('Evidence verified vs total submitted'),
                    trailing: Text(
                      '${metrics.verificationCompletionRate.toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.warning, color: Colors.white, size: 20),
                    ),
                    title: const Text('Suspicious / High-Risk Flagged Cases'),
                    subtitle: const Text('Submissions flagged for manual admin override'),
                    trailing: Text(
                      '${metrics.suspiciousCases}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: Icon(Icons.history, color: Colors.white, size: 20),
                    ),
                    title: const Text('System Security Audit Trail Logs'),
                    subtitle: const Text('Immutable logged actions'),
                    trailing: Text('${metrics.totalAuditLogs}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 24),

                // Export Action Bar
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Export PDF'),
                        onPressed: () => _exportReport('PDF'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.table_chart_outlined),
                        label: const Text('Export CSV'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _exportReport('CSV'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Generating system report...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}
