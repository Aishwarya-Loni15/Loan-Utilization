import '../../core/enums/risk_level.dart';
import '../../domain/entities/ai_analysis.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/mock_database_service.dart';
import '../models/ai_analysis_model.dart';

class AiRepositoryImpl implements AiRepository {
  final MockDatabaseService _db = MockDatabaseService();

  @override
  Future<AiAnalysisEntity> analyzeSubmission(String submissionId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      return _db.aiAnalyses.firstWhere((a) => a.submissionId == submissionId);
    } catch (_) {
      final now = DateTime.now();
      final analysis = AiAnalysisModel(
        analysisId: 'ai_${now.millisecondsSinceEpoch}',
        submissionId: submissionId,
        aiScore: 92.0,
        riskLevel: RiskLevel.low,
        purposeMatchScore: 94.0,
        invoiceMatchScore: 90.0,
        imageMatchScore: 92.0,
        locationScore: 98.0,
        duplicateScore: 0.0,
        extractedInvoiceAmount: 185000.0,
        detectedObjects: ['Tractor Equipment', 'Agri Sprayer', 'Solar Pump'],
        detectedText: 'TAX INVOICE ABC AGRO MACHINERY PANDHARPUR',
        reasons: [
          'GPS geotag coordinates verify village location boundary.',
          'Detected asset matches sanctioned agricultural loan scheme.',
          'OCR invoice text extracted matches claim amount.',
        ],
        analyzedAt: now,
      );
      _db.aiAnalyses.insert(0, analysis);
      return analysis;
    }
  }

  @override
  Future<Map<String, dynamic>> extractInvoiceData(String documentUrl) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      'extractedAmount': 185000.0,
      'vendorName': 'ABC Agro Machinery',
      'invoiceNumber': 'INV-2026-994',
      'confidence': 0.94,
    };
  }

  @override
  Future<List<String>> detectObjects(String imageUrl) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ['Tractor Machinery', 'Solar Pump Attachment', 'Agricultural Field'];
  }

  @override
  Future<double> calculateRiskScore({
    required double purposeScore,
    required double invoiceScore,
    required double imageScore,
    required double locationScore,
  }) async {
    final compositeScore = (purposeScore * 0.3) + (invoiceScore * 0.3) + (imageScore * 0.2) + (locationScore * 0.2);
    return compositeScore.clamp(0.0, 100.0);
  }
}
