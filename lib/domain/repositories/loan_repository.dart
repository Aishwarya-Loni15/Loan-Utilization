import '../../domain/entities/loan.dart';

abstract class LoanRepository {
  Future<List<LoanEntity>> getLoans();
  Future<List<LoanEntity>> getUserLoans(String userId, {String? userEmail});
  Future<LoanEntity?> getLoanById(String loanId);
  Future<void> createLoan(LoanEntity loan);
  Future<void> updateLoan(LoanEntity loan);
  Future<LoanEntity> calculateUtilization(String loanId, double additionalUtilizedAmount);
  Future<void> deleteLoan(String loanId);
}
