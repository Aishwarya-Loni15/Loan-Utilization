import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../loans/providers/loan_provider.dart';
import '../../utilization/providers/utilization_provider.dart';

class BeneficiaryDashboardMetrics {
  final int totalLoans;
  final double sanctionedAmount;
  final double disbursedAmount;
  final double utilizedAmount;
  final double remainingAmount;
  final double utilizationPercentage;
  final int pendingSubmissions;
  final int approvedSubmissions;
  final int rejectedSubmissions;

  const BeneficiaryDashboardMetrics({
    required this.totalLoans,
    required this.sanctionedAmount,
    required this.disbursedAmount,
    required this.utilizedAmount,
    required this.remainingAmount,
    required this.utilizationPercentage,
    required this.pendingSubmissions,
    required this.approvedSubmissions,
    required this.rejectedSubmissions,
  });
}

final beneficiaryMetricsProvider = Provider<AsyncValue<BeneficiaryDashboardMetrics>>((ref) {
  final loansAsync = ref.watch(userLoansProvider);
  final submissionsAsync = ref.watch(userSubmissionsProvider);

  if (loansAsync.isLoading || submissionsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (loansAsync.hasError) {
    return AsyncValue.error(loansAsync.error!, loansAsync.stackTrace!);
  }

  final loans = loansAsync.value ?? [];
  final submissions = submissionsAsync.value ?? [];

  final totalLoans = loans.length;
  final sanctioned = loans.fold<double>(0, (sum, l) => sum + l.sanctionedAmount);
  final disbursed = loans.fold<double>(0, (sum, l) => sum + l.disbursedAmount);
  final utilized = loans.fold<double>(0, (sum, l) => sum + l.utilizedAmount);
  final remaining = (disbursed - utilized).clamp(0.0, double.infinity);
  final percentage = disbursed > 0 ? ((utilized / disbursed) * 100).clamp(0.0, 100.0) : 0.0;

  final pending = submissions.where((s) => s.status.name == 'pending' || s.status.name == 'underReview').length;
  final approved = submissions.where((s) => s.status.name == 'approved').length;
  final rejected = submissions.where((s) => s.status.name == 'rejected').length;

  return AsyncValue.data(
    BeneficiaryDashboardMetrics(
      totalLoans: totalLoans,
      sanctionedAmount: sanctioned,
      disbursedAmount: disbursed,
      utilizedAmount: utilized,
      remainingAmount: remaining,
      utilizationPercentage: percentage,
      pendingSubmissions: pending,
      approvedSubmissions: approved,
      rejectedSubmissions: rejected,
    ),
  );
});
