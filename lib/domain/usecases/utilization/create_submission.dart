import '../../../domain/entities/utilization_submission.dart';
import '../../../domain/repositories/utilization_repository.dart';

class CreateSubmission {
  final UtilizationRepository repository;

  CreateSubmission(this.repository);

  Future<UtilizationSubmissionEntity> call(UtilizationSubmissionEntity submission) async {
    return await repository.submitEvidence(submission, null as dynamic);
  }
}
