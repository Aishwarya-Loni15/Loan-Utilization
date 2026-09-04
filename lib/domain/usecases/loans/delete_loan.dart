import '../../repositories/loan_repository.dart';

class DeleteLoan {
  final LoanRepository repository;

  DeleteLoan(this.repository);

  Future<void> call(String loanId) async {
    return await repository.deleteLoan(loanId);
  }
}
