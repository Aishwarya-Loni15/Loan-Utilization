import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/auth/providers/auth_provider.dart';
import 'package:laon/features/beneficiary/providers/beneficiary_provider.dart';
import 'package:laon/features/utilization/providers/utilization_provider.dart';
import 'package:laon/features/loans/providers/loan_provider.dart';
import 'package:laon/core/widgets/loan_qr_dialog.dart';
import '../widgets/link_loan_dialog.dart';
import '../widgets/beneficiary_bottom_nav.dart';
import '../widgets/loan_summary_card.dart';
import '../widgets/recent_submission_card.dart';
import '../widgets/utilization_progress_card.dart';
import 'beneficiary_notifications_page.dart';
import 'beneficiary_profile_page.dart';

class BeneficiaryHomePage extends ConsumerStatefulWidget {
  const BeneficiaryHomePage({super.key});

  @override
  ConsumerState<BeneficiaryHomePage> createState() => _BeneficiaryHomePageState();
}

class _BeneficiaryHomePageState extends ConsumerState<BeneficiaryHomePage> {
  int _currentBottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (_currentBottomNavIndex == 1) {
      return Scaffold(
        body: const BeneficiaryNotificationsPage(),
        bottomNavigationBar: BeneficiaryBottomNav(
          currentIndex: _currentBottomNavIndex,
          onTap: (idx) => setState(() => _currentBottomNavIndex = idx),
        ),
      );
    }

    if (_currentBottomNavIndex == 2) {
      return Scaffold(
        body: const BeneficiaryProfilePage(),
        bottomNavigationBar: BeneficiaryBottomNav(
          currentIndex: _currentBottomNavIndex,
          onTap: (idx) => setState(() => _currentBottomNavIndex = idx),
        ),
      );
    }

    final user = ref.watch(currentUserProvider).value;
    final metricsAsync = ref.watch(beneficiaryMetricsProvider);
    final submissionsAsync = ref.watch(userSubmissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.name ?? 'Beneficiary Portal',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Beneficiary Account',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => setState(() => _currentBottomNavIndex = 1),
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
              metricsAsync.when(
                data: (metrics) => Column(
                  children: [
                    LoanSummaryCard(metrics: metrics),
                    const SizedBox(height: 16),
                    UtilizationProgressCard(metrics: metrics),
                  ],
                ),
                loading: () => const LoadingWidget(message: 'Calculating financial metrics...'),
                error: (e, _) => AppErrorWidget(message: e.toString()),
              ),
              const SizedBox(height: 24),

              // My Linked Loans Section
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Active Loans',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        elevation: 2,
                      ),
                      onPressed: () => LinkLoanDialog.show(context),
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                      label: const Text('Link My Loan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ref.watch(userLoansProvider).when(
                data: (loans) {
                  if (loans.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text('No linked loans found. Ask your bank manager to link your offline loan account.'),
                    );
                  }

                  return Column(
                    children: loans.map((loan) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Account: ${loan.loanId}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
                                  tooltip: 'View QR Code',
                                  onPressed: () => LoanQrDialog.show(context, loan),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              loan.schemeName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              'Purpose: ${loan.purpose}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock_outline_rounded, size: 12, color: Colors.blue),
                                  SizedBox(width: 4),
                                  Text(
                                    'Immutable Loan Terms (Account, Amount, Bank, Purpose & Date)',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Disbursed: ₹${loan.disbursedAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                Text('Utilized: ₹${loan.utilizedAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: AppColors.success)),
                                Text('Remaining: ₹${loan.remainingAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: AppColors.warning)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                                onPressed: () => context.push('/submit-evidence', extra: loan.loanId),
                                icon: const Icon(Icons.add_a_photo, size: 16),
                                label: const Text('Submit Utilization Proof'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const LoadingWidget(message: 'Loading loans...'),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent Submissions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => context.push('/submit-evidence'),
                      icon: const Icon(Icons.add_a_photo, size: 16),
                      label: const Text('Submit Proof', style: TextStyle(fontSize: 11)),
                    ),
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
                      child: const Text('No utilization evidence submitted yet.'),
                    );
                  }

                  final displaySubmissions = submissions.take(5).toList();
                  return Column(
                    children: displaySubmissions.map((submission) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: RecentSubmissionCard(
                          submission: submission,
                          onTap: () {
                            context.push('/submission-details/${submission.submissionId}');
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const LoadingWidget(message: 'Loading submissions...'),
                error: (e, _) => AppErrorWidget(message: e.toString()),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BeneficiaryBottomNav(
        currentIndex: _currentBottomNavIndex,
        onTap: (idx) => setState(() => _currentBottomNavIndex = idx),
      ),
    );
  }
}
