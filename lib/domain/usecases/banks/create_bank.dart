import '../../entities/bank.dart';
import '../../repositories/bank_repository.dart';

class CreateBank {
  final BankRepository repository;

  CreateBank(this.repository);

  Future<void> call(BankEntity bank) async {
    await repository.createBank(bank);
  }
}
