import '../../entities/loan.dart';
import '../../repositories/loan_repository.dart';

class CreateLoan {
  final LoanRepository repository;

  CreateLoan(this.repository);

  Future<void> call(LoanEntity loan) async {
    await repository.createLoan(loan);
  }
}
