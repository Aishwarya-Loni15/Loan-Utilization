import 'dart:io';
import '../../core/enums/submission_status.dart';
import '../../data/models/ai_analysis_model.dart';
import '../entities/utilization_submission.dart';

abstract class UtilizationRepository {
  Future<List<UtilizationSubmissionEntity>> getAllSubmissions();
  Future<List<UtilizationSubmissionEntity>> getSubmissionsForBeneficiary(String beneficiaryId);
  Future<List<UtilizationSubmissionEntity>> getSubmissionsForLoan(String loanId);
  Future<List<UtilizationSubmissionEntity>> getPendingSubmissions();
  Future<List<UtilizationSubmissionEntity>> getSuspiciousSubmissions();
  Future<UtilizationSubmissionEntity?> getSubmissionById(String submissionId);
  Future<AiAnalysisModel?> getAiAnalysisForSubmission(String submissionId);
  Future<UtilizationSubmissionEntity> submitEvidence(UtilizationSubmissionEntity submission, AiAnalysisModel aiAnalysis);
  Future<String> uploadFile(File file, String path);
  Future<void> reviewSubmission({
    required String submissionId,
    required SubmissionStatus status,
    required String officerName,
    String? rejectionReason,
  });
}
