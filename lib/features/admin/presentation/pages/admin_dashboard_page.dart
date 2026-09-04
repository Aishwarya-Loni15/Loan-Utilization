import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/admin/providers/admin_provider.dart';
import 'package:laon/features/auth/providers/auth_provider.dart';
import '../widgets/admin_statistics.dart';
import '../widgets/admin_dashboard_charts.dart';
import '../widgets/managers_and_officers_widget.dart';
import '../widgets/system_health_card.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final metricsAsync = ref.watch(adminMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.name ?? 'System Administrator',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Laon Utilization Complete Admin Console',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'System Configuration',
            onPressed: () => context.push('/system-configuration'),
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'System Reports',
            onPressed: () => context.push('/admin-reports'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => ref.read(currentUserProvider.notifier).logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              metricsAsync.when(
                data: (metrics) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdminStatisticsWidget(metrics: metrics),
                    const SizedBox(height: 24),
                    AdminDashboardChartsWidget(metrics: metrics),
                  ],
                ),
                loading: () => const LoadingWidget(message: 'Calculating system statistics...'),
                error: (e, _) => AppErrorWidget(message: e.toString()),
              ),
              const SizedBox(height: 24),
              const ManagersAndOfficersWidget(),
              const SizedBox(height: 24),
              const SystemHealthCardWidget(),
              const SizedBox(height: 24),
              Text(
                'Administrative Access Console',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              // Grid displaying all core admin functions
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.35,
                children: [
                  _AdminNavCard(
                    title: 'Manage System Users',
                    subtitle: 'All User Accounts & Roles',
                    icon: Icons.people_alt_outlined,
                    color: AppColors.primary,
                    onTap: () => context.push('/manage-users'),
                  ),
                  _AdminNavCard(
                    title: 'Manage Bank Managers',
                    subtitle: 'Partner Branch Accounts',
                    icon: Icons.account_balance_outlined,
                    color: AppColors.success,
                    onTap: () => context.push('/manage-bank-managers'),
                  ),
                  _AdminNavCard(
                    title: 'Manage State Officers',
                    subtitle: 'Jurisdictions & Verification',
                    icon: Icons.badge_outlined,
                    color: Colors.blue.shade700,
                    onTap: () => context.push('/manage-state-officers'),
                  ),
                  _AdminNavCard(
                    title: 'View All Loans',
                    subtitle: 'Sanctioned Scheme Portfolio',
                    icon: Icons.assignment_outlined,
                    color: AppColors.secondary,
                    onTap: () => context.push('/manage-loans'),
                  ),
                  _AdminNavCard(
                    title: 'View All Beneficiaries',
                    subtitle: 'Loan Beneficiary Registry',
                    icon: Icons.diversity_3_outlined,
                    color: Colors.teal,
                    onTap: () => context.push('/view-all-beneficiaries'),
                  ),
                  _AdminNavCard(
                    title: 'View System Analytics',
                    subtitle: 'Disbursement & Trends',
                    icon: Icons.bar_chart_rounded,
                    color: Colors.indigo,
                    onTap: () => context.push('/system-analytics'),
                  ),
                  _AdminNavCard(
                    title: 'Verification Statistics',
                    subtitle: 'AI & Manual Metrics',
                    icon: Icons.fact_check_outlined,
                    color: Colors.purple,
                    onTap: () => context.push('/verification-statistics'),
                  ),
                  _AdminNavCard(
                    title: 'Generate Reports',
                    subtitle: 'Audit, Financial & PDF Export',
                    icon: Icons.summarize_outlined,
                    color: Colors.deepOrange,
                    onTap: () => context.push('/admin-reports'),
                  ),
                  _AdminNavCard(
                    title: 'System Configuration',
                    subtitle: 'AI Rules & Geofence Settings',
                    icon: Icons.tune_rounded,
                    color: Colors.brown,
                    onTap: () => context.push('/system-configuration'),
                  ),
                  _AdminNavCard(
                    title: 'Suspicious Flagged Cases',
                    subtitle: 'High Risk Evidence',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.danger,
                    onTap: () => context.push('/suspicious-cases'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminNavCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminNavCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
