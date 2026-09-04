import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/ai_repository_impl.dart';
import '../../../domain/entities/ai_analysis.dart';
import '../../../domain/repositories/ai_repository.dart';
import '../../../domain/usecases/ai/analyze_submission.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl();
});

final analyzeSubmissionUseCaseProvider = Provider<AnalyzeSubmission>((ref) {
  return AnalyzeSubmission(ref.watch(aiRepositoryProvider));
});

final aiAnalysisFamilyProvider = FutureProvider.family<AiAnalysisEntity, String>((ref, submissionId) async {
  final useCase = ref.watch(analyzeSubmissionUseCaseProvider);
  return await useCase.call(submissionId);
});
