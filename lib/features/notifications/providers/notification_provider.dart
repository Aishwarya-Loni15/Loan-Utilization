import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/core/enums/user_role.dart';
import 'package:laon/domain/entities/app_notification.dart';

final notificationsProvider = StateNotifierProvider<NotificationNotifier, List<AppNotificationEntity>>((ref) {
  return NotificationNotifier();
});

class NotificationNotifier extends StateNotifier<List<AppNotificationEntity>> {
  NotificationNotifier() : super(_initialNotifications);

  static final List<AppNotificationEntity> _initialNotifications = [
    // Beneficiary Notifications
    AppNotificationEntity(
      id: 'notif_ben_01',
      targetUserId: 'user_ben_01',
      targetRole: UserRole.beneficiary,
      title: 'Loan Linked Successfully',
      message: 'Your PM-KUSUM Solar Tractor Scheme loan (LN20260001) has been successfully linked to your account.',
      type: NotificationType.loanLinked,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotificationEntity(
      id: 'notif_ben_02',
      targetUserId: 'user_ben_01',
      targetRole: UserRole.beneficiary,
      title: 'Proof Submitted',
      message: 'Your utilization proof package (sub_001_verified) was received and is undergoing automated AI analysis.',
      type: NotificationType.proofSubmitted,
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
    ),
    AppNotificationEntity(
      id: 'notif_ben_03',
      targetUserId: 'user_ben_01',
      targetRole: UserRole.beneficiary,
      title: 'Proof Under Review',
      message: 'Your proof for ₹1,85,000 is currently under review by Bank Manager Amitabh Deshmukh.',
      type: NotificationType.proofUnderReview,
      createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
    ),
    AppNotificationEntity(
      id: 'notif_ben_04',
      targetUserId: 'user_ben_01',
      targetRole: UserRole.beneficiary,
      title: 'Proof Approved',
      message: 'Congratulations! Your utilization proof for ₹1,85,000 has been officially approved.',
      type: NotificationType.proofApproved,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),

    // Bank Manager Notifications
    AppNotificationEntity(
      id: 'notif_mgr_01',
      targetUserId: 'user_bank_sbi',
      targetRole: UserRole.bankManager,
      title: 'Beneficiary Submitted Proof',
      message: 'Ramesh Vitthal Patil submitted new evidence for loan #loan_agri_201 (₹1,85,000).',
      type: NotificationType.proofSubmitted,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AppNotificationEntity(
      id: 'notif_mgr_02',
      targetUserId: 'user_bank_sbi',
      targetRole: UserRole.bankManager,
      title: 'AI Alert: Suspicious Evidence',
      message: 'AI Flag: PURPOSE_MISMATCH detected on submission #sub_002_flagged. Immediate manager review required.',
      type: NotificationType.aiSuspiciousDetected,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AppNotificationEntity(
      id: 'notif_mgr_03',
      targetUserId: 'user_bank_sbi',
      targetRole: UserRole.bankManager,
      title: 'Resubmission Received',
      message: 'Beneficiary resubmitted clearer invoice proof for loan #loan_agri_203.',
      type: NotificationType.resubmissionReceived,
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),

    // State Officer Notifications
    AppNotificationEntity(
      id: 'notif_off_01',
      targetUserId: 'user_officer_sol',
      targetRole: UserRole.stateOfficer,
      title: 'High-Risk Case Flagged',
      message: 'Solapur District: 2 high-risk utilization cases flagged requiring field verification.',
      type: NotificationType.highRiskCase,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    AppNotificationEntity(
      id: 'notif_off_02',
      targetUserId: 'user_officer_sol',
      targetRole: UserRole.stateOfficer,
      title: 'Pending Verification Queue Alert',
      message: 'Pandharpur Taluka has 5 pending verification reviews awaiting bank manager sign-off.',
      type: NotificationType.largeQueueAlert,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotificationEntity(
      id: 'notif_off_03',
      targetUserId: 'user_officer_sol',
      targetRole: UserRole.stateOfficer,
      title: 'Important District Report Ready',
      message: 'Solapur District Quarterly Agricultural Utilization Audit Report generated.',
      type: NotificationType.importantReport,
      createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
    ),
  ];

  void addNotification(AppNotificationEntity notification) {
    state = [notification, ...state];
  }

  void markAsRead(String notificationId) {
    state = [
      for (final n in state)
        if (n.id == notificationId)
          AppNotificationEntity(
            id: n.id,
            targetUserId: n.targetUserId,
            targetRole: n.targetRole,
            title: n.title,
            message: n.message,
            type: n.type,
            createdAt: n.createdAt,
            isRead: true,
            payload: n.payload,
          )
        else
          n,
    ];
  }
}
