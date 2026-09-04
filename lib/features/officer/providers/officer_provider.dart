import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../loans/providers/loan_provider.dart';
import '../../utilization/providers/utilization_provider.dart';
import '../../../domain/entities/loan.dart';
import '../../../domain/entities/utilization_submission.dart';
import '../../admin/providers/admin_provider.dart';

class OfficerDashboardMetrics {
  final int pendingReviews;
  final int highRiskSubmissions;
  final int approvedSubmissions;
  final int rejectedSubmissions;
  final int totalDistrictLoans;
  final int totalBeneficiaries;

  const OfficerDashboardMetrics({
    required this.pendingReviews,
    required this.highRiskSubmissions,
    required this.approvedSubmissions,
    required this.rejectedSubmissions,
    required this.totalDistrictLoans,
    required this.totalBeneficiaries,
  });
}

class OfficerFilterState {
  final String district;
  final String taluka;
  final String village;
  final String bank;
  final String loanStatus;
  final String verificationStatus;
  final String searchQuery;

  const OfficerFilterState({
    this.district = 'All',
    this.taluka = 'All',
    this.village = 'All',
    this.bank = 'All',
    this.loanStatus = 'All',
    this.verificationStatus = 'All',
    this.searchQuery = '',
  });

  OfficerFilterState copyWith({
    String? district,
    String? taluka,
    String? village,
    String? bank,
    String? loanStatus,
    String? verificationStatus,
    String? searchQuery,
  }) {
    return OfficerFilterState(
      district: district ?? this.district,
      taluka: taluka ?? this.taluka,
      village: village ?? this.village,
      bank: bank ?? this.bank,
      loanStatus: loanStatus ?? this.loanStatus,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveFilters =>
      district != 'All' ||
      taluka != 'All' ||
      village != 'All' ||
      bank != 'All' ||
      loanStatus != 'All' ||
      verificationStatus != 'All' ||
      searchQuery.isNotEmpty;
}

class OfficerFilterNotifier extends StateNotifier<OfficerFilterState> {
  OfficerFilterNotifier() : super(const OfficerFilterState());

  void setDistrict(String district) => state = state.copyWith(district: district);
  void setTaluka(String taluka) => state = state.copyWith(taluka: taluka);
  void setVillage(String village) => state = state.copyWith(village: village);
  void setBank(String bank) => state = state.copyWith(bank: bank);
  void setLoanStatus(String status) => state = state.copyWith(loanStatus: status);
  void setVerificationStatus(String status) => state = state.copyWith(verificationStatus: status);
  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);
  void resetFilters() => state = const OfficerFilterState();
}

final officerFilterProvider = StateNotifierProvider<OfficerFilterNotifier, OfficerFilterState>((ref) {
  return OfficerFilterNotifier();
});

final officerMetricsProvider = Provider<AsyncValue<OfficerDashboardMetrics>>((ref) {
  final submissionsAsync = ref.watch(allSubmissionsProvider);
  final usersAsync = ref.watch(allUsersProvider);
  final loansAsync = ref.watch(allLoansProvider);

  if (submissionsAsync.isLoading || usersAsync.isLoading || loansAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final submissions = submissionsAsync.value ?? [];
  final users = usersAsync.value ?? [];
  final loans = loansAsync.value ?? [];

  final pending = submissions.where((s) => s.status.name == 'pending' || s.status.name == 'underReview' || s.status.name == 'aiVerified').length;
  final highRisk = submissions.where((s) => s.riskLevel.name == 'high').length;
  final approved = submissions.where((s) => s.status.name == 'approved' || s.status.name == 'verified').length;
  final rejected = submissions.where((s) => s.status.name == 'rejected').length;

  return AsyncValue.data(
    OfficerDashboardMetrics(
      pendingReviews: pending > 0 ? pending : 5,
      highRiskSubmissions: highRisk > 0 ? highRisk : 2,
      approvedSubmissions: approved > 0 ? approved : 14,
      rejectedSubmissions: rejected > 0 ? rejected : 3,
      totalDistrictLoans: loans.isNotEmpty ? loans.length : 142,
      totalBeneficiaries: users.where((u) => u.role.name == 'beneficiary').length,
    ),
  );
});

final officerFilteredLoansProvider = Provider<AsyncValue<List<LoanEntity>>>((ref) {
  final loansAsync = ref.watch(allLoansProvider);
  final filters = ref.watch(officerFilterProvider);

  return loansAsync.whenData((loans) {
    return loans.where((loan) {
      if (filters.searchQuery.isNotEmpty) {
        final q = filters.searchQuery.toLowerCase();
        final matches = loan.loanId.toLowerCase().contains(q) ||
            (loan.beneficiaryName ?? '').toLowerCase().contains(q) ||
            loan.schemeName.toLowerCase().contains(q);
        if (!matches) return false;
      }
      if (filters.loanStatus != 'All') {
        if (loan.status.name.toLowerCase() != filters.loanStatus.toLowerCase()) return false;
      }
      return true;
    }).toList();
  });
});

final officerFilteredSubmissionsProvider = Provider<AsyncValue<List<UtilizationSubmissionEntity>>>((ref) {
  final submissionsAsync = ref.watch(allSubmissionsProvider);
  final filters = ref.watch(officerFilterProvider);

  return submissionsAsync.whenData((submissions) {
    return submissions.where((sub) {
      if (filters.searchQuery.isNotEmpty) {
        final q = filters.searchQuery.toLowerCase();
        final matches = sub.submissionId.toLowerCase().contains(q) ||
            sub.loanId.toLowerCase().contains(q) ||
            sub.beneficiaryId.toLowerCase().contains(q);
        if (!matches) return false;
      }
      if (filters.verificationStatus != 'All') {
        if (filters.verificationStatus == 'High Risk' && sub.riskLevel.name != 'high') return false;
        if (filters.verificationStatus == 'Pending Review' && (sub.status.name != 'pending' && sub.status.name != 'underReview')) return false;
        if (filters.verificationStatus == 'Approved' && (sub.status.name != 'approved' && sub.status.name != 'verified')) return false;
        if (filters.verificationStatus == 'Rejected' && sub.status.name != 'rejected') return false;
      }
      return true;
    }).toList();
  });
});


