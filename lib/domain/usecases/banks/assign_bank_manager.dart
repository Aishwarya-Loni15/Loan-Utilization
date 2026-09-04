import '../../repositories/bank_repository.dart';

class AssignBankManager {
  final BankRepository repository;

  AssignBankManager(this.repository);

  Future<void> call({
    required String bankId,
    required String managerId,
    required String managerName,
  }) async {
    await repository.assignBankManager(bankId, managerId, managerName);
  }
}
