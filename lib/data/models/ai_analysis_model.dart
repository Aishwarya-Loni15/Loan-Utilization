import '../../core/enums/risk_level.dart';
import '../../domain/entities/ai_analysis.dart';

class AiAnalysisModel extends AiAnalysisEntity {
  const AiAnalysisModel({
    required super.analysisId,
    required super.submissionId,
    required super.aiScore,
    required super.riskLevel,
    required super.purposeMatchScore,
    required super.invoiceMatchScore,
    required super.imageMatchScore,
    required super.locationScore,
    required super.duplicateScore,
    super.extractedInvoiceAmount,
    required super.detectedObjects,
    required super.detectedText,
    required super.reasons,
    required super.analyzedAt,
    super.imageAuthenticityStatus = 'REAL',
    super.geotagAuthenticityStatus = 'REAL',
    super.imageAuthenticityScore = 92.0,
    super.geotagAuthenticityScore = 95.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'analysisId': analysisId,
      'submissionId': submissionId,
      'aiScore': aiScore,
      'riskLevel': riskLevel.value,
      'purposeMatchScore': purposeMatchScore,
      'invoiceMatchScore': invoiceMatchScore,
      'imageMatchScore': imageMatchScore,
      'locationScore': locationScore,
      'duplicateScore': duplicateScore,
      'extractedInvoiceAmount': extractedInvoiceAmount,
      'detectedObjects': detectedObjects,
      'detectedText': detectedText,
      'reasons': reasons,
      'analyzedAt': analyzedAt.toIso8601String(),
      'imageAuthenticityStatus': imageAuthenticityStatus,
      'geotagAuthenticityStatus': geotagAuthenticityStatus,
      'imageAuthenticityScore': imageAuthenticityScore,
      'geotagAuthenticityScore': geotagAuthenticityScore,
    };
  }

  factory AiAnalysisModel.fromMap(Map<String, dynamic> map, String id) {
    return AiAnalysisModel(
      analysisId: id,
      submissionId: map['submissionId'] ?? '',
      aiScore: (map['aiScore'] ?? 0.0).toDouble(),
      riskLevel: RiskLevel.fromString(map['riskLevel']),
      purposeMatchScore: (map['purposeMatchScore'] ?? 0.0).toDouble(),
      invoiceMatchScore: (map['invoiceMatchScore'] ?? 0.0).toDouble(),
      imageMatchScore: (map['imageMatchScore'] ?? 0.0).toDouble(),
      locationScore: (map['locationScore'] ?? 0.0).toDouble(),
      duplicateScore: (map['duplicateScore'] ?? 0.0).toDouble(),
      extractedInvoiceAmount: map['extractedInvoiceAmount'] != null
          ? (map['extractedInvoiceAmount'] as num).toDouble()
          : null,
      detectedObjects: List<String>.from(map['detectedObjects'] ?? []),
      detectedText: map['detectedText'] ?? '',
      reasons: List<String>.from(map['reasons'] ?? []),
      analyzedAt: map['analyzedAt'] != null
          ? DateTime.parse(map['analyzedAt'])
          : DateTime.now(),
      imageAuthenticityStatus: map['imageAuthenticityStatus'] ?? 'REAL',
      geotagAuthenticityStatus: map['geotagAuthenticityStatus'] ?? 'REAL',
      imageAuthenticityScore: (map['imageAuthenticityScore'] ?? 92.0).toDouble(),
      geotagAuthenticityScore: (map['geotagAuthenticityScore'] ?? 95.0).toDouble(),
    );
  }
}
