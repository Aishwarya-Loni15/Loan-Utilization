import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/features/auth/providers/auth_provider.dart';
import 'package:laon/features/auth/presentation/pages/login_page.dart';
import 'package:laon/features/auth/presentation/pages/register_page.dart';
import 'package:laon/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:laon/features/auth/presentation/pages/email_verification_page.dart';
import 'package:laon/features/auth/presentation/pages/unauthorized_page.dart';
import 'package:laon/features/beneficiary/presentation/pages/beneficiary_home_page.dart';
import 'package:laon/features/officer/presentation/pages/officer_dashboard_page.dart';
import 'package:laon/features/bank/presentation/pages/bank_dashboard_page.dart';
import 'package:laon/features/bank/presentation/pages/bank_loans_page.dart';
import 'package:laon/features/bank/presentation/pages/bank_submissions_page.dart';
import 'package:laon/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:laon/features/utilization/presentation/pages/create_submission_page.dart';
import 'package:laon/features/utilization/presentation/pages/gps_capture_screen.dart';
import 'package:laon/features/utilization/presentation/pages/submission_details_page.dart';
import 'package:laon/features/maps/presentation/pages/location_map_page.dart';
import 'package:laon/features/splash/presentation/pages/splash_page.dart';
import 'auth_guard.dart';
import 'route_names.dart';
import 'package:laon/features/admin/presentation/pages/manage_users_page.dart';
import 'package:laon/features/admin/presentation/pages/manage_loans_page.dart';
import 'package:laon/features/admin/presentation/pages/manage_banks_page.dart';
import 'package:laon/features/admin/presentation/pages/manage_bank_managers_page.dart';
import 'package:laon/features/admin/presentation/pages/manage_state_officers_page.dart';
import 'package:laon/features/admin/presentation/pages/view_all_beneficiaries_page.dart';
import 'package:laon/features/admin/presentation/pages/system_analytics_page.dart';
import 'package:laon/features/admin/presentation/pages/verification_statistics_page.dart';
import 'package:laon/features/admin/presentation/pages/system_config_page.dart';
import 'package:laon/features/admin/presentation/pages/manage_locations_page.dart';
import 'package:laon/features/admin/presentation/pages/suspicious_cases_page.dart';
import 'package:laon/features/admin/presentation/pages/audit_logs_page.dart';
import 'package:laon/features/admin/presentation/pages/admin_reports_page.dart';
import 'package:laon/features/officer/presentation/pages/officer_jurisdiction_page.dart';
import 'package:laon/features/officer/presentation/pages/officer_loans_page.dart';
import 'package:laon/features/officer/presentation/pages/officer_beneficiaries_page.dart';
import 'package:laon/features/officer/presentation/pages/officer_utilization_page.dart';
import 'package:laon/features/officer/presentation/pages/officer_suspicious_page.dart';
import 'package:laon/features/officer/presentation/pages/officer_reports_page.dart';
import 'package:laon/features/officer/presentation/pages/pending_reviews_page.dart';
import 'package:laon/features/officer/presentation/pages/review_submission_page.dart';
import 'package:laon/features/bank/presentation/pages/bank_reports_page.dart';
import 'package:laon/features/bank/presentation/pages/bank_verification_screen.dart';
import 'package:laon/features/officer/presentation/pages/jurisdiction_drilldown_page.dart';
import 'package:laon/features/loans/presentation/pages/loan_details_page.dart';
import 'package:laon/features/loans/presentation/pages/create_loan_page.dart';
import 'package:laon/domain/entities/loan.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(currentUserProvider, (prev, next) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: RouteNames.login,
    refreshListenable: notifier,

    redirect: (context, state) {
      final userAsync = ref.read(currentUserProvider);

      // Do NOT redirect anywhere while authentication state is still loading
      if (userAsync.isLoading) return null;

      final location = state.uri.toString();
      final isSplash = location == RouteNames.splash;

      // Handle splash page routing when loading is complete
      if (isSplash) {
        if (userAsync.hasError) return RouteNames.login;
        final user = userAsync.valueOrNull;
        if (user == null) return RouteNames.login;
        return AuthGuard.getDashboardRouteForRole(user.role);
      }

      // Use valueOrNull safely for all role-guarded routes
      final user = userAsync.valueOrNull;
      return AuthGuard.redirect(context, state, user);
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? state.extra as String?;
          return ForgotPasswordPage(initialEmail: email);
        },
      ),
      GoRoute(
        path: RouteNames.emailVerification,
        builder: (context, state) => const EmailVerificationPage(),
      ),
      GoRoute(
        path: RouteNames.unauthorized,
        builder: (context, state) => const UnauthorizedPage(),
      ),
      GoRoute(
        path: RouteNames.beneficiaryHome,
        builder: (context, state) => const BeneficiaryHomePage(),
      ),
      GoRoute(
        path: RouteNames.officerDashboard,
        builder: (context, state) => const OfficerDashboardPage(),
      ),
      GoRoute(
        path: RouteNames.bankDashboard,
        builder: (context, state) => const BankDashboardPage(),
      ),
      GoRoute(
        path: RouteNames.bankLoans,
        builder: (context, state) => const BankLoansPage(),
      ),
      GoRoute(
        path: RouteNames.bankSubmissions,
        builder: (context, state) {
          final filter = state.uri.queryParameters['filter'] ?? 'all';
          return BankSubmissionsPage(initialFilter: filter);
        },
      ),
      GoRoute(
        path: RouteNames.adminDashboard,
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: RouteNames.submitEvidence,
        builder: (context, state) {
          final loanId = state.extra as String? ?? 'loan_agri_201';
          return CreateSubmissionPage(loanId: loanId);
        },
      ),
      GoRoute(
        path: RouteNames.gnssCapture,
        builder: (context, state) {
          final loanId = state.extra as String? ?? 'LN000123';
          return GpsCaptureScreen(loanId: loanId);
        },
      ),
      GoRoute(
        path: RouteNames.submissionDetails,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return SubmissionDetailsPage(submissionId: id);
        },
      ),
      GoRoute(
        path: RouteNames.mapView,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return LocationMapPage(
            latitude: extra['latitude'] ?? 17.6774,
            longitude: extra['longitude'] ?? 75.3283,
            title: extra['title'] ?? 'Submission Geotag Location',
          );
        },
      ),
      GoRoute(
        path: RouteNames.manageUsers,
        builder: (context, state) => const ManageUsersPage(),
      ),
      GoRoute(
        path: RouteNames.manageLoans,
        builder: (context, state) => const ManageLoansPage(),
      ),
      GoRoute(
        path: RouteNames.manageBanks,
        builder: (context, state) => const ManageBanksPage(),
      ),
      GoRoute(
        path: RouteNames.manageBankManagers,
        builder: (context, state) => const ManageBankManagersPage(),
      ),
      GoRoute(
        path: RouteNames.manageStateOfficers,
        builder: (context, state) => const ManageStateOfficersPage(),
      ),
      GoRoute(
        path: RouteNames.viewAllBeneficiaries,
        builder: (context, state) => const ViewAllBeneficiariesPage(),
      ),
      GoRoute(
        path: RouteNames.systemAnalytics,
        builder: (context, state) => const SystemAnalyticsPage(),
      ),
      GoRoute(
        path: RouteNames.verificationStatistics,
        builder: (context, state) => const VerificationStatisticsPage(),
      ),
      GoRoute(
        path: RouteNames.systemConfiguration,
        builder: (context, state) => const SystemConfigPage(),
      ),
      GoRoute(
        path: RouteNames.manageLocations,
        builder: (context, state) => const ManageLocationsPage(),
      ),
      GoRoute(
        path: RouteNames.suspiciousCases,
        builder: (context, state) => const SuspiciousCasesPage(),
      ),
      GoRoute(
        path: RouteNames.auditLogs,
        builder: (context, state) => const AuditLogsPage(),
      ),
      GoRoute(
        path: RouteNames.adminReports,
        builder: (context, state) => const AdminReportsPage(),
      ),
      GoRoute(
        path: RouteNames.officerJurisdiction,
        builder: (context, state) => const OfficerJurisdictionPage(),
      ),
      GoRoute(
        path: RouteNames.officerLoans,
        builder: (context, state) => const OfficerLoansPage(),
      ),
      GoRoute(
        path: RouteNames.officerBeneficiaries,
        builder: (context, state) => const OfficerBeneficiariesPage(),
      ),
      GoRoute(
        path: RouteNames.officerUtilization,
        builder: (context, state) => const OfficerUtilizationPage(),
      ),
      GoRoute(
        path: RouteNames.officerSuspicious,
        builder: (context, state) => const OfficerSuspiciousPage(),
      ),
      GoRoute(
        path: RouteNames.officerReports,
        builder: (context, state) => const OfficerReportsPage(),
      ),
      GoRoute(
        path: RouteNames.pendingReviews,
        builder: (context, state) => const PendingReviewsPage(),
      ),
      GoRoute(
        path: RouteNames.reviewSubmission,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ReviewSubmissionPage(submissionId: id);
        },
      ),
      GoRoute(
        path: '/bank-reports',
        builder: (context, state) => const BankReportsPage(),
      ),
      GoRoute(
        path: RouteNames.bankVerification,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return BankVerificationScreen(submissionId: id);
        },
      ),
      GoRoute(
        path: RouteNames.jurisdictionDrilldown,
        builder: (context, state) => const JurisdictionDrilldownPage(),
      ),
      GoRoute(
        path: RouteNames.loanDetails,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final extraLoan = state.extra as LoanEntity?;
          return LoanDetailsPage(loanId: id, initialLoan: extraLoan);
        },
      ),
      GoRoute(
        path: '/create-loan',
        builder: (context, state) => const CreateLoanPage(),
      ),
    ],
  );
});
