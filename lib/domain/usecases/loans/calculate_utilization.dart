import '../../entities/loan.dart';
import '../../repositories/loan_repository.dart';

class CalculateUtilization {
  final LoanRepository repository;

  CalculateUtilization(this.repository);

  Future<LoanEntity> call(String loanId, double additionalUtilizedAmount) async {
    return await repository.calculateUtilization(loanId, additionalUtilizedAmount);
  }
}
