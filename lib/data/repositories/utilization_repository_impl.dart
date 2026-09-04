import 'dart:io';
import '../../domain/repositories/utilization_repository.dart';
import '../../domain/entities/utilization_submission.dart';
import '../models/utilization_submission_model.dart';
import '../models/ai_analysis_model.dart';
import '../models/loan_model.dart';
import '../../core/enums/submission_status.dart';
import '../../core/enums/risk_level.dart';
import '../../core/enums/loan_status.dart';
import '../datasources/mock_database_service.dart';
import '../datasources/remote/utilization_remote_datasource.dart';
import '../datasources/remote/loan_remote_datasource.dart';

class UtilizationRepositoryImpl implements UtilizationRepository {
  final MockDatabaseService _db = MockDatabaseService();
  final UtilizationRemoteDataSource _remote = UtilizationRemoteDataSource();

  @override
  Future<List<UtilizationSubmissionModel>> getAllSubmissions() async {
    await _db.loadPersistedData();
    try {
      final remoteSubs = await _remote.getSubmissions();
      if (remoteSubs.isNotEmpty) {
        final existingIds = remoteSubs.map((s) => s.submissionId).toSet();
        for (final sub in remoteSubs) {
          _db.submissions.removeWhere((s) => s.submissionId == sub.submissionId);
          _db.submissions.add(sub);
        }
        final mockRemaining = _db.submissions.where((s) => !existingIds.contains(s.submissionId));
        return [...remoteSubs, ...mockRemaining];
      }
    } catch (_) {}
    return List.from(_db.submissions);
  }

  @override
  Future<List<UtilizationSubmissionModel>> getSubmissionsForBeneficiary(String beneficiaryId) async {
    await _db.loadPersistedData();
    try {
      final remoteSubs = await _remote.getSubmissionsForBeneficiary(beneficiaryId);
      if (remoteSubs.isNotEmpty) {
        return remoteSubs;
      }
    } catch (_) {}
    return _db.submissions.where((s) => s.beneficiaryId == beneficiaryId).toList();
  }

  @override
  Future<List<UtilizationSubmissionModel>> getSubmissionsForLoan(String loanId) async {
    await _db.loadPersistedData();
    return _db.submissions.where((s) => s.loanId == loanId).toList();
  }

  @override
  Future<List<UtilizationSubmissionModel>> getPendingSubmissions() async {
    await _db.loadPersistedData();
    return _db.submissions
        .where((s) => s.status == SubmissionStatus.pending || s.status == SubmissionStatus.underReview || s.status == SubmissionStatus.aiVerified)
        .toList();
  }

  @override
  Future<List<UtilizationSubmissionModel>> getSuspiciousSubmissions() async {
    await _db.loadPersistedData();
    return _db.submissions.where((s) => s.riskLevel == RiskLevel.high).toList();
  }

  @override
  Future<UtilizationSubmissionModel?> getSubmissionById(String submissionId) async {
    try {
      return _db.submissions.firstWhere((s) => s.submissionId == submissionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AiAnalysisModel?> getAiAnalysisForSubmission(String submissionId) async {
    try {
      return _db.aiAnalyses.firstWhere((a) => a.submissionId == submissionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> uploadFile(File file, String path) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'https://storage.googleapis.com/loanlens-app.appspot.com/$path/${file.path.split('/').last}';
  }

  @override
  Future<UtilizationSubmissionEntity> submitEvidence(
      UtilizationSubmissionEntity submission, AiAnalysisModel aiAnalysis) async {
    final model = submission is UtilizationSubmissionModel
        ? submission
        : UtilizationSubmissionModel(
            submissionId: submission.submissionId,
            loanId: submission.loanId,
            beneficiaryId: submission.beneficiaryId,
            amountSpent: submission.amountSpent,
            description: submission.description,
            photoUrls: submission.photoUrls,
            videoUrls: submission.videoUrls,
            documentUrls: submission.documentUrls,
            latitude: submission.latitude,
            longitude: submission.longitude,
            locationAccuracy: submission.locationAccuracy,
            capturedAt: submission.capturedAt,
            uploadedAt: submission.uploadedAt,
            status: submission.status,
            aiScore: submission.aiScore,
            riskLevel: submission.riskLevel,
            reviewedBy: submission.reviewedBy,
            reviewedAt: submission.reviewedAt,
            rejectionReason: submission.rejectionReason,
            createdAt: submission.createdAt,
            updatedAt: submission.updatedAt,
          );
    _db.submissions.insert(0, model);
    _db.aiAnalyses.insert(0, aiAnalysis);

    // Dynamically update loan utilized amount & reduce remaining balance upon beneficiary submission
    final loanIndex = _db.loans.indexWhere((l) => l.loanId == submission.loanId);
    if (loanIndex != -1) {
      final loan = _db.loans[loanIndex];
      final newUtilized = loan.utilizedAmount + submission.amountSpent;
      final newRemaining = (loan.disbursedAmount - newUtilized).clamp(0.0, double.infinity);
      final newPercentage = loan.disbursedAmount > 0 ? ((newUtilized / loan.disbursedAmount) * 100).clamp(0.0, 100.0) : 0.0;
      final newStatus = newPercentage >= 100 ? LoanStatus.completed : LoanStatus.active;

      final updatedLoan = LoanModel(
        loanId: loan.loanId,
        beneficiaryId: loan.beneficiaryId,
        bankId: loan.bankId,
        schemeName: loan.schemeName,
        purpose: loan.purpose,
        category: loan.category,
        sanctionedAmount: loan.sanctionedAmount,
        disbursedAmount: loan.disbursedAmount,
        utilizedAmount: newUtilized,
        remainingAmount: newRemaining,
        utilizationPercentage: newPercentage,
        disbursementDate: loan.disbursementDate,
        expectedUtilizationDate: loan.expectedUtilizationDate,
        status: newStatus,
        createdAt: loan.createdAt,
        updatedAt: DateTime.now(),
        loanAccountNumber: loan.loanAccountNumber,
        beneficiaryName: loan.beneficiaryName,
        beneficiaryMobile: loan.beneficiaryMobile,
        beneficiaryEmail: loan.beneficiaryEmail,
        bankName: loan.bankName,
        branchName: loan.branchName,
        state: loan.state,
        district: loan.district,
        taluka: loan.taluka,
        village: loan.village,
        isLinked: loan.isLinked,
      );
      _db.loans[loanIndex] = updatedLoan;
      try {
        LoanRemoteDataSource().updateLoan(updatedLoan);
      } catch (_) {}
    }
    await _db.savePersistedData();
    return submission;
  }

  @override
  Future<void> reviewSubmission({
    required String submissionId,
    required SubmissionStatus status,
    required String officerName,
    String? rejectionReason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _db.submissions.indexWhere((s) => s.submissionId == submissionId);
    if (index != -1) {
      final old = _db.submissions[index];
      _db.submissions[index] = UtilizationSubmissionModel(
        submissionId: old.submissionId,
        loanId: old.loanId,
        beneficiaryId: old.beneficiaryId,
        amountSpent: old.amountSpent,
        description: old.description,
        photoUrls: old.photoUrls,
        videoUrls: old.videoUrls,
        documentUrls: old.documentUrls,
        latitude: old.latitude,
        longitude: old.longitude,
        locationAccuracy: old.locationAccuracy,
        capturedAt: old.capturedAt,
        uploadedAt: old.uploadedAt,
        status: status,
        aiScore: old.aiScore,
        riskLevel: old.riskLevel,
        reviewedBy: officerName,
        reviewedAt: DateTime.now(),
        rejectionReason: rejectionReason,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      await _db.savePersistedData();

      // If approved, update loan utilized amount
      if (status == SubmissionStatus.approved) {
        final loanIndex = _db.loans.indexWhere((l) => l.loanId == old.loanId);
        if (loanIndex != -1) {
          final loan = _db.loans[loanIndex];
          final newUtilized = loan.utilizedAmount + old.amountSpent;
          final newRemaining = (loan.disbursedAmount - newUtilized).clamp(0.0, double.infinity);
          final newPercentage = loan.disbursedAmount > 0 ? ((newUtilized / loan.disbursedAmount) * 100).clamp(0.0, 100.0) : 0.0;
          final newStatus = newPercentage >= 100 ? LoanStatus.completed : LoanStatus.active;

          _db.loans[loanIndex] = LoanModel(
            loanId: loan.loanId,
            beneficiaryId: loan.beneficiaryId,
            bankId: loan.bankId,
            schemeName: loan.schemeName,
            purpose: loan.purpose,
            category: loan.category,
            sanctionedAmount: loan.sanctionedAmount,
            disbursedAmount: loan.disbursedAmount,
            utilizedAmount: newUtilized,
            remainingAmount: newRemaining,
            utilizationPercentage: newPercentage,
            disbursementDate: loan.disbursementDate,
            expectedUtilizationDate: loan.expectedUtilizationDate,
            status: newStatus,
            createdAt: loan.createdAt,
            updatedAt: DateTime.now(),
            loanAccountNumber: loan.loanAccountNumber,
            beneficiaryName: loan.beneficiaryName,
            beneficiaryMobile: loan.beneficiaryMobile,
            beneficiaryEmail: loan.beneficiaryEmail,
            bankName: loan.bankName,
            branchName: loan.branchName,
            state: loan.state,
            district: loan.district,
            taluka: loan.taluka,
            village: loan.village,
            isLinked: loan.isLinked,
          );
        }
      }
    }
  }
}
