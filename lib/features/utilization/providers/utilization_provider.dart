import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/core/enums/risk_level.dart';
import 'package:laon/core/enums/submission_status.dart';
import 'package:laon/core/enums/user_role.dart';
import 'package:laon/data/models/ai_analysis_model.dart';
import 'package:laon/data/models/utilization_submission_model.dart';
import 'package:laon/data/repositories/utilization_repository_impl.dart';
import 'package:laon/domain/entities/app_notification.dart';
import 'package:laon/domain/entities/utilization_submission.dart';
import 'package:laon/domain/repositories/utilization_repository.dart';
import 'package:laon/features/auth/providers/auth_provider.dart';
import 'package:laon/features/loans/providers/loan_provider.dart';
import 'package:laon/features/notifications/providers/notification_provider.dart';

final utilizationRepositoryProvider = Provider<UtilizationRepository>((ref) {
  return UtilizationRepositoryImpl();
});

final allSubmissionsProvider = FutureProvider<List<UtilizationSubmissionEntity>>((ref) async {
  try {
    final repo = ref.watch(utilizationRepositoryProvider);
    return await repo.getAllSubmissions();
  } catch (e) {
    return [];
  }
});

final userSubmissionsProvider = FutureProvider<List<UtilizationSubmissionEntity>>((ref) async {
  final repo = ref.watch(utilizationRepositoryProvider);
  final userState = ref.watch(currentUserProvider);
  final user = userState.value;
  if (user == null) return [];
  return repo.getSubmissionsForBeneficiary(user.uid);
});

final pendingSubmissionsProvider = FutureProvider<List<UtilizationSubmissionEntity>>((ref) async {
  final repo = ref.watch(utilizationRepositoryProvider);
  return repo.getPendingSubmissions();
});

final suspiciousSubmissionsProvider = FutureProvider<List<UtilizationSubmissionEntity>>((ref) async {
  final repo = ref.watch(utilizationRepositoryProvider);
  return repo.getSuspiciousSubmissions();
});

final aiAnalysisFamily = FutureProvider.family<AiAnalysisModel?, String>((ref, submissionId) async {
  final repo = ref.watch(utilizationRepositoryProvider);
  return repo.getAiAnalysisForSubmission(submissionId);
});

final submitEvidenceNotifierProvider = StateNotifierProvider<SubmitEvidenceNotifier, AsyncValue<void>>((ref) {
  return SubmitEvidenceNotifier(ref);
});

class SubmitEvidenceNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  SubmitEvidenceNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<UtilizationSubmissionEntity> submit({
    required String loanId,
    required double amountSpent,
    required String description,
    required List<String> photoUrls,
    required List<String> videoUrls,
    required List<String> documentUrls,
    required double latitude,
    required double longitude,
    required double accuracy,
    double? aiScore,
    AiAnalysisModel? aiAnalysis,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(currentUserProvider).value;
      final repo = _ref.read(utilizationRepositoryProvider);

      final subId = 'sub_${DateTime.now().millisecondsSinceEpoch}';
      final submission = UtilizationSubmissionModel(
        submissionId: subId,
        loanId: loanId,
        beneficiaryId: user?.uid ?? 'user_ben_01',
        amountSpent: amountSpent,
        description: description,
        photoUrls: photoUrls,
        videoUrls: videoUrls,
        documentUrls: documentUrls,
        latitude: latitude,
        longitude: longitude,
        locationAccuracy: accuracy,
        capturedAt: DateTime.now(),
        uploadedAt: DateTime.now(),
        status: SubmissionStatus.underReview,
        aiScore: aiScore,
        riskLevel: aiAnalysis?.riskLevel ?? RiskLevel.low,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repo.submitEvidence(submission, aiAnalysis ?? AiAnalysisModel(
        analysisId: 'ai_pending_$subId',
        submissionId: subId,
        aiScore: 0.0,
        riskLevel: RiskLevel.low,
        purposeMatchScore: 0.0,
        invoiceMatchScore: 0.0,
        imageMatchScore: 0.0,
        locationScore: 0.0,
        duplicateScore: 0.0,
        detectedObjects: ['Geotagged Photo Evidence'],
        detectedText: 'Submitted for Bank Manager Verification',
        reasons: ['Evidence submitted by beneficiary. Awaiting Bank Manager verification.'],
        analyzedAt: DateTime.now(),
      ));
      
      // Dispatch real-time notification directly to Bank Manager
      _ref.read(notificationsProvider.notifier).addNotification(
        AppNotificationEntity(
          id: 'notif_mgr_${DateTime.now().millisecondsSinceEpoch}',
          targetUserId: 'user_bank_sbi',
          targetRole: UserRole.bankManager,
          title: '📸 New Geotagged Photo Uploaded',
          message: '${user?.fullName ?? "Beneficiary"} uploaded a geotagged proof photo for loan #$loanId (₹${amountSpent.toStringAsFixed(0)}) at GPS: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}.',
          type: NotificationType.proofSubmitted,
          createdAt: DateTime.now(),
          payload: subId,
        ),
      );

      // Dispatch confirmation notification to Beneficiary
      if (user != null) {
        _ref.read(notificationsProvider.notifier).addNotification(
          AppNotificationEntity(
            id: 'notif_ben_${DateTime.now().millisecondsSinceEpoch}',
            targetUserId: user.uid,
            targetRole: UserRole.beneficiary,
            title: 'Geotagged Photo Sent to Bank Manager',
            message: 'Your geotagged proof photo package (#$subId) for ₹${amountSpent.toStringAsFixed(0)} was successfully uploaded and sent to your Bank Manager.',
            type: NotificationType.proofSubmitted,
            createdAt: DateTime.now(),
            payload: subId,
          ),
        );
      }

      _ref.invalidate(allSubmissionsProvider);
      _ref.invalidate(userSubmissionsProvider);
      _ref.invalidate(pendingSubmissionsProvider);
      _ref.invalidate(suspiciousSubmissionsProvider);
      _ref.invalidate(allLoansProvider);
      _ref.invalidate(userLoansProvider);
      _ref.invalidate(bankLoansProvider);

      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> review({
    required String submissionId,
    required SubmissionStatus status,
    String? rejectionReason,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(utilizationRepositoryProvider);
      final user = _ref.read(currentUserProvider).value;

      await repo.reviewSubmission(
        submissionId: submissionId,
        status: status,
        officerName: user?.fullName ?? 'Bank Manager',
        rejectionReason: rejectionReason,
      );

      final isApproved = status == SubmissionStatus.approved;
      _ref.read(notificationsProvider.notifier).addNotification(
        AppNotificationEntity(
          id: 'notif_rev_${DateTime.now().millisecondsSinceEpoch}',
          targetUserId: 'user_ben_01',
          targetRole: UserRole.beneficiary,
          title: isApproved ? 'Proof Approved by Bank Manager' : 'Proof Audit Updated',
          message: isApproved
              ? 'Your geotagged utilization proof ($submissionId) was approved by Bank Manager ${user?.fullName ?? ""}.'
              : 'Your geotagged proof ($submissionId) review status was updated: ${status.name}. Remarks: ${rejectionReason ?? "N/A"}',
          type: isApproved ? NotificationType.proofApproved : NotificationType.proofRejected,
          createdAt: DateTime.now(),
          payload: submissionId,
        ),
      );

      _ref.invalidate(allSubmissionsProvider);
      _ref.invalidate(userSubmissionsProvider);
      _ref.invalidate(pendingSubmissionsProvider);
      _ref.invalidate(suspiciousSubmissionsProvider);
      _ref.invalidate(allLoansProvider);
      _ref.invalidate(bankLoansProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

