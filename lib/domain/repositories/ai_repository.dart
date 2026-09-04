import '../../domain/entities/ai_analysis.dart';

abstract class AiRepository {
  Future<AiAnalysisEntity> analyzeSubmission(String submissionId);
  Future<Map<String, dynamic>> extractInvoiceData(String documentUrl);
  Future<List<String>> detectObjects(String imageUrl);
  Future<double> calculateRiskScore({
    required double purposeScore,
    required double invoiceScore,
    required double imageScore,
    required double locationScore,
  });
}
