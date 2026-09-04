import '../../entities/utilization_submission.dart';
import '../../repositories/utilization_repository.dart';

class GetSubmissions {
  final UtilizationRepository repository;

  GetSubmissions(this.repository);

  Future<List<UtilizationSubmissionEntity>> forUser(String userId) async {
    return await repository.getSubmissionsForBeneficiary(userId);
  }

  Future<List<UtilizationSubmissionEntity>> forLoan(String loanId) async {
    return await repository.getSubmissionsForLoan(loanId);
  }

  Future<UtilizationSubmissionEntity?> byId(String submissionId) async {
    return await repository.getSubmissionById(submissionId);
  }
}
