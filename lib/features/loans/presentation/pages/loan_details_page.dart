import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laon/core/utils/currency_utils.dart';
import 'package:laon/core/utils/date_utils.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/domain/entities/loan.dart';
import 'package:laon/features/loans/providers/loan_provider.dart';
import '../widgets/loan_progress.dart';
import '../widgets/loan_status_chip.dart';

import 'package:laon/core/enums/user_role.dart';
import 'package:laon/core/widgets/status_chip.dart';
import 'package:laon/features/auth/providers/auth_provider.dart';
import 'package:laon/features/utilization/providers/utilization_provider.dart';
import 'package:laon/app/theme/app_colors.dart';

class LoanDetailsPage extends ConsumerWidget {
  final String loanId;
  final LoanEntity? initialLoan;

  const LoanDetailsPage({
    super.key,
    required this.loanId,
    this.initialLoan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanAsync = ref.watch(loanDetailsProvider(loanId));
    final submissionsAsync = ref.watch(allSubmissionsProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final isManagerOrAdmin = currentUser?.role == UserRole.bankManager || currentUser?.role == UserRole.admin;
    final loanSubmissions = (submissionsAsync.value ?? [])
        .where((s) => s.loanId == loanId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Account Details'),
        actions: [
          if (isManagerOrAdmin)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
              tooltip: 'Delete Loan Account',
              onPressed: () {
                final loanData = loanAsync.value;
                final loan = loanData ?? initialLoan;
                if (loan != null) {
                  _confirmDeleteLoan(context, ref, loan);
                }
              },
            ),
        ],
      ),
      body: loanAsync.when(
        data: (loanData) {
          final loan = loanData ?? initialLoan;
          if (loan == null) {
            return const Center(child: Text('Loan account record not found.'));
          }

          // Bank Manager Access Control Check
          if (currentUser != null && currentUser.role == UserRole.bankManager) {
            final userEmail = currentUser.email.trim().toLowerCase();
            final userUid = currentUser.uid;
            final loanMgrId = (loan.bankManagerId ?? '').trim();
            final isManagerMatch = (loanMgrId.isNotEmpty && (loanMgrId == userUid || loanMgrId.toLowerCase() == userEmail)) ||
                (userUid == 'user_bank_sbi' && (loanMgrId.isEmpty || loanMgrId == 'user_bank_sbi'));

            if (!isManagerMatch) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.gpp_bad_rounded, size: 64, color: AppColors.danger),
                      const SizedBox(height: 16),
                      const Text(
                        'Access Restricted',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.danger),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The beneficiary images and data are visible only to the bank manager who added their link.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              );
            }
          }

          // Registered Email Access Control Check
          if (currentUser != null && currentUser.role == UserRole.beneficiary) {
            final userEmail = currentUser.email.trim().toLowerCase();
            final userUid = currentUser.uid;
            final loanBenEmail = (loan.beneficiaryEmail ?? '').trim().toLowerCase();
            final loanBenId = loan.beneficiaryId;

            final isOwner = (loanBenEmail.isNotEmpty && loanBenEmail == userEmail) ||
                (loanBenId.isNotEmpty && (loanBenId == userUid || loanBenId.contains(userUid)));

            if (!isOwner) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.gpp_bad_rounded, size: 64, color: AppColors.danger),
                      const SizedBox(height: 16),
                      const Text(
                        'Access Restricted',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.danger),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Only the registered email address (${loan.beneficiaryEmail ?? "assigned beneficiary"}) can access this loan record.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              );
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        loan.schemeName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    LoanStatusChipWidget(status: loan.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Loan Ref ID: ${loan.loanId}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LoanProgressWidget(
                      disbursedAmount: loan.disbursedAmount,
                      utilizedAmount: loan.utilizedAmount,
                      utilizationPercentage: loan.utilizationPercentage,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Financial Specifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('Category & Purpose'),
                  subtitle: Text('${loan.category} • ${loan.purpose}'),
                ),
                if (currentUser?.role != UserRole.beneficiary)
                  ListTile(
                    leading: const Icon(Icons.payments_outlined),
                    title: const Text('Sanctioned Loan Capital'),
                    subtitle: Text(CurrencyUtils.formatINR(loan.sanctionedAmount)),
                  ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
                  title: const Text('Bank Manager Disbursed Amount (Static)'),
                  subtitle: Text('${CurrencyUtils.formatINR(loan.disbursedAmount)} • Fixed capital disbursed by Bank Manager'),
                ),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: const Text('Utilized Amount (Verified)'),
                  subtitle: Text(CurrencyUtils.formatINR(loan.utilizedAmount)),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Disbursement Date'),
                  subtitle: Text(AppDateUtils.formatDate(loan.disbursementDate)),
                ),
                ListTile(
                  leading: const Icon(Icons.event_available_outlined),
                  title: const Text('Target Utilization Deadline'),
                  subtitle: Text(AppDateUtils.formatDate(loan.expectedUtilizationDate)),
                ),
                const SizedBox(height: 24),
                
                // Submitted Proof Evidence Section for Manager / Audit
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Submitted Proof Evidence by Beneficiary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${loanSubmissions.length} Submissions',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (loanSubmissions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        const Text(
                          'No utilization proof evidence submitted yet by beneficiary.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  ...loanSubmissions.map((sub) {
                    final isFake = sub.isImageFake;
                    final isAiGen = sub.isAiGeneratedImage;
                    final isWrongAmount = sub.amountSpent > loan.remainingAmount;
                    final isWrongAmountOrFake = isWrongAmount || isFake;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isAiGen
                              ? Colors.purple.shade700
                              : (isWrongAmountOrFake ? AppColors.danger.withValues(alpha: 0.5) : AppColors.border),
                          width: isWrongAmountOrFake ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context.push('/submission-details/${sub.submissionId}'),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SubmissionStatusChip(status: sub.status),
                                      if (isFake) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isAiGen ? Colors.purple.shade900 : Colors.red.shade700,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isAiGen ? Icons.smart_toy_rounded : Icons.gpp_bad_rounded,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isAiGen ? '🤖 AI FAKE' : '⚠️ FAKE IMAGE',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    '₹${sub.amountSpent.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                sub.description,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    'GPS: ${sub.latitude.toStringAsFixed(3)}, ${sub.longitude.toStringAsFixed(3)}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${sub.uploadedAt.day}/${sub.uploadedAt.month}/${sub.uploadedAt.year}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                              if (isFake) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isAiGen ? Colors.purple.shade50 : AppColors.danger.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isAiGen ? Colors.purple.shade300 : AppColors.danger.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isAiGen ? Icons.smart_toy_rounded : Icons.gpp_bad_rounded,
                                        size: 16,
                                        color: isAiGen ? Colors.purple.shade900 : AppColors.danger,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          isAiGen
                                              ? '🤖 AI DETECTED: UPLOADED IMAGE IS FAKE (Synthesized AI Deepfake)'
                                              : '⚠️ AI DETECTED: UPLOADED IMAGE IS FAKE (Digital Manipulation)',
                                          style: TextStyle(
                                            color: isAiGen ? Colors.purple.shade900 : AppColors.danger,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else if (isWrongAmount) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.danger),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '⚠️ WRONG ENTERED AMOUNT: Claimed amount exceeds remaining balance',
                                          style: TextStyle(
                                            color: AppColors.danger,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                if (isManagerOrAdmin) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDeleteLoan(context, ref, loan),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.delete_forever_rounded, color: AppColors.danger),
                      label: const Text(
                        'Delete Loan Account',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading loan details...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }

  void _confirmDeleteLoan(BuildContext context, WidgetRef ref, LoanEntity loan) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Delete Loan Account'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete loan account for "${loan.beneficiaryName ?? loan.loanId}" (${loan.loanId})?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                final repository = ref.read(loanRepositoryProvider);
                await repository.deleteLoan(loan.loanId);
                ref.invalidate(allLoansProvider);
                ref.invalidate(bankLoansProvider);
                ref.invalidate(userLoansProvider);
                ref.invalidate(loanDetailsProvider(loan.loanId));

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Loan account ${loan.loanId} deleted successfully.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete loan: ${e.toString()}'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
