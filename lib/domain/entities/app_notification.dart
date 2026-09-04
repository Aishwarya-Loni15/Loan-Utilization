import 'package:laon/core/enums/user_role.dart';

enum NotificationType {
  loanLinked,
  proofSubmitted,
  proofUnderReview,
  proofApproved,
  proofRejected,
  resubmissionRequested,
  aiSuspiciousDetected,
  resubmissionReceived,
  highRiskCase,
  largeQueueAlert,
  importantReport;

  String get displayName {
    switch (this) {
      case NotificationType.loanLinked:
        return 'Loan Linked';
      case NotificationType.proofSubmitted:
        return 'Proof Submitted';
      case NotificationType.proofUnderReview:
        return 'Proof Under Review';
      case NotificationType.proofApproved:
        return 'Proof Approved';
      case NotificationType.proofRejected:
        return 'Proof Rejected';
      case NotificationType.resubmissionRequested:
        return 'Resubmission Requested';
      case NotificationType.aiSuspiciousDetected:
        return 'AI Suspicious Evidence';
      case NotificationType.resubmissionReceived:
        return 'Resubmission Received';
      case NotificationType.highRiskCase:
        return 'High Risk Case Alert';
      case NotificationType.largeQueueAlert:
        return 'Large Queue Alert';
      case NotificationType.importantReport:
        return 'Important Report';
    }
  }
}

class AppNotificationEntity {
  final String id;
  final String targetUserId;
  final UserRole targetRole;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? payload;

  const AppNotificationEntity({
    required this.id,
    required this.targetUserId,
    required this.targetRole,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.payload,
  });
}
