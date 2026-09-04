import '../../entities/bank.dart';
import '../../repositories/bank_repository.dart';

class GetBanks {
  final BankRepository repository;

  GetBanks(this.repository);

  Future<List<BankEntity>> call() async {
    return await repository.getBanks();
  }
}
