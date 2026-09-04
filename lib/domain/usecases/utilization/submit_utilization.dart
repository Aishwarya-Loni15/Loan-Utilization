import '../../../data/models/ai_analysis_model.dart';
import '../../entities/utilization_submission.dart';
import '../../repositories/utilization_repository.dart';

class SubmitUtilization {
  final UtilizationRepository repository;

  SubmitUtilization(this.repository);

  Future<UtilizationSubmissionEntity> call(
    UtilizationSubmissionEntity submission,
    AiAnalysisModel aiAnalysis,
  ) async {
    return await repository.submitEvidence(submission, aiAnalysis);
  }
}
