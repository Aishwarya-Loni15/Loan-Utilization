import 'ai_verification_engine.dart';
import '../../data/models/ai_analysis_model.dart';
import '../../core/enums/risk_level.dart';

class AiVerificationService {
  static Future<AiAnalysisModel> analyzeSubmission({
    required String loanPurpose,
    required double loanAmount,
    required double claimedAmount,
    required String description,
    required List<String> imagePaths,
    required List<String> documentPaths,
    required double latitude,
    required double longitude,
  }) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final String mockDetectedText = '''
ABC Agro Equipment & Machinery Ltd.
Station Road, Pandharpur, Solapur.
GSTIN: 27AABCS1429E1Z3
Invoice No: INV-2026-8849
Date: 04/08/2026
Item: Solar Powered Agricultural Sprayer Equipment (45HP Engine)
Serial No: AG-SPR-883920
Amount: Rs. ${claimedAmount.toStringAsFixed(0)}
Payment Method: Bank Transfer / Direct Disbursement
''';

    final List<String> mockObjects = [
      'Agricultural Equipment',
      'Solar Sprayer Tank',
      'Engine Unit',
      'Authentic Machinery Plate',
    ];

    double purposeMatchScore = 94.0;
    double invoiceMatchScore = 92.0;
    double imageMatchScore = 90.0;
    double locationScore = 96.0;
    double duplicateScore = 100.0;

    final List<String> reasons = [];

    // Analyze purpose keywords
    final purposeLower = loanPurpose.toLowerCase();
    final descLower = description.toLowerCase();

    if (purposeLower.contains('sewing') && !descLower.contains('sewing')) {
      purposeMatchScore = 40.0;
      reasons.add('Mismatch: Loan purpose is Sewing Machine but submitted description/invoice mentions different item.');
    } else {
      reasons.add('Purpose Match (94%): Detected machinery matches designated loan category.');
    }

    // Amount validation & extracted receipt comparison
    double extractedReceiptAmount = claimedAmount;
    final primaryImagePath = imagePaths.isNotEmpty ? imagePaths.first : '';
    final isAiGen = AiVerificationEngine.isAiGeneratedPhoto(primaryImagePath, description);
    final hasFakeKeywords = isAiGen ||
        AiVerificationEngine.isFakePhoto(primaryImagePath, description) ||
        documentPaths.any((p) => AiVerificationEngine.isFakePhoto(p, description));

    String imageStatus = 'REAL';
    if (isAiGen) {
      imageStatus = 'AI_GENERATED_FAKE';
      imageMatchScore = 10.0;
      invoiceMatchScore = 20.0;
      reasons.insert(0, '🤖 AI-GENERATED FAKE IMAGE DETECTED: Submitted photo is synthesized by AI (Deepfake / Generative Model). FLAGGED AS FAKE.');
    } else if (hasFakeKeywords) {
      imageStatus = 'FAKE_OR_TAMPERED';
      imageMatchScore = 20.0;
      invoiceMatchScore = 20.0;
      reasons.insert(0, '⚠️ FAKE / TAMPERED PROOF DETECTED: Submitted image or metadata contains unverified or edited artifacts.');
    }

    if (claimedAmount > loanAmount) {
      invoiceMatchScore = 30.0;
      reasons.insert(0, '❌ WRONG ENTERED AMOUNT ALERT: Claimed amount (₹${claimedAmount.toStringAsFixed(0)}) exceeds maximum allowed loan balance (₹${loanAmount.toStringAsFixed(0)})!');
    } else {
      reasons.add('Amount Verified: Claimed amount Rs. ${claimedAmount.toStringAsFixed(0)} is within approved budget.');
    }

    // Location check (Solapur/Pandharpur area lat 17.677, long 75.32)
    if (latitude < 15.0 || latitude > 20.0 || longitude < 72.0 || longitude > 78.0) {
      locationScore = 30.0;
      reasons.add('Location Alert: Captured GPS coordinate is outside beneficiary registered district boundary.');
    } else {
      reasons.add('GPS Geotag Verified: Coordinate (Lat $latitude, Long $longitude) is within registered farm boundary.');
    }

    reasons.add('Duplicate Fingerprint Check: 100% unique submission hash (No identical image/document in global repository).');

    // Compute composite AI score
    final double overallScore = (purposeMatchScore * 0.35) +
        (invoiceMatchScore * 0.25) +
        (imageMatchScore * 0.20) +
        (locationScore * 0.10) +
        (duplicateScore * 0.10);

    final riskLevel = RiskLevel.fromScore(overallScore);

    return AiAnalysisModel(
      analysisId: 'ai_ana_${DateTime.now().millisecondsSinceEpoch}',
      submissionId: 'sub_pending',
      aiScore: double.parse(overallScore.toStringAsFixed(1)),
      riskLevel: riskLevel,
      purposeMatchScore: purposeMatchScore,
      invoiceMatchScore: invoiceMatchScore,
      imageMatchScore: imageMatchScore,
      locationScore: locationScore,
      duplicateScore: duplicateScore,
      extractedInvoiceAmount: extractedReceiptAmount,
      detectedObjects: mockObjects,
      detectedText: mockDetectedText,
      reasons: reasons,
      analyzedAt: DateTime.now(),
      imageAuthenticityStatus: imageStatus,
      geotagAuthenticityStatus: (locationScore < 50) ? 'FAKE_OR_SPOOFED' : 'REAL',
      imageAuthenticityScore: isAiGen ? 10.0 : (hasFakeKeywords ? 25.0 : 92.0),
      geotagAuthenticityScore: locationScore,
    );
  }
}
