import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/auth/providers/auth_provider.dart';
import 'package:laon/features/officer/providers/officer_provider.dart';
import 'package:laon/features/utilization/providers/utilization_provider.dart';
import 'package:laon/features/locations/presentation/widgets/dashboard_location_filter_widget.dart';
import '../widgets/officer_statistics.dart';
import '../widgets/review_card.dart';

class OfficerDashboardPage extends ConsumerWidget {
  const OfficerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final metricsAsync = ref.watch(officerMetricsProvider);
    final submissionsAsync = ref.watch(allSubmissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.name ?? 'State Officer Portal',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'District: ${user?.district ?? "Solapur"} • State Officer',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'District Reports',
            onPressed: () => context.push('/officer-reports'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
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
              const DashboardLocationFilterWidget(),
              metricsAsync.when(
                data: (metrics) => Column(
                  children: [
                    OfficerStatisticsWidget(metrics: metrics),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/pending-reviews'),
                        icon: const Icon(Icons.rate_review_outlined),
                        label: Text('Review Pending Queue (${metrics.pendingReviews})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const LoadingWidget(message: 'Calculating district metrics...'),
                error: (e, _) => AppErrorWidget(message: e.toString()),
              ),
              const SizedBox(height: 24),

              Text(
                'State Officer Functions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.35,
                children: [
                  _NavCard(
                    title: '6-Tier Drill-Down',
                    subtitle: 'State → District → Taluka → Village → Loan → Beneficiary',
                    icon: Icons.account_tree_outlined,
                    color: AppColors.primary,
                    onTap: () => context.push('/jurisdiction-drilldown'),
                  ),
                  _NavCard(
                    title: 'Jurisdiction Data',
                    subtitle: 'State & District Coverage',
                    icon: Icons.map_outlined,
                    color: Colors.blueGrey,
                    onTap: () => context.push('/officer-jurisdiction'),
                  ),
                  _NavCard(
                    title: 'District Loans',
                    subtitle: 'Read-Only Scheme Portfolio',
                    icon: Icons.assignment_outlined,
                    color: AppColors.secondary,
                    onTap: () => context.push('/officer-loans'),
                  ),
                  _NavCard(
                    title: 'District Beneficiaries',
                    subtitle: 'Beneficiary Registry',
                    icon: Icons.people_outline_rounded,
                    color: Colors.teal,
                    onTap: () => context.push('/officer-beneficiaries'),
                  ),
                  _NavCard(
                    title: 'Utilization Monitor',
                    subtitle: 'Evidence Status Timeline',
                    icon: Icons.fact_check_outlined,
                    color: Colors.indigo,
                    onTap: () => context.push('/officer-utilization'),
                  ),
                  _NavCard(
                    title: 'Suspicious Cases',
                    subtitle: 'High-Risk Evidence Flags',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.danger,
                    onTap: () => context.push('/officer-suspicious'),
                  ),
                  _NavCard(
                    title: 'Verification Reports',
                    subtitle: 'District Operational Audit',
                    icon: Icons.summarize_outlined,
                    color: Colors.deepOrange,
                    onTap: () => context.push('/officer-reports'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Submissions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/pending-reviews'),
                    child: const Text('View All Queue'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              submissionsAsync.when(
                data: (submissions) {
                  if (submissions.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text('No submissions received in district queue.'),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: submissions.length > 5 ? 5 : submissions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final sub = submissions[index];
                      return ReviewCardWidget(
                        submission: sub,
                        onTap: () {
                          context.push('/review-submission/${sub.submissionId}');
                        },
                      );
                    },
                  );
                },
                loading: () => const LoadingWidget(message: 'Loading district submissions...'),
                error: (e, _) => AppErrorWidget(message: e.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavCard({
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
