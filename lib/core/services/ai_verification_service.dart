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
    required double longitude