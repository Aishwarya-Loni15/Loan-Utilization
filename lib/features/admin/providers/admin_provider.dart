import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/user_role.dart';
import '../../../data/models/user_model.dart';
import '../../../data/datasources/remote/user_remote_datasource.dart';
import '../../bank/providers/bank_provider.dart';
import '../../loans/providers/loan_provider.dart';
import '../../utilization/providers/utilization_provider.dart';

class AdminDashboardMetrics {
  final int totalUsers;
  final int activeUsers;
  final int blockedUsers;
  final int totalLoans;
  final int totalBanks;
  final int totalBankManagers;
  final int totalStateOfficers;
  final int totalBeneficiaries;
  final int suspiciousCases;
  final int totalAuditLogs;
  final double totalDisbursedAmount;
  final double verificationCompletionRate;
  final int totalSubmissions;
  final int approvedSubmissions;
  final int rejectedSubmissions;
  final int pendingSubmissions;

  const AdminDashboardMetrics({
    required this.totalUsers,
    required this.activeUsers,
    required this.blockedUsers,
    required this.totalLoans,
    required this.totalBanks,
    required this.totalBankManagers,
    required this.totalStateOfficers,
    required this.totalBeneficiaries,
    required this.suspiciousCases,
    required this.totalAuditLogs,
    required this.totalDisbursedAmount,
    required this.verificationCompletionRate,
    required this.totalSubmissions,
    required this.approvedSubmissions,
    required this.rejectedSubmissions,
    required this.pendingSubmissions,
  });
}

class SystemConfig {
  final double aiConfidenceThreshold;
  final bool autoApprovalEnabled;
  final double geotagRadiusMeters;
  final int maxImageSizeBytes;
  final int maxPhotosPerSubmission;
  final bool maintenanceMode;
  final bool require2FA;
  final String auditLogLevel;

  const SystemConfig({
    this.aiConfidenceThreshold = 85.0,
    this.autoApprovalEnabled = true,
    this.geotagRadiusMeters = 100.0,
    this.maxImageSizeBytes = 5,
    this.maxPhotosPerSubmission = 5,
    this.maintenanceMode = false,
    this.require2FA = false,
    this.auditLogLevel = 'Standard',
  });

  SystemConfig copyWith({
    double? aiConfidenceThreshold,
    bool? autoApprovalEnabled,
    double? geotagRadiusMeters,
    int? maxImageSizeBytes,
    int? maxPhotosPerSubmission,
    bool? maintenanceMode,
    bool? require2FA,
    String? auditLogLevel,
  }) {
    return SystemConfig(
      aiConfidenceThreshold: aiConfidenceThreshold ?? this.aiConfidenceThreshold,
      autoApprovalEnabled: autoApprovalEnabled ?? this.autoApprovalEnabled,
      geotagRadiusMeters: geotagRadiusMeters ?? this.geotagRadiusMeters,
      maxImageSizeBytes: maxImageSizeBytes ?? this.maxImageSizeBytes,
      maxPhotosPerSubmission: maxPhotosPerSubmission ?? this.maxPhotosPerSubmission,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      require2FA: require2FA ?? this.require2FA,
      auditLogLevel: auditLogLevel ?? this.auditLogLevel,
    );
  }
}

class VerificationStats {
  final int totalSubmissions;
  final int autoApprovedCount;
  final int officerApprovedCount;
  final int rejectedCount;
  final int highRiskCount;
  final double avgConfidenceScore;
  final double avgTurnaroundHours;

  const VerificationStats({
    required this.totalSubmissions,
    required this.autoApprovedCount,
    required this.officerApprovedCount,
    required this.rejectedCount,
    required this.highRiskCount,
    required this.avgConfidenceScore,
    required this.avgTurnaroundHours,
  });
}

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSource();
});

final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final dataSource = ref.watch(userRemoteDataSourceProvider);
  return await dataSource.getAllUsers();
});

final bankManagersProvider = Provider<AsyncValue<List<UserModel>>>((ref) {
  final usersAsync = ref.watch(allUsersProvider);
  return usersAsync.whenData(
    (users) => users.where((u) => u.role == UserRole.bankManager).toList(),
  );
});

final stateOfficersProvider = Provider<AsyncValue<List<UserModel>>>((ref) {
  final usersAsync = ref.watch(allUsersProvider);
  return usersAsync.whenData(
    (users) => users.where((u) => u.role == UserRole.stateOfficer).toList(),
  );
});

final beneficiariesProvider = Provider<AsyncValue<List<UserModel>>>((ref) {
  final usersAsync = ref.watch(allUsersProvider);
  return usersAsync.whenData(
    (users) => users.where((u) => u.role == UserRole.beneficiary).toList(),
  );
});

final adminMetricsProvider = Provider<AsyncValue<AdminDashboardMetrics>>((ref) {
  final loansAsync = ref.watch(allLoansProvider);
  final banksAsync = ref.watch(banksProvider);
  final submissionsAsync = ref.watch(allSubmissionsProvider);
  final usersAsync = ref.watch(allUsersProvider);

  if (loansAsync.isLoading || banksAsync.isLoading || submissionsAsync.isLoading || usersAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final loans = loansAsync.value ?? [];
  final banks = banksAsync.value ?? [];
  final submissions = submissionsAsync.value ?? [];
  final users = usersAsync.value ?? [];

  final bankManagers = users.where((u) => u.role == UserRole.bankManager).length;
  final stateOfficers = users.where((u) => u.role == UserRole.stateOfficer).length;
  final beneficiaries = users.where((u) => u.role == UserRole.beneficiary).length;
  final suspicious = submissions.where((s) => s.riskLevel.name == 'high').length;

  double totalAmount = 0.0;
  for (var loan in loans) {
    totalAmount += loan.sanctionedAmount;
  }

  final approvedCount = submissions.where((s) => s.status.name == 'approved' || s.status.name == 'verified').length;
  final rejectedCount = submissions.where((s) => s.status.name == 'rejected').length;
  final pendingCount = submissions.where((s) => s.status.name == 'underReview' || s.status.name == 'pending' || s.status.name == 'submitted' || s.status.name == 'bankVerified').length;

  final completionRate = submissions.isNotEmpty ? (approvedCount / submissions.length) * 100.0 : 0.0;

  return AsyncValue.data(
    AdminDashboardMetrics(
      totalUsers: users.length,
      activeUsers: users.where((u) => !u.isBlocked).length,
      blockedUsers: users.where((u) => u.isBlocked).length,
      totalLoans: loans.length,
      totalBanks: banks.length,
      totalBankManagers: bankManagers,
      totalStateOfficers: stateOfficers,
      totalBeneficiaries: beneficiaries,
      suspiciousCases: suspicious,
      totalAuditLogs: 0,
      totalDisbursedAmount: totalAmount,
      verificationCompletionRate: completionRate,
      totalSubmissions: submissions.length,
      approvedSubmissions: approvedCount,
      rejectedSubmissions: rejectedCount,
      pendingSubmissions: pendingCount,
    ),
  );
});

final verificationStatsProvider = Provider<VerificationStats>((ref) {
  final submissionsAsync = ref.watch(allSubmissionsProvider);
  final submissions = submissionsAsync.value ?? [];

  int autoApproved = 0;
  int officerApproved = 0;
  int rejected = 0;
  int highRisk = 0;
  double totalConfidence = 0.0;

  for (var s in submissions) {
    if (s.riskLevel.name == 'high') highRisk++;
    if (s.status.name == 'rejected') {
      rejected++;
    } else if (s.status.name == 'approved' || s.status.name == 'verified') {
      officerApproved++;
    }
    if (s.aiScore != null && s.aiScore! >= 80.0) {
      autoApproved++;
    }
    if (s.aiScore != null) {
      totalConfidence += s.aiScore!;
    }
  }

  final avgConfidence = submissions.isNotEmpty ? (totalConfidence / submissions.length) : 0.0;

  return VerificationStats(
    totalSubmissions: submissions.length,
    autoApprovedCount: autoApproved,
    officerApprovedCount: officerApproved,
    rejectedCount: rejected,
    highRiskCount: highRisk,
    avgConfidenceScore: avgConfidence,
    avgTurnaroundHours: 0.0,
  );
});

class SystemConfigNotifier extends StateNotifier<SystemConfig> {
  SystemConfigNotifier() : super(const SystemConfig());

  void updateConfig(SystemConfig newConfig) {
    state = newConfig;
  }

  void toggleMaintenanceMode(bool value) {
    state = state.copyWith(maintenanceMode: value);
  }

  void updateConfidenceThreshold(double threshold) {
    state = state.copyWith(aiConfidenceThreshold: threshold);
  }
}

final systemConfigProvider = StateNotifierProvider<SystemConfigNotifier, SystemConfig>((ref) {
  return SystemConfigNotifier();
});

class UserBlockNotifier extends StateNotifier<AsyncValue<void>> {
  UserBlockNotifier() : super(const AsyncValue.data(null));

  Future<void> toggleUserBlockStatus(String userId, bool currentStatus) async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final userBlockNotifierProvider = StateNotifierProvider<UserBlockNotifier, AsyncValue<void>>((ref) {
  return UserBlockNotifier();
});

