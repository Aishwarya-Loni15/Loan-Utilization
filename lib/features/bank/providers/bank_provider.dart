import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/bank_repository_impl.dart';
import '../../../domain/entities/bank.dart';
import '../../../domain/repositories/bank_repository.dart';
import '../../../domain/usecases/banks/assign_bank_manager.dart';
import '../../../domain/usecases/banks/create_bank.dart';
import '../../../domain/usecases/banks/get_banks.dart';
import '../../../domain/usecases/banks/update_bank.dart';
import '../../loans/providers/loan_provider.dart';
import '../../utilization/providers/utilization_provider.dart';
import '../../../core/enums/loan_status.dart';
import '../../../core/enums/submission_status.dart';
import '../../../core/enums/risk_level.dart';

final bankRepositoryProvider = Provider<BankRepository>((ref) {
  return BankRepositoryImpl();
});

final getBanksUseCaseProvider = Provider<GetBanks>((ref) {
  return GetBanks(ref.watch(bankRepositoryProvider));
});

final createBankUseCaseProvider = Provider<CreateBank>((ref) {
  return CreateBank(ref.watch(bankRepositoryProvider));
});

final updateBankUseCaseProvider = Provider<UpdateBank>((ref) {
  return UpdateBank(ref.watch(bankRepositoryProvider));
});

final assignBankManagerUseCaseProvider = Provider<AssignBankManager>((ref) {
  return AssignBankManager(ref.watch(bankRepositoryProvider));
});

final banksProvider = FutureProvider<List<BankEntity>>((ref) async {
  final getBanks = ref.watch(getBanksUseCaseProvider);
  return await getBanks.call();
});

final bankDetailsProvider = FutureProvider.family<BankEntity?, String>((ref, id) async {
  final repository = ref.watch(bankRepositoryProvider);
  return await repository.getBankById(id);
});

class BankDashboardMetrics {
  final int totalLoans;
  final int activeLoans;
  final double utilizationPercentage;
  final int pendingReviews;
  final int approvedSubmissions;
  final int rejectedSubmissions;
  final int highRiskCases;

  const BankDashboardMetrics({
    required this.totalLoans,
    required this.activeLoans,
    required this.utilizationPercentage,
    required this.pendingReviews,
    required this.approvedSubmissions,
    required this.rejectedSubmissions,
    required this.highRiskCases,
  });
}

final bankDashboardMetricsProvider = Provider<AsyncValue<BankDashboardMetrics>>((ref) {
  final bankLoansAsync = ref.watch(bankLoansProvider);
  final allSubmissionsAsync = ref.watch(allSubmissionsProvider);

  if (bankLoansAsync.isLoading || allSubmissionsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (bankLoansAsync.hasError) {
    return AsyncValue.error(bankLoansAsync.error!, bankLoansAsync.stackTrace!);
  }
  if (allSubmissionsAsync.hasError) {
    return AsyncValue.error(allSubmissionsAsync.error!, allSubmissionsAsync.stackTrace!);
  }

  final bankLoans = bankLoansAsync.valueOrNull ?? [];
  final allSubmissions = allSubmissionsAsync.valueOrNull ?? [];

  // Restrict submissions strictly to loans belonging to this bank manager
  final bankLoanIds = bankLoans.map((l) => l.loanId).toSet();
  final bankSubmissions = allSubmissions.where((s) => bankLoanIds.contains(s.loanId)).toList();

  final totalLoans = bankLoans.length;
  final activeLoans = bankLoans.where((l) => l.status == LoanStatus.active).length;

  final totalDisbursed = bankLoans.fold<double>(0, (sum, l) => sum + l.disbursedAmount);
  final totalUtilized = bankLoans.fold<double>(0, (sum, l) => sum + l.utilizedAmount);
  final utilizationPct = totalDisbursed > 0 ? ((totalUtilized / totalDisbursed) * 100).clamp(0.0, 100.0) : 0.0;

  final pendingReviews = bankSubmissions.where((s) =>
      s.status == SubmissionStatus.submitted ||
      s.status == SubmissionStatus.underOfficerReview ||
      s.status == SubmissionStatus.aiProcessing ||
      s.status == SubmissionStatus.pending ||
      s.status == SubmissionStatus.underReview
  ).length;
  final approved = bankSubmissions.where((s) => s.status == SubmissionStatus.approved || s.status == SubmissionStatus.aiVerified).length;
  final rejected = bankSubmissions.where((s) => s.status == SubmissionStatus.rejected).length;
  final highRisk = bankSubmissions.where((s) => s.riskLevel == RiskLevel.high).length;

  return AsyncValue.data(
    BankDashboardMetrics(
      totalLoans: totalLoans,
      activeLoans: activeLoans,
      utilizationPercentage: utilizationPct,
      pendingReviews: pendingReviews,
      approvedSubmissions: approved,
      rejectedSubmissions: rejected,
      highRiskCases: highRisk,
    ),
  );
});
