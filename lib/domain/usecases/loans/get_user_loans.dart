import '../../entities/loan.dart';
import '../../repositories/loan_repository.dart';

class GetUserLoans {
  final LoanRepository repository;

  GetUserLoans(this.repository);

  Future<List<LoanEntity>> call(String userId, {String? userEmail}) async {
    return await repository.getUserLoans(userId, userEmail: userEmail);
  }
}
