import '../../../data/models/ai_analysis_model.dart';
import '../../entities/utilization_submission.dart';
import '../../repositories/utilization_repository.dart';

class ResubmitSubmission {
  final UtilizationRepository repository;

  ResubmitSubmission(this.repository);

  Future<UtilizationSubmissionEntity> call(
    UtilizationSubmissionEntity newSubmission,
    AiAnalysisModel aiAnalysis,
  ) async {
    return await repository.submitEvidence(newSubmission, aiAnalysis);
  }
}
