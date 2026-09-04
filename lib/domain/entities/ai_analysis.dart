import '../../core/enums/risk_level.dart';

class AiAnalysisEntity {
  final String analysisId;
  final String submissionId;
  final double aiScore;
  final RiskLevel riskLevel;
  final double purposeMatchScore;
  final double invoiceMatchScore;
  final double imageMatchScore;
  final double locationScore;
  final double duplicateScore;
  final double? extractedInvoiceAmount;
  final List<String> detectedObjects;
  final String detectedText;
  final List<String> reasons;
  final DateTime analyzedAt;

  final String imageAuthenticityStatus; // 'REAL' or 'FAKE_OR_TAMPERED'
  final String geotagAuthenticityStatus; // 'REAL' or 'FAKE_OR_SPOOFED'
  final double imageAuthenticityScore;
  final double geotagAuthenticityScore;

  const AiAnalysisEntity({
    required this.analysisId,
    required this.submissionId,
    required this.aiScore,
    required this.riskLevel,
    required this.purposeMatchScore,
    required this.invoiceMatchScore,
    required this.imageMatchScore,
    required this.locationScore,
    required this.duplicateScore,
    this.extractedInvoiceAmount,
    required this.detectedObjects,
    required this.detectedText,
    required this.reasons,
    required this.analyzedAt,
    this.imageAuthenticityStatus = 'REAL',
    this.geotagAuthenticityStatus = 'REAL',
    this.imageAuthenticityScore = 92.0,
    this.geotagAuthenticityScore = 95.0,
  });

  bool get isImageReal => imageAuthenticityStatus == 'REAL';
  bool get isAiGenerated => imageAuthenticityStatus == 'AI_GENERATED_FAKE';
  bool get isImageFake => imageAuthenticityStatus == 'AI_GENERATED_FAKE' || imageAuthenticityStatus == 'FAKE_OR_TAMPERED';
  bool get isGeotagReal => geotagAuthenticityStatus == 'REAL';

  String get imageAuthenticityLabel {
    if (isAiGenerated) return 'IMAGE IS FAKE (AI GENERATED)';
    if (isImageFake) return 'FAKE IMAGE';
    return 'REAL IMAGE';
  }
}
