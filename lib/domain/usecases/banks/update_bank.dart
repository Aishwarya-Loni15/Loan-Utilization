import '../../entities/bank.dart';
import '../../repositories/bank_repository.dart';

class UpdateBank {
  final BankRepository repository;

  UpdateBank(this.repository);

  Future<void> call(BankEntity bank) async {
    await repository.updateBank(bank);
  }
}
