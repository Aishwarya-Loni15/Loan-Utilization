import '../../repositories/ai_repository.dart';

class CalculateRiskScore {
  final AiRepository repository;

  CalculateRiskScore(this.repository);

  Future<double> call({
    required double purposeScore,
    required double invoiceScore,
    required double imageScore,
    required double locationScore,
  }) async {
    return await repository.calculateRiskScore(
      purposeScore: purposeScore,
      invoiceScore: invoiceScore,
      imageScore: imageScore,
      locationScore: locationScore,
    );
  }
}
