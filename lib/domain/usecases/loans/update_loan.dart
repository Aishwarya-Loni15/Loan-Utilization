import '../../entities/loan.dart';
import '../../repositories/loan_repository.dart';

class UpdateLoan {
  final LoanRepository repository;

  UpdateLoan(this.repository);

  Future<void> call(LoanEntity loan) async {
    await repository.updateLoan(loan);
  }
}
