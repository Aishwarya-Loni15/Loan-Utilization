import '../../domain/entities/bank.dart';

abstract class BankRepository {
  Future<List<BankEntity>> getBanks();
  Future<BankEntity?> getBankById(String id);
  Future<void> createBank(BankEntity bank);
  Future<void> updateBank(BankEntity bank);
  Future<void> assignBankManager(String bankId, String managerId, String managerName);
}
