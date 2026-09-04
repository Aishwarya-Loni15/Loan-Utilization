import '../../entities/loan.dart';
import '../../repositories/loan_repository.dart';

class GetLoan {
  final LoanRepository repository;

  GetLoan(this.repository);

  Future<LoanEntity?> call(String loanId) async {
    return await repository.getLoanById(loanId);
  }
}
