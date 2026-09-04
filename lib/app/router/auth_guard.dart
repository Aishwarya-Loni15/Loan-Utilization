import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/enums/user_role.dart';
import '../../domain/entities/user.dart';
import 'route_names.dart';

class AuthGuard {
  static String? redirect(BuildContext context, GoRouterState state, UserEntity? user) {
    final location = state.uri.toString();
    final isSplash = location == RouteNames.splash;
    final isAuthRoute = location == RouteNames.login ||
        location == RouteNames.register ||
        location == RouteNames.forgotPassword ||
        location == RouteNames.emailVerification;
    final isUnauthorized = location == RouteNames.unauthorized;

    if (isSplash) return null;

    // Unauthenticated access check
    if (user == null) {
      return isAuthRoute || isUnauthorized ? null : RouteNames.login;
    }

    // Redirect logged-in user away from auth pages to their authorized role dashboard
    if (isAuthRoute) {
      return getDashboardRouteForRole(user.role);
    }

    // Role Permission Verification Guard
    final requiredRoles = _getRequiredRolesForLocation(location);
    if (requiredRoles != null && !requiredRoles.contains(user.role)) {
      return RouteNames.unauthorized;
    }

    return null;
  }

  static String getDashboardRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return RouteNames.adminDashboard;
      case UserRole.stateOfficer:
        return RouteNames.officerDashboard;
      case UserRole.bankManager:
        return RouteNames.bankDashboard;
      case UserRole.beneficiary:
        return RouteNames.beneficiaryHome;
    }
  }

  static List<UserRole>? _getRequiredRolesForLocation(String location) {
    if (location.startsWith(RouteNames.adminDashboard) ||
        location.startsWith(RouteNames.manageUsers) ||
        location.startsWith(RouteNames.manageLoans) ||
        location.startsWith(RouteNames.manageBanks) ||
        location.startsWith(RouteNames.manageBankManagers) ||
        location.startsWith(RouteNames.manageStateOfficers) ||
        location.startsWith(RouteNames.viewAllBeneficiaries) ||
        location.startsWith(RouteNames.systemAnalytics) ||
        location.startsWith(RouteNames.verificationStatistics) ||
        location.startsWith(RouteNames.systemConfiguration) ||
        location.startsWith(RouteNames.manageLocations) ||
        location.startsWith(RouteNames.suspiciousCases) ||
        location.startsWith(RouteNames.auditLogs) ||
        location.startsWith(RouteNames.adminReports)) {
      return [UserRole.admin];
    }
    if (location.startsWith(RouteNames.officerDashboard) ||
        location.startsWith(RouteNames.officerJurisdiction) ||
        location.startsWith(RouteNames.officerLoans) ||
        location.startsWith(RouteNames.officerBeneficiaries) ||
        location.startsWith(RouteNames.officerUtilization) ||
        location.startsWith(RouteNames.officerSuspicious) ||
        location.startsWith(RouteNames.officerReports) ||
        location.startsWith(RouteNames.pendingReviews) ||
        location.startsWith('/review-submission')) {
      return [UserRole.stateOfficer, UserRole.admin];
    }
    if (location.startsWith(RouteNames.bankDashboard) ||
        location.startsWith(RouteNames.bankLoans) ||
        location.startsWith(RouteNames.bankSubmissions)) {
      return [UserRole.bankManager, UserRole.admin];
    }
    if (location.startsWith(RouteNames.beneficiaryHome)) {
      return [UserRole.beneficiary, UserRole.admin];
    }
    if (location.startsWith(RouteNames.submitEvidence)) {
      return [UserRole.beneficiary, UserRole.bankManager, UserRole.stateOfficer, UserRole.admin];
    }
    return null;
  }
}
