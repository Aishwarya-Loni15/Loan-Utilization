import '../../entities/ai_analysis.dart';
import '../../repositories/ai_repository.dart';

class AnalyzeSubmission {
  final AiRepository repository;

  AnalyzeSubmission(this.repository);

  Future<AiAnalysisEntity> call(String submissionId) async {
    return await repository.analyzeSubmission(submissionId);
  }
}
